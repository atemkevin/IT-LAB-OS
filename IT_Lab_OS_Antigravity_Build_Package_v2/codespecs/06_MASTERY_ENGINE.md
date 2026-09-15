# IT Lab OS — Mastery Engine Specification

## Formula
mastery = knowledge*0.30 + practice*0.20 + troubleshooting*0.25 + project*0.15 + retention*0.10

## State function
0–29 Not Started
30–49 Developing
50–69 Practicing
70–84 Proficient
85–100 Strong

## Evidence sources
lesson, practice, quiz, troubleshooting, project, retention, mission.

## Calculation requirements
- Clamp each dimension to 0–100.
- Clamp overall mastery to 0–100.
- Calculate on server only.
- Persist evidence for every material change.
- Update timestamps and attempt counts transactionally where possible.
- Do not let a single quiz or lesson overwrite unrelated dimensions.

## Example
knowledge=80, practice=70, troubleshooting=60, project=50, retention=75 => 67.5.

## Suggested file layout
lib/mastery/calculateMastery.ts
lib/mastery/calculateState.ts
lib/mastery/recordEvidence.ts
lib/mastery/updateSkillMastery.ts
lib/mastery/types.ts
