"use client";

/**
 * /ai — AI Engineering Mentor
 *
 * Mode-aware chat interface backed by /api/ai/chat with conversation
 * persistence and streaming responses.
 */
import { useState, useRef, useCallback } from "react";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Bot, Send, Sparkles, User, AlertCircle, BookOpen, Wrench, MessageSquare, Target, BarChart3, Loader2 } from "lucide-react";

type MentorMode = "tutor" | "coach" | "troubleshooter" | "interviewer" | "reviewer";

interface ChatMessage {
  role: "user" | "assistant";
  content: string;
}

const MODES: Array<{ id: MentorMode; label: string; icon: React.ReactNode; description: string }> = [
  { id: "tutor", label: "Tutor", icon: <BookOpen className="h-3.5 w-3.5" />, description: "Clear explanations with examples" },
  { id: "coach", label: "Coach", icon: <Target className="h-3.5 w-3.5" />, description: "Progress-aware study advice" },
  { id: "troubleshooter", label: "Troubleshooter", icon: <Wrench className="h-3.5 w-3.5" />, description: "Diagnostic reasoning for labs" },
  { id: "interviewer", label: "Interviewer", icon: <MessageSquare className="h-3.5 w-3.5" />, description: "Simulates a technical interview" },
  { id: "reviewer", label: "Reviewer", icon: <BarChart3 className="h-3.5 w-3.5" />, description: "Summarises learning, identifies gaps" },
];

export default function AIPage() {
  const [mode, setMode] = useState<MentorMode>("tutor");
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [conversationId, setConversationId] = useState<string | null>(null);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const abortRef = useRef<AbortController | null>(null);
  const scrollRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = useCallback(() => {
    scrollRef.current?.scrollIntoView({ behavior: "smooth" });
  }, []);

  // Auto-detect context from URL (e.g. /ai?skillId=...) — lazy init, runs once
  const [context] = useState<{ skillId?: string } | null>(() => {
    if (typeof window === "undefined") return null;
    const skillId = new URLSearchParams(window.location.search).get("skillId");
    return skillId ? { skillId } : null;
  });

  function switchMode(newMode: MentorMode) {
    setMode(newMode);
    // Start fresh conversation when switching modes
    setMessages([]);
    setConversationId(null);
    setError(null);
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!input.trim() || loading) return;

    const userMessage: ChatMessage = { role: "user", content: input.trim() };
    const newMessages = [...messages, userMessage];
    setMessages(newMessages);
    setInput("");
    setLoading(true);
    setError(null);

    // Add placeholder assistant message
    setMessages((prev) => [...prev, { role: "assistant", content: "" }]);

    abortRef.current = new AbortController();

    try {
      const res = await fetch("/api/ai/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          messages: newMessages,
          mode,
          conversationId: conversationId ?? undefined,
          context: context ?? undefined,
        }),
        signal: abortRef.current.signal,
      });

      if (res.status === 429) {
        const data = await res.json().catch(() => ({}));
        setError(data.error || "Too many messages. Please wait a moment.");
        setMessages((prev) => prev.slice(0, -1));
        return;
      }

      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error(data.error || "Failed to get response");
      }

      // Capture conversation id from response headers
      const responseConvId = res.headers.get("X-Conversation-Id");
      if (responseConvId) setConversationId(responseConvId);

      if (!res.body) throw new Error("No response body");

      const reader = res.body.getReader();
      const decoder = new TextDecoder();
      let assistantContent = "";
      let buffer = "";

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split("\n");
        buffer = lines.pop() ?? "";

        for (const line of lines) {
          const trimmed = line.trim();
          if (!trimmed.startsWith("data: ")) continue;
          const data = trimmed.slice(6);
          if (data === "[DONE]") continue;

          try {
            const parsed = JSON.parse(data);
            const delta = parsed.choices?.[0]?.delta?.content;
            if (delta) {
              assistantContent += delta;
              setMessages((prev) => {
                const next = [...prev];
                next[next.length - 1] = { role: "assistant", content: assistantContent };
                return next;
              });
            }
          } catch {
            // Ignore malformed SSE lines
          }
        }
      }
    } catch (err: unknown) {
      if (err instanceof Error && err.name === "AbortError") return;
      setError(err instanceof Error ? err.message : "An unexpected error occurred");
      setMessages((prev) => prev.slice(0, -1));
    } finally {
      setLoading(false);
      abortRef.current = null;
      setTimeout(scrollToBottom, 50);
    }
  }

  function handleStop() {
    abortRef.current?.abort();
  }

  const currentModeDef = MODES.find((m) => m.id === mode)!;
  const hasMessages = messages.length > 0;

  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">AI Engineering Mentor</h1>
        <p className="text-sm text-[var(--color-text-tertiary)]">
          Your personal IT learning assistant. Choose a mode and start a session.
        </p>
      </div>

      {/* Mode selector */}
      <div className="flex flex-wrap gap-2">
        {MODES.map((m) => (
          <Button
            key={m.id}
            variant={mode === m.id ? "default" : "outline"}
            size="sm"
            onClick={() => switchMode(m.id)}
            disabled={loading}
          >
            {m.icon}
            {m.label}
          </Button>
        ))}
      </div>

      <Card className="flex h-[600px] flex-col">
        <CardHeader className="border-b border-[var(--color-border)] pb-3">
          <div className="flex items-center gap-2">
            <div className="flex h-7 w-7 items-center justify-center rounded-md bg-[var(--color-brand-soft)] text-[var(--color-brand)]">
              {currentModeDef.icon}
            </div>
            <div className="flex-1">
              <div className="flex items-center gap-2">
                <CardTitle className="text-sm">{currentModeDef.label} Mode</CardTitle>
                {conversationId && (
                  <Badge variant="default" className="text-[10px]">Session active</Badge>
                )}
              </div>
              <CardDescription className="text-[11px]">
                {currentModeDef.description}
              </CardDescription>
            </div>
          </div>
        </CardHeader>

        <CardContent className="flex flex-1 flex-col p-4 overflow-hidden">
          <div className="flex-1 overflow-y-auto space-y-4 pr-1 -mr-1">
            {!hasMessages ? (
              <div className="flex h-full flex-1 items-center justify-center text-center">
                <div className="max-w-sm space-y-2">
                  <Sparkles className="mx-auto h-8 w-8 text-[var(--color-brand)]" />
                  <p className="text-sm font-medium text-[var(--color-text-primary)]">
                    {mode === "tutor" && "Ask for explanations or how things work."}
                    {mode === "coach" && "Get personalized study advice based on your progress."}
                    {mode === "troubleshooter" && "Stuck on a lab? Describe what you're seeing."}
                    {mode === "interviewer" && "Ready for a mock technical interview?"}
                    {mode === "reviewer" && "Get a summary of what you've learned and what to review next."}
                  </p>
                  <p className="text-xs text-[var(--color-text-tertiary)]">
                    {mode === "tutor" && 'Try: "Why does chmod 755 grant read/execute to group?"'}
                    {mode === "coach" && 'Try: "What should I focus on today?"'}
                    {mode === "troubleshooter" && 'Try: "My nginx service won\'t start, what should I check?"'}
                    {mode === "interviewer" && 'Try: "Start a Linux networking interview."'}
                    {mode === "reviewer" && 'Try: "Summarize what I\'ve learned this week."'}
                  </p>
                </div>
              </div>
            ) : (
              messages.map((msg, i) => (
                <div
                  key={i}
                  className={`flex gap-2.5 ${msg.role === "user" ? "flex-row-reverse" : ""}`}
                >
                  <div
                    className={`flex h-7 w-7 shrink-0 items-center justify-center rounded-md ${
                      msg.role === "assistant"
                        ? "bg-[var(--color-brand-soft)] text-[var(--color-brand)]"
                        : "bg-[var(--color-surface-raised)] text-[var(--color-text-secondary)]"
                    }`}
                  >
                    {msg.role === "assistant" ? (
                      <Bot className="h-4 w-4" />
                    ) : (
                      <User className="h-4 w-4" />
                    )}
                  </div>
                  <div
                    className={`max-w-[80%] rounded-lg px-3 py-2 text-sm ${
                      msg.role === "assistant"
                        ? "bg-[var(--color-surface)] border border-[var(--color-border)] text-[var(--color-text-secondary)]"
                        : "bg-[var(--color-brand)] text-white"
                    }`}
                  >
                    {msg.content || (msg.role === "assistant" && loading && i === messages.length - 1) ? (
                      <div className="whitespace-pre-wrap">
                        {msg.content}
                        {msg.role === "assistant" && loading && i === messages.length - 1 && !msg.content && (
                          <Loader2 className="inline-block h-4 w-4 animate-spin text-[var(--color-brand)]/50" />
                        )}
                      </div>
                    ) : null}
                  </div>
                </div>
              ))
            )}
            {error && (
              <div className="flex items-center gap-2 rounded-lg border border-[var(--color-negative)]/30 bg-[var(--color-negative-soft)] p-3 text-xs text-[var(--color-negative)]">
                <AlertCircle className="h-4 w-4 shrink-0" />
                {error}
              </div>
            )}
            <div ref={scrollRef} />
          </div>

          <form onSubmit={handleSubmit} className="mt-4 flex gap-2">
            <Input
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder={
                mode === "tutor"
                  ? "Ask for an explanation..."
                  : mode === "coach"
                    ? "Ask for study advice..."
                    : mode === "troubleshooter"
                      ? "Describe the problem you're seeing..."
                      : mode === "interviewer"
                        ? "Ready for a question..."
                        : "Ask for a review..."
              }
              className="flex-1"
              disabled={loading}
            />
            {loading ? (
              <Button type="button" variant="secondary" onClick={handleStop}>
                Stop
              </Button>
            ) : (
              <Button type="submit" disabled={!input.trim()}>
                <Send className="h-4 w-4" />
                Send
              </Button>
            )}
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
