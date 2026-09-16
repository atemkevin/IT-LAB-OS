/**
 * /projects — Hands-on Projects
 * Server Component. Fetches published projects with associated skills.
 */
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Badge, DifficultyBadge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { FolderGit2 } from "lucide-react";
import type { Project, Skill, UserProjectProgress, Difficulty } from "@/lib/database.types";

interface ProjectWithSkills extends Project {
  skills?: Skill[];
}

export default async function ProjectsPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  const [projectsRes, progressRes] = await Promise.all([
    supabase
      .from("projects")
      .select("*")
      .eq("is_published", true)
      .order("difficulty", { ascending: true }),
    user
      ? supabase
          .from("user_project_progress")
          .select("*")
          .eq("user_id", user.id)
      : Promise.resolve({ data: null, error: null }),
  ]);

  const projects = (projectsRes.data ?? []) as Project[];
  const progressMap = new Map<string, UserProjectProgress>(
    (progressRes.data ?? []).map((p: UserProjectProgress) => [p.project_id, p]),
  );

  // Fetch skills for all projects in one query
  const projectIds = projects.map((p) => p.id);
  const { data: projectSkills } = projectIds.length
    ? await supabase
        .from("project_skills")
        .select("project_id, skill_id")
        .in("project_id", projectIds)
    : { data: [] };

  const skillIds = Array.from(
    new Set((projectSkills ?? []).map((ps: { skill_id: string }) => ps.skill_id)),
  );
  const { data: skills } = skillIds.length
    ? await supabase.from("skills").select("id, name").in("id", skillIds)
    : { data: [] };

  const skillMap = new Map<string, string>(
    (skills ?? []).map((s: { id: string; name: string }) => [s.id, s.name]),
  );

  // Group skills by project
  const skillsByProject = new Map<string, string[]>();
  for (const ps of projectSkills ?? []) {
    const list = skillsByProject.get(ps.project_id) ?? [];
    const name = skillMap.get(ps.skill_id);
    if (name) list.push(name);
    skillsByProject.set(ps.project_id, list);
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">Hands-on Projects</h1>
        <p className="text-sm text-[var(--color-text-tertiary)]">
          Real-world infrastructure and software delivery deliverables to validate senior competency.
        </p>
      </div>

      {projects.length === 0 ? (
        <div className="text-center py-12">
          <FolderGit2 className="h-12 w-12 text-[var(--color-text-disabled)] mx-auto mb-3" />
          <p className="text-sm text-[var(--color-text-tertiary)]">No projects published yet.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
          {projects.map((p) => {
            const progress = progressMap.get(p.id);
            const projectSkills = skillsByProject.get(p.id) ?? [];
            return (
              <Card key={p.id} className="flex flex-col justify-between">
                <CardHeader>
                  <div className="flex items-center justify-between">
                    <DifficultyBadge difficulty={(p.difficulty as Difficulty) ?? "intermediate"} />
                    {progress ? (
                      <Badge variant={progress.status === "completed" ? "positive" : "brand"}>
                        {progress.status.replace("_", " ")}
                      </Badge>
                    ) : (
                      <Badge variant="default">15% Mastery Weight</Badge>
                    )}
                  </div>
                  <CardTitle className="mt-3 text-lg">{p.title}</CardTitle>
                  <CardDescription>{p.description}</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  {projectSkills.length > 0 && (
                    <div className="flex flex-wrap gap-1.5">
                      {projectSkills.map((s) => (
                        <span
                          key={s}
                          className="rounded bg-[var(--color-surface-raised)] px-2 py-0.5 text-[10px] text-[var(--color-text-secondary)]"
                        >
                          {s}
                        </span>
                      ))}
                    </div>
                  )}
                  {progress && (
                    <div className="flex items-center gap-2">
                      <div className="h-1.5 flex-1 rounded-full bg-[var(--color-surface-raised)]">
                        <div
                          className="h-1.5 rounded-full bg-[var(--color-brand)]"
                          style={{ width: `${progress.progress}%` }}
                        />
                      </div>
                      <span className="text-[10px] text-[var(--color-text-tertiary)]">
                        {progress.progress}%
                      </span>
                    </div>
                  )}
                  <Link href={`/projects/${p.slug}`}>
                    <Button variant="outline" className="w-full">
                      <FolderGit2 className="h-4 w-4" />
                      {progress ? "Continue Project" : "View Project Brief"}
                    </Button>
                  </Link>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}
