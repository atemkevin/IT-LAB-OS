"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { ONBOARDING_QUESTIONS, type AssessmentResult } from "@/lib/onboarding/assessment";
import {
  CheckCircle2,
  ChevronRight,
  ChevronLeft,
  Terminal,
  Shield,
  Bot,
  Layers,
  Sparkles,
  ArrowRight,
} from "lucide-react";

const STEPS = [
  "Experience Level",
  "Primary Goal",
  "Daily Study Cadence",
  "Lab Environment",
  "Baseline Assessment",
];

const EXPERIENCE_OPTIONS = [
  { id: "Complete beginner", label: "Complete beginner", desc: "New to IT systems, terminal commands, and networking concepts." },
  { id: "Some basic knowledge", label: "Some basic knowledge", desc: "Familiar with general tech concepts, used basic shell or command prompt." },
  { id: "Intermediate", label: "Intermediate", desc: "Hands-on experience configuring services, networks, or writing scripts." },
  { id: "Experienced", label: "Experienced", desc: "Working professional looking to cross-train or formalize deep lab mastery." },
];

const GOAL_OPTIONS = [
  { id: "Network Engineer", label: "Network Engineer", icon: Layers, desc: "Master TCP/IP, subnetting, routing, DNS, and traffic analysis." },
  { id: "Cybersecurity", label: "Cybersecurity", icon: Shield, desc: "Focus on defensive hardening, identity, access control, and auditing." },
  { id: "AI Automation", label: "AI Automation", icon: Bot, desc: "Build agentic workflows, API integrations, and Python automation." },
  { id: "General IT / Infrastructure", label: "General IT / Infrastructure", icon: Terminal, desc: "Broad mastery across Linux, Windows AD, virtualization, and systems infrastructure." },
];

const TIME_OPTIONS = [
  { minutes: 30, label: "30 min / day", desc: "Steady, sustainable daily progress." },
  { minutes: 60, label: "60 min / day", desc: "Balanced standard pace (Recommended)." },
  { minutes: 90, label: "90 min / day", desc: "Accelerated immersion track." },
  { minutes: 120, label: "120 min / day", desc: "Intensive engineering bootcamp pace." },
];

const ENVIRONMENT_OPTIONS = [
  "Windows PC",
  "Linux",
  "VPS",
  "Docker",
  "VirtualBox/VMware",
  "GitHub",
  "Cloud account",
  "No lab environment yet",
];

export default function OnboardingPage() {
  const router = useRouter();

  const [currentStep, setCurrentStep] = useState(0);
  const [experienceLevel, setExperienceLevel] = useState<string>("Some basic knowledge");
  const [primaryGoal, setPrimaryGoal] = useState<string>("General IT / Infrastructure");
  const [dailyMinutes, setDailyMinutes] = useState<30 | 60 | 90 | 120>(60);
  const [environment, setEnvironment] = useState<string[]>(["Windows PC", "GitHub"]);
  const [assessmentAnswers, setAssessmentAnswers] = useState<Record<string, string>>({});

  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [assessmentOutcome, setAssessmentOutcome] = useState<AssessmentResult | null>(null);

  function toggleEnvironment(item: string) {
    if (item === "No lab environment yet") {
      setEnvironment(["No lab environment yet"]);
      return;
    }
    setEnvironment((prev) => {
      const filtered = prev.filter((i) => i !== "No lab environment yet");
      return filtered.includes(item) ? filtered.filter((i) => i !== item) : [...filtered, item];
    });
  }

  async function handleComplete() {
    setSubmitting(true);
    setError(null);

    try {
      const res = await fetch("/api/onboarding", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          experience_level: experienceLevel,
          primary_goal: primaryGoal,
          daily_minutes: dailyMinutes,
          environment: environment.length > 0 ? environment : ["No lab environment yet"],
          assessmentAnswers,
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error?.message || "Failed to submit onboarding");
      }

      setAssessmentOutcome(data.assessmentResult);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : "An unexpected error occurred");
      setSubmitting(false);
    }
  }

  // Final Summary screen after assessment completes
  if (assessmentOutcome) {
    return (
      <div className="mx-auto max-w-2xl py-12 px-4">
        <Card className="border-[var(--color-brand)]/40 p-6">
          <div className="text-center">
            <div className="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-[var(--color-positive-soft)] text-[var(--color-positive)]">
              <CheckCircle2 className="h-6 w-6" />
            </div>
            <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">
              Onboarding Complete!
            </h1>
            <p className="mt-1 text-sm text-[var(--color-text-tertiary)]">
              Your profile and personalized baseline learning path have been configured.
            </p>
          </div>

          <div className="mt-6 space-y-4 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] p-5">
            <div className="flex items-center justify-between border-b border-[var(--color-border)] pb-3">
              <span className="text-xs text-[var(--color-text-secondary)]">Assessment Score</span>
              <span className="text-sm font-bold text-[var(--color-text-primary)]">
                {assessmentOutcome.percentageScore}% ({assessmentOutcome.correctCount} / {assessmentOutcome.totalQuestions} correct)
              </span>
            </div>

            <div className="flex items-center justify-between border-b border-[var(--color-border)] pb-3">
              <span className="text-xs text-[var(--color-text-secondary)]">Identified Starting Level</span>
              <Badge variant="brand" className="capitalize">
                {assessmentOutcome.startingLevel}
              </Badge>
            </div>

            <div className="flex items-center justify-between border-b border-[var(--color-border)] pb-3">
              <span className="text-xs text-[var(--color-text-secondary)]">Recommended First Skill</span>
              <span className="font-mono text-xs font-semibold text-[var(--color-brand)]">
                {assessmentOutcome.recommendedFirstSkill}
              </span>
            </div>

            {assessmentOutcome.weakDomains.length > 0 && (
              <div>
                <p className="text-xs font-medium text-[var(--color-warning)] mb-1.5">
                  Focus Areas to Strengthen:
                </p>
                <div className="flex flex-wrap gap-1.5">
                  {assessmentOutcome.weakDomains.map((d) => (
                    <Badge key={d} variant="warning">
                      {d}
                    </Badge>
                  ))}
                </div>
              </div>
            )}
          </div>

          <div className="mt-6">
            <Button
              className="w-full"
              size="lg"
              onClick={() => {
                router.push("/dashboard");
                router.refresh();
              }}
            >
              <span>Launch Learning Dashboard</span>
              <ArrowRight className="h-4 w-4" />
            </Button>
          </div>
        </Card>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-2xl py-8 px-4">
      {/* Step Indicator */}
      <div className="mb-6">
        <div className="flex items-center justify-between text-xs text-[var(--color-text-tertiary)] mb-2">
          <span>Step {currentStep + 1} of {STEPS.length}: <strong className="text-[var(--color-text-primary)]">{STEPS[currentStep]}</strong></span>
          <span>{Math.round(((currentStep + 1) / STEPS.length) * 100)}%</span>
        </div>
        <div className="h-1.5 w-full overflow-hidden rounded-full bg-[var(--color-surface-raised)]">
          <div
            className="h-full bg-[var(--color-brand)] transition-all duration-300"
            style={{ width: `${((currentStep + 1) / STEPS.length) * 100}%` }}
          />
        </div>
      </div>

      <Card>
        {error && (
          <div className="m-4 rounded-lg border border-[var(--color-negative)]/30 bg-[var(--color-negative-soft)] p-3 text-xs text-[var(--color-negative)]">
            {error}
          </div>
        )}

        {/* STEP 1: Experience */}
        {currentStep === 0 && (
          <div>
            <CardHeader>
              <CardTitle>What is your current technical background?</CardTitle>
              <CardDescription>
                This establishes your curriculum pacing and initial challenge calibration.
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-3">
              {EXPERIENCE_OPTIONS.map((opt) => (
                <button
                  key={opt.id}
                  type="button"
                  onClick={() => setExperienceLevel(opt.id)}
                  className={`flex w-full flex-col rounded-xl border p-4 text-left transition-colors ${
                    experienceLevel === opt.id
                      ? "border-[var(--color-brand)] bg-[var(--color-brand-soft)] text-[var(--color-text-primary)]"
                      : "border-[var(--color-border)] hover:bg-[var(--color-surface-raised)]"
                  }`}
                >
                  <span className="text-sm font-semibold">{opt.label}</span>
                  <span className="mt-1 text-xs text-[var(--color-text-tertiary)]">{opt.desc}</span>
                </button>
              ))}
            </CardContent>
          </div>
        )}

        {/* STEP 2: Goal */}
        {currentStep === 1 && (
          <div>
            <CardHeader>
              <CardTitle>What is your primary engineering goal?</CardTitle>
              <CardDescription>
                We will prioritize skills, lab incident drills, and projects matching this specialization.
              </CardDescription>
            </CardHeader>
            <CardContent className="grid grid-cols-1 gap-3 sm:grid-cols-2">
              {GOAL_OPTIONS.map((g) => {
                const Icon = g.icon;
                const isSelected = primaryGoal === g.id;
                return (
                  <button
                    key={g.id}
                    type="button"
                    onClick={() => setPrimaryGoal(g.id)}
                    className={`flex flex-col rounded-xl border p-4 text-left transition-colors ${
                      isSelected
                        ? "border-[var(--color-brand)] bg-[var(--color-brand-soft)] text-[var(--color-text-primary)]"
                        : "border-[var(--color-border)] hover:bg-[var(--color-surface-raised)]"
                    }`}
                  >
                    <Icon className={`h-5 w-5 mb-2 ${isSelected ? "text-[var(--color-brand)]" : "text-[var(--color-text-tertiary)]"}`} />
                    <span className="text-sm font-semibold">{g.label}</span>
                    <span className="mt-1 text-xs text-[var(--color-text-tertiary)]">{g.desc}</span>
                  </button>
                );
              })}
            </CardContent>
          </div>
        )}

        {/* STEP 3: Time */}
        {currentStep === 2 && (
          <div>
            <CardHeader>
              <CardTitle>How much daily study time can you commit?</CardTitle>
              <CardDescription>
                Your Daily Missions will be sized to fit comfortably within this window.
              </CardDescription>
            </CardHeader>
            <CardContent className="grid grid-cols-1 gap-3 sm:grid-cols-2">
              {TIME_OPTIONS.map((t) => (
                <button
                  key={t.minutes}
                  type="button"
                  onClick={() => setDailyMinutes(t.minutes as 30 | 60 | 90 | 120)}
                  className={`flex flex-col rounded-xl border p-4 text-left transition-colors ${
                    dailyMinutes === t.minutes
                      ? "border-[var(--color-brand)] bg-[var(--color-brand-soft)] text-[var(--color-text-primary)]"
                      : "border-[var(--color-border)] hover:bg-[var(--color-surface-raised)]"
                  }`}
                >
                  <span className="text-sm font-semibold">{t.label}</span>
                  <span className="mt-1 text-xs text-[var(--color-text-tertiary)]">{t.desc}</span>
                </button>
              ))}
            </CardContent>
          </div>
        )}

        {/* STEP 4: Environment */}
        {currentStep === 3 && (
          <div>
            <CardHeader>
              <CardTitle>What lab tools and systems do you currently have?</CardTitle>
              <CardDescription>
                Select all that apply. Hands-on projects will recommend configurations you can run.
              </CardDescription>
            </CardHeader>
            <CardContent className="grid grid-cols-2 gap-2.5 sm:grid-cols-4">
              {ENVIRONMENT_OPTIONS.map((item) => {
                const isChecked = environment.includes(item);
                return (
                  <button
                    key={item}
                    type="button"
                    onClick={() => toggleEnvironment(item)}
                    className={`rounded-lg border p-3 text-center text-xs font-medium transition-colors ${
                      isChecked
                        ? "border-[var(--color-brand)] bg-[var(--color-brand-soft)] text-[var(--color-brand)]"
                        : "border-[var(--color-border)] text-[var(--color-text-secondary)] hover:bg-[var(--color-surface-raised)]"
                    }`}
                  >
                    {item}
                  </button>
                );
              })}
            </CardContent>
          </div>
        )}

        {/* STEP 5: Assessment */}
        {currentStep === 4 && (
          <div>
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>Baseline Technical Assessment</CardTitle>
                <Badge variant="brand">{ONBOARDING_QUESTIONS.length} Questions</Badge>
              </div>
              <CardDescription>
                Answer these diagnostic questions to identify your starting level and any weak prerequisites.
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              {ONBOARDING_QUESTIONS.map((q, qIndex) => (
                <div key={q.id} className="space-y-2 rounded-xl border border-[var(--color-border)] p-4 bg-[var(--color-surface)]">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-mono text-[var(--color-brand)]">{q.domain}</span>
                    <span className="text-xs text-[var(--color-text-tertiary)]">Q{qIndex + 1} of {ONBOARDING_QUESTIONS.length}</span>
                  </div>
                  <p className="text-sm font-medium text-[var(--color-text-primary)]">{q.prompt}</p>
                  <div className="grid grid-cols-1 gap-2 pt-2">
                    {q.options.map((opt) => {
                      const isSelected = assessmentAnswers[q.id] === opt;
                      return (
                        <button
                          key={opt}
                          type="button"
                          onClick={() =>
                            setAssessmentAnswers((prev) => ({ ...prev, [q.id]: opt }))
                          }
                          className={`rounded-lg border p-3 text-left text-xs transition-colors ${
                            isSelected
                              ? "border-[var(--color-brand)] bg-[var(--color-brand-soft)] text-[var(--color-text-primary)] font-medium"
                              : "border-[var(--color-border)] hover:bg-[var(--color-surface-raised)] text-[var(--color-text-secondary)]"
                          }`}
                        >
                          {opt}
                        </button>
                      );
                    })}
                  </div>
                </div>
              ))}
            </CardContent>
          </div>
        )}

        <CardFooter className="flex items-center justify-between border-t border-[var(--color-border)] p-4">
          <Button
            variant="ghost"
            disabled={currentStep === 0 || submitting}
            onClick={() => setCurrentStep((s) => Math.max(0, s - 1))}
          >
            <ChevronLeft className="h-4 w-4" />
            Back
          </Button>

          {currentStep < STEPS.length - 1 ? (
            <Button onClick={() => setCurrentStep((s) => s + 1)}>
              Continue
              <ChevronRight className="h-4 w-4" />
            </Button>
          ) : (
            <Button
              onClick={handleComplete}
              disabled={submitting || Object.keys(assessmentAnswers).length < ONBOARDING_QUESTIONS.length}
            >
              <Sparkles className="h-4 w-4" />
              {submitting ? "Analyzing Assessment..." : "Complete Onboarding"}
            </Button>
          )}
        </CardFooter>
      </Card>
    </div>
  );
}
