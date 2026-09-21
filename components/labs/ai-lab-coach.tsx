"use client";

import { useState, useRef, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Bot, Send, Sparkles, User, Loader2, RefreshCw } from "lucide-react";
import type { LabContext } from "@/lib/ai/types";

interface Props {
  scenarioSlug: string;
  scenarioTitle: string;
  hintLevel: number;
  getContainerFiles?: () => Promise<Array<{ path: string; content: string }>>;
  getRecentCommands?: () => Array<{ command: string; output?: string }>;
}

interface CoachMessage {
  role: "user" | "assistant";
  content: string;
}

export function AILabCoach({
  scenarioSlug,
  scenarioTitle,
  hintLevel,
  getContainerFiles,
  getRecentCommands,
}: Props) {
  const [messages, setMessages] = useState<CoachMessage[]>([
    {
      role: "assistant",
      content: `Hello! I'm your AI Lab Coach. I can inspect your live virtual container files and terminal outputs to give you Socratic debugging guidance without spoiling the solution. What would you like to investigate?`,
    },
  ]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [statusNote, setStatusNote] = useState<string | null>(null);
  const scrollRef = useRef<HTMLDivElement>(null);
  const abortRef = useRef<AbortController | null>(null);

  useEffect(() => {
    scrollRef.current?.scrollTo({ top: scrollRef.current.scrollHeight, behavior: "smooth" });
  }, [messages, loading]);

  async function sendMessage(textToSend?: string) {
    const text = (textToSend || input).trim();
    if (!text || loading) return;

    setInput("");
    setLoading(true);
    setStatusNote("Reading container environment...");

    const newMessages: CoachMessage[] = [...messages, { role: "user", content: text }];
    setMessages([...newMessages, { role: "assistant", content: "" }]);

    abortRef.current = new AbortController();

    try {
      // Gather live container snapshot
      let files: Array<{ path: string; content: string }> = [];
      if (getContainerFiles) {
        try {
          files = await getContainerFiles();
        } catch (e) {
          console.warn("Failed to extract container files", e);
        }
      }

      const recentCommands = getRecentCommands ? getRecentCommands() : [];

      const labContext: LabContext = {
        scenarioSlug,
        scenarioTitle,
        hintLevel,
        recentCommands,
        files,
      };

      setStatusNote("Thinking...");

      const res = await fetch("/api/ai/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          messages: newMessages.map((m) => ({ role: m.role, content: m.content })),
          mode: "troubleshooter",
          labContext,
        }),
        signal: abortRef.current.signal,
      });

      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error(data.error || "Failed to reach AI coach");
      }

      setStatusNote(null);

      const reader = res.body?.getReader();
      if (!reader) throw new Error("No response body");

      const decoder = new TextDecoder();
      let assistantText = "";

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        const chunk = decoder.decode(value, { stream: true });
        for (const line of chunk.split("\n")) {
          if (!line.startsWith("data: ") || line === "data: [DONE]") continue;
          try {
            const json = JSON.parse(line.slice(6));
            const delta = json.choices?.[0]?.delta?.content;
            if (delta) {
              assistantText += delta;
              setMessages((prev) => {
                const updated = [...prev];
                updated[updated.length - 1] = {
                  role: "assistant",
                  content: assistantText,
                };
                return updated;
              });
            }
          } catch {
            // ignore non-json line
          }
        }
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Error connecting to AI Coach";
      setMessages((prev) => {
        const updated = [...prev];
        updated[updated.length - 1] = {
          role: "assistant",
          content: `⚠️ ${msg}. Check terminal output or try asking again.`,
        };
        return updated;
      });
    } finally {
      setLoading(false);
      setStatusNote(null);
    }
  }

  function handleQuickPrompt(prompt: string) {
    sendMessage(prompt);
  }

  function handleReset() {
    setMessages([
      {
        role: "assistant",
        content: `Conversation reset. I'm ready to inspect your container files. What symptom should we look into?`,
      },
    ]);
  }

  return (
    <Card className="flex flex-col border-[var(--color-brand)]/20 shadow-sm">
      <CardHeader className="pb-2.5">
        <div className="flex items-center justify-between">
          <CardTitle className="flex items-center gap-2 text-sm font-semibold">
            <Bot className="h-4 w-4 text-[var(--color-brand)]" />
            AI Lab Coach
            <Badge variant="positive" className="text-[10px] font-normal">
              Agentic
            </Badge>
          </CardTitle>
          <Button
            variant="ghost"
            size="sm"
            className="h-7 w-7 p-0 text-[var(--color-text-tertiary)]"
            onClick={handleReset}
            title="Reset Coach Chat"
            disabled={loading}
          >
            <RefreshCw className="h-3 w-3" />
          </Button>
        </div>
      </CardHeader>

      <CardContent className="space-y-3 pt-0 text-xs">
        {/* Quick Diagnostic Prompts */}
        <div className="flex flex-wrap gap-1.5">
          <button
            type="button"
            disabled={loading}
            onClick={() => handleQuickPrompt("Why is my code or container failing?")}
            className="inline-flex items-center gap-1 rounded-full border border-[var(--color-border)] bg-[var(--color-surface-raised)] px-2 py-1 text-[11px] text-[var(--color-text-secondary)] hover:border-[var(--color-brand)]/50 hover:text-[var(--color-text-primary)] transition disabled:opacity-50"
          >
            <Sparkles className="h-2.5 w-2.5 text-[var(--color-warning)]" />
            Why did it fail?
          </button>
          <button
            type="button"
            disabled={loading}
            onClick={() => handleQuickPrompt("Can you review my container file syntax?")}
            className="inline-flex items-center gap-1 rounded-full border border-[var(--color-border)] bg-[var(--color-surface-raised)] px-2 py-1 text-[11px] text-[var(--color-text-secondary)] hover:border-[var(--color-brand)]/50 hover:text-[var(--color-text-primary)] transition disabled:opacity-50"
          >
            🔍 Review syntax
          </button>
          <button
            type="button"
            disabled={loading}
            onClick={() => handleQuickPrompt("What diagnostic command should I run next?")}
            className="inline-flex items-center gap-1 rounded-full border border-[var(--color-border)] bg-[var(--color-surface-raised)] px-2 py-1 text-[11px] text-[var(--color-text-secondary)] hover:border-[var(--color-brand)]/50 hover:text-[var(--color-text-primary)] transition disabled:opacity-50"
          >
            🧭 Next step
          </button>
        </div>

        {/* Chat Message Scroll Area */}
        <div
          ref={scrollRef}
          className="h-56 overflow-y-auto rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-base)] p-2.5 space-y-2.5 font-sans"
        >
          {messages.map((m, idx) => (
            <div
              key={idx}
              className={`flex gap-2 ${
                m.role === "user" ? "justify-end" : "justify-start"
              }`}
            >
              {m.role === "assistant" && (
                <div className="flex h-5 w-5 shrink-0 select-none items-center justify-center rounded-full bg-[var(--color-brand)]/10 text-[var(--color-brand)]">
                  <Bot className="h-3 w-3" />
                </div>
              )}
              <div
                className={`max-w-[85%] rounded-lg px-2.5 py-1.5 text-xs whitespace-pre-wrap ${
                  m.role === "user"
                    ? "bg-[var(--color-brand)] text-white"
                    : "bg-[var(--color-surface-raised)] text-[var(--color-text-secondary)] border border-[var(--color-border)]"
                }`}
              >
                {m.content || (
                  <span className="flex items-center gap-1 text-[var(--color-text-tertiary)] italic">
                    <Loader2 className="h-3 w-3 animate-spin" /> Thinking...
                  </span>
                )}
              </div>
              {m.role === "user" && (
                <div className="flex h-5 w-5 shrink-0 select-none items-center justify-center rounded-full bg-[var(--color-surface-raised)] text-[var(--color-text-tertiary)]">
                  <User className="h-3 w-3" />
                </div>
              )}
            </div>
          ))}

          {statusNote && (
            <div className="text-[10px] text-[var(--color-text-tertiary)] italic pl-7 flex items-center gap-1">
              <Loader2 className="h-2.5 w-2.5 animate-spin" />
              {statusNote}
            </div>
          )}
        </div>

        {/* User Input Form */}
        <form
          onSubmit={(e) => {
            e.preventDefault();
            sendMessage();
          }}
          className="flex gap-1.5"
        >
          <Input
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="Ask the coach for diagnostic guidance..."
            disabled={loading}
            className="h-8 text-xs"
          />
          <Button type="submit" size="sm" className="h-8 px-2.5" disabled={loading || !input.trim()}>
            {loading ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : <Send className="h-3.5 w-3.5" />}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}
