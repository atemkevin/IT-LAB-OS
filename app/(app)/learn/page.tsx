import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import Link from "next/link";
import { BookOpen } from "lucide-react";

export default function LearnPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">
          Learning Path
        </h1>
        <p className="text-sm text-[var(--color-text-tertiary)]">
          Structured curriculum across 12 IT and Engineering domains.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
        <Card className="hover:border-[var(--color-brand)]/50 transition-colors">
          <CardHeader>
            <div className="flex items-center justify-between">
              <span className="text-xs font-mono text-[var(--color-brand)]">Domain 01</span>
              <Badge variant="difficulty-beginner">Beginner</Badge>
            </div>
            <CardTitle className="mt-2">Linux & Systems Administration</CardTitle>
            <CardDescription>
              Core shell commands, permissions, processes, and service management.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Link
              href="/skills"
              className="inline-flex items-center gap-1.5 text-xs font-medium text-[var(--color-brand)] hover:underline"
            >
              <BookOpen className="h-3.5 w-3.5" />
              <span>Explore 3 Skills →</span>
            </Link>
          </CardContent>
        </Card>

        <Card className="hover:border-[var(--color-brand)]/50 transition-colors">
          <CardHeader>
            <div className="flex items-center justify-between">
              <span className="text-xs font-mono text-[var(--color-brand)]">Domain 02</span>
              <Badge variant="difficulty-beginner">Beginner</Badge>
            </div>
            <CardTitle className="mt-2">Networking Fundamentals</CardTitle>
            <CardDescription>
              TCP/IP, subnetting, DNS, routing, firewall rules, and traffic analysis.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Link
              href="/skills"
              className="inline-flex items-center gap-1.5 text-xs font-medium text-[var(--color-brand)] hover:underline"
            >
              <BookOpen className="h-3.5 w-3.5" />
              <span>Explore 3 Skills →</span>
            </Link>
          </CardContent>
        </Card>

        <Card className="hover:border-[var(--color-brand)]/50 transition-colors">
          <CardHeader>
            <div className="flex items-center justify-between">
              <span className="text-xs font-mono text-[var(--color-brand)]">Domain 03</span>
              <Badge variant="difficulty-intermediate">Intermediate</Badge>
            </div>
            <CardTitle className="mt-2">Security & Identity</CardTitle>
            <CardDescription>
              Authentication, TLS/SSL, PKI, least privilege, and defensive auditing.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Link
              href="/skills"
              className="inline-flex items-center gap-1.5 text-xs font-medium text-[var(--color-brand)] hover:underline"
            >
              <BookOpen className="h-3.5 w-3.5" />
              <span>Explore 2 Skills →</span>
            </Link>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
