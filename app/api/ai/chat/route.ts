/**
 * POST /api/ai/chat
 *
 * Streaming AI chat endpoint with mode-aware prompts, context injection,
 * and conversation persistence. Proxies to the configured AI provider.
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";
import { rateLimit } from "@/lib/rate-limit";
import { loadUserContext } from "@/lib/ai/context";
import { buildSystemPrompt, MENTOR_MODES, MODE_PARAMS } from "@/lib/ai/prompts";
import {
  createConversation,
  loadConversationHistory,
  saveMessage,
  saveAssistantMessage,
} from "@/lib/ai/persistence";
import type { MentorMode } from "@/lib/ai/types";

const MENTOR_MODE_VALUES = ["tutor", "coach", "troubleshooter", "interviewer", "reviewer"] as const;

const bodySchema = z.object({
  messages: z
    .array(
      z.object({
        role: z.enum(["user", "assistant"]),
        content: z.string(),
      }),
    )
    .min(1),
  mode: z.enum(MENTOR_MODE_VALUES).optional().default("tutor"),
  conversationId: z.string().uuid().optional(),
  context: z
    .object({
      skillId: z.string().uuid().optional(),
      lessonId: z.string().uuid().optional(),
      scenarioId: z.string().uuid().optional(),
    })
    .optional(),
});

export async function POST(request: NextRequest) {
  try {
    const supabase = await createClient();
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const limit = rateLimit(`ai-chat:${user.id}`, 20, 60_000);
    if (!limit.success) {
      return NextResponse.json(
        { error: "Rate limit exceeded. Please slow down." },
        {
          status: 429,
          headers: {
            "X-RateLimit-Remaining": String(limit.remaining),
            "X-RateLimit-Reset": String(limit.resetAt),
          },
        },
      );
    }

    const body = await request.json();
    const parsed = bodySchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json(
        { error: "Invalid request body", details: parsed.error.flatten() },
        { status: 400 },
      );
    }

    const { messages, mode, conversationId: existingConvId, context: reqContext } = parsed.data;

    const apiKey = process.env.AI_API_KEY;
    const model = process.env.AI_MODEL;
    const baseUrl = process.env.AI_BASE_URL;
    if (!apiKey || !model || !baseUrl) {
      return NextResponse.json(
        { error: "AI service not configured. Check AI_API_KEY, AI_MODEL, and AI_BASE_URL." },
        { status: 503 },
      );
    }

    // Load learner context for the system prompt
    const userContext = await loadUserContext(user.id);
    const systemPrompt = buildSystemPrompt(mode as MentorMode, userContext);

    // Conversation management: load history or create new
    let convId: string;
    let historyMessages: Array<{ role: "user" | "assistant"; content: string }> = [];

    if (existingConvId) {
      // Continue existing conversation
      convId = existingConvId;
      historyMessages = await loadConversationHistory(user.id, convId);
      // Persist the new user message
      const latestUserMsg = messages[messages.length - 1];
      if (latestUserMsg?.role === "user") {
        await saveMessage(convId, "user", latestUserMsg.content);
      }
    } else {
      // New conversation
      convId = await createConversation(user.id, mode as MentorMode, reqContext ?? {});
      // Persist the first user message
      const latestUserMsg = messages[messages.length - 1];
      if (latestUserMsg?.role === "user") {
        await saveMessage(convId, "user", latestUserMsg.content);
      }
    }

    // Build the full message list for the AI provider:
    // [system] + [history from DB] + [current message]
    // If continuing a conversation, historyMessages already has the prior context.
    // We prefer historyMessages over client-supplied messages for correctness,
    // but fall back to client messages for the first turn.
    const chatMessages = [
      { role: "system" as const, content: systemPrompt },
      ...(historyMessages.length > 0 ? historyMessages : messages),
    ];

    const modeParams = MODE_PARAMS[mode as MentorMode];

    const aiRes = await fetch(`${baseUrl}/chat/completions`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model,
        messages: chatMessages,
        stream: true,
        temperature: modeParams.temperature,
        max_tokens: modeParams.maxTokens,
      }),
    });

    if (!aiRes.ok) {
      const errText = await aiRes.text().catch(() => "Unknown error");
      console.error("[ai-chat] Provider error:", aiRes.status, errText);
      return NextResponse.json(
        { error: "AI provider error. Please try again later." },
        { status: 502 },
      );
    }

    if (!aiRes.body) {
      return NextResponse.json({ error: "No response body from AI provider" }, { status: 502 });
    }

    // Capture the stream to persist the full response after completion
    const reader = aiRes.body.getReader();
    let assistantContent = "";

    const stream = new ReadableStream({
      async start(controller) {
        try {
          const decoder = new TextDecoder();
          while (true) {
            const { done, value } = await reader.read();
            if (done) break;
            controller.enqueue(value);

            // Extract text chunks for persistence (SSE format: "data: {...}\n\n")
            const chunk = decoder.decode(value, { stream: true });
            for (const line of chunk.split("\n")) {
              if (!line.startsWith("data: ") || line === "data: [DONE]") continue;
              try {
                const json = JSON.parse(line.slice(6));
                const delta = json.choices?.[0]?.delta?.content;
                if (delta) assistantContent += delta;
              } catch {
                // Ignore malformed SSE lines
              }
            }
          }
        } catch (err) {
          console.error("[ai-chat] Stream error:", err);
          controller.error(err);
        } finally {
          controller.close();
          // Persist the full assistant response (fire-and-forget)
          saveAssistantMessage(convId, assistantContent).catch((e) =>
            console.error("[ai-chat] Failed to persist assistant message:", e),
          );
        }
      },
      cancel() {
        reader.cancel();
      },
    });

    return new Response(stream, {
      headers: {
        "Content-Type": "text/event-stream",
        "Cache-Control": "no-cache",
        Connection: "keep-alive",
        "X-Conversation-Id": convId,
        "X-Mentor-Mode": mode,
      },
    });
  } catch (err) {
    console.error("[ai-chat] Unexpected error:", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
