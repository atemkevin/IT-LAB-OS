# IT Lab OS — Database Specification

## Core tables
profiles
domains
skills
skill_prerequisites
lessons
lesson_sections
user_lesson_progress
practice_tasks
practice_attempts
quiz_questions
quiz_options
quiz_attempts
troubleshooting_scenarios
troubleshooting_attempts
projects
project_skills
project_requirements
user_project_progress
user_skill_progress
mastery_evidence
learning_sessions
daily_missions
mission_task_progress
notes
ai_conversations
ai_messages

## Optional/future
notifications
achievements
user_achievements
lab_templates
lab_instances
lab_sessions
lab_events
lab_results

## Key rules
- profiles.id references auth.users(id)
- User-owned tables are isolated with auth.uid() RLS policies.
- Published canonical content is readable by authenticated learners.
- Mastery score fields are system-controlled.
- Correct quiz answers are server-only during attempts.
- Service role is never exposed to the browser.

## user_skill_progress authoritative fields
knowledge_score
practice_score
troubleshooting_score
project_score
retention_score
mastery_score
mastery_state
confidence
attempt_count
last_activity_at
last_reviewed_at

## evidence
Every meaningful learning event creates mastery_evidence with evidence_type, source_id, skill_id, score, and metadata.

## Indexes
Index foreign keys and frequent user-scoped queries: user_id, skill_id, domain_id, lesson_id, mission_id, scenario_id, project_id, created_at. Use composite indexes for common user + entity lookups.
