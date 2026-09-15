import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Badge, DifficultyBadge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Terminal, CheckCircle2 } from "lucide-react";

export default function LabsPage() {
  const scenarios = [
    {
      slug: "dns-failure",
      title: "DNS Resolution Failure",
      difficulty: "beginner" as const,
      description: "A web service cannot reach api.internal. Identify the malformed resolv.conf entry.",
    },
    {
      slug: "nginx-stopped",
      title: "Web Service Crash Loop",
      difficulty: "intermediate" as const,
      description: "Nginx fails on boot due to port 80 conflict with Apache. Trace and free the socket.",
    },
    {
      slug: "disk-full",
      title: "Root Partition Exhaustion",
      difficulty: "beginner" as const,
      description: "Logs filling /var/log/journal. Find large files and clean without breaking services.",
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">Troubleshooting Labs</h1>
        <p className="text-sm text-[var(--color-text-tertiary)]">
          Deterministic incident response drills. Simulated environments, zero infrastructure risk.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
        {scenarios.map((s) => (
          <Card key={s.slug} className="flex flex-col justify-between">
            <CardHeader>
              <div className="flex items-center justify-between">
                <DifficultyBadge difficulty={s.difficulty} />
                <Badge variant="default">Simulated</Badge>
              </div>
              <CardTitle className="mt-3 text-base">{s.title}</CardTitle>
              <CardDescription>{s.description}</CardDescription>
            </CardHeader>
            <CardContent className="pt-2">
              <Button variant="secondary" className="w-full">
                <Terminal className="h-4 w-4" />
                Launch Terminal
              </Button>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
