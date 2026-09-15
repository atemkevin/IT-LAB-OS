import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

export default function SettingsPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">System Settings</h1>
        <p className="text-sm text-[var(--color-text-tertiary)]">
          Application configuration, keys, and security settings.
        </p>
      </div>

      <div className="space-y-4">
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle>System Information</CardTitle>
              <Badge variant="brand">v0.1.0</Badge>
            </div>
            <CardDescription>IT Lab OS Foundation Runtime</CardDescription>
          </CardHeader>
          <CardContent className="space-y-2 text-xs text-[var(--color-text-tertiary)]">
            <div className="flex justify-between border-b border-[var(--color-border)] py-1.5">
              <span>Stack</span>
              <span className="font-mono text-[var(--color-text-primary)]">Next.js 16 + React 19 + Tailwind v4</span>
            </div>
            <div className="flex justify-between border-b border-[var(--color-border)] py-1.5">
              <span>Database & Auth</span>
              <span className="font-mono text-[var(--color-text-primary)]">Supabase (PostgreSQL + RLS)</span>
            </div>
            <div className="flex justify-between border-b border-[var(--color-border)] py-1.5">
              <span>Lab Execution</span>
              <span className="font-mono text-[var(--color-text-primary)]">Deterministic State Machine</span>
            </div>
            <div className="flex justify-between py-1.5">
              <span>Security Policy</span>
              <span className="font-mono text-[var(--color-positive)]">No Shell/Docker Execution In Browser</span>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
