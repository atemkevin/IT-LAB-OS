import { z } from "zod";

export const loginSchema = z.object({
  email: z.string().email("Please enter a valid email address"),
  password: z.string().min(6, "Password must be at least 6 characters"),
});

export const registerSchema = z
  .object({
    email: z.string().email("Please enter a valid email address"),
    password: z
      .string()
      .min(8, "Password must be at least 8 characters long")
      .regex(/[A-Z]/, "Password must contain at least one uppercase letter")
      .regex(/[0-9]/, "Password must contain at least one number"),
    confirmPassword: z.string(),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Passwords do not match",
    path: ["confirmPassword"],
  });

export const forgotPasswordSchema = z.object({
  email: z.string().email("Please enter a valid email address"),
});

export const resetPasswordSchema = z
  .object({
    password: z
      .string()
      .min(8, "Password must be at least 8 characters long")
      .regex(/[A-Z]/, "Password must contain at least one uppercase letter")
      .regex(/[0-9]/, "Password must contain at least one number"),
    confirmPassword: z.string(),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Passwords do not match",
    path: ["confirmPassword"],
  });

export const EXPERIENCE_LEVELS = [
  "Complete beginner",
  "Some basic knowledge",
  "Intermediate",
  "Experienced",
] as const;

export type ExperienceLevel = (typeof EXPERIENCE_LEVELS)[number];

export const PRIMARY_GOALS = [
  "Network Engineer",
  "Cybersecurity",
  "AI Automation",
  "General IT / Infrastructure",
] as const;

export type PrimaryGoal = (typeof PRIMARY_GOALS)[number];

export interface UserEnvironment {
  tools: string[];
  startingLevel: ExperienceLevel;
  weakDomains: string[];
  weakSkills: string[];
  recommendedFirstSkill: string;
  assessmentScore: number;
  completedAt: string;
  updatedAt?: string;
}

export const onboardingSchema = z.object({
  experience_level: z.enum(EXPERIENCE_LEVELS),
  primary_goal: z.enum(PRIMARY_GOALS),
  daily_minutes: z.union([
    z.literal(30),
    z.literal(60),
    z.literal(90),
    z.literal(120),
  ]),
  environment: z.array(z.string()).min(1, "Please select at least one environment option"),
  assessmentAnswers: z.record(z.string(), z.string()).optional(),
});

export type LoginInput = z.infer<typeof loginSchema>;
export type RegisterInput = z.infer<typeof registerSchema>;
export type ForgotPasswordInput = z.infer<typeof forgotPasswordSchema>;
export type ResetPasswordInput = z.infer<typeof resetPasswordSchema>;
export type OnboardingInput = z.infer<typeof onboardingSchema>;
