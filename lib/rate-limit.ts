/**
 * lib/rate-limit.ts
 *
 * Simple in-memory rate limiter for API routes.
 * Sufficient for a single-user / small-scale application.
 * For production scale, replace with Redis or Upstash.
 */

interface RateLimitEntry {
  count: number;
  resetAt: number; // timestamp ms
}

const store = new Map<string, RateLimitEntry>();

const CLEANUP_INTERVAL_MS = 60_000; // 1 minute

let nextCleanup = Date.now() + CLEANUP_INTERVAL_MS;

// Lazy cleanup to prevent memory leaks without using setInterval,
// which causes issues in Serverless environments and Next.js HMR.
function cleanup(now: number) {
  for (const [key, entry] of store.entries()) {
    if (entry.resetAt < now) {
      store.delete(key);
    }
  }
  nextCleanup = now + CLEANUP_INTERVAL_MS;
}

export interface RateLimitResult {
  success: boolean;
  limit: number;
  remaining: number;
  resetAt: number;
}

/**
 * Check and increment a rate limit bucket.
 *
 * @param key - Unique identifier (e.g., `user:${userId}:quiz`)
 * @param limit - Max requests allowed in the window
 * @param windowMs - Time window in milliseconds
 */
export function rateLimit(key: string, limit: number, windowMs: number): RateLimitResult {
  const now = Date.now();

  // Perform lazy cleanup if interval has passed
  if (now > nextCleanup) {
    cleanup(now);
  }

  const entry = store.get(key);

  if (!entry || entry.resetAt < now) {
    // New window
    const newEntry: RateLimitEntry = { count: 1, resetAt: now + windowMs };
    store.set(key, newEntry);
    return {
      success: true,
      limit,
      remaining: limit - 1,
      resetAt: newEntry.resetAt,
    };
  }

  if (entry.count >= limit) {
    return {
      success: false,
      limit,
      remaining: 0,
      resetAt: entry.resetAt,
    };
  }

  entry.count += 1;
  return {
    success: true,
    limit,
    remaining: limit - entry.count,
    resetAt: entry.resetAt,
  };
}
