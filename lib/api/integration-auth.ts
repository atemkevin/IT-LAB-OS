/**
 * lib/api/integration-auth.ts
 *
 * Shared auth helper for /api/integrations/* endpoints.
 * Validates the X-Integration-Key header against env INTEGRATION_API_KEY
 * using a constant-time comparison to prevent timing attacks.
 *
 * Returns null on success, or a NextResponse 401 on failure.
 */
import { NextResponse } from "next/server";
import { timingSafeEqual } from "node:crypto";

export const INTEGRATION_HEADER = "x-integration-key";

/**
 * Verify the integration API key on the incoming request.
 * Treats the env as authoritative — if absent, denies everything.
 */
export function verifyIntegrationKey(
  headerValue: string | null,
): NextResponse | null {
  const expected = process.env.INTEGRATION_API_KEY;
  if (!expected) {
    return NextResponse.json(
      { error: { code: "INTERNAL_ERROR", message: "Integration auth not configured" } },
      { status: 503 },
    );
  }
  if (!headerValue) {
    return NextResponse.json(
      { error: { code: "UNAUTHORIZED", message: "Missing integration key" } },
      { status: 401 },
    );
  }
  const a = Buffer.from(expected, "utf8");
  const b = Buffer.from(headerValue, "utf8");
  if (a.length !== b.length || !timingSafeEqual(a, b)) {
    return NextResponse.json(
      { error: { code: "UNAUTHORIZED", message: "Invalid integration key" } },
      { status: 401 },
    );
  }
  return null;
}
