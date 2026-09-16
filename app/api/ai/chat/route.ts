/**
 * POST /api/ai/chat
 *
 * Streaming AI chat endpoint. Proxies to the configured AI provider
 * using the OpenAI-compatible chat completions API.
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";
import { rateLimit } from "@/lib/rate-limit";

const bodySchema = z.object({
  messages: z.array(
    z.object({
      role: z.enum(["system", "user", "assistant"]),
      content: z.string(),
    })
  ),
});

const SYSTEM_PROMPT = `You are an expert IT engineering mentor and tutor. Your role is to help learners master technical skills across Linux, networking, cybersecurity, Windows AD, Python automation, cloud, and DevOps.

Guidelines:
- Explain concepts clearly with practical examples.
- When asked about labs or troubleshooting, guide the learner through diagnostic reasoning rather than giving the answer directly.
- For interview prep, ask follow-up questions to deepen understanding.
- Keep responses concise but thorough. Use code blocks for commands and configuration.
- If the learner is stuck, offer hints before revealing solutions.
- Base your answers on real-world best practices and industry standards.`;

export async function POST(request: NextRequest) {
  try {
    // Auth check
    const supabase = await createClient();
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    // Rate limit: 20 messages per minute per user
    const limit = rateLimit(`ai-chat:${user.id}`, 20, 60_000);
    if (!limit.success) {
      return NextResponse.json(
        { error: "Rate limit exceeded. Please slow down." },
        { status: 429, headers: { "X-RateLimit-Remaining": String(limit.remaining), "X-RateLimit-Reset": String(limit.resetAt) } }
      );
    }

    // Validate body
    const body = await request.json();
    const parsed = bodySchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: "Invalid request body" }, { status: 400 });
    }

    const { messages } = parsed.data;

    // Env check
    const apiKey = process.env.AI_API_KEY;
    const model = process.env.AI_MODEL;
    const baseUrl = process.env.AI_BASE_URL;

    if (!apiKey || !model || !baseUrl) {
      return NextResponse.json(
        { error: "AI service not configured. Check AI_API_KEY, AI_MODEL, and AI_BASE_URL." },
        { status: 503 }
      );
    }

    // Build messages with system prompt
    const chatMessages = [
      { role: "system" as const, content: SYSTEM_PROMPT },
      ...messages,
    ];

    // Stream from AI provider
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
        temperature: 0.7,
        max_tokens: 2048,
      }),
    });

    if (!aiRes.ok) {
      const errText = await aiRes.text().catch(() => "Unknown error");
      console.error("[ai-chat] Provider error:", aiRes.status, errText);
      return NextResponse.json(
        { error: "AI provider error. Please try again later." },
        { status: 502 }
      );
    }

    if (!aiRes.body) {
      return NextResponse.json({ error: "No response body from AI provider" }, { status: 502 });
    }

    // Forward the stream
    const reader = aiRes.body.getReader();
    const encoder = new TextEncoder();

    const stream = new ReadableStream({
      async start(controller) {
        try {
          while (true) {
            const { done, value } = await reader.read();
            if (done) break;
            controller.enqueue(value);
          }
        } catch (err) {
          console.error("[ai-chat] Stream error:", err);
          controller.error(err);
        } finally {
          controller.close();
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
      },
    });
  } catch (err) {
    console.error("[ai-chat] Unexpected error:", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
