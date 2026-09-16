/**
 * /projects/[slug] — Project Detail
 * Server Component. Shows project brief, requirements, deliverables, acceptance criteria, and progress.
 */
import { notFound } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { getAdminClient } from "@/lib/supabase/admin";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Badge, DifficultyBadge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ArrowLeft, CheckCircle2, Circle, Clock, FolderGit2 } from "lucide-react";
import ProjectActionClient from "./project-action-client";
import type { Difficulty, Project, ProjectRequirement } from "@/lib/database.types";

export default async function ProjectDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  const admin = getAdminClient();

  // Fetch project first to get the ID
  const { data: projectData } = await admin
    .from("projects")
    .select("*")
    .eq("slug", slug)
    .eq("is_published", true)
    .maybeSingle();

  const project = projectData as Project | null;

  if (!project) {
    notFound();
  }

  // Fetch requirements, skills, and user progress in parallel
  const [reqs, skillsData, userProgress] = await Promise.all([
    admin
      .from("project_requirements")
      .select("id, requirement, sort_order")
      .eq("project_id", project.id)
      .order("sort_order", { ascending: true }),
    admin
      .from("project_skills")
      .select("skill_id")
      .eq("project_id", project.id),
    user
      ? supabase
          .from("user_project_progress")
          .select("*")
          .eq("user_id", user.id)
          .eq("project_id", project.id)
          .maybeSingle()
      : Promise.resolve({ data: null, error: null }),
  ]);

  // Fetch skill names
  const skillIds = (skillsData.data ?? []).map((ps: { skill_id: string }) => ps.skill_id);
  const { data: skills } = skillIds.length
    ? await supabase.from("skills").select("id, name, slug").in("id", skillIds)
    : { data: [] };

  const requirements = (reqs.data ?? []) as ProjectRequirement[];
  const deliverables = Array.isArray(project.deliverables) ? (project.deliverables as string[]) : [];
  const acceptanceCriteria = Array.isArray(project.acceptance_criteria) ? (project.acceptance_criteria as string[]) : [];
  const prerequisites = Array.isArray(project.prerequisites) ? (project.prerequisites as string[]) : [];

  const progress = userProgress.data;

  return (
    <div className="space-y-6">
      <Link
        href="/projects"
        className="inline-flex items-center gap-1 text-sm text-[var(--color-text-tertiary)] hover:text-[var(--color-text-primary)]"
      >
        <ArrowLeft className="h-4 w-4" />
        Back to Projects
      </Link>

      <div>
        <div className="flex items-center gap-3 mb-2">
          <DifficultyBadge difficulty={(project.difficulty as Difficulty) ?? "intermediate"} />
          {project.estimated_minutes && (
            <span className="inline-flex items-center gap-1 text-xs text-[var(--color-text-tertiary)]">
              <Clock className="h-3.5 w-3.5" />
              {project.estimated_minutes} min
            </span>
          )}
          {progress && (
            <Badge variant={progress.status === "completed" ? "positive" : "brand"}>
              {progress.status.replace(/_/g, " ")}
            </Badge>
          )}
        </div>
        <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">{project.title}</h1>
        <p className="text-sm text-[var(--color-text-tertiary)] mt-1">{project.description}</p>
      </div>

      {progress && (
        <Card>
          <CardContent className="pt-4">
            <div className="flex items-center gap-3">
              <div className="h-2 flex-1 rounded-full bg-[var(--color-surface-raised)]">
                <div
                  className="h-2 rounded-full bg-[var(--color-brand)] transition-all"
                  style={{ width: `${progress.progress}%` }}
                />
              </div>
              <span className="text-sm font-medium text-[var(--color-text-primary)]">
                {progress.progress}%
              </span>
            </div>
          </CardContent>
        </Card>
      )}

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        {/* Requirements */}
        {requirements.length > 0 && (
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Requirements</CardTitle>
              <CardDescription>Complete each requirement to finish the project.</CardDescription>
            </CardHeader>
            <CardContent className="space-y-2">
              {requirements.map((req, i) => (
                <div key={req.id} className="flex items-start gap-3 rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] p-3">
                  {progress && progress.progress >= ((i + 1) / requirements.length) * 100 ? (
                    <CheckCircle2 className="mt-0.5 h-4 w-4 shrink-0 text-[var(--color-positive)]" />
                  ) : (
                    <Circle className="mt-0.5 h-4 w-4 shrink-0 text-[var(--color-text-disabled)]" />
                  )}
                  <p className="text-xs text-[var(--color-text-secondary)]">{req.requirement}</p>
                </div>
              ))}
            </CardContent>
          </Card>
        )}

        {/* Deliverables */}
        {deliverables.length > 0 && (
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Deliverables</CardTitle>
              <CardDescription>What you need to produce.</CardDescription>
            </CardHeader>
            <CardContent className="space-y-2">
              {deliverables.map((d, i) => (
                <div key={i} className="flex items-start gap-2">
                  <FolderGit2 className="mt-0.5 h-4 w-4 shrink-0 text-[var(--color-brand)]" />
                  <p className="text-xs text-[var(--color-text-secondary)]">{d}</p>
                </div>
              ))}
            </CardContent>
          </Card>
        )}

        {/* Acceptance Criteria */}
        {acceptanceCriteria.length > 0 && (
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Acceptance Criteria</CardTitle>
              <CardDescription>How your project will be evaluated.</CardDescription>
            </CardHeader>
            <CardContent className="space-y-2">
              {acceptanceCriteria.map((c, i) => (
                <div key={i} className="flex items-start gap-2">
                  <CheckCircle2 className="mt-0.5 h-4 w-4 shrink-0 text-[var(--color-text-tertiary)]" />
                  <p className="text-xs text-[var(--color-text-secondary)]">{c}</p>
                </div>
              ))}
            </CardContent>
          </Card>
        )}

        {/* Prerequisites */}
        {prerequisites.length > 0 && (
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Prerequisites</CardTitle>
              <CardDescription>Required knowledge before starting.</CardDescription>
            </CardHeader>
            <CardContent className="space-y-2">
              {prerequisites.map((p, i) => (
                <div key={i} className="flex items-start gap-2">
                  <Circle className="mt-0.5 h-4 w-4 shrink-0 text-[var(--color-text-disabled)]" />
                  <p className="text-xs text-[var(--color-text-secondary)]">{p}</p>
                </div>
              ))}
            </CardContent>
          </Card>
        )}
      </div>

      {/* Skills Applied */}
      {skills && skills.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Skills Applied</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex flex-wrap gap-2">
              {skills.map((s: { id: string; name: string; slug: string }) => (
                <Link key={s.id} href={`/skills/${s.slug}`}>
                  <Badge variant="default" className="cursor-pointer hover:border-[var(--color-brand)]/50">
                    {s.name}
                  </Badge>
                </Link>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Action Button */}
      {user && (
        <ProjectActionClient
          slug={slug}
          currentStatus={progress?.status ?? "not_started"}
          currentProgress={progress?.progress ?? 0}
          requirementsCount={requirements.length}
        />
      )}
    </div>
  );
}
