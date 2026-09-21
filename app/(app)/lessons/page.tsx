import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';
import { Card, CardHeader, CardContent } from '@/components/ui/card';
import { Badge, DifficultyBadge } from '@/components/ui/badge';
import { BookOpen, Clock, ArrowRight, CheckCircle2 } from 'lucide-react';

export const metadata = {
  title: 'All Lessons | IT Lab OS',
  description: 'Browse the complete curriculum of IT, Linux, networking, and security lessons.',
};

export default async function LessonsDirectoryPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  // Fetch all domains, skills, and published lessons
  const { data: domains } = await supabase
    .from('domains')
    .select('id, name, slug, sort_order')
    .order('sort_order', { ascending: true });

  const { data: skills } = await supabase
    .from('skills')
    .select('id, name, slug, domain_id, sort_order')
    .order('sort_order', { ascending: true });

  const { data: lessons } = await supabase
    .from('lessons')
    .select('id, skill_id, slug, title, summary, difficulty, estimated_minutes, sort_order')
    .eq('is_published', true)
    .order('sort_order', { ascending: true });

  // Fetch user progress if authenticated
  let completedLessonIds = new Set<string>();
  if (user) {
    const { data: progress } = await supabase
      .from('user_lesson_progress')
      .select('lesson_id')
      .eq('user_id', user.id)
      .eq('status', 'completed');

    if (progress) {
      completedLessonIds = new Set(progress.map((p) => p.lesson_id));
    }
  }

  // Organize by domain -> skills -> lessons
  const domainTree = (domains ?? [])
    .map((domain) => {
      const domainSkills = (skills ?? [])
        .filter((s) => s.domain_id === domain.id)
        .map((skill) => {
          const skillLessons = (lessons ?? []).filter((l) => l.skill_id === skill.id);
          return {
            ...skill,
            lessons: skillLessons,
          };
        })
        .filter((s) => s.lessons.length > 0);

      return {
        ...domain,
        skills: domainSkills,
        totalLessons: domainSkills.reduce((acc, s) => acc + s.lessons.length, 0),
      };
    })
    .filter((d) => d.totalLessons > 0);

  const totalAllLessons = lessons?.length ?? 0;

  return (
    <div className="space-y-8 max-w-5xl mx-auto">
      <div>
        <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">
          Curriculum Lessons
        </h1>
        <p className="text-sm text-[var(--color-text-tertiary)] mt-1">
          Browse all {totalAllLessons} interactive lessons across {domainTree.length} domains.
        </p>
      </div>

      <div className="space-y-8">
        {domainTree.map((domain, dIdx) => (
          <div key={domain.id} className="space-y-4">
            <div className="flex items-center gap-2 border-b border-[var(--color-border)] pb-2">
              <span className="text-xs font-mono text-[var(--color-brand)] font-semibold">
                Domain {String(domain.sort_order ?? dIdx + 1).padStart(2, '0')}
              </span>
              <h2 className="text-lg font-bold text-[var(--color-text-primary)]">
                {domain.name}
              </h2>
              <Badge variant="default" className="ml-auto text-[10px]">
                {domain.totalLessons} lesson{domain.totalLessons !== 1 ? 's' : ''}
              </Badge>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {domain.skills.map((skill) => (
                <Card key={skill.id} className="flex flex-col justify-between">
                  <CardHeader className="pb-2">
                    <div className="flex items-center justify-between">
                      <Link
                        href={`/skills/${skill.slug}`}
                        className="text-sm font-semibold text-[var(--color-text-primary)] hover:text-[var(--color-brand)] hover:underline"
                      >
                        {skill.name}
                      </Link>
                      <Link
                        href={`/skills/${skill.slug}`}
                        className="text-xs text-[var(--color-text-tertiary)] hover:text-[var(--color-brand)] inline-flex items-center gap-0.5"
                      >
                        Skill Hub <ArrowRight className="h-3 w-3" />
                      </Link>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-2 pt-0">
                    {skill.lessons.map((lesson) => {
                      const isDone = completedLessonIds.has(lesson.id);
                      return (
                        <Link
                          key={lesson.id}
                          href={`/lessons/${lesson.id}`}
                          className="group flex items-start justify-between rounded-md border border-[var(--color-border)] p-2.5 transition-colors hover:border-[var(--color-brand)]/50 hover:bg-[var(--color-surface-elevated)]"
                        >
                          <div className="space-y-1 pr-2">
                            <div className="flex items-center gap-2">
                              <BookOpen className="h-3.5 w-3.5 text-[var(--color-brand)] shrink-0" />
                              <span className="text-xs font-medium text-[var(--color-text-primary)] group-hover:text-[var(--color-brand)]">
                                {lesson.title}
                              </span>
                              {isDone && (
                                <CheckCircle2 className="h-3.5 w-3.5 text-green-500 shrink-0" />
                              )}
                            </div>
                            {lesson.summary && (
                              <p className="text-[11px] text-[var(--color-text-tertiary)] line-clamp-1">
                                {lesson.summary}
                              </p>
                            )}
                          </div>
                          <div className="flex items-center gap-1.5 shrink-0">
                            <DifficultyBadge difficulty={lesson.difficulty as any} />
                            <span className="text-[10px] text-[var(--color-text-tertiary)] flex items-center gap-0.5">
                              <Clock className="h-2.5 w-2.5" /> {lesson.estimated_minutes}m
                            </span>
                          </div>
                        </Link>
                      );
                    })}
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
