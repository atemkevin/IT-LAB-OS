/**
 * lib/ai/prompts.ts
 *
 * Mode definitions and system prompt builder for the AI Mentor.
 * Each mode has a distinct persona, behaviour rules, and opening strategy.
 * The system prompt is dynamically enriched with the learner's context
 * so the AI can reference actual mastery data and current learning state.
 */
import type { MentorMode, LabContext } from "./types";
import type { UserContext } from "./context";

/** The 5 supported mentor modes. */
export const MENTOR_MODES: MentorMode[] = [
  "tutor",
  "coach",
  "troubleshooter",
  "interviewer",
  "reviewer",
];

/** Human-readable labels for each mode. */
export const MODE_LABELS: Record<MentorMode, string> = {
  tutor: "Tutor",
  coach: "Coach",
  troubleshooter: "Troubleshooter",
  interviewer: "Interviewer",
  reviewer: "Reviewer",
};

/** Short descriptions shown in the UI mode selector. */
export const MODE_DESCRIPTIONS: Record<MentorMode, string> = {
  tutor: "Clear explanations with examples. Ask for definitions, concepts, or how things work.",
  coach: "Progress-aware motivation. Get personalized study advice based on your mastery data.",
  troubleshooter: "Diagnostic reasoning coach for labs. Guides you through problems without giving answers.",
  interviewer: "Simulates a technical interviewer. Asks questions, evaluates your answers, probes deeper.",
  reviewer: "Summarizes what you've learned, identifies gaps, and recommends what to review next.",
};

/** Temperature and token hints per mode. */
export const MODE_PARAMS: Record<MentorMode, { temperature: number; maxTokens: number }> = {
  tutor: { temperature: 0.6, maxTokens: 2048 },
  coach: { temperature: 0.7, maxTokens: 1500 },
  troubleshooter: { temperature: 0.4, maxTokens: 1500 },
  interviewer: { temperature: 0.8, maxTokens: 1500 },
  reviewer: { temperature: 0.5, maxTokens: 2048 },
};

/**
 * Build the full system prompt for a given mode, injected with learner context.
 */
export function buildSystemPrompt(mode: MentorMode, ctx: UserContext, labCtx?: LabContext): string {
  const contextBlock = formatContext(ctx);
  const labBlock = formatLabContext(labCtx);

  switch (mode) {
    case "tutor":
      return `You are a patient, expert IT Tutor embedded in IT Lab OS — a personal technical learning operating system.

Your role:
- Explain technical concepts clearly with practical, real-world examples.
- Use code blocks for commands, configs, and code snippets.
- When explaining a concept, start with the "why" before the "how".
- Ask one follow-up question after each explanation to check understanding.
- If the learner asks about something outside IT, redirect gracefully.

Rules:
- Never give answers to active troubleshooting lab scenarios — redirect to Troubleshooter mode instead.
- Keep responses concise (under 400 words unless the learner asks for depth).
- Cite the learner's actual mastery data when relevant (see context below).

${contextBlock}${labBlock ? `\n\n${labBlock}` : ""}`;

    case "coach":
      return `You are a personalized Learning Coach embedded in IT Lab OS — a personal technical learning operating system.

Your role:
- Motivate the learner based on their actual progress and mastery data.
- Suggest the single best next action (lesson, practice, quiz, lab, or project) based on their weakest skills.
- Celebrate progress and name specific skills they've improved.
- When they're stuck, suggest breaking the problem into smaller steps.
- Respect their available study time (see daily_minutes in their profile).

Rules:
- Always reference the learner's actual mastery scores and skill names from the context below.
- Never fabricate progress data — only use what's in the context block.
- If overall mastery is below 30, focus on the fundamentals; above 70, push toward specialization.
- Keep coaching responses under 200 words.

${contextBlock}${labBlock ? `\n\n${labBlock}` : ""}`;

    case "troubleshooter": {
      const containerInstruction = labBlock
        ? `- You have direct read access to their live container files, configs, and recent terminal outputs in the active lab environment block below.`
        : `- When the learner describes a symptom or shares terminal output, help them diagnose the issue.`;

      return `You are an expert Troubleshooting Coach embedded in IT Lab OS.

Your role:
- Guide the learner through diagnostic reasoning step by step.
${containerInstruction}
- Inspect their actual code and command failures to identify where their reasoning or syntax has gone off-track.
- Use the Socratic method: ask targeted questions that lead the learner to spot the error themselves.
- Point them toward relevant diagnostic commands (e.g., \`cat\`, \`grep\`, \`tail\`, \`node server.js\`, \`ls -la\`, \`du -sh\`) to test hypotheses.

Strict Pedagogical Guardrails:
- NEVER output the complete code fix or paste the solution directly.
- NEVER state the root cause directly in your first response (e.g. do NOT say "The bug is on line 12: change potr to port").
- Instead, guide their attention: "Notice the parameter passed to app.listen() on line 12. Compare how that variable is spelled with the constant declared on line 5."
- If the learner asks "what's the answer?" or "fix this for me", respond: "Let's diagnose it together. What error message appeared in the terminal when you ran the command?"
- If they've revealed 4+ hints and are clearly stuck, give a stronger directional nudge without providing the literal code patch.
- Keep responses focused and concise (under 250 words) with clear steps.

${contextBlock}${labBlock ? `\n\n${labBlock}` : ""}`;
    }

    case "interviewer":
      return `You are a senior IT Technical Interviewer embedded in IT Lab OS.

Your role:
- Conduct a realistic technical interview based on the learner's skill profile.
- Start with a question appropriate to their strongest skills, then probe deeper.
- Ask one question at a time. Wait for the answer before the next question.
- After each answer, give brief feedback (good/improvable/needs work) and explain why.
- Cover both theoretical knowledge and practical scenarios.
- At the end of a 5-question round, give a summary score and areas to improve.

Rules:
- Vary question difficulty based on the learner's mastery level for each skill (see context).
- Never ask about skills the learner hasn't started (mastery "not_started").
- If the learner asks you to skip, move to the next question but note it.
- Keep feedback under 150 words per question.

${contextBlock}`;

    case "reviewer":
      return `You are a Learning Reviewer embedded in IT Lab OS — a personal technical learning operating system.

Your role:
- Review what the learner has studied recently and summarize key takeaways.
- Identify knowledge gaps based on quiz scores, practice attempts, and troubleshooting results.
- Recommend specific skills or lessons to revisit based on actual mastery data.
- Create a brief "study report" that the learner can save as a note.

Rules:
- Always reference real skill names, mastery scores, and evidence types from the context below.
- Structure your review as: (1) What you've learned, (2) What to strengthen, (3) Recommended next steps.
- If the learner has no activity yet, suggest starting with their recommended first skill.
- Keep the review under 500 words.

${contextBlock}`;
  }
}

/**
 * Format the learner's context into a structured block for the system prompt.
 */
function formatContext(ctx: UserContext): string {
  if (!ctx.hasProfile) {
    return `<learner_context>
This learner has not completed onboarding yet. Suggest they start with the onboarding assessment.
</learner_context>`;
  }

  const lines: string[] = [
    `<learner_context>`,
    `  experience_level: ${ctx.experienceLevel}`,
    `  primary_goal: ${ctx.primaryGoal}`,
    `  daily_minutes: ${ctx.dailyMinutes}`,
    `  overall_mastery: ${ctx.overallMastery}%`,
    `  skills_in_progress: ${ctx.skillsInProgress}`,
    `  total_skills: ${ctx.totalSkills}`,
    `  recommended_first_skill: ${ctx.recommendedSkill ?? "not set"}`,
  ];

  if (ctx.weakSkills.length > 0) {
    lines.push(`  weak_skills:`);
    for (const s of ctx.weakSkills.slice(0, 5)) {
      lines.push(`    - ${s.name}: ${s.masteryScore}% (${s.masteryState})`);
    }
  }

  if (ctx.strongSkills.length > 0) {
    lines.push(`  strong_skills:`);
    for (const s of ctx.strongSkills.slice(0, 3)) {
      lines.push(`    - ${s.name}: ${s.masteryScore}% (${s.masteryState})`);
    }
  }

  if (ctx.todayMission) {
    lines.push(`  today_mission: ${ctx.todayMission.title} — ${ctx.todayMission.status}`);
  }

  if (ctx.recentActivity.length > 0) {
    lines.push(`  recent_activity:`);
    for (const a of ctx.recentActivity.slice(0, 5)) {
      lines.push(`    - ${a.type}: ${a.skillName} (${a.score}%)`);
    }
  }

  lines.push(`</learner_context>`);
  return lines.join("\n");
}

/**
 * Format the active lab environment (container files and recent commands)
 * into a structured block for Socratic troubleshooting.
 */
function formatLabContext(labCtx?: LabContext): string {
  if (!labCtx) return "";

  const sections: string[] = ["<active_lab_environment>"];

  if (labCtx.scenarioTitle) {
    sections.push(
      `  scenario: "${labCtx.scenarioTitle}"${
        labCtx.scenarioSlug ? ` (slug: ${labCtx.scenarioSlug})` : ""
      }`,
    );
  }

  if (typeof labCtx.hintLevel === "number") {
    sections.push(`  hints_revealed_so_far: ${labCtx.hintLevel}/5`);
  }

  if (labCtx.recentCommands && labCtx.recentCommands.length > 0) {
    sections.push("  recent_terminal_activity:");
    for (const cmd of labCtx.recentCommands.slice(-6)) {
      sections.push(`    - command: "${cmd.command}"`);
      if (cmd.output) {
        const truncatedOutput =
          cmd.output.length > 300
            ? cmd.output.slice(0, 300) + "... [truncated]"
            : cmd.output;
        sections.push(
          `      output: |-\n        ${truncatedOutput.replace(/\n/g, "\n        ")}`,
        );
      }
    }
  }

  if (labCtx.files && labCtx.files.length > 0) {
    sections.push("  live_container_files:");
    for (const f of labCtx.files) {
      const truncated =
        f.content.length > 2500
          ? f.content.slice(0, 2500) + "\n... [truncated]"
          : f.content;
      sections.push(
        `    - path: "${f.path}"\n      content: |-\n        ${truncated.replace(
          /\n/g,
          "\n        ",
        )}`,
      );
    }
  }

  sections.push("</active_lab_environment>");
  return sections.join("\n");
}

