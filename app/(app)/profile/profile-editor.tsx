"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import type { Profile } from "@/lib/database.types";

interface ProfileEditorProps {
  initialProfile: Profile | null;
  email: string;
}

export function ProfileEditor({ initialProfile, email }: ProfileEditorProps) {
  const router = useRouter();

  const [displayName, setDisplayName] = useState(initialProfile?.display_name || "");
  const [experienceLevel, setExperienceLevel] = useState(initialProfile?.experience_level || "Intermediate");
  const [primaryGoal, setPrimaryGoal] = useState(initialProfile?.primary_goal || "General IT / Infrastructure");
  const [dailyMinutes, setDailyMinutes] = useState<30 | 60 | 90 | 120>(
    (initialProfile?.daily_minutes as 30 | 60 | 90 | 120) || 60,
  );

  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<{ type: "success" | "error"; text: string } | null>(null);

  // Extract environment info
  const envObj = (initialProfile?.environment || {}) as Record<string, unknown>;
  const tools = Array.isArray(envObj.tools) ? (envObj.tools as string[]) : [];

  async function handleSave(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setMessage(null);

    try {
      const res = await fetch("/api/profile", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          display_name: displayName,
          experience_level: experienceLevel,
          primary_goal: primaryGoal,
          daily_minutes: dailyMinutes,
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error?.message || "Failed to update profile");
      }

      setMessage({ type: "success", text: "Profile updated successfully!" });
      router.refresh();
    } catch (err: unknown) {
      setMessage({
        type: "error",
        text: err instanceof Error ? err.message : "An unexpected error occurred",
      });
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="space-y-6">
      {message && (
        <div
          className={`rounded-lg border p-3 text-xs ${
            message.type === "success"
              ? "border-[var(--color-positive)]/30 bg-[var(--color-positive-soft)] text-[var(--color-positive)]"
              : "border-[var(--color-negative)]/30 bg-[var(--color-negative-soft)] text-[var(--color-negative)]"
          }`}
        >
          {message.text}
        </div>
      )}

      <form onSubmit={handleSave} className="grid grid-cols-1 gap-6 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Identity & Credentials</CardTitle>
            <CardDescription>Your public profile and account details</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label htmlFor="email-display">Email Address</Label>
              <Input id="email-display" value={email} disabled className="opacity-70" />
            </div>

            <div>
              <Label htmlFor="display-name">Display Name</Label>
              <Input
                id="display-name"
                value={displayName}
                onChange={(e) => setDisplayName(e.target.value)}
                placeholder="e.g. Alex"
              />
            </div>

            <div>
              <Label htmlFor="experience">Experience Level</Label>
              <select
                id="experience"
                value={experienceLevel}
                onChange={(e) => setExperienceLevel(e.target.value)}
                className="mt-1 flex h-9 w-full rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] px-3 py-1.5 text-sm text-[var(--color-text-primary)] focus:border-[var(--color-brand)] focus:outline-none focus:ring-1 focus:ring-[var(--color-brand)]"
              >
                <option value="Complete beginner">Complete beginner</option>
                <option value="Some basic knowledge">Some basic knowledge</option>
                <option value="Intermediate">Intermediate</option>
                <option value="Experienced">Experienced</option>
              </select>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Learning Schedule & Specialization</CardTitle>
            <CardDescription>Configures recommendation weights and mission sizing</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label htmlFor="primary-goal">Primary Engineering Goal</Label>
              <select
                id="primary-goal"
                value={primaryGoal}
                onChange={(e) => setPrimaryGoal(e.target.value)}
                className="mt-1 flex h-9 w-full rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] px-3 py-1.5 text-sm text-[var(--color-text-primary)] focus:border-[var(--color-brand)] focus:outline-none focus:ring-1 focus:ring-[var(--color-brand)]"
              >
                <option value="Network Engineer">Network Engineer</option>
                <option value="Cybersecurity">Cybersecurity</option>
                <option value="AI Automation">AI Automation</option>
                <option value="General IT / Infrastructure">General IT / Infrastructure</option>
              </select>
            </div>

            <div>
              <Label htmlFor="daily-minutes">Daily Study Cadence</Label>
              <select
                id="daily-minutes"
                value={dailyMinutes}
                onChange={(e) =>
                  setDailyMinutes(Number(e.target.value) as 30 | 60 | 90 | 120)
                }
                className="mt-1 flex h-9 w-full rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] px-3 py-1.5 text-sm text-[var(--color-text-primary)] focus:border-[var(--color-brand)] focus:outline-none focus:ring-1 focus:ring-[var(--color-brand)]"
              >
                <option value={30}>30 minutes / day</option>
                <option value={60}>60 minutes / day (Recommended)</option>
                <option value={90}>90 minutes / day</option>
                <option value={120}>120 minutes / day</option>
              </select>
            </div>

            {tools.length > 0 && (
              <div>
                <Label>Registered Lab Tools</Label>
                <div className="mt-1.5 flex flex-wrap gap-1.5">
                  {tools.map((t) => (
                    <Badge key={t} variant="default">
                      {t}
                    </Badge>
                  ))}
                </div>
              </div>
            )}
          </CardContent>
        </Card>

        <div className="md:col-span-2 flex justify-end">
          <Button type="submit" disabled={saving}>
            {saving ? "Saving Changes..." : "Save Profile"}
          </Button>
        </div>
      </form>
    </div>
  );
}
