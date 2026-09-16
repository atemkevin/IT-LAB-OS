"use client";

import { useState, useRef, useCallback } from "react";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Bot, Send, Sparkles, User, AlertCircle } from "lucide-react";

interface ChatMessage {
  role: "user" | "assistant";
  content: string;
}

export default function AIPage() {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const abortRef = useRef<AbortController | null>(null);
  const scrollRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = useCallback(() => {
    scrollRef.current?.scrollIntoView({ behavior: "smooth" });
  }, []);

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
        body: JSON.stringify({ messages: newMessages }),
        signal: abortRef.current.signal,
      });

      if (res.status === 429) {
        const data = await res.json().catch(() => ({}));
        setError(data.error || "Too many messages. Please wait a moment.");
        setMessages((prev) => prev.slice(0, -1)); // Remove empty assistant message
        return;
      }

      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error(data.error || "Failed to get response");
      }

      if (!res.body) throw new Error("No response body");

      // Read SSE stream
      const reader = res.body.getReader();
      const decoder = new TextDecoder();
      let assistantContent = "";

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        const chunk = decoder.decode(value, { stream: true });
        const lines = chunk.split("\n");

        for (const line of lines) {
          if (!line.startsWith("data: ")) continue;
          const data = line.slice(6);
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
      setMessages((prev) => prev.slice(0, -1)); // Remove empty assistant message
    } finally {
      setLoading(false);
      abortRef.current = null;
      setTimeout(scrollToBottom, 50);
    }
  }

  function handleStop() {
    abortRef.current?.abort();
  }

  const hasMessages = messages.length > 0;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">AI Engineering Mentor</h1>
          <p className="text-sm text-[var(--color-text-tertiary)]">
            Grounding assistance in Tutor, Coach, Troubleshooter, Interviewer, or Reviewer modes.
          </p>
        </div>
      </div>

      <Card className="flex h-[600px] flex-col">
        <CardHeader className="border-b border-[var(--color-border)] pb-3">
          <div className="flex items-center gap-2">
            <div className="flex h-7 w-7 items-center justify-center rounded-md bg-[var(--color-brand-soft)] text-[var(--color-brand)]">
              <Bot className="h-4 w-4" />
            </div>
            <div>
              <CardTitle className="text-sm">Mentor Session</CardTitle>
              <CardDescription className="text-[11px]">
                Ask for explanations, hints on difficult labs, or mock technical interview questions.
              </CardDescription>
            </div>
          </div>
        </CardHeader>

        <CardContent className="flex flex-1 flex-col p-4 overflow-hidden">
          {/* Messages area */}
          <div className="flex-1 overflow-y-auto space-y-4 pr-1 -mr-1">
            {!hasMessages ? (
              <div className="flex h-full flex-1 items-center justify-center text-center">
                <div className="max-w-sm space-y-2">
                  <Sparkles className="mx-auto h-8 w-8 text-[var(--color-brand)]" />
                  <p className="text-sm font-medium text-[var(--color-text-primary)]">
                    How can I assist your learning today?
                  </p>
                  <p className="text-xs text-[var(--color-text-tertiary)]">
                    Try asking: &quot;Why does chmod 755 grant read/execute to group and others?&quot; or &quot;Guide me through diagnosing an unresponsive systemd unit.&quot;
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
                          <span className="inline-block h-4 w-4 animate-pulse rounded-full bg-[var(--color-brand)]/50" />
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

          {/* Input area */}
          <form onSubmit={handleSubmit} className="mt-4 flex gap-2">
            <Input
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder="Ask your AI mentor a technical question..."
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
