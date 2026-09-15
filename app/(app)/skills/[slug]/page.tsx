import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Badge, MasteryBadge, DifficultyBadge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ArrowLeft, BookOpen, Terminal, CheckCircle2, HelpCircle } from "lucide-react";
import Link from "next/link";

export default async function SkillDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;

  return (
    <div className="space-y-6">
      <Link
        href="/skills"
        className="inline-flex items-center gap-1.5 text-xs text-[var(--color-text-tertiary)] hover:text-[var(--color-text-primary)]"
      >
        <ArrowLeft className="h-3.5 w-3.5" />
        Back to Skills
      </Link>

      <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-2xl font-bold capitalize text-[var(--color-text-primary)]">
              {slug.replace(/-/g, " ")}
            </h1>
            <DifficultyBadge difficulty="beginner" />
          </div>
          <p className="mt-1 text-xs text-[var(--color-text-tertiary)]">
            Detailed learning track and multi-dimensional mastery verification.
          </p>
        </div>
        <MasteryBadge state="not_started" />
      </div>

      {/* 5-part mastery breakdown cards */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-5">
        <Card className="p-3">
          <p className="text-xs text-[var(--color-text-tertiary)]">Knowledge (30%)</p>
          <p className="text-lg font-bold text-[var(--color-text-primary)]">0%</p>
        </Card>
        <Card className="p-3">
          <p className="text-xs text-[var(--color-text-tertiary)]">Practice (20%)</p>
          <p className="text-lg font-bold text-[var(--color-text-primary)]">0%</p>
        </Card>
        <Card className="p-3">
          <p className="text-xs text-[var(--color-text-tertiary)]">Troubleshoot (25%)</p>
          <p className="text-lg font-bold text-[var(--color-text-primary)]">0%</p>
        </Card>
        <Card className="p-3">
          <p className="text-xs text-[var(--color-text-tertiary)]">Project (15%)</p>
          <p className="text-lg font-bold text-[var(--color-text-primary)]">0%</p>
        </Card>
        <Card className="p-3">
          <p className="text-xs text-[var(--color-text-tertiary)]">Retention (10%)</p>
          <p className="text-lg font-bold text-[var(--color-text-primary)]">0%</p>
        </Card>
      </div>

      {/* Action Sections */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Lesson Content</CardTitle>
            <CardDescription>Core concepts, architecture, and syntax</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <p className="text-sm text-[var(--color-text-secondary)]">
              Follow along with structured conceptual modules and interactive terminal prompts.
            </p>
            <div className="flex gap-3">
              <Button>
                <BookOpen className="h-4 w-4" />
                Start Lesson
              </Button>
              <Button variant="outline">
                <HelpCircle className="h-4 w-4" />
                Take Quiz
              </Button>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Simulated Lab</CardTitle>
            <CardDescription>Deterministic troubleshooting</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <p className="text-xs text-[var(--color-text-tertiary)]">
              Diagnose broken states in simulated environments without touching production servers.
            </p>
            <Link href="/labs" className="block">
              <Button variant="secondary" className="w-full">
                <Terminal className="h-4 w-4" />
                Launch Scenario Lab
              </Button>
            </Link>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
