import type { ExperienceLevel, PrimaryGoal } from "@/lib/auth/schemas";

export interface AssessmentQuestion {
  id: string;
  domain: string;
  domainSlug: string;
  prompt: string;
  options: string[];
  correctAnswer: string;
  skillSlug: string;
}

export const ONBOARDING_QUESTIONS: AssessmentQuestion[] = [
  {
    id: "q_comp",
    domain: "Computer / IT Fundamentals",
    domainSlug: "computer-fundamentals",
    prompt: "Which computer hardware component acts as high-speed, volatile temporary workspace that loses its data when powered off?",
    options: [
      "Solid State Drive (SSD)",
      "Random Access Memory (RAM)",
      "Read-Only Memory (ROM)",
      "Hard Disk Drive (HDD)",
    ],
    correctAnswer: "Random Access Memory (RAM)",
    skillSlug: "cpu-memory-storage",
  },
  {
    id: "q_os",
    domain: "Operating Systems",
    domainSlug: "operating-systems",
    prompt: "In modern operating systems, what is the term for a background process that runs continuously without direct user interaction?",
    options: [
      "Foreground job",
      "Service (or Daemon)",
      "Hypervisor",
      "Bootloader",
    ],
    correctAnswer: "Service (or Daemon)",
    skillSlug: "processes-services",
  },
  {
    id: "q_net",
    domain: "Networking",
    domainSlug: "networking",
    prompt: "What network protocol automatically leases IP addresses, subnet masks, and default gateways to local client hosts?",
    options: ["DNS", "DHCP", "BGP", "ARP"],
    correctAnswer: "DHCP",
    skillSlug: "ip-addressing",
  },
  {
    id: "q_linux",
    domain: "Linux",
    domainSlug: "linux",
    prompt: "In standard Linux octal file permissions, what numeric mode grants Read, Write, and Execute to the owner, but only Read to group and others?",
    options: ["777", "755", "744", "644"],
    correctAnswer: "744",
    skillSlug: "linux-permissions",
  },
  {
    id: "q_sec",
    domain: "Cybersecurity",
    domainSlug: "cybersecurity",
    prompt: "What is the primary difference between Authentication and Authorization in secure access control?",
    options: [
      "Authentication verifies who you are; Authorization determines what resources you are allowed to access",
      "Authentication encrypts passwords; Authorization issues TLS certificates",
      "Authentication applies to network firewalls; Authorization applies to storage drives",
      "Authentication occurs after access is granted; Authorization occurs before login",
    ],
    correctAnswer: "Authentication verifies who you are; Authorization determines what resources you are allowed to access",
    skillSlug: "authentication-authorization",
  },
  {
    id: "q_auto",
    domain: "Automation / scripting",
    domainSlug: "python-automation",
    prompt: "In Python automation scripts, which data structure stores an ordered, mutable sequence of elements enclosed in square brackets?",
    options: ["Dictionary", "Tuple", "List", "Set"],
    correctAnswer: "List",
    skillSlug: "python-basics",
  },
];

export interface AssessmentResult {
  totalQuestions: number;
  correctCount: number;
  percentageScore: number;
  startingLevel: ExperienceLevel;
  weakDomains: string[];
  weakSkills: string[];
  recommendedFirstSkill: string;
  details: Record<string, { prompt: string; userChoice: string; isCorrect: boolean }>;
}

/**
 * Evaluate deterministic onboarding assessment answers without client tampering.
 */
export function evaluateAssessment(
  answers: Record<string, string> = {},
  primaryGoal?: PrimaryGoal | string,
): AssessmentResult {
  let correctCount = 0;
  const weakDomains: string[] = [];
  const weakSkills: string[] = [];
  const details: AssessmentResult["details"] = {};

  for (const q of ONBOARDING_QUESTIONS) {
    const userChoice = answers[q.id] || "";
    const isCorrect = userChoice.trim() === q.correctAnswer.trim();

    if (isCorrect) {
      correctCount++;
    } else {
      if (!weakDomains.includes(q.domain)) weakDomains.push(q.domain);
      if (!weakSkills.includes(q.skillSlug)) weakSkills.push(q.skillSlug);
    }

    details[q.id] = {
      prompt: q.prompt,
      userChoice,
      isCorrect,
    };
  }

  const percentageScore = Math.round((correctCount / ONBOARDING_QUESTIONS.length) * 100);

  // Map score to the authoritative 4-level experience model
  let startingLevel: ExperienceLevel = "Complete beginner";
  if (percentageScore >= 84) {
    startingLevel = "Experienced";
  } else if (percentageScore >= 50) {
    startingLevel = "Intermediate";
  } else if (percentageScore >= 33) {
    startingLevel = "Some basic knowledge";
  } else {
    startingLevel = "Complete beginner";
  }

  // Determine tailored starting skill based on primary goal and assessment weaknesses
  let recommendedFirstSkill = "computer-basics";
  if (primaryGoal === "Network Engineer") {
    recommendedFirstSkill = weakSkills.includes("ip-addressing") ? "ip-addressing" : "subnetting";
  } else if (primaryGoal === "Cybersecurity") {
    recommendedFirstSkill = weakSkills.includes("authentication-authorization")
      ? "security-fundamentals"
      : "authentication-authorization";
  } else if (primaryGoal === "AI Automation") {
    recommendedFirstSkill = weakSkills.includes("python-basics") ? "python-basics" : "api-basics";
  } else {
    // General IT / Infrastructure
    if (weakSkills.includes("cpu-memory-storage")) {
      recommendedFirstSkill = "computer-basics";
    } else if (weakSkills.includes("processes-services")) {
      recommendedFirstSkill = "processes-services";
    } else if (weakSkills.includes("linux-permissions")) {
      recommendedFirstSkill = "linux-cli";
    } else {
      recommendedFirstSkill = "computer-basics";
    }
  }

  return {
    totalQuestions: ONBOARDING_QUESTIONS.length,
    correctCount,
    percentageScore,
    startingLevel,
    weakDomains,
    weakSkills,
    recommendedFirstSkill,
    details,
  };
}
