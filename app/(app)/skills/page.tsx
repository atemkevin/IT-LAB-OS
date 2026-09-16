import { createClient } from "@/lib/supabase/server";
import { getDomainsWithSkills } from "@/lib/learning/skills";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Badge, MasteryBadge, DifficultyBadge } from "@/components/ui/badge";
import Link from "next/link";
import { ArrowRight, Search } from "lucide-react";

interface Props {
  searchParams: Promise<{ domain?: string; difficulty?: string; q?: string }>;
}

export default async function SkillsPage({ searchParams }: Props) {
  const { domain: domainFilter, difficulty: diffFilter, q: query } = await searchParams;

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  const domains = await getDomainsWithSkills(user?.id ?? null);

  // Flatten all skills
  const allSkills = domains.flatMap((d) => d.skills);

  // Apply filters
  const filtered = allSkills.filter((skill) => {
    if (domainFilter && skill.domain.slug !== domainFilter) return false;
    if (diffFilter && skill.difficulty !== diffFilter) return false;
    if (query) {
      const q = query.toLowerCase();
      return (
        skill.name.toLowerCase().includes(q) ||
        (skill.description ?? "").toLowerCase().includes(q)
      );
    }
    return true;
  });

  // Group filtered skills by domain
  const grouped = new Map<string, typeof filtered>();
  for (const skill of filtered) {
    const key = skill.domain.id;
    const list = grouped.get(key) ?? [];
    list.push(skill);
    grouped.set(key, list);
  }

  const domainGroups = domains
    .filter((d) => grouped.has(d.domain.id))
    .map((d) => ({ domain: d.domain, skills: grouped.get(d.domain.id) ?? [] }));

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">Skills Matrix</h1>
        <p className="text-sm text-[var(--color-text-tertiary)]">
          Master skills across Knowledge, Practice, Labs, Projects, and Retention.
        </p>
      </div>

      {/* Filter row */}
      <div className="flex flex-wrap gap-2 items-center text-xs">
        <Link href="/skills" className={`px-3 py-1 rounded-full border ${!domainFilter ? "bg-[var(--color-brand)] text-white border-transparent" : "border-[var(--color-border)] text-[var(--color-text-secondary)] hover:border-[var(--color-brand)]"}`}>
          All Domains
        </Link>
        {domains.filter((d) => d.totalSkills > 0).map((d) => (
          <Link
            key={d.domain.slug}
            href={`/skills?domain=${d.domain.slug}`}
            className={`px-3 py-1 rounded-full border truncate max-w-[200px] ${domainFilter === d.domain.slug ? "bg-[var(--color-brand)] text-white border-transparent" : "border-[var(--color-border)] text-[var(--color-text-secondary)] hover:border-[var(--color-brand)]"}`}
          >
            {d.domain.name}
          </Link>
        ))}
      </div>

      {/* Stats */}
      <p className="text-xs text-[var(--color-text-tertiary)]">
        Showing {filtered.length} skills
      </p>

      {/* Domain groups */}
      {domainGroups.length === 0 ? (
        <div className="rounded-lg border border-[var(--color-border)] p-8 text-center">
          <p className="text-sm text-[var(--color-text-tertiary)]">No skills found.</p>
        </div>
      ) : (
        domainGroups.map(({ domain, skills }) => (
          <div key={domain.id} className="space-y-3">
            <h2 className="text-sm font-semibold text-[var(--color-text-secondary)] uppercase tracking-wide">
              {domain.name}
            </h2>
            <div className="grid grid-cols-1 gap-3 md:grid-cols-2 lg:grid-cols-3">
              {skills.map((skill) => (
                <Card key={skill.slug} className="flex flex-col justify-between">
                  <CardHeader className="pb-2">
                    <div className="flex items-center justify-between gap-2">
                      <DifficultyBadge difficulty={skill.difficulty as "beginner" | "intermediate" | "advanced"} />
                      <MasteryBadge state={skill.accessState === "locked" ? "not_started" : (skill.userProgress?.mastery_state as "not_started" | "developing" | "practicing" | "proficient" | "strong" ?? "not_started")} />
                    </div>
                    <CardTitle className="mt-2 text-sm leading-snug">{skill.name}</CardTitle>
                    {skill.description && (
                      <CardDescription className="text-xs line-clamp-2">
                        {skill.description}
                      </CardDescription>
                    )}
                  </CardHeader>
                  <CardContent className="pt-0">
                    <div className="flex items-center justify-between border-t border-[var(--color-border)] pt-3">
                      <span className="text-xs text-[var(--color-text-tertiary)]">
                        {skill.estimated_minutes}min
                      </span>
                      {skill.accessState === "locked" ? (
                        <span className="text-xs text-[var(--color-text-tertiary)]">🔒 Locked</span>
                      ) : (
                        <Link
                          href={`/skills/${skill.slug}`}
                          className="inline-flex items-center gap-1 text-xs font-medium text-[var(--color-brand)] hover:underline"
                        >
                          <span>Open</span>
                          <ArrowRight className="h-3 w-3" />
                        </Link>
                      )}
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>
        ))
      )}
    </div>
  );
}