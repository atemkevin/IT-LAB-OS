import { createClient } from '@/lib/supabase/server';
import { LessonsDirectoryClient, type DomainItem } from './lessons-directory-client';

export const metadata = {
  title: 'Curriculum Lessons | IT Lab OS',
  description: 'Browse the complete curriculum of IT, Linux, networking, and security lessons from beginner to advanced.',
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
  let completedLessonIds: string[] = [];
  if (user) {
    const { data: progress } = await supabase
      .from('user_lesson_progress')
      .select('lesson_id')
      .eq('user_id', user.id)
      .eq('status', 'completed');

    if (progress) {
      completedLessonIds = progress.map((p) => p.lesson_id);
    }
  }

  // Organize by domain -> skills -> lessons
  const domainTree: DomainItem[] = (domains ?? [])
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
          Master {totalAllLessons} interactive lessons spanning foundational concepts, real-world operations, and advanced enterprise architectures.
        </p>
      </div>

      <LessonsDirectoryClient
        initialDomains={domainTree}
        completedLessonIds={completedLessonIds}
      />
    </div>
  );
}
