"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { createClient } from "@/lib/supabase/client";
import { registerSchema } from "@/lib/auth/schemas";

export default function RegisterPage() {
  const router = useRouter();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [infoMessage, setInfoMessage] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setInfoMessage(null);

    // Validate client-side
    const parsed = registerSchema.safeParse({ email, password, confirmPassword });
    if (!parsed.success) {
      setError(parsed.error.errors[0]?.message || "Invalid registration form");
      return;
    }

    setLoading(true);

    try {
      const supabase = createClient();
      const { data, error: signUpError } = await supabase.auth.signUp({
        email,
        password,
        options: {
          emailRedirectTo: `${window.location.origin}/auth/callback?redirectTo=/onboarding`,
        },
      });

      if (signUpError) {
        setError(signUpError.message);
      } else if (data.session) {
        // Auto-confirmed or existing session
        router.push("/onboarding");
        router.refresh();
      } else {
        setInfoMessage(
          "Registration successful! Please check your email to confirm your account and begin onboarding.",
        );
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
        <CardTitle className="text-xl">Create Account</CardTitle>
        <CardDescription>
          Begin your engineering mastery journey with IT Lab OS
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          {error && (
            <div className="rounded-lg border border-[var(--color-negative)]/30 bg-[var(--color-negative-soft)] p-3 text-xs text-[var(--color-negative)]">
              {error}
            </div>
          )}
          {infoMessage && (
            <div className="rounded-lg border border-[var(--color-positive)]/30 bg-[var(--color-positive-soft)] p-3 text-xs text-[var(--color-positive)]">
              {infoMessage}
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
            <Label htmlFor="password">Password</Label>
            <Input
              id="password"
              type="password"
              autoComplete="new-password"
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Min. 8 chars, 1 uppercase, 1 number"
            />
            <p className="mt-1 text-[11px] text-[var(--color-text-tertiary)]">
              Must be at least 8 characters with at least one number and uppercase letter.
            </p>
          </div>

          <div>
            <Label htmlFor="confirm-password">Confirm Password</Label>
            <Input
              id="confirm-password"
              type="password"
              autoComplete="new-password"
              required
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              placeholder="Repeat your password"
            />
          </div>

          <Button type="submit" className="w-full" disabled={loading}>
            {loading ? "Creating Account..." : "Create Account"}
          </Button>

          <div className="text-center pt-2">
            <span className="text-xs text-[var(--color-text-tertiary)]">
              Already have an account?{" "}
              <Link href="/login" className="text-[var(--color-brand)] hover:underline font-medium">
                Sign in
              </Link>
            </span>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}
