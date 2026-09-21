"use client";

import { useState, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { createClient } from "@/lib/supabase/client";

function sanitizeRedirect(url: string | null): string {
  if (!url) return "/dashboard";
  if (url.startsWith("/") && !url.startsWith("//")) {
    return url;
  }
  return "/dashboard";
}

function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const redirectTo = sanitizeRedirect(searchParams.get("redirectTo"));

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const supabase = createClient();
      const { data, error: signInError } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (signInError) {
        setError(signInError.message);
      } else if (data.user) {
        // Check onboarding status
        const { data: profile } = await supabase
          .from("profiles")
          .select("onboarding_done")
          .eq("id", data.user.id)
          .maybeSingle();

        if (!profile || !profile.onboarding_done) {
          router.push("/onboarding");
        } else {
          router.push(redirectTo);
        }
        router.refresh();
      }
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : "An unexpected error occurred");
    } finally {
      setLoading(false);
    }
  }

  return (
    <Card className="w-full">
      <CardHeader className="text-center">
        <div className="mx-auto mb-2 flex h-10 w-10 items-center justify-center rounded-xl bg-[var(--color-brand)]">
          <span className="text-base font-bold text-white">IT</span>
        </div>
        <h1 className="text-xl font-semibold text-[var(--color-text-primary)]">Sign In</h1>
        <CardDescription>
          Access your personalized IT Lab OS workspace
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          {error && (
            <div className="rounded-lg border border-[var(--color-negative)]/30 bg-[var(--color-negative-soft)] p-3 text-xs text-[var(--color-negative)]">
              {error}
            </div>
          )}

          <div>
            <Label htmlFor="email">Email Address</Label>
            <Input
              id="email"
              type="email"
              autoComplete="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="you@example.com"
            />
          </div>

          <div>
            <div className="flex items-center justify-between">
              <Label htmlFor="password">Password</Label>
              <Link
                href="/forgot-password"
                className="text-[11px] text-[var(--color-brand)] hover:underline"
              >
                Forgot password?
              </Link>
            </div>
            <Input
              id="password"
              type="password"
              autoComplete="current-password"
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
            />
          </div>

          <Button type="submit" className="w-full" disabled={loading}>
            {loading ? "Signing in..." : "Sign In"}
          </Button>

          <div className="text-center pt-2">
            <span className="text-xs text-[var(--color-text-tertiary)]">
              Don&apos;t have an account?{" "}
              <Link href="/register" className="text-[var(--color-brand)] hover:underline font-medium">
                Create account
              </Link>
            </span>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}

export default function LoginPage() {
  return (
    <Suspense fallback={<div className="text-center text-xs text-[var(--color-text-tertiary)]">Loading...</div>}>
      <LoginForm />
    </Suspense>
  );
}
