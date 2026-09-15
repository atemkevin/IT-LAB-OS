# IT Lab OS — Test Specification

## Unit tests
1. Mastery formula returns expected weighted score.
2. Mastery clamps scores to 0–100.
3. Mastery states map correctly at boundaries.
4. Quiz scoring handles single and multi-select.
5. Recommendation weights normalize correctly.
6. Troubleshooting state transitions are deterministic.
7. Hint penalties reduce score.
8. Mission selection respects time budget.

## Integration tests
1. Authenticated user can read published curriculum.
2. User A cannot read User B progress.
3. Completing a lesson updates lesson progress.
4. Quiz submission persists attempt and evidence.
5. Mastery updates after evidence.
6. Mission progress persists.
7. Troubleshooting commands are simulated, not executed by OS.
8. AI endpoint works without exposing the key.
9. Notes CRUD respects user isolation.
10. Project progress respects user isolation.

## Security tests
- Direct client update of mastery is rejected.
- Direct access to another user's rows is rejected.
- Unpublished content is unavailable to ordinary learners.
- Quiz answers are not exposed pre-submission.
- Protected API routes reject unauthenticated requests.
- Integration routes reject missing/invalid tokens.
- Upload validation rejects unsupported file types and oversized files.

## E2E
Register → Onboarding → Dashboard → Skill → Lesson → Quiz → Mission → Troubleshooting → AI Mentor → Notes → Progress.

## Acceptance
No phase is complete if its relevant tests fail or if verification was skipped.
