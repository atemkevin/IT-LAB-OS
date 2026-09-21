import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

/**
 * Public paths that do NOT require authentication.
 */
const PUBLIC_PATHS = [
  "/login",
  "/register",
  "/forgot-password",
  "/reset-password",
  "/auth/callback",
  "/api/health",
  "/portfolio",
  "/icon",
  "/apple-icon",
  "/manifest.webmanifest",
];

/**
 * Paths that must be excluded from middleware processing entirely.
 * /api/integrations is NOT bypassed — those routes authenticate via
 * X-Integration-Key (see lib/api/integration-auth.ts), not the user session.
 */
const BYPASS_PATHS = ["/_next", "/favicon.ico", "/public"];

function isPublicPath(pathname: string): boolean {
  return PUBLIC_PATHS.some(
    (p) => pathname === p || pathname.startsWith(p + "/"),
  );
}

function isBypassPath(pathname: string): boolean {
  return BYPASS_PATHS.some((p) => pathname.startsWith(p));
}

export async function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // Skip middleware for static assets and bypass paths
  if (isBypassPath(pathname)) {
    return NextResponse.next();
  }

  let response = NextResponse.next({
    request,
  });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet: Array<{ name: string; value: string; options?: any }>) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value),
          );
          response = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options),
          );
        },
      },
    },
  );

  // Refresh session (this also validates the session token).
  // Integrations authenticate via a header, not a session cookie, so we don't
  // require a user for /api/integrations/* — the route handler itself
  // verifies the X-Integration-Key header.
  const isIntegrationRoute = pathname.startsWith("/api/integrations");
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const isAuthenticated = !!user;

  // Redirect authenticated users away from public auth pages
  if (
    isAuthenticated &&
    (pathname === "/login" || pathname === "/register" || pathname === "/forgot-password")
  ) {
    return NextResponse.redirect(new URL("/dashboard", request.url));
  }

  // Redirect unauthenticated users to login (skip integration routes)
  if (!isAuthenticated && !isPublicPath(pathname) && !isIntegrationRoute) {
    const loginUrl = new URL("/login", request.url);
    loginUrl.searchParams.set("redirectTo", pathname);
    return NextResponse.redirect(new URL(loginUrl, request.url));
  }

  return response;
}

export const config = {
  matcher: [
    /*
     * Match all request paths except:
     * - _next/static (static files)
     * - _next/image (image optimization)
     * - favicon.ico
     * - Public files in /public folder (*.png, *.jpg, etc.)
     */
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
