/**
 * lib/ai/persistence.ts
 *
 * Save and load AI conversations and messages.
 * Uses the authenticated client for reads (RLS-protected) and admin for
 * writes on the conversations table (no INSERT RLS policy — intentional).
 * Server-only.
 */
import { createClient } from "@/lib/supabase/server";
import { getAdminClient } from "@/lib/supabase/admin";
import type { MentorMode, ChatMessage } from "./types";
import type { Json } from "@/lib/database.types";

/**
 * Create a new conversation row. Returns the conversation id.
 * Uses admin client because `ai_conversations` has no INSERT RLS policy
 * (the RLS policies allow own SELECT and UPDATE but not INSERT).
 */
export async function createConversation(
  userId: string,
  mode: MentorMode,
  context: Record<string, unknown>,
): Promise<string> {
  const admin = getAdminClient();
  const { data, error } = await admin
    .from("ai_conversations")
    .insert({
      user_id: userId,
      mode,
      context: context as Json,
      title: modeTitle(mode),
    })
    .select("id")
    .single();

  if (error || !data) {
    throw new Error("Failed to create conversation");
  }
  return data.id;
}

/**
 * Load conversation history (messages only) for continuing a conversation.
 * Returns empty array if conversation doesn't belong to the user.
 */
export async function loadConversationHistory(
  userId: string,
  conversationId: string,
): Promise<ChatMessage[]> {
  const supabase = await createClient();

  // Verify ownership via RLS
  const { data: conv } = await supabase
    .from("ai_conversations")
    .select("id")
    .eq("id", conversationId)
    .eq("user_id", userId)
    .maybeSingle();

  if (!conv) return [];

  const { data: msgs } = await supabase
    .from("ai_messages")
    .select("role, content")
    .eq("conversation_id", conversationId)
    .order("created_at", { ascending: true });

  return (msgs ?? []).map((m) => ({
    role: m.role as "user" | "assistant",
    content: m.content,
  }));
}

/**
 * Persist a user message to the conversation.
 * Uses admin client because `ai_messages` INSERT policy is "exists own conversation".
 */
export async function saveMessage(
  conversationId: string,
  role: "user" | "assistant",
  content: string,
): Promise<void> {
  const admin = getAdminClient();
  await admin.from("ai_messages").insert({
    conversation_id: conversationId,
    role,
    content,
    metadata: {},
  });
}

/**
 * Persist the full assistant response at once (non-streaming save).
 * Call this after the stream completes.
 */
export async function saveAssistantMessage(
  conversationId: string,
  content: string,
): Promise<void> {
  if (!content) return;
  await saveMessage(conversationId, "assistant", content);
}

/**
 * Generate a default title for a new conversation based on mode.
 */
function modeTitle(mode: MentorMode): string {
  const labels: Record<MentorMode, string> = {
    tutor: "Tutoring Session",
    coach: "Coaching Session",
    troubleshooter: "Troubleshooting Session",
    interviewer: "Interview Prep Session",
    reviewer: "Study Review",
  };
  return labels[mode];
}
