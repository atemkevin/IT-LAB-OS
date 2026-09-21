"use client";

import { useEffect, useRef, useState, useCallback } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Lightbulb, Send, RotateCcw, CheckCircle2, Terminal as TerminalIcon } from "lucide-react";
import { WebContainer } from "@webcontainer/api";
import { Terminal } from "@xterm/xterm";
import { FitAddon } from "@xterm/addon-fit";
import "@xterm/xterm/css/xterm.css";
import { AILabCoach } from "@/components/labs/ai-lab-coach";

interface Props {
  slug: string;
  title: string;
  initialHints: string[];
  rootCause: string;
  repairAction: string;
}

interface CommandEntry {
  command: string;
  output: string;
  status: "ok" | "denied";
}

let webcontainerInstance: WebContainer | null = null;

export default function LabClient({ slug, title, initialHints, rootCause, repairAction }: Props) {
  const [attemptId, setAttemptId] = useState<string | null>(null);
  const [scenario, setScenario] = useState<any>(null);
  const [lines, setLines] = useState<CommandEntry[]>([]);
  const [input, setInput] = useState("");
  const [hint, setHint] = useState<string | null>(null);
  const [hintLevel, setHintLevel] = useState(0);
  const [submitted, setSubmitted] = useState(false);
  const [score, setScore] = useState<{ score: number; resolved: boolean; rootCauseIdentified: boolean } | null>(null);
  const [diagnosis, setDiagnosis] = useState("");
  const [attemptedFix, setAttemptedFix] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const scrollRef = useRef<HTMLDivElement>(null);
  const terminalRef = useRef<HTMLDivElement>(null);
  const xtermRef = useRef<Terminal | null>(null);

  const initWebContainer = useCallback(async (fs: any) => {
    if (!terminalRef.current) return;
    
    if (!xtermRef.current) {
      const term = new Terminal({ convertEol: true, fontSize: 12, fontFamily: "monospace" });
      const fitAddon = new FitAddon();
      term.loadAddon(fitAddon);
      term.open(terminalRef.current);
      fitAddon.fit();
      xtermRef.current = term;
    }

    const term = xtermRef.current;
    term.write(`\x1b[32mBooting Ephemeral Container for ${title}...\x1b[0m\r\n`);

    try {
      if (!webcontainerInstance) {
        webcontainerInstance = await WebContainer.boot();
      }
      await webcontainerInstance.mount(fs);

      const process = await webcontainerInstance.spawn("jsh");
      
      process.output.pipeTo(new WritableStream({
        write(data) {
          term.write(data);
        }
      }));

      const inputPipe = process.input.getWriter();
      term.onData((data) => {
        inputPipe.write(data);
      });
      
    } catch (err: any) {
      term.write(`\x1b[31mError booting container: ${err.message}\x1b[0m\r\n`);
    }
  }, [title]);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      setBusy(true);
      setError(null);
      try {
        const res = await fetch(`/api/troubleshooting/${slug}/start`, { method: "POST" });
        if (!res.ok) {
          throw new Error((await res.json().catch(() => ({}))).error ?? "Failed to start lab");
        }
        const data = await res.json();
        if (cancelled) return;
        setAttemptId(data.attemptId);
        setScenario(data.scenario);
        
        if (data.scenario.runnerType === "deterministic") {
          setLines([
            { command: "(scenario started)", output: `Welcome to "${data.scenario.title}". Run diagnostics to investigate.`, status: "ok" },
          ]);
        } else if (data.scenario.runnerType === "webcontainer") {
          await initWebContainer(data.scenario.webcontainerFs);
        }
      } catch (e: unknown) {
        const msg = e instanceof Error ? e.message : "Failed to start lab";
        setError(msg);
      } finally {
        setBusy(false);
      }
    })();
    return () => { cancelled = true; };
  }, [slug, initWebContainer]);

  useEffect(() => {
    if (scenario?.runnerType === "deterministic") {
      scrollRef.current?.scrollTo({ top: scrollRef.current.scrollHeight, behavior: "smooth" });
    }
  }, [lines, scenario]);

  async function runCommand(e: React.FormEvent) {
    e.preventDefault();
    if (!attemptId || !input.trim() || busy || submitted) return;
    const cmd = input.trim();
    setInput("");
    setBusy(true);
    setError(null);
    try {
      const res = await fetch(`/api/troubleshooting/${slug}/command`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ attemptId, command: cmd }),
      });
      if (!res.ok) {
        throw new Error((await res.json().catch(() => ({}))).error ?? "Command failed");
      }
      const data = await res.json();
      setLines((l) => [...l, { command: cmd, output: data.result.output, status: data.result.status }]);
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : "Command failed";
      setError(msg);
    } finally {
      setBusy(false);
    }
  }

  async function showHint() {
    if (!attemptId || busy) return;
    const next = hintLevel + 1;
    if (next > initialHints.length) return;
    setBusy(true);
    setError(null);
    try {
      const res = await fetch(`/api/troubleshooting/${slug}/hint`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ attemptId }),
      });
      if (!res.ok) {
        throw new Error((await res.json().catch(() => ({}))).error ?? "Hint failed");
      }
      const data = await res.json();
      setHint(data.hint.text);
      setHintLevel(data.hint.level);
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : "Hint failed";
      setError(msg);
    } finally {
      setBusy(false);
    }
  }

  async function finish() {
    if (!attemptId || busy) return;
    setBusy(true);
    setError(null);
    
    let clientVerificationResult = undefined;
    if (scenario?.runnerType === "webcontainer" && webcontainerInstance) {
      try {
        const process = await webcontainerInstance.spawn("node", [".verify.js"]);
        let output = "";
        process.output.pipeTo(new WritableStream({
          write(data) { output += data; }
        }));
        await process.exit;
        clientVerificationResult = JSON.parse(output.trim());
      } catch (err) {
        console.error("Verification failed", err);
        clientVerificationResult = { passed: false, rootCauseIdentified: false };
      }
    }

    try {
      const res = await fetch(`/api/troubleshooting/${slug}/finish`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ attemptId, diagnosis, attemptedFix, clientVerificationResult }),
      });
      if (!res.ok) {
        throw new Error((await res.json().catch(() => ({}))).error ?? "Finish failed");
      }
      const data = await res.json();
      setScore(data);
      setSubmitted(true);
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : "Finish failed";
      setError(msg);
    } finally {
      setBusy(false);
    }
  }

  function reset() {
    window.location.reload();
  }

  const maxHint = initialHints.length;
  const canHint = !submitted && !!attemptId && hintLevel < maxHint;
  const canSubmit = !submitted && !!attemptId;

  const getRecentCommands = useCallback(() => {
    return lines.map((l) => ({ command: l.command, output: l.output }));
  }, [lines]);

  const getContainerFiles = useCallback(async () => {
    if (!webcontainerInstance) return [];

    const fileList: Array<{ path: string; content: string }> = [];

    async function traverse(dir: string) {
      try {
        const entries = await webcontainerInstance!.fs.readdir(dir, { withFileTypes: true });
        for (const entry of entries) {
          const fullPath = dir ? `${dir}/${entry.name}` : entry.name;
          if (
            entry.name.startsWith(".git") ||
            entry.name === "node_modules" ||
            entry.name === ".verify.js"
          ) {
            continue;
          }
          if (entry.isDirectory()) {
            await traverse(fullPath);
          } else {
            try {
              const content = await webcontainerInstance!.fs.readFile(fullPath, "utf-8");
              fileList.push({ path: fullPath, content });
            } catch {
              // skip unreadable
            }
          }
        }
      } catch {
        // skip unreadable directories
      }
    }

    await traverse("");
    return fileList;
  }, []);

  return (
    <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
      <div className="lg:col-span-2 space-y-4">
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle className="flex items-center gap-2 text-base">
                <TerminalIcon className="h-4 w-4 text-[var(--color-brand)]" />
                Terminal — {title}
              </CardTitle>
              <Button variant="ghost" size="sm" onClick={reset} disabled={busy}>
                <RotateCcw className="h-3.5 w-3.5" />
                Restart
              </Button>
            </div>
          </CardHeader>
          <CardContent>
            {scenario?.runnerType === "webcontainer" ? (
              <div 
                ref={terminalRef} 
                className="h-80 w-full overflow-hidden rounded-lg bg-black p-2" 
              />
            ) : (
              <>
                <div
                  ref={scrollRef}
                  className="h-72 overflow-y-auto rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-base)] p-3 font-mono text-xs"
                >
                  {lines.map((l, idx) => (
                    <div key={idx} className="mb-2">
                      <div className="text-[var(--color-brand)]">
                        learner@it-lab-os:~$ <span className="text-[var(--color-text-primary)]">{l.command}</span>
                      </div>
                      <pre
                        className={
                          l.status === "denied"
                            ? "whitespace-pre-wrap text-[var(--color-warning)]"
                            : "whitespace-pre-wrap text-[var(--color-text-secondary)]"
                        }
                      >
                        {l.output}
                      </pre>
                    </div>
                  ))}
                  {lines.length === 0 && (
                    <div className="text-[var(--color-text-tertiary)]">Initialising scenario…</div>
                  )}
                </div>

                <form onSubmit={runCommand} className="mt-3 flex gap-2">
                  <Input
                    value={input}
                    onChange={(e) => setInput(e.target.value)}
                    placeholder="Type a command and press Enter…"
                    disabled={!attemptId || busy || submitted}
                    autoFocus
                  />
                  <Button type="submit" disabled={!attemptId || busy || submitted || !input.trim()}>
                    <Send className="h-4 w-4" />
                    Run
                  </Button>
                </form>
              </>
            )}
          </CardContent>
        </Card>

        {canSubmit && (
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Diagnosis & Fix</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <div>
                <label className="text-xs font-semibold text-[var(--color-text-tertiary)]">
                  What did you identify as the root cause?
                </label>
                <textarea
                  className="mt-1 w-full rounded-md border border-[var(--color-border)] bg-[var(--color-surface)] p-2 text-sm text-[var(--color-text-primary)] outline-none focus:border-[var(--color-brand)]"
                  rows={3}
                  value={diagnosis}
                  onChange={(e) => setDiagnosis(e.target.value)}
                  placeholder="e.g. The DNS resolver was misconfigured…"
                />
              </div>
              <div>
                <label className="text-xs font-semibold text-[var(--color-text-tertiary)]">
                  What action did you (or would you) take to fix it?
                </label>
                <textarea
                  className="mt-1 w-full rounded-md border border-[var(--color-border)] bg-[var(--color-surface)] p-2 text-sm text-[var(--color-text-primary)] outline-none focus:border-[var(--color-brand)]"
                  rows={3}
                  value={attemptedFix}
                  onChange={(e) => setAttemptedFix(e.target.value)}
                  placeholder="e.g. Replace the invalid resolver with 8.8.8.8…"
                />
              </div>
              <Button onClick={finish} disabled={busy}>
                <CheckCircle2 className="h-4 w-4" />
                Finish &amp; Score
              </Button>
            </CardContent>
          </Card>
        )}

        {submitted && score && (
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Result</CardTitle>
            </CardHeader>
            <CardContent className="space-y-2 text-sm">
              <p className="text-3xl font-bold text-[var(--color-text-primary)]">{score.score}</p>
              <p className="text-[var(--color-text-tertiary)]">
                {score.resolved ? "Scenario resolved." : "Scenario not fully resolved."}
                {score.rootCauseIdentified ? " Root cause identified." : ""}
              </p>
              {score.rootCauseIdentified === false && (
                <p className="text-xs text-[var(--color-text-tertiary)]">
                  Expected: {rootCause}
                </p>
              )}
              <p className="text-xs text-[var(--color-text-tertiary)]">
                Expected repair: {repairAction}
              </p>
            </CardContent>
          </Card>
        )}
      </div>

      <div className="space-y-4">
        <AILabCoach
          scenarioSlug={slug}
          scenarioTitle={title}
          hintLevel={hintLevel}
          getContainerFiles={getContainerFiles}
          getRecentCommands={getRecentCommands}
        />

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-base">
              <Lightbulb className="h-4 w-4 text-[var(--color-warning)]" />
              Hint Ladder
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-2 text-sm">
            <p className="text-xs text-[var(--color-text-tertiary)]">
              5-step ladder. Each hint used reduces your score by a small amount.
            </p>
            <Button onClick={showHint} disabled={!canHint} variant="secondary" className="w-full">
              {hintLevel === 0 ? "Reveal hint 1" : hintLevel >= maxHint ? "No more hints" : `Reveal hint ${hintLevel + 1}`}
            </Button>
            {hint && (
              <div className="rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-raised)] p-3 text-xs text-[var(--color-text-secondary)]">
                <p className="font-semibold text-[var(--color-text-primary)]">Hint {hintLevel}</p>
                <p className="mt-1">{hint}</p>
              </div>
            )}
          </CardContent>
        </Card>

        {error && (
          <Card>
            <CardContent className="pt-4 text-sm text-[var(--color-warning)]">{error}</CardContent>
          </Card>
        )}
      </div>
    </div>
  );
}
