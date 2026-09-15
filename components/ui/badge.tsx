import { type VariantProps, cva } from "class-variance-authority";
import { cn } from "@/lib/utils";
import type { MasteryState, Difficulty } from "@/lib/database.types";

const badgeVariants = cva(
  "inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium",
  {
    variants: {
      variant: {
        default: "bg-[var(--color-surface-raised)] text-[var(--color-text-secondary)]",
        brand: "bg-[var(--color-brand-soft)] text-[var(--color-brand)]",
        positive: "bg-[var(--color-positive-soft)] text-[var(--color-positive)]",
        negative: "bg-[var(--color-negative-soft)] text-[var(--color-negative)]",
        warning: "bg-[var(--color-warning-soft)] text-[var(--color-warning)]",
        info: "bg-[var(--color-info-soft)] text-[var(--color-info)]",
        "mastery-not-started": "bg-[var(--color-mastery-not-started)]/20 text-[var(--color-mastery-not-started)]",
        "mastery-developing": "bg-[var(--color-mastery-developing)]/20 text-[var(--color-mastery-developing)]",
        "mastery-practicing": "bg-[var(--color-mastery-practicing)]/20 text-[var(--color-mastery-practicing)]",
        "mastery-proficient": "bg-[var(--color-mastery-proficient)]/20 text-[var(--color-mastery-proficient)]",
        "mastery-strong": "bg-[var(--color-mastery-strong)]/20 text-[var(--color-mastery-strong)]",
        "difficulty-beginner": "bg-[var(--color-difficulty-beginner)]/20 text-[var(--color-difficulty-beginner)]",
        "difficulty-intermediate": "bg-[var(--color-difficulty-intermediate)]/20 text-[var(--color-difficulty-intermediate)]",
        "difficulty-advanced": "bg-[var(--color-difficulty-advanced)]/20 text-[var(--color-difficulty-advanced)]",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  },
);

export interface BadgeProps
  extends React.HTMLAttributes<HTMLSpanElement>,
    VariantProps<typeof badgeVariants> {}

export function Badge({ className, variant, ...props }: BadgeProps) {
  return (
    <span className={cn(badgeVariants({ variant }), className)} {...props} />
  );
}

/**
 * Mastery state badge with automatic color coding.
 */
export function MasteryBadge({ state }: { state: MasteryState }) {
  const labels: Record<MasteryState, string> = {
    not_started: "Not Started",
    developing: "Developing",
    practicing: "Practicing",
    proficient: "Proficient",
    strong: "Strong",
  };

  const variants: Record<MasteryState, BadgeProps["variant"]> = {
    not_started: "mastery-not-started",
    developing: "mastery-developing",
    practicing: "mastery-practicing",
    proficient: "mastery-proficient",
    strong: "mastery-strong",
  };

  return <Badge variant={variants[state]}>{labels[state]}</Badge>;
}

/**
 * Difficulty badge with automatic color coding.
 */
export function DifficultyBadge({ difficulty }: { difficulty: Difficulty }) {
  const labels: Record<Difficulty, string> = {
    beginner: "Beginner",
    intermediate: "Intermediate",
    advanced: "Advanced",
  };

  const variants: Record<Difficulty, BadgeProps["variant"]> = {
    beginner: "difficulty-beginner",
    intermediate: "difficulty-intermediate",
    advanced: "difficulty-advanced",
  };

  return <Badge variant={variants[difficulty]}>{labels[difficulty]}</Badge>;
}
