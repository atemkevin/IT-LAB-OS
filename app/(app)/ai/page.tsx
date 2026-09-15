import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Bot, Send, Sparkles } from "lucide-react";

export default function AIPage() {
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
        <CardContent className="flex flex-1 flex-col justify-between p-4">
          <div className="flex flex-1 items-center justify-center text-center">
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

          <form onSubmit={(e) => e.preventDefault()} className="mt-4 flex gap-2">
            <Input
              placeholder="Ask your AI mentor a technical question..."
              className="flex-1"
            />
            <Button type="submit">
              <Send className="h-4 w-4" />
              Send
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
