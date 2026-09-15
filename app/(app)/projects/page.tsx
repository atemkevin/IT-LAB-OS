import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Badge, DifficultyBadge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { FolderGit2 } from "lucide-react";

export default function ProjectsPage() {
  const projects = [
    {
      slug: "hardened-bastion-host",
      title: "Hardened Bastion Host Setup",
      difficulty: "intermediate" as const,
      description: "Provision and harden an SSH gateway with fail2ban, key-only auth, and rate limits.",
      skills: ["Linux Navigation", "SSH Hardening", "Firewall Rules"],
    },
    {
      slug: "automated-backup-pipeline",
      title: "Automated Off-site Backup Script",
      difficulty: "beginner" as const,
      description: "Write a resilient Bash script that snapshots database dumps, encrypts with GPG, and rotates.",
      skills: ["Bash Scripting", "Cron Scheduling", "GPG Encryption"],
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">Hands-on Projects</h1>
        <p className="text-sm text-[var(--color-text-tertiary)]">
          Real-world infrastructure and software delivery deliverables to validate senior competency.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
        {projects.map((p) => (
          <Card key={p.slug} className="flex flex-col justify-between">
            <CardHeader>
              <div className="flex items-center justify-between">
                <DifficultyBadge difficulty={p.difficulty} />
                <Badge variant="brand">15% Mastery Weight</Badge>
              </div>
              <CardTitle className="mt-3 text-lg">{p.title}</CardTitle>
              <CardDescription>{p.description}</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex flex-wrap gap-1.5">
                {p.skills.map((s) => (
                  <span
                    key={s}
                    className="rounded bg-[var(--color-surface-raised)] px-2 py-0.5 text-[10px] text-[var(--color-text-secondary)]"
                  >
                    {s}
                  </span>
                ))}
              </div>
              <Button variant="outline" className="w-full">
                <FolderGit2 className="h-4 w-4" />
                View Project Brief
              </Button>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
