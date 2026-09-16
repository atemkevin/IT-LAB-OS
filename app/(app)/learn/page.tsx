import { createClient } from "@/lib/supabase/server";
import { getDomainsWithSkills } from "@/lib/learning/skills";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import Link from "next/link";
import { BookOpen, Lock, ChevronRight } from "lucide-react";

const DOMAIN_ICONS: Record<string, string> = {
  "computer-fundamentals": "🖥️",
  "operating-systems": "⚙️",
  "networking": "🌐",
  "linux": "🐧",
  "windows-ad": "🪟",
  "python-automation": "🐍",
  "cybersecurity": "🔒",
  "web-security": "🛡️",
  "cloud": "☁️",
  "docker-devops": "🐳",
  "ai-automation": "🤖",
  "specialization": "⭐",
};

export default async function LearnPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  const domains = await getDomainsWithSkills(user?.id ?? null);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">
          Learning Path
        </h1>
        <p className="text-sm text-[var(--color-text-tertiary)]">
          Structured curriculum across {domains.length} IT and engineering domains.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
        {domains.map((d, i) => {
          const icon = DOMAIN_ICONS[d.domain.slug] ?? "📚";
          const hasSkills = d.totalSkills > 0;

          return (
            <Card
              key={d.domain.id}
              className="hover:border-[var(--color-brand)]/50 transition-colors flex flex-col justify-between"
            >
              <CardHeader>
                <div className="flex items-center justify-between">
                  <span className="text-xs font-mono text-[var(--color-brand)]">
                    Domain {String(d.domain.sort_order ?? i + 1).padStart(2, "0")}
                  </span>
                  <span className="text-lg">{icon}</span>
                </div>
                <CardTitle className="mt-2 text-base">{d.domain.name}</CardTitle>
                {d.domain.description && (
                  <CardDescription className="text-xs">
                    {d.domain.description}
                  </CardDescription>
                )}
              </CardHeader>
              <CardContent className="space-y-3">
                {/* Progress bar */}
                {hasSkills && (
                  <div className="space-y-1">
                    <div className="flex justify-between text-xs text-[var(--color-text-tertiary)]">
                      <span>{d.completedSkills}/{d.totalSkills} skills</span>
                      <span>{d.progressPercent}%</span>
                    </div>
                    <div className="h-1.5 w-full rounded-full bg-[var(--color-surface-elevated)]">
                      <div
                        className="h-1.5 rounded-full bg-[var(--color-brand)]"
                        style={{ width: `${d.progressPercent}%` }}
                      />
                    </div>
                  </div>
                )}

                <Link
                  href={`/skills?domain=${d.domain.slug}`}
                  className="inline-flex items-center gap-1.5 text-xs font-medium text-[var(--color-brand)] hover:underline"
                >
                  <BookOpen className="h-3.5 w-3.5" />
                  <span>
                    Explore {d.totalSkills} Skill{d.totalSkills !== 1 ? "s" : ""} →
                  </span>
                </Link>
              </CardContent>
            </Card>
          );
        })}
      </div>
    </div>
  );
}