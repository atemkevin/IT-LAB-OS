/**
 * lib/learning/types.ts
 *
 * Shared types for the learning engine.
 * Server and client safe -- no Supabase imports here.
 */
import type {
  Domain,
  Skill,
  Lesson,
  LessonSection,
  PracticeTask,
  UserLessonProgress,
  UserSkillProgress,
  MasteryState,
  Difficulty,
} from "@/lib/database.types";

// --- Skill Access States ---------------------------------------------------

export type SkillAccessState =
  | "locked"
  | "available"
  | "in_progress"
  | "practicing"
  | "proficient"
  | "strong";

// --- Enriched Skill Types --------------------------------------------------

export interface SkillWithDomain extends Skill {
  domain: Domain;
  accessState: SkillAccessState;
  userProgress: UserSkillProgress | null;
}

export interface DomainWithSkills {
  domain: Domain;
  skills: SkillWithDomain[];
  totalSkills: number;
  completedSkills: number;
  progressPercent: number;
}

// --- Lesson Types ----------------------------------------------------------

export interface LessonWithSections extends Lesson {
  sections: LessonSection[];
}

export interface LessonWithProgress extends Lesson {
  progress: UserLessonProgress | null;
}

// --- Skill Detail (full) --------------------------------------------------

export interface PrerequisiteStatus {
  skill: Skill;
  domain: Domain;
  isMet: boolean;
  requiredMastery: number;
  currentMastery: number;
}

export interface SkillDetail extends Skill {
  domain: Domain;
  accessState: SkillAccessState;
  userProgress: UserSkillProgress | null;
  prerequisites: PrerequisiteStatus[];
  lessons: LessonWithProgress[];
  practiceTasks: PracticeTask[];
  quizQuestionCount: number;
}

// --- Quiz Types (client-safe -- no is_correct) ----------------------------

export interface SafeQuizOption {
  id: string;
  optionText: string;
  sortOrder: number;
}

export interface SafeQuizQuestion {
  id: string;
  prompt: string;
  questionType: "single" | "multi" | "scenario";
  explanation: string | null;
  sortOrder: number;
  options: SafeQuizOption[];
}

export interface QuizSubmission {
  answers: Record<string, string[]>;
}

export interface QuizQuestionResult {
  questionId: string;
  prompt: string;
  isCorrect: boolean;
  explanation: string | null;
  selectedOptionIds: string[];
  correctOptionIds: string[];
}

export interface QuizResult {
  score: number;
  correctCount: number;
  questionCount: number;
  passed: boolean;
  results: QuizQuestionResult[];
  masteryEvidenceCreated: boolean;
}

// --- Practice Types --------------------------------------------------------

export interface PracticeSubmission {
  notes?: string;
  completed: boolean;
}

export interface PracticeResult {
  attemptId: string;
  passed: boolean;
  score: number;
  feedback: string;
}

// --- Progress Update -------------------------------------------------------

export interface SkillProgressUpdate {
  knowledge_score?: number;
  practice_score?: number;
  troubleshooting_score?: number;
  project_score?: number;
  retention_score?: number;
}

// Re-export common types for convenience
export type {
  MasteryState,
  Difficulty,
  Domain,
  Skill,
  Lesson,
  LessonSection,
  PracticeTask,
  UserLessonProgress,
  UserSkillProgress,
};
