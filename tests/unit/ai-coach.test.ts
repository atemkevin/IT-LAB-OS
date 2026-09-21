import { describe, it, expect } from "vitest";
import { buildSystemPrompt } from "@/lib/ai/prompts";
import type { UserContext } from "@/lib/ai/context";
import type { LabContext } from "@/lib/ai/types";

function createMockUserContext(overrides: Partial<UserContext> = {}): UserContext {
  return {
    hasProfile: true,
    experienceLevel: "intermediate",
    primaryGoal: "Learn Linux & Networking",
    dailyMinutes: 45,
    overallMastery: 55,
    skillsInProgress: 3,
    totalSkills: 12,
    recommendedSkill: "linux-cli",
    weakSkills: [
      { name: "Linux CLI", masteryScore: 25, masteryState: "developing" },
      { name: "DNS", masteryScore: 30, masteryState: "developing" },
    ],
    strongSkills: [
      { name: "Computer Basics", masteryScore: 85, masteryState: "strong" },
    ],
    todayMission: null,
    recentActivity: [
      { type: "troubleshooting", skillName: "Linux CLI", score: 80, createdAt: "2026-09-18T10:00:00Z" },
    ],
    ...overrides,
  };
}

describe("AI Coach System Prompt & Socratic Guardrails", () => {
  it("injects <active_lab_environment> block when labContext is provided", () => {
    const userCtx = createMockUserContext();
    const labCtx: LabContext = {
      scenarioSlug: "node-crash",
      scenarioTitle: "Node.js Server Crash",
      hintLevel: 1,
      recentCommands: [
        { command: "node server.js", output: "ReferenceError: potr is not defined" },
      ],
      files: [
        { path: "server.js", content: "app.listen(potr, () => {});" },
        { path: "package.json", content: '{"name": "crash-app"}' },
      ],
    };

    const prompt = buildSystemPrompt("troubleshooter", userCtx, labCtx);

    // Verify active lab environment markers
    expect(prompt).toContain("<active_lab_environment>");
    expect(prompt).toContain('scenario: "Node.js Server Crash" (slug: node-crash)');
    expect(prompt).toContain("hints_revealed_so_far: 1/5");
    expect(prompt).toContain('command: "node server.js"');
    expect(prompt).toContain("ReferenceError: potr is not defined");
    expect(prompt).toContain('path: "server.js"');
    expect(prompt).toContain("app.listen(potr, () => {});");
    expect(prompt).toContain("</active_lab_environment>");
  });

  it("enforces strict Socratic rules forbidding direct code solutions", () => {
    const userCtx = createMockUserContext();
    const labCtx: LabContext = {
      scenarioSlug: "api-cors-error",
      scenarioTitle: "API Gateway CORS Preflight Failure",
    };

    const prompt = buildSystemPrompt("troubleshooter", userCtx, labCtx);

    expect(prompt).toContain("Strict Pedagogical Guardrails:");
    expect(prompt).toContain("NEVER output the complete code fix or paste the solution directly");
    expect(prompt).toContain("NEVER state the root cause directly in your first response");
    expect(prompt).toContain("Socratic method");
  });

  it("gracefully omits <active_lab_environment> when labContext is undefined", () => {
    const userCtx = createMockUserContext();
    const prompt = buildSystemPrompt("troubleshooter", userCtx, undefined);

    expect(prompt).not.toContain("<active_lab_environment>");
    expect(prompt).toContain("Troubleshooting Coach embedded in IT Lab OS");
  });

  it("truncates very large files in labContext to prevent context window explosion", () => {
    const userCtx = createMockUserContext();
    const hugeContent = "A".repeat(4000);
    const labCtx: LabContext = {
      scenarioSlug: "log-triage",
      scenarioTitle: "Emergency Log Storage Triage",
      files: [{ path: "var/log/app-error.log", content: hugeContent }],
    };

    const prompt = buildSystemPrompt("troubleshooter", userCtx, labCtx);

    expect(prompt).toContain("... [truncated]");
    expect(prompt.length).toBeLessThan(hugeContent.length + 3000);
  });
});
