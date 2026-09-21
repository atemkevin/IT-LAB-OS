"use client";

import { useState, useMemo } from 'react';
import Link from 'next/link';
import { Card, CardHeader, CardContent } from '@/components/ui/card';
import { Badge, DifficultyBadge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { BookOpen, Clock, ArrowRight, CheckCircle2, Search, Filter } from 'lucide-react';

export interface LessonItem {
  id: string;
  skill_id: string;
  slug: string;
  title: string;
  summary: string | null;
  difficulty: string | null;
  estimated_minutes: number | null;
  sort_order: number;
}

export interface SkillItem {
  id: string;
  name: string;
  slug: string;
  domain_id: string;
  sort_order: number;
  lessons: LessonItem[];
}

export interface DomainItem {
  id: string;
  name: string;
  slug: string;
  sort_order: number;
  skills: SkillItem[];
  totalLessons: number;
}

interface LessonsDirectoryClientProps {
  initialDomains: DomainItem[];
  completedLessonIds: string[];
}

export function LessonsDirectoryClient({
  initialDomains,
  completedLessonIds,
}: LessonsDirectoryClientProps) {
  const [search, setSearch] = useState('');
  const [selectedDifficulty, setSelectedDifficulty] = useState<string>('all');

  const completedSet = useMemo(() => new Set(completedLessonIds), [completedLessonIds]);

  // Filtered domains and skills
  const filteredDomains = useMemo(() => {
    const q = search.trim().toLowerCase();

    return initialDomains
      .map((domain) => {
        const filteredSkills = domain.skills
          .map((skill) => {
            const matchingLessons = skill.lessons.filter((lesson) => {
              // Difficulty check
              if (selectedDifficulty !== 'all' && lesson.difficulty !== selectedDifficulty) {
                return false;
              }
              // Search query check
              if (!q) return true;
              return (
                lesson.title.toLowerCase().includes(q) ||
                (lesson.summary && lesson.summary.toLowerCase().includes(q)) ||
                skill.name.toLowerCase().includes(q) ||
                domain.name.toLowerCase().includes(q)
              );
            });

            return {
              ...skill,
              lessons: matchingLessons,
            };
          })
          .filter((s) => s.lessons.length > 0);

        return {
          ...domain,
          skills: filteredSkills,
          totalLessons: filteredSkills.reduce((acc, s) => acc + s.lessons.length, 0),
        };
      })
      .filter((d) => d.totalLessons > 0);
  }, [initialDomains, search, selectedDifficulty]);

  const totalMatchingLessons = useMemo(() => {
    return filteredDomains.reduce((acc, d) => acc + d.totalLessons, 0);
  }, [filteredDomains]);

  // Overall counts
  const totalCount = useMemo(() => {
    return initialDomains.reduce((acc, d) => acc + d.totalLessons, 0);
  }, [initialDomains]);

  return (
    <div className="space-y-6">
      {/* Search & Filter Controls */}
      <div className="flex flex-col sm:flex-row items-center gap-3">
        <div className="relative w-full sm:flex-1">
          <Search className="absolute left-3 top-2.5 h-4 w-4 text-[var(--color-text-tertiary)]" />
          <Input
            type="text"
            placeholder="Search lessons by topic, command, or concept..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="pl-9 h-10 text-sm"
          />
        </div>

        {/* Difficulty Filter Pills */}
        <div className="flex items-center gap-1.5 w-full sm:w-auto overflow-x-auto pb-1 sm:pb-0">
          <Button
            size="sm"
            variant={selectedDifficulty === 'all' ? 'default' : 'outline'}
            onClick={() => setSelectedDifficulty('all')}
            className="h-9 text-xs"
          >
            All ({totalCount})
          </Button>
          <Button
            size="sm"
            variant={selectedDifficulty === 'beginner' ? 'default' : 'outline'}
            onClick={() => setSelectedDifficulty('beginner')}
            className="h-9 text-xs"
          >
            🟢 Beginner
          </Button>
          <Button
            size="sm"
            variant={selectedDifficulty === 'intermediate' ? 'default' : 'outline'}
            onClick={() => setSelectedDifficulty('intermediate')}
            className="h-9 text-xs"
          >
            🟡 Intermediate
          </Button>
          <Button
            size="sm"
            variant={selectedDifficulty === 'advanced' ? 'default' : 'outline'}
            onClick={() => setSelectedDifficulty('advanced')}
            className="h-9 text-xs"
          >
            🔴 Advanced
          </Button>
        </div>
      </div>

      {/* Matching Count Bar */}
      <div className="flex items-center justify-between text-xs text-[var(--color-text-tertiary)] px-1">
        <span>
          Showing {totalMatchingLessons} lesson{totalMatchingLessons !== 1 ? 's' : ''}
          {selectedDifficulty !== 'all' ? ` (${selectedDifficulty})` : ''}
          {search ? ` matching "${search}"` : ''}
        </span>
        {search && (
          <button
            onClick={() => setSearch('')}
            className="text-[var(--color-brand)] hover:underline"
          >
            Clear search
          </button>
        )}
      </div>

      {/* Lessons List */}
      {filteredDomains.length === 0 ? (
        <Card className="p-8 text-center space-y-3">
          <BookOpen className="h-8 w-8 text-[var(--color-text-tertiary)] mx-auto" />
          <p className="text-sm text-[var(--color-text-secondary)] font-medium">
            No lessons match your search or filter.
          </p>
          <Button
            size="sm"
            variant="outline"
            onClick={() => {
              setSearch('');
              setSelectedDifficulty('all');
            }}
          >
            Reset Filters
          </Button>
        </Card>
      ) : (
        <div className="space-y-8">
          {filteredDomains.map((domain, dIdx) => (
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
                        const isDone = completedSet.has(lesson.id);
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
      )}
    </div>
  );
}
