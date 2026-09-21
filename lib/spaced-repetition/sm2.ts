/**
 * lib/spaced-repetition/sm2.ts
 *
 * Implementation of the SuperMemo-2 (SM-2) Spaced Repetition Algorithm.
 * Tracks memory consolidation, calculates intervals and easiness factors,
 * and models memory retention decay over time.
 */

export interface SM2State {
  /** Number of consecutive successful recalls (grade >= 3) */
  repetitionCount: number;
  /** Current interval in days until the next scheduled review */
  intervalDays: number;
  /** Easiness factor (measure of item difficulty, minimum 1.3, initial 2.5) */
  easinessFactor: number;
}

export interface SM2ReviewResult extends SM2State {
  /** Grade received (0-5) */
  grade: number;
  /** Calculated retention score (0-100) after this review */
  retentionScore: number;
  /** Target timestamp for the next review */
  nextReviewDue: Date;
}

/**
 * Maps a percentage score (0-100, e.g. from a quiz) to an SM-2 grade (0-5).
 */
export function scoreToSM2Grade(scorePercentage: number): number {
  if (scorePercentage >= 90) return 5; // Perfect recall
  if (scorePercentage >= 75) return 4; // Good recall with minor hesitation
  if (scorePercentage >= 60) return 3; // Pass with difficulty
  if (scorePercentage >= 40) return 2; // Incorrect, but remembered upon seeing answer
  if (scorePercentage >= 20) return 1; // Incorrect, familiar
  return 0; // Complete blackout
}

/**
 * Calculates the next SM-2 review state based on user recall grade (0-5).
 *
 * Rules:
 * 1. EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
 * 2. EF' is clamped to minimum 1.3
 * 3. If q >= 3 (successful recall):
 *    - repetition 0 -> interval = 1 day
 *    - repetition 1 -> interval = 6 days
 *    - repetition n -> interval = round(previous_interval * EF)
 *    - repetitionCount increments
 * 4. If q < 3 (failed recall):
 *    - repetitionCount resets to 0
 *    - interval resets to 1 day
 *
 * @param current - Current SM-2 state
 * @param grade - Quality score 0-5
 * @param reviewDate - Date of review (defaults to now)
 */
export function calculateSM2(
  current: SM2State,
  grade: number,
  reviewDate: Date = new Date()
): SM2ReviewResult {
  const q = Math.max(0, Math.min(5, Math.round(grade)));
  const currentEF = current.easinessFactor ?? 2.5;
  const currentInterval = Math.max(1, current.intervalDays ?? 1);
  const currentRepetition = Math.max(0, current.repetitionCount ?? 0);

  // 1. Calculate new Easiness Factor (EF)
  const efDelta = 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02);
  const newEF = Math.max(1.3, Math.round((currentEF + efDelta) * 100) / 100);

  // 2. Calculate new interval and repetition count
  let newRepetition: number;
  let newInterval: number;

  if (q >= 3) {
    // Successful recall
    if (currentRepetition === 0) {
      newInterval = 1;
    } else if (currentRepetition === 1) {
      newInterval = 6;
    } else {
      newInterval = Math.max(1, Math.round(currentInterval * newEF));
    }
    newRepetition = currentRepetition + 1;
  } else {
    // Recall failure — reset cycle
    newRepetition = 0;
    newInterval = 1;
  }

  // 3. Calculate target next review date
  const nextReviewDue = new Date(reviewDate.getTime() + newInterval * 24 * 60 * 60 * 1000);

  // 4. Calculate fresh retention score (0-100)
  // Grade 5 = 100%, Grade 4 = 85%, Grade 3 = 70%, Grade 2 = 40%, Grade 1 = 20%, Grade 0 = 10%
  const retentionScore = calculateFreshRetention(q, newRepetition);

  return {
    repetitionCount: newRepetition,
    intervalDays: newInterval,
    easinessFactor: newEF,
    grade: q,
    retentionScore,
    nextReviewDue,
  };
}

function calculateFreshRetention(grade: number, repetitionCount: number): number {
  if (grade === 5) return 100;
  if (grade === 4) return Math.min(95, 80 + repetitionCount * 3);
  if (grade === 3) return Math.min(85, 65 + repetitionCount * 2);
  if (grade === 2) return 40;
  if (grade === 1) return 25;
  return 10;
}

/**
 * Calculates decayed retention score based on the Ebbinghaus forgetting curve.
 *
 * Formula:
 * R(t) = max(10, min(100, round(initialRetention * exp(-0.4 * (daysElapsed / intervalDays)))))
 *
 * @param initialRetention - Retention score immediately after last review (0-100)
 * @param intervalDays - Scheduled interval in days
 * @param lastReviewedAt - Timestamp of last review
 * @param asOfDate - Evaluation date (defaults to now)
 */
export function calculateDecayedRetention(
  initialRetention: number,
  intervalDays: number,
  lastReviewedAt: Date,
  asOfDate: Date = new Date()
): number {
  const elapsedMs = Math.max(0, asOfDate.getTime() - lastReviewedAt.getTime());
  const elapsedDays = elapsedMs / (24 * 60 * 60 * 1000);
  const interval = Math.max(1, intervalDays);

  // Decay factor: at t == interval, retention falls to ~67% of initial. At 2*interval, ~45%.
  const decayRate = 0.4;
  const retentionFraction = Math.exp(-decayRate * (elapsedDays / interval));
  const decayed = Math.round(initialRetention * retentionFraction);

  return Math.max(10, Math.min(100, decayed));
}

/**
 * Checks whether an item is currently due for review.
 */
export function isReviewDue(nextReviewDue: Date, asOfDate: Date = new Date()): boolean {
  return nextReviewDue.getTime() <= asOfDate.getTime();
}
