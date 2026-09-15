# IT Lab OS — Recommendation Engine

## Purpose
Determine the learner's next best action, not just the next course page.

## Inputs
- skill mastery
- skill dimensions
- prerequisites
- recent failures
- recent activity
- review due date
- primary career goal
- unfinished work
- available study minutes

## Priority model
Use a configurable weighted score. Initial suggestion:
weakness 0.30
prerequisite importance 0.25
recent failure 0.20
review due 0.15
goal relevance 0.10

Normalize each factor to 0–100. Return reason codes plus human-readable explanation.

## Output
`{ actionType, targetId, priority, reason, estimatedMinutes }`

## Principles
- Prefer weak prerequisites blocking important skills.
- Repeated failure increases review priority.
- Strong skills should require less repetitive basic work.
- Respect the user's available study duration.
- Never recommend a skill whose prerequisites are completely unavailable unless the recommendation is explicitly a prerequisite action.
