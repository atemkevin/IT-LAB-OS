/**
 * tests/unit/integration-auth.test.ts
 *
 * Unit tests for the X-Integration-Key verification helper.
 * Constant-time comparison + env-missing denial + header-missing denial.
 */
import { describe, it, expect, beforeEach, afterEach } from "vitest";
import { verifyIntegrationKey, INTEGRATION_HEADER } from "@/lib/api/integration-auth";

const VALID = "test_integration_key_abc123";

describe("verifyIntegrationKey", () => {
  const original = process.env.INTEGRATION_API_KEY;

  beforeEach(() => {
    process.env.INTEGRATION_API_KEY = VALID;
  });
  afterEach(() => {
    if (original === undefined) delete process.env.INTEGRATION_API_KEY;
    else process.env.INTEGRATION_API_KEY = original;
  });

  it("returns null when the key matches", () => {
    expect(verifyIntegrationKey(VALID)).toBeNull();
  });

  it("rejects an empty header", () => {
    const res = verifyIntegrationKey("");
    expect(res?.status).toBe(401);
  });

  it("rejects a null header", () => {
    const res = verifyIntegrationKey(null);
    expect(res?.status).toBe(401);
  });

  it("rejects a wrong-length key", () => {
    const res = verifyIntegrationKey("short");
    expect(res?.status).toBe(401);
  });

  it("rejects a same-length but incorrect key", () => {
    // Same length as VALID (24 chars) but different
    const res = verifyIntegrationKey("test_integration_key_xyz789");
    expect(res?.status).toBe(401);
  });

  it("returns 503 when env is not configured", () => {
    delete process.env.INTEGRATION_API_KEY;
    const res = verifyIntegrationKey(VALID);
    expect(res?.status).toBe(503);
  });

  it("exports the expected header constant", () => {
    expect(INTEGRATION_HEADER).toBe("x-integration-key");
  });
});
