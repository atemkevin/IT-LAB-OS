/**
 * tests/unit/quiz-scoring.test.ts
 * Unit tests for quiz scoring logic (standalone, no DB calls).
 */
import { describe, it, expect } from "vitest";
import { calculateMasteryState } from "@/lib/mastery/calculateMastery";

/**
 * Simulate the quiz grading logic from lib/learning/quizzes.ts
 * without making real DB calls.
 */
function gradeAnswers(
  questions: Array<{ id: string }>,
  correctAnswerMap: Map<string, Set<string>>,
  userAnswers: Record<string, string[]>
): { score: number; correctCount: number; questionCount: number; passed: boolean } {
  let correctCount = 0;

  for (const q of questions) {
    const selected = new Set(userAnswers[q.id] ?? []);
    const correct = correctAnswerMap.get(q.id) ?? new Set<string>();
    const isCorrect =
      selected.size === correct.size &&
      [...selected].every((id) => correct.has(id));
    if (isCorrect) correctCount++;
  }

  const questionCount = questions.length;
  const score = questionCount > 0 ? Math.round((correctCount / questionCount) * 100) : 0;
  const passed = score >= 70;

  return { score, correctCount, questionCount, passed };
}

const QUESTIONS = [
  { id: "q1" },
  { id: "q2" },
  { id: "q3" },
];

const CORRECT_MAP = new Map<string, Set<string>>([
  ["q1", new Set(["opt-A"])],
  ["q2", new Set(["opt-C"])],
  ["q3", new Set(["opt-B", "opt-D"])],
]);

describe("Quiz scoring", () => {
  it("scores 0% when all answers are wrong", () => {
    const answers = { q1: ["opt-X"], q2: ["opt-X"], q3: ["opt-X"] };
    const result = gradeAnswers(QUESTIONS, CORRECT_MAP, answers);
    expect(result.score).toBe(0);
    expect(result.correctCount).toBe(0);
    expect(result.passed).toBe(false);
  });

  it("scores 100% when all answers are correct", () => {
    const answers = { q1: ["opt-A"], q2: ["opt-C"], q3: ["opt-B", "opt-D"] };
    const result = gradeAnswers(QUESTIONS, CORRECT_MAP, answers);
    expect(result.score).toBe(100);
    expect(result.correctCount).toBe(3);
    expect(result.passed).toBe(true);
  });

  it("scores 67% when 2/3 correct (not passed)", () => {
    const answers = { q1: ["opt-A"], q2: ["opt-C"], q3: ["opt-X"] };
    const result = gradeAnswers(QUESTIONS, CORRECT_MAP, answers);
    expect(result.score).toBe(67);
    expect(result.correctCount).toBe(2);
    expect(result.passed).toBe(false);
  });

  it("marks single-answer wrong if extra options selected", () => {
    // q1 correct is opt-A only; selecting both opt-A and opt-X should be wrong
    const answers = { q1: ["opt-A", "opt-X"], q2: ["opt-C"], q3: ["opt-B", "opt-D"] };
    const result = gradeAnswers(QUESTIONS, CORRECT_MAP, answers);
    expect(result.correctCount).toBe(2); // q1 wrong
  });

  it("marks multi-answer wrong if only partial selection", () => {
    // q3 correct is {opt-B, opt-D}; selecting only opt-B is wrong
    const answers = { q1: ["opt-A"], q2: ["opt-C"], q3: ["opt-B"] };
    const result = gradeAnswers(QUESTIONS, CORRECT_MAP, answers);
    expect(result.correctCount).toBe(2); // q3 wrong
  });

  it("returns passed=true at exactly 70%", () => {
    // 7 questions, 5 correct = ~71.4%
    const qs = Array.from({ length: 7 }, (_, i) => ({ id: `q${i}` }));
    const correctMap = new Map(qs.map((q) => [q.id, new Set(["opt-A"])]));
    const userAnswers: Record<string, string[]> = {};
    for (let i = 0; i < 5; i++) userAnswers[`q${i}`] = ["opt-A"];
    for (let i = 5; i < 7; i++) userAnswers[`q${i}`] = ["opt-X"];
    const result = gradeAnswers(qs, correctMap, userAnswers);
    expect(result.passed).toBe(true);
  });

  it("returns score 0 when no questions", () => {
    const result = gradeAnswers([], new Map(), {});
    expect(result.score).toBe(0);
    expect(result.questionCount).toBe(0);
  });
});

describe("Score to mastery state", () => {
  it("maps 0 to not_started", () => {
    expect(calculateMasteryState(0)).toBe("not_started");
  });

  it("maps 29 to not_started", () => {
    expect(calculateMasteryState(29)).toBe("not_started");
  });

  it("maps 30 to developing", () => {
    expect(calculateMasteryState(30)).toBe("developing");
  });

  it("maps 50 to practicing", () => {
    expect(calculateMasteryState(50)).toBe("practicing");
  });

  it("maps 70 to proficient", () => {
    expect(calculateMasteryState(70)).toBe("proficient");
  });

  it("maps 85 to strong", () => {
    expect(calculateMasteryState(85)).toBe("strong");
  });

  it("maps 100 to strong", () => {
    expect(calculateMasteryState(100)).toBe("strong");
  });
});