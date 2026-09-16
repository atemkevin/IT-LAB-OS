import { NextResponse } from "next/server";

/**
 * GET /api/health
 *
 * Public health check endpoint. Used by monitoring and middleware
 * to verify the application is responsive.
 */
export async function GET() {
  return NextResponse.json(
    {
      status: "ok",
      timestamp: new Date().toISOString(),
      service: "it-lab-os",
    },
    { status: 200 }
  );
}
