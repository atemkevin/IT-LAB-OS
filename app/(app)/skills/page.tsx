import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Badge, MasteryBadge, DifficultyBadge } from "@/components/ui/badge";
import Link from "next/link";
import { ArrowRight } from "lucide-react";

export default function SkillsPage() {
  const sampleSkills = [
    {
      slug: "linux-navigation-permissions",
      name: "Linux Navigation & File Permissions",
      domain: "Linux & Systems",
      difficulty: "beginner" as const,
      masteryState: "not_started" as const,
      score: 0,
      description: "Understand paths, chmod, chown, umask, and directory trees safely.",
    },
    {
      slug: "dns-troubleshooting",
      name: "DNS Resolution & Troubleshooting",
      domain: "Networking Fundamentals",
      difficulty: "intermediate" as const,
      masteryState: "not_started" as const,
      score: 0,
      description: "Diagnose resolution failures using dig, nslookup, and /etc/hosts.",
    },
    {
      slug: "ssh-key-authentication",
      name: "SSH Hardening & Key Authentication",
      domain: "Security & Identity",
      difficulty: "beginner" as const,
      masteryState: "not_started" as const,
      score: 0,
      description: "Generate ed25519 keys, configure sshd_config, disable root password login.",
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">Skills Matrix</h1>
        <p className="text-sm text-[var(--color-text-tertiary)]">
          Master skills across Knowledge, Practice, Labs, Projects, and Retention.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
        {sampleSkills.map((skill) => (
          <Card key={skill.slug} className="flex flex-col justify-between">
            <CardHeader>
              <div className="flex items-center justify-between gap-2">
                <span className="text-xs font-medium text-[var(--color-text-tertiary)]">
                  {skill.domain}
                </span>
                <DifficultyBadge difficulty={skill.difficulty} />
              </div>
              <CardTitle className="mt-2 text-base">{skill.name}</CardTitle>
              <CardDescription>{skill.description}</CardDescription>
            </CardHeader>
            <CardContent className="pt-2">
              <div className="flex items-center justify-between border-t border-[var(--color-border)] pt-3">
                <MasteryBadge state={skill.masteryState} />
                <Link
                  href={`/skills/${skill.slug}`}
                  className="inline-flex items-center gap-1 text-xs font-medium text-[var(--color-brand)] hover:underline"
                >
                  <span>Practice</span>
                  <ArrowRight className="h-3 w-3" />
                </Link>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
