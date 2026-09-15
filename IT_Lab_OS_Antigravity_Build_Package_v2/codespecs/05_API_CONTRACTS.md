# IT Lab OS — API Contracts

## General rules
All protected endpoints authenticate the current session. User identity comes from the server session. Validate all request bodies with Zod. Return structured JSON. Do not return secrets or internal errors.

## Lessons
POST `/api/lessons/{id}/complete`
Body: `{}` or lesson-specific completion payload.
Returns: updated lesson progress + relevant mastery update.

## Quizzes
POST `/api/quizzes/{id}/submit`
Body: `{ answers: Record<string, string[]> }`
Returns: score, correctness summary, explanations, evidence id, updated mastery. Correct answers are only evaluated server-side.

## Practice
POST `/api/practice/{id}/submit`
Body: `{ submission: unknown, notes?: string }`
Returns: score, passed, feedback, updated mastery.

## Missions
GET `/api/missions/today`
POST `/api/missions/{id}/start`
POST `/api/missions/{id}/complete`

## Troubleshooting
POST `/api/troubleshooting/{id}/start`
POST `/api/troubleshooting/{id}/command` Body: `{ attemptId: string, command: string }`
POST `/api/troubleshooting/{id}/hint` Body: `{ attemptId: string }`
POST `/api/troubleshooting/{id}/finish` Body: `{ attemptId: string, diagnosis?: string, attemptedFix?: string }`

## AI
POST `/api/ai/chat`
Body: `{ conversationId?: string, mode: 'tutor'|'coach'|'troubleshooter'|'interviewer'|'reviewer', message: string, context?: { skillId?: string; lessonId?: string; scenarioId?: string } }`

## Progress
GET `/api/progress`
GET `/api/mastery`

## Integrations
GET `/api/integrations/daily-mission`
GET `/api/integrations/progress`
GET `/api/integrations/weak-skills`
POST `/api/integrations/events`
Integration auth is required.

## Error format
`{ error: { code: string, message: string } }`
Standard codes: UNAUTHORIZED, FORBIDDEN, VALIDATION_ERROR, NOT_FOUND, CONFLICT, RATE_LIMITED, AI_ERROR, INTERNAL_ERROR.
