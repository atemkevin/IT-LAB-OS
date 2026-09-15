/**
 * Database types for IT Lab OS.
 *
 * This file is the source of truth for TypeScript types.
 * After applying the Supabase migration, regenerate with:
 *   npx supabase gen types typescript --project-id <your-project-id> > lib/database.types.ts
 *
 * Until then, this provides hand-written types that match 001_core_schema.sql exactly.
 */

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export type MasteryState =
  | "not_started"
  | "developing"
  | "practicing"
  | "proficient"
  | "strong";

export type Difficulty = "beginner" | "intermediate" | "advanced";

export type EvidenceType =
  | "lesson"
  | "practice"
  | "quiz"
  | "troubleshooting"
  | "project"
  | "retention"
  | "mission";

export type AIMode =
  | "tutor"
  | "coach"
  | "troubleshooter"
  | "interviewer"
  | "reviewer";

export type LessonStatus = "not_started" | "in_progress" | "completed";

export type ProjectStatus = "not_started" | "in_progress" | "submitted" | "completed";

export type MissionStatus = "not_started" | "in_progress" | "completed" | "skipped";

export type QuestionType = "single" | "multi" | "scenario";

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          display_name: string | null;
          avatar_url: string | null;
          experience_level: string | null;
          daily_minutes: 30 | 60 | 90 | 120 | null;
          primary_goal: string | null;
          environment: Json;
          onboarding_done: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id: string;
          display_name?: string | null;
          avatar_url?: string | null;
          experience_level?: string | null;
          daily_minutes?: 30 | 60 | 90 | 120 | null;
          primary_goal?: string | null;
          environment?: Json;
          onboarding_done?: boolean;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          display_name?: string | null;
          avatar_url?: string | null;
          experience_level?: string | null;
          daily_minutes?: 30 | 60 | 90 | 120 | null;
          primary_goal?: string | null;
          environment?: Json;
          onboarding_done?: boolean;
          updated_at?: string;
        };
        Relationships: [];
      };
      domains: {
        Row: {
          id: string;
          slug: string;
          name: string;
          description: string | null;
          sort_order: number;
          icon: string | null;
          is_published: boolean;
          created_at: string;
        };
        Insert: {
          id?: string;
          slug: string;
          name: string;
          description?: string | null;
          sort_order?: number;
          icon?: string | null;
          is_published?: boolean;
          created_at?: string;
        };
        Update: {
          slug?: string;
          name?: string;
          description?: string | null;
          sort_order?: number;
          icon?: string | null;
          is_published?: boolean;
        };
        Relationships: [];
      };
      skills: {
        Row: {
          id: string;
          domain_id: string;
          slug: string;
          name: string;
          description: string | null;
          why_it_matters: string | null;
          difficulty: Difficulty;
          estimated_minutes: number;
          learning_objectives: Json;
          tags: Json;
          sort_order: number;
          is_published: boolean;
          created_at: string;
        };
        Insert: {
          id?: string;
          domain_id: string;
          slug: string;
          name: string;
          description?: string | null;
          why_it_matters?: string | null;
          difficulty?: Difficulty;
          estimated_minutes?: number;
          learning_objectives?: Json;
          tags?: Json;
          sort_order?: number;
          is_published?: boolean;
          created_at?: string;
        };
        Update: {
          domain_id?: string;
          slug?: string;
          name?: string;
          description?: string | null;
          why_it_matters?: string | null;
          difficulty?: Difficulty;
          estimated_minutes?: number;
          learning_objectives?: Json;
          tags?: Json;
          sort_order?: number;
          is_published?: boolean;
        };
        Relationships: [{ foreignKeyName: "skills_domain_id_fkey"; columns: ["domain_id"]; referencedRelation: "domains"; referencedColumns: ["id"] }];
      };
      skill_prerequisites: {
        Row: {
          skill_id: string;
          prerequisite_skill_id: string;
          required_mastery: number;
        };
        Insert: {
          skill_id: string;
          prerequisite_skill_id: string;
          required_mastery?: number;
        };
        Update: {
          required_mastery?: number;
        };
        Relationships: [];
      };
      lessons: {
        Row: {
          id: string;
          skill_id: string;
          slug: string;
          title: string;
          summary: string | null;
          content_markdown: string | null;
          difficulty: string | null;
          estimated_minutes: number | null;
          sort_order: number;
          is_published: boolean;
          created_at: string;
        };
        Insert: {
          id?: string;
          skill_id: string;
          slug: string;
          title: string;
          summary?: string | null;
          content_markdown?: string | null;
          difficulty?: string | null;
          estimated_minutes?: number | null;
          sort_order?: number;
          is_published?: boolean;
          created_at?: string;
        };
        Update: {
          skill_id?: string;
          slug?: string;
          title?: string;
          summary?: string | null;
          content_markdown?: string | null;
          difficulty?: string | null;
          estimated_minutes?: number | null;
          sort_order?: number;
          is_published?: boolean;
        };
        Relationships: [];
      };
      lesson_sections: {
        Row: {
          id: string;
          lesson_id: string;
          section_type: string;
          title: string | null;
          content_markdown: string | null;
          sort_order: number;
        };
        Insert: {
          id?: string;
          lesson_id: string;
          section_type: string;
          title?: string | null;
          content_markdown?: string | null;
          sort_order?: number;
        };
        Update: {
          section_type?: string;
          title?: string | null;
          content_markdown?: string | null;
          sort_order?: number;
        };
        Relationships: [];
      };
      user_lesson_progress: {
        Row: {
          user_id: string;
          lesson_id: string;
          status: LessonStatus;
          progress: number;
          started_at: string | null;
          completed_at: string | null;
          updated_at: string;
        };
        Insert: {
          user_id: string;
          lesson_id: string;
          status?: LessonStatus;
          progress?: number;
          started_at?: string | null;
          completed_at?: string | null;
          updated_at?: string;
        };
        Update: {
          status?: LessonStatus;
          progress?: number;
          started_at?: string | null;
          completed_at?: string | null;
          updated_at?: string;
        };
        Relationships: [];
      };
      practice_tasks: {
        Row: {
          id: string;
          skill_id: string;
          title: string;
          objective: string | null;
          context: string | null;
          requirements: Json;
          success_criteria: Json;
          hints: Json;
          is_published: boolean;
        };
        Insert: {
          id?: string;
          skill_id: string;
          title: string;
          objective?: string | null;
          context?: string | null;
          requirements?: Json;
          success_criteria?: Json;
          hints?: Json;
          is_published?: boolean;
        };
        Update: {
          title?: string;
          objective?: string | null;
          context?: string | null;
          requirements?: Json;
          success_criteria?: Json;
          hints?: Json;
          is_published?: boolean;
        };
        Relationships: [];
      };
      practice_attempts: {
        Row: {
          id: string;
          user_id: string;
          practice_task_id: string;
          submission: Json | null;
          feedback: string | null;
          score: number | null;
          passed: boolean | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          practice_task_id: string;
          submission?: Json | null;
          feedback?: string | null;
          score?: number | null;
          passed?: boolean | null;
          created_at?: string;
        };
        Update: {
          submission?: Json | null;
          feedback?: string | null;
          score?: number | null;
          passed?: boolean | null;
        };
        Relationships: [];
      };
      quiz_questions: {
        Row: {
          id: string;
          skill_id: string;
          prompt: string;
          question_type: QuestionType;
          explanation: string | null;
          sort_order: number;
          is_published: boolean;
        };
        Insert: {
          id?: string;
          skill_id: string;
          prompt: string;
          question_type?: QuestionType;
          explanation?: string | null;
          sort_order?: number;
          is_published?: boolean;
        };
        Update: {
          prompt?: string;
          question_type?: QuestionType;
          explanation?: string | null;
          sort_order?: number;
          is_published?: boolean;
        };
        Relationships: [];
      };
      /**
       * NOTE: quiz_options has NO SELECT policy for regular clients (RLS).
       * Do NOT use the anon/user client to query this table.
       * Use getAdminClient() in server-side quiz evaluation only.
       */
      quiz_options: {
        Row: {
          id: string;
          question_id: string;
          option_text: string;
          is_correct: boolean;
          sort_order: number;
        };
        Insert: {
          id?: string;
          question_id: string;
          option_text: string;
          is_correct?: boolean;
          sort_order?: number;
        };
        Update: {
          option_text?: string;
          is_correct?: boolean;
          sort_order?: number;
        };
        Relationships: [];
      };
      quiz_attempts: {
        Row: {
          id: string;
          user_id: string;
          skill_id: string;
          answers: Json;
          score: number;
          correct_count: number | null;
          question_count: number | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          skill_id: string;
          answers: Json;
          score: number;
          correct_count?: number | null;
          question_count?: number | null;
          created_at?: string;
        };
        Update: {
          answers?: Json;
          score?: number;
          correct_count?: number | null;
          question_count?: number | null;
        };
        Relationships: [];
      };
      troubleshooting_scenarios: {
        Row: {
          id: string;
          skill_id: string | null;
          slug: string;
          title: string;
          description: string | null;
          difficulty: Difficulty | null;
          initial_state: Json;
          allowed_commands: Json;
          states: Json;
          transitions: Json;
          hints: Json;
          root_cause: string | null;
          repair_action: string | null;
          verification: Json;
          scoring_rules: Json;
          is_published: boolean;
        };
        Insert: {
          id?: string;
          skill_id?: string | null;
          slug: string;
          title: string;
          description?: string | null;
          difficulty?: Difficulty | null;
          initial_state?: Json;
          allowed_commands?: Json;
          states?: Json;
          transitions?: Json;
          hints?: Json;
          root_cause?: string | null;
          repair_action?: string | null;
          verification?: Json;
          scoring_rules?: Json;
          is_published?: boolean;
        };
        Update: {
          skill_id?: string | null;
          slug?: string;
          title?: string;
          description?: string | null;
          difficulty?: Difficulty | null;
          initial_state?: Json;
          allowed_commands?: Json;
          states?: Json;
          transitions?: Json;
          hints?: Json;
          root_cause?: string | null;
          repair_action?: string | null;
          verification?: Json;
          scoring_rules?: Json;
          is_published?: boolean;
        };
        Relationships: [];
      };
      troubleshooting_attempts: {
        Row: {
          id: string;
          user_id: string;
          scenario_id: string;
          current_state: Json;
          commands_run: Json;
          hints_used: number;
          diagnosis: string | null;
          attempted_fix: string | null;
          verification_result: Json | null;
          root_cause_identified: boolean;
          resolved: boolean;
          score: number | null;
          started_at: string;
          completed_at: string | null;
        };
        Insert: {
          id?: string;
          user_id: string;
          scenario_id: string;
          current_state?: Json;
          commands_run?: Json;
          hints_used?: number;
          diagnosis?: string | null;
          attempted_fix?: string | null;
          verification_result?: Json | null;
          root_cause_identified?: boolean;
          resolved?: boolean;
          score?: number | null;
          started_at?: string;
          completed_at?: string | null;
        };
        Update: {
          current_state?: Json;
          commands_run?: Json;
          hints_used?: number;
          diagnosis?: string | null;
          attempted_fix?: string | null;
          verification_result?: Json | null;
          root_cause_identified?: boolean;
          resolved?: boolean;
          score?: number | null;
          completed_at?: string | null;
        };
        Relationships: [];
      };
      projects: {
        Row: {
          id: string;
          slug: string;
          title: string;
          description: string | null;
          difficulty: Difficulty | null;
          estimated_minutes: number | null;
          prerequisites: Json;
          deliverables: Json;
          acceptance_criteria: Json;
          is_published: boolean;
        };
        Insert: {
          id?: string;
          slug: string;
          title: string;
          description?: string | null;
          difficulty?: Difficulty | null;
          estimated_minutes?: number | null;
          prerequisites?: Json;
          deliverables?: Json;
          acceptance_criteria?: Json;
          is_published?: boolean;
        };
        Update: {
          slug?: string;
          title?: string;
          description?: string | null;
          difficulty?: Difficulty | null;
          estimated_minutes?: number | null;
          prerequisites?: Json;
          deliverables?: Json;
          acceptance_criteria?: Json;
          is_published?: boolean;
        };
        Relationships: [];
      };
      project_skills: {
        Row: { project_id: string; skill_id: string };
        Insert: { project_id: string; skill_id: string };
        Update: Record<string, never>;
        Relationships: [];
      };
      project_requirements: {
        Row: {
          id: string;
          project_id: string;
          requirement: string;
          sort_order: number;
        };
        Insert: {
          id?: string;
          project_id: string;
          requirement: string;
          sort_order?: number;
        };
        Update: { requirement?: string; sort_order?: number };
        Relationships: [];
      };
      user_project_progress: {
        Row: {
          user_id: string;
          project_id: string;
          status: ProjectStatus;
          progress: number;
          submission: Json | null;
          updated_at: string;
        };
        Insert: {
          user_id: string;
          project_id: string;
          status?: ProjectStatus;
          progress?: number;
          submission?: Json | null;
          updated_at?: string;
        };
        Update: {
          status?: ProjectStatus;
          progress?: number;
          submission?: Json | null;
          updated_at?: string;
        };
        Relationships: [];
      };
      /**
       * NOTE: user_skill_progress has NO INSERT/UPDATE policy for learners.
       * All writes must use getAdminClient().
       */
      user_skill_progress: {
        Row: {
          user_id: string;
          skill_id: string;
          knowledge_score: number;
          practice_score: number;
          troubleshooting_score: number;
          project_score: number;
          retention_score: number;
          mastery_score: number;
          mastery_state: MasteryState;
          confidence: number;
          attempt_count: number;
          last_activity_at: string | null;
          last_reviewed_at: string | null;
          updated_at: string;
        };
        Insert: {
          user_id: string;
          skill_id: string;
          knowledge_score?: number;
          practice_score?: number;
          troubleshooting_score?: number;
          project_score?: number;
          retention_score?: number;
          mastery_score?: number;
          mastery_state?: MasteryState;
          confidence?: number;
          attempt_count?: number;
          last_activity_at?: string | null;
          last_reviewed_at?: string | null;
          updated_at?: string;
        };
        Update: {
          knowledge_score?: number;
          practice_score?: number;
          troubleshooting_score?: number;
          project_score?: number;
          retention_score?: number;
          mastery_score?: number;
          mastery_state?: MasteryState;
          confidence?: number;
          attempt_count?: number;
          last_activity_at?: string | null;
          last_reviewed_at?: string | null;
          updated_at?: string;
        };
        Relationships: [];
      };
      mastery_evidence: {
        Row: {
          id: string;
          user_id: string;
          skill_id: string;
          evidence_type: EvidenceType;
          source_id: string | null;
          score: number;
          metadata: Json;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          skill_id: string;
          evidence_type: EvidenceType;
          source_id?: string | null;
          score: number;
          metadata?: Json;
          created_at?: string;
        };
        Update: {
          score?: number;
          metadata?: Json;
        };
        Relationships: [];
      };
      learning_sessions: {
        Row: {
          id: string;
          user_id: string;
          started_at: string;
          ended_at: string | null;
          duration_seconds: number | null;
          source_type: string | null;
          source_id: string | null;
        };
        Insert: {
          id?: string;
          user_id: string;
          started_at?: string;
          ended_at?: string | null;
          duration_seconds?: number | null;
          source_type?: string | null;
          source_id?: string | null;
        };
        Update: {
          ended_at?: string | null;
          duration_seconds?: number | null;
          source_type?: string | null;
          source_id?: string | null;
        };
        Relationships: [];
      };
      daily_missions: {
        Row: {
          id: string;
          user_id: string;
          mission_date: string;
          duration_minutes: number;
          title: string;
          objective: string | null;
          context: string | null;
          tasks: Json;
          hints: Json;
          success_criteria: Json;
          reflection: string | null;
          recommendation_reason: string | null;
          status: MissionStatus;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          mission_date: string;
          duration_minutes: number;
          title: string;
          objective?: string | null;
          context?: string | null;
          tasks?: Json;
          hints?: Json;
          success_criteria?: Json;
          reflection?: string | null;
          recommendation_reason?: string | null;
          status?: MissionStatus;
          created_at?: string;
        };
        Update: {
          duration_minutes?: number;
          title?: string;
          objective?: string | null;
          context?: string | null;
          tasks?: Json;
          hints?: Json;
          success_criteria?: Json;
          reflection?: string | null;
          recommendation_reason?: string | null;
          status?: MissionStatus;
        };
        Relationships: [];
      };
      mission_task_progress: {
        Row: {
          user_id: string;
          mission_id: string;
          task_key: string;
          completed: boolean;
          notes: string | null;
          completed_at: string | null;
        };
        Insert: {
          user_id: string;
          mission_id: string;
          task_key: string;
          completed?: boolean;
          notes?: string | null;
          completed_at?: string | null;
        };
        Update: {
          completed?: boolean;
          notes?: string | null;
          completed_at?: string | null;
        };
        Relationships: [];
      };
      notes: {
        Row: {
          id: string;
          user_id: string;
          title: string;
          content_markdown: string;
          tags: Json;
          skill_id: string | null;
          lesson_id: string | null;
          scenario_id: string | null;
          project_id: string | null;
          pinned: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          title: string;
          content_markdown?: string;
          tags?: Json;
          skill_id?: string | null;
          lesson_id?: string | null;
          scenario_id?: string | null;
          project_id?: string | null;
          pinned?: boolean;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          title?: string;
          content_markdown?: string;
          tags?: Json;
          skill_id?: string | null;
          lesson_id?: string | null;
          scenario_id?: string | null;
          project_id?: string | null;
          pinned?: boolean;
          updated_at?: string;
        };
        Relationships: [];
      };
      ai_conversations: {
        Row: {
          id: string;
          user_id: string;
          mode: AIMode;
          title: string | null;
          context: Json;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          mode: AIMode;
          title?: string | null;
          context?: Json;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          mode?: AIMode;
          title?: string | null;
          context?: Json;
          updated_at?: string;
        };
        Relationships: [];
      };
      ai_messages: {
        Row: {
          id: string;
          conversation_id: string;
          role: "user" | "assistant" | "system";
          content: string;
          metadata: Json;
          created_at: string;
        };
        Insert: {
          id?: string;
          conversation_id: string;
          role: "user" | "assistant" | "system";
          content: string;
          metadata?: Json;
          created_at?: string;
        };
        Update: {
          content?: string;
          metadata?: Json;
        };
        Relationships: [];
      };
    };
    Views: Record<string, never>;
    Functions: Record<string, never>;
    Enums: Record<string, never>;
    CompositeTypes: Record<string, never>;
  };
}

// Convenience row types
export type Profile = Database["public"]["Tables"]["profiles"]["Row"];
export type Domain = Database["public"]["Tables"]["domains"]["Row"];
export type Skill = Database["public"]["Tables"]["skills"]["Row"];
export type SkillPrerequisite = Database["public"]["Tables"]["skill_prerequisites"]["Row"];
export type Lesson = Database["public"]["Tables"]["lessons"]["Row"];
export type LessonSection = Database["public"]["Tables"]["lesson_sections"]["Row"];
export type UserLessonProgress = Database["public"]["Tables"]["user_lesson_progress"]["Row"];
export type PracticeTask = Database["public"]["Tables"]["practice_tasks"]["Row"];
export type PracticeAttempt = Database["public"]["Tables"]["practice_attempts"]["Row"];
export type QuizQuestion = Database["public"]["Tables"]["quiz_questions"]["Row"];
export type QuizOption = Database["public"]["Tables"]["quiz_options"]["Row"];
export type QuizAttempt = Database["public"]["Tables"]["quiz_attempts"]["Row"];
export type TroubleshootingScenario = Database["public"]["Tables"]["troubleshooting_scenarios"]["Row"];
export type TroubleshootingAttempt = Database["public"]["Tables"]["troubleshooting_attempts"]["Row"];
export type Project = Database["public"]["Tables"]["projects"]["Row"];
export type ProjectSkill = Database["public"]["Tables"]["project_skills"]["Row"];
export type ProjectRequirement = Database["public"]["Tables"]["project_requirements"]["Row"];
export type UserProjectProgress = Database["public"]["Tables"]["user_project_progress"]["Row"];
export type UserSkillProgress = Database["public"]["Tables"]["user_skill_progress"]["Row"];
export type MasteryEvidence = Database["public"]["Tables"]["mastery_evidence"]["Row"];
export type LearningSession = Database["public"]["Tables"]["learning_sessions"]["Row"];
export type DailyMission = Database["public"]["Tables"]["daily_missions"]["Row"];
export type MissionTaskProgress = Database["public"]["Tables"]["mission_task_progress"]["Row"];
export type Note = Database["public"]["Tables"]["notes"]["Row"];
export type AIConversation = Database["public"]["Tables"]["ai_conversations"]["Row"];
export type AIMessage = Database["public"]["Tables"]["ai_messages"]["Row"];
