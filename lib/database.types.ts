export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      ai_conversations: {
        Row: {
          context: Json
          created_at: string
          id: string
          mode: string
          title: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          context?: Json
          created_at?: string
          id?: string
          mode: string
          title?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          context?: Json
          created_at?: string
          id?: string
          mode?: string
          title?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      ai_messages: {
        Row: {
          content: string
          conversation_id: string
          created_at: string
          id: string
          metadata: Json
          role: string
        }
        Insert: {
          content: string
          conversation_id: string
          created_at?: string
          id?: string
          metadata?: Json
          role: string
        }
        Update: {
          content?: string
          conversation_id?: string
          created_at?: string
          id?: string
          metadata?: Json
          role?: string
        }
        Relationships: [
          {
            foreignKeyName: "ai_messages_conversation_id_fkey"
            columns: ["conversation_id"]
            isOneToOne: false
            referencedRelation: "ai_conversations"
            referencedColumns: ["id"]
          },
        ]
      }
      daily_missions: {
        Row: {
          context: string | null
          created_at: string
          duration_minutes: number
          hints: Json
          id: string
          mission_date: string
          objective: string | null
          recommendation_reason: string | null
          reflection: string | null
          status: string
          success_criteria: Json
          tasks: Json
          title: string
          user_id: string
        }
        Insert: {
          context?: string | null
          created_at?: string
          duration_minutes: number
          hints?: Json
          id?: string
          mission_date: string
          objective?: string | null
          recommendation_reason?: string | null
          reflection?: string | null
          status?: string
          success_criteria?: Json
          tasks?: Json
          title: string
          user_id: string
        }
        Update: {
          context?: string | null
          created_at?: string
          duration_minutes?: number
          hints?: Json
          id?: string
          mission_date?: string
          objective?: string | null
          recommendation_reason?: string | null
          reflection?: string | null
          status?: string
          success_criteria?: Json
          tasks?: Json
          title?: string
          user_id?: string
        }
        Relationships: []
      }
      domains: {
        Row: {
          created_at: string
          description: string | null
          icon: string | null
          id: string
          is_published: boolean
          name: string
          slug: string
          sort_order: number
        }
        Insert: {
          created_at?: string
          description?: string | null
          icon?: string | null
          id?: string
          is_published?: boolean
          name: string
          slug: string
          sort_order?: number
        }
        Update: {
          created_at?: string
          description?: string | null
          icon?: string | null
          id?: string
          is_published?: boolean
          name?: string
          slug?: string
          sort_order?: number
        }
        Relationships: []
      }
      learning_sessions: {
        Row: {
          duration_seconds: number | null
          ended_at: string | null
          id: string
          source_id: string | null
          source_type: string | null
          started_at: string
          user_id: string
        }
        Insert: {
          duration_seconds?: number | null
          ended_at?: string | null
          id?: string
          source_id?: string | null
          source_type?: string | null
          started_at?: string
          user_id: string
        }
        Update: {
          duration_seconds?: number | null
          ended_at?: string | null
          id?: string
          source_id?: string | null
          source_type?: string | null
          started_at?: string
          user_id?: string
        }
        Relationships: []
      }
      lesson_sections: {
        Row: {
          content_markdown: string | null
          id: string
          lesson_id: string
          section_type: string
          sort_order: number
          title: string | null
        }
        Insert: {
          content_markdown?: string | null
          id?: string
          lesson_id: string
          section_type: string
          sort_order?: number
          title?: string | null
        }
        Update: {
          content_markdown?: string | null
          id?: string
          lesson_id?: string
          section_type?: string
          sort_order?: number
          title?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "lesson_sections_lesson_id_fkey"
            columns: ["lesson_id"]
            isOneToOne: false
            referencedRelation: "lessons"
            referencedColumns: ["id"]
          },
        ]
      }
      lessons: {
        Row: {
          content_markdown: string | null
          created_at: string
          difficulty: string | null
          estimated_minutes: number | null
          id: string
          is_published: boolean
          skill_id: string
          slug: string
          sort_order: number
          summary: string | null
          title: string
        }
        Insert: {
          content_markdown?: string | null
          created_at?: string
          difficulty?: string | null
          estimated_minutes?: number | null
          id?: string
          is_published?: boolean
          skill_id: string
          slug: string
          sort_order?: number
          summary?: string | null
          title: string
        }
        Update: {
          content_markdown?: string | null
          created_at?: string
          difficulty?: string | null
          estimated_minutes?: number | null
          id?: string
          is_published?: boolean
          skill_id?: string
          slug?: string
          sort_order?: number
          summary?: string | null
          title?: string
        }
        Relationships: [
          {
            foreignKeyName: "lessons_skill_id_fkey"
            columns: ["skill_id"]
            isOneToOne: false
            referencedRelation: "skills"
            referencedColumns: ["id"]
          },
        ]
      }
      mastery_evidence: {
        Row: {
          created_at: string
          evidence_type: string
          id: string
          metadata: Json
          score: number
          skill_id: string
          source_id: string | null
          user_id: string
        }
        Insert: {
          created_at?: string
          evidence_type: string
          id?: string
          metadata?: Json
          score: number
          skill_id: string
          source_id?: string | null
          user_id: string
        }
        Update: {
          created_at?: string
          evidence_type?: string
          id?: string
          metadata?: Json
          score?: number
          skill_id?: string
          source_id?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "mastery_evidence_skill_id_fkey"
            columns: ["skill_id"]
            isOneToOne: false
            referencedRelation: "skills"
            referencedColumns: ["id"]
          },
        ]
      }
      mission_task_progress: {
        Row: {
          completed: boolean
          completed_at: string | null
          mission_id: string
          notes: string | null
          task_key: string
          user_id: string
        }
        Insert: {
          completed?: boolean
          completed_at?: string | null
          mission_id: string
          notes?: string | null
          task_key: string
          user_id: string
        }
        Update: {
          completed?: boolean
          completed_at?: string | null
          mission_id?: string
          notes?: string | null
          task_key?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "mission_task_progress_mission_id_fkey"
            columns: ["mission_id"]
            isOneToOne: false
            referencedRelation: "daily_missions"
            referencedColumns: ["id"]
          },
        ]
      }
      notes: {
        Row: {
          content_markdown: string
          created_at: string
          id: string
          lesson_id: string | null
          pinned: boolean
          project_id: string | null
          scenario_id: string | null
          skill_id: string | null
          tags: Json
          title: string
          updated_at: string
          user_id: string
        }
        Insert: {
          content_markdown?: string
          created_at?: string
          id?: string
          lesson_id?: string | null
          pinned?: boolean
          project_id?: string | null
          scenario_id?: string | null
          skill_id?: string | null
          tags?: Json
          title: string
          updated_at?: string
          user_id: string
        }
        Update: {
          content_markdown?: string
          created_at?: string
          id?: string
          lesson_id?: string | null
          pinned?: boolean
          project_id?: string | null
          scenario_id?: string | null
          skill_id?: string | null
          tags?: Json
          title?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "notes_lesson_id_fkey"
            columns: ["lesson_id"]
            isOneToOne: false
            referencedRelation: "lessons"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notes_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notes_scenario_id_fkey"
            columns: ["scenario_id"]
            isOneToOne: false
            referencedRelation: "troubleshooting_scenarios"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notes_skill_id_fkey"
            columns: ["skill_id"]
            isOneToOne: false
            referencedRelation: "skills"
            referencedColumns: ["id"]
          },
        ]
      }
      practice_attempts: {
        Row: {
          created_at: string
          feedback: string | null
          id: string
          passed: boolean | null
          practice_task_id: string
          score: number | null
          skill_id: string | null
          submission: Json | null
          user_id: string
        }
        Insert: {
          created_at?: string
          feedback?: string | null
          id?: string
          passed?: boolean | null
          practice_task_id: string
          score?: number | null
          skill_id?: string | null
          submission?: Json | null
          user_id: string
        }
        Update: {
          created_at?: string
          feedback?: string | null
          id?: string
          passed?: boolean | null
          practice_task_id?: string
          score?: number | null
          skill_id?: string | null
          submission?: Json | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "practice_attempts_practice_task_id_fkey"
            columns: ["practice_task_id"]
            isOneToOne: false
            referencedRelation: "practice_tasks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "practice_attempts_skill_id_fkey"
            columns: ["skill_id"]
            isOneToOne: false
            referencedRelation: "skills"
            referencedColumns: ["id"]
          },
        ]
      }
      practice_tasks: {
        Row: {
          context: string | null
          evidence_keys: Json
          hints: Json
          id: string
          is_published: boolean
          objective: string | null
          requirements: Json
          skill_id: string
          success_criteria: Json
          title: string
        }
        Insert: {
          context?: string | null
          evidence_keys?: Json
          hints?: Json
          id?: string
          is_published?: boolean
          objective?: string | null
          requirements?: Json
          skill_id: string
          success_criteria?: Json
          title: string
        }
        Update: {
          context?: string | null
          evidence_keys?: Json
          hints?: Json
          id?: string
          is_published?: boolean
          objective?: string | null
          requirements?: Json
          skill_id?: string
          success_criteria?: Json
          title?: string
        }
        Relationships: [
          {
            foreignKeyName: "practice_tasks_skill_id_fkey"
            columns: ["skill_id"]
            isOneToOne: false
            referencedRelation: "skills"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          avatar_url: string | null
          created_at: string
          current_streak: number
          daily_minutes: number | null
          display_name: string | null
          environment: Json | null
          experience_level: string | null
          id: string
          last_activity_date: string | null
          longest_streak: number
          onboarding_done: boolean
          primary_goal: string | null
          updated_at: string
        }
        Insert: {
          avatar_url?: string | null
          created_at?: string
          current_streak?: number
          daily_minutes?: number | null
          display_name?: string | null
          environment?: Json | null
          experience_level?: string | null
          id: string
          last_activity_date?: string | null
          longest_streak?: number
          onboarding_done?: boolean
          primary_goal?: string | null
          updated_at?: string
        }
        Update: {
          avatar_url?: string | null
          created_at?: string
          current_streak?: number
          daily_minutes?: number | null
          display_name?: string | null
          environment?: Json | null
          experience_level?: string | null
          id?: string
          last_activity_date?: string | null
          longest_streak?: number
          onboarding_done?: boolean
          primary_goal?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      project_requirements: {
        Row: {
          id: string
          project_id: string
          requirement: string
          sort_order: number
        }
        Insert: {
          id?: string
          project_id: string
          requirement: string
          sort_order?: number
        }
        Update: {
          id?: string
          project_id?: string
          requirement?: string
          sort_order?: number
        }
        Relationships: [
          {
            foreignKeyName: "project_requirements_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      project_skills: {
        Row: {
          project_id: string
          skill_id: string
        }
        Insert: {
          project_id: string
          skill_id: string
        }
        Update: {
          project_id?: string
          skill_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "project_skills_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "project_skills_skill_id_fkey"
            columns: ["skill_id"]
            isOneToOne: false
            referencedRelation: "skills"
            referencedColumns: ["id"]
          },
        ]
      }
      projects: {
        Row: {
          acceptance_criteria: Json
          deliverables: Json
          description: string | null
          difficulty: string | null
          estimated_minutes: number | null
          id: string
          is_published: boolean
          prerequisites: Json
          slug: string
          title: string
        }
        Insert: {
          acceptance_criteria?: Json
          deliverables?: Json
          description?: string | null
          difficulty?: string | null
          estimated_minutes?: number | null
          id?: string
          is_published?: boolean
          prerequisites?: Json
          slug: string
          title: string
        }
        Update: {
          acceptance_criteria?: Json
          deliverables?: Json
          description?: string | null
          difficulty?: string | null
          estimated_minutes?: number | null
          id?: string
          is_published?: boolean
          prerequisites?: Json
          slug?: string
          title?: string
        }
        Relationships: []
      }
      quiz_attempts: {
        Row: {
          answers: Json
          correct_count: number | null
          created_at: string
          id: string
          question_count: number | null
          score: number
          skill_id: string
          user_id: string
        }
        Insert: {
          answers: Json
          correct_count?: number | null
          created_at?: string
          id?: string
          question_count?: number | null
          score: number
          skill_id: string
          user_id: string
        }
        Update: {
          answers?: Json
          correct_count?: number | null
          created_at?: string
          id?: string
          question_count?: number | null
          score?: number
          skill_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "quiz_attempts_skill_id_fkey"
            columns: ["skill_id"]
            isOneToOne: false
            referencedRelation: "skills"
            referencedColumns: ["id"]
          },
        ]
      }
      quiz_options: {
        Row: {
          id: string
          is_correct: boolean
          option_text: string
          question_id: string
          sort_order: number
        }
        Insert: {
          id?: string
          is_correct?: boolean
          option_text: string
          question_id: string
          sort_order?: number
        }
        Update: {
          id?: string
          is_correct?: boolean
          option_text?: string
          question_id?: string
          sort_order?: number
        }
        Relationships: [
          {
            foreignKeyName: "quiz_options_question_id_fkey"
            columns: ["question_id"]
            isOneToOne: false
            referencedRelation: "quiz_questions"
            referencedColumns: ["id"]
          },
        ]
      }
      quiz_questions: {
        Row: {
          explanation: string | null
          id: string
          is_published: boolean
          prompt: string
          question_type: string
          skill_id: string
          sort_order: number
        }
        Insert: {
          explanation?: string | null
          id?: string
          is_published?: boolean
          prompt: string
          question_type?: string
          skill_id: string
          sort_order?: number
        }
        Update: {
          explanation?: string | null
          id?: string
          is_published?: boolean
          prompt?: string
          question_type?: string
          skill_id?: string
          sort_order?: number
        }
        Relationships: [
          {
            foreignKeyName: "quiz_questions_skill_id_fkey"
            columns: ["skill_id"]
            isOneToOne: false
            referencedRelation: "skills"
            referencedColumns: ["id"]
          },
        ]
      }
      skill_prerequisites: {
        Row: {
          prerequisite_skill_id: string
          required_mastery: number
          skill_id: string
        }
        Insert: {
          prerequisite_skill_id: string
          required_mastery?: number
          skill_id: string
        }
        Update: {
          prerequisite_skill_id?: string
          required_mastery?: number
          skill_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "skill_prerequisites_prerequisite_skill_id_fkey"
            columns: ["prerequisite_skill_id"]
            isOneToOne: false
            referencedRelation: "skills"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "skill_prerequisites_skill_id_fkey"
            columns: ["skill_id"]
            isOneToOne: false
            referencedRelation: "skills"
            referencedColumns: ["id"]
          },
        ]
      }
      skills: {
        Row: {
          created_at: string
          description: string | null
          difficulty: string
          domain_id: string
          estimated_minutes: number
          id: string
          is_published: boolean
          learning_objectives: Json
          name: string
          slug: string
          sort_order: number
          tags: Json
          why_it_matters: string | null
        }
        Insert: {
          created_at?: string
          description?: string | null
          difficulty?: string
          domain_id: string
          estimated_minutes?: number
          id?: string
          is_published?: boolean
          learning_objectives?: Json
          name: string
          slug: string
          sort_order?: number
          tags?: Json
          why_it_matters?: string | null
        }
        Update: {
          created_at?: string
          description?: string | null
          difficulty?: string
          domain_id?: string
          estimated_minutes?: number
          id?: string
          is_published?: boolean
          learning_objectives?: Json
          name?: string
          slug?: string
          sort_order?: number
          tags?: Json
          why_it_matters?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "skills_domain_id_fkey"
            columns: ["domain_id"]
            isOneToOne: false
            referencedRelation: "domains"
            referencedColumns: ["id"]
          },
        ]
      }
      troubleshooting_attempts: {
        Row: {
          attempted_fix: string | null
          commands_run: Json
          completed_at: string | null
          current_state: Json
          diagnosis: string | null
          hints_used: number
          id: string
          resolved: boolean
          root_cause_identified: boolean
          scenario_id: string
          score: number | null
          started_at: string
          user_id: string
          verification_result: Json | null
        }
        Insert: {
          attempted_fix?: string | null
          commands_run?: Json
          completed_at?: string | null
          current_state?: Json
          diagnosis?: string | null
          hints_used?: number
          id?: string
          resolved?: boolean
          root_cause_identified?: boolean
          scenario_id: string
          score?: number | null
          started_at?: string
          user_id: string
          verification_result?: Json | null
        }
        Update: {
          attempted_fix?: string | null
          commands_run?: Json
          completed_at?: string | null
          current_state?: Json
          diagnosis?: string | null
          hints_used?: number
          id?: string
          resolved?: boolean
          root_cause_identified?: boolean
          scenario_id?: string
          score?: number | null
          started_at?: string
          user_id?: string
          verification_result?: Json | null
        }
        Relationships: [
          {
            foreignKeyName: "troubleshooting_attempts_scenario_id_fkey"
            columns: ["scenario_id"]
            isOneToOne: false
            referencedRelation: "troubleshooting_scenarios"
            referencedColumns: ["id"]
          },
        ]
      }
      troubleshooting_scenarios: {
        Row: {
          allowed_commands: Json
          description: string | null
          difficulty: string | null
          hints: Json
          id: string
          initial_state: Json
          is_published: boolean
          repair_action: string | null
          root_cause: string | null
          scoring_rules: Json
          skill_id: string | null
          slug: string
          states: Json
          title: string
          transitions: Json
          verification: Json
        }
        Insert: {
          allowed_commands?: Json
          description?: string | null
          difficulty?: string | null
          hints?: Json
          id?: string
          initial_state?: Json
          is_published?: boolean
          repair_action?: string | null
          root_cause?: string | null
          scoring_rules?: Json
          skill_id?: string | null
          slug: string
          states?: Json
          title: string
          transitions?: Json
          verification?: Json
        }
        Update: {
          allowed_commands?: Json
          description?: string | null
          difficulty?: string | null
          hints?: Json
          id?: string
          initial_state?: Json
          is_published?: boolean
          repair_action?: string | null
          root_cause?: string | null
          scoring_rules?: Json
          skill_id?: string | null
          slug?: string
          states?: Json
          title?: string
          transitions?: Json
          verification?: Json
        }
        Relationships: [
          {
            foreignKeyName: "troubleshooting_scenarios_skill_id_fkey"
            columns: ["skill_id"]
            isOneToOne: false
            referencedRelation: "skills"
            referencedColumns: ["id"]
          },
        ]
      }
      user_activity_logs: {
        Row: {
          activity_date: string
          activity_type: string
          created_at: string
          details: Json | null
          id: string
          user_id: string
        }
        Insert: {
          activity_date?: string
          activity_type: string
          created_at?: string
          details?: Json | null
          id?: string
          user_id: string
        }
        Update: {
          activity_date?: string
          activity_type?: string
          created_at?: string
          details?: Json | null
          id?: string
          user_id?: string
        }
        Relationships: []
      }
      user_lesson_progress: {
        Row: {
          completed_at: string | null
          lesson_id: string
          progress: number
          started_at: string | null
          status: string
          updated_at: string
          user_id: string
        }
        Insert: {
          completed_at?: string | null
          lesson_id: string
          progress?: number
          started_at?: string | null
          status?: string
          updated_at?: string
          user_id: string
        }
        Update: {
          completed_at?: string | null
          lesson_id?: string
          progress?: number
          started_at?: string | null
          status?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_lesson_progress_lesson_id_fkey"
            columns: ["lesson_id"]
            isOneToOne: false
            referencedRelation: "lessons"
            referencedColumns: ["id"]
          },
        ]
      }
      user_project_progress: {
        Row: {
          progress: number
          project_id: string
          status: string
          submission: Json | null
          updated_at: string
          user_id: string
        }
        Insert: {
          progress?: number
          project_id: string
          status?: string
          submission?: Json | null
          updated_at?: string
          user_id: string
        }
        Update: {
          progress?: number
          project_id?: string
          status?: string
          submission?: Json | null
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_project_progress_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      user_skill_progress: {
        Row: {
          attempt_count: number
          confidence: number
          knowledge_score: number
          last_activity_at: string | null
          last_reviewed_at: string | null
          mastery_score: number
          mastery_state: string
          practice_score: number
          project_score: number
          retention_score: number
          skill_id: string
          troubleshooting_score: number
          updated_at: string
          user_id: string
        }
        Insert: {
          attempt_count?: number
          confidence?: number
          knowledge_score?: number
          last_activity_at?: string | null
          last_reviewed_at?: string | null
          mastery_score?: number
          mastery_state?: string
          practice_score?: number
          project_score?: number
          retention_score?: number
          skill_id: string
          troubleshooting_score?: number
          updated_at?: string
          user_id: string
        }
        Update: {
          attempt_count?: number
          confidence?: number
          knowledge_score?: number
          last_activity_at?: string | null
          last_reviewed_at?: string | null
          mastery_score?: number
          mastery_state?: string
          practice_score?: number
          project_score?: number
          retention_score?: number
          skill_id?: string
          troubleshooting_score?: number
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_skill_progress_skill_id_fkey"
            columns: ["skill_id"]
            isOneToOne: false
            referencedRelation: "skills"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export type MasteryState = "not_started" | "developing" | "practicing" | "proficient" | "strong";
export type Difficulty = "beginner" | "intermediate" | "advanced";
export type LessonStatus = "not_started" | "in_progress" | "completed";
export type EvidenceType = "lesson" | "quiz" | "practice" | "troubleshooting" | "project";
export type QuestionType = "single" | "multi" | "scenario";

// Convenience table row aliases
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

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {},
  },
} as const

export type Note = Database["public"]["Tables"]["notes"]["Row"];
export type AIConversation = Database["public"]["Tables"]["ai_conversations"]["Row"];
export type AIMessage = Database["public"]["Tables"]["ai_messages"]["Row"];


