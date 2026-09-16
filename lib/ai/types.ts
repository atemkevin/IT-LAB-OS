/**
 * lib/ai/types.ts
 *
 * Shared type contracts for the AI Mentor system.
 * Server and client safe — no Supabase imports.
 */

/** The 5 supported mentor modes. */
export type MentorMode = "tutor" | "coach" | "troubleshooter" | "interviewer" | "reviewer";

/** Incoming message shape from the client. */
export interface ChatMessage {
  role: "user" | "assistant";
  content: string;
}

/** Full request body for POST /api/ai/chat. */
export interface ChatRequest {
  messages: ChatMessage[];
  mode?: MentorMode;
  conversationId?: string;
  context?: {
    skillId?: string;
    lessonId?: string;
    scenarioId?: string;
  };
}

/** Response envelope for conversation metadata. */
export interface ChatResponseMeta {
  conversationId: string;
  mode: MentorMode;
  title: string | null;
}
