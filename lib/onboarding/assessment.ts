export interface AssessmentQuestion {
  id: string;
  domain: string;
  prompt: string;
  options: string[];
  correctAnswer: string;
  skillSlug: string;
}

export const ONBOARDING_QUESTIONS: AssessmentQuestion[] = [
  {
    id: "q_linux",
    domain: "Linux",
    prompt: "Which Linux command displays real-time running processes and their memory and CPU usage?",
    options: ["ls -la", "top", "cat /proc/version", "chmod 755"],
    correctAnswer: "top",
    skillSlug: "processes-services",
  },
  {
    id: "q_net",
    domain: "Networking",
    prompt: "What network protocol automatically leases IP addresses and configuration parameters to local hosts?",
    options: ["DNS", "DHCP", "BGP", "ARP"],
    correctAnswer: "DHCP",
    skillSlug: "ip-addressing",
  },
  {
    id: "q_sec",
    domain: "Cybersecurity",
    prompt: "When hardening remote server access via SSH, which configuration provides the strongest defensive security?",
    options: [
      "Using password authentication with 8 characters",
      "Disabling root password login and enforcing Ed25519 key-based authentication",
      "Changing SSH port to 2222 with plain telnet fallback",
      "Allowing password login only during scheduled business hours",
    ],
    correctAnswer: "Disabling root password login and enforcing Ed25519 key-based authentication",
    skillSlug: "ssh",
  },
  {
    id: "q_auto",
    domain: "Automation & DevOps",
    prompt: "In modern infrastructure management, what is the primary benefit of declarative Infrastructure as Code (IaC)?",
    options: [
      "It eliminates the need for git version control",
      "It describes the desired target state and enables reproducible, automated deployments",
      "It accelerates network packet routing at the kernel level",
      "It removes the need for ingress firewall rules",
    ],
    correctAnswer: "It describes the desired target state and enables reproducible, automated deployments",
    skillSlug: "automation-workflows",
  },
];

export interface AssessmentResult {
  totalQuestions: number;
  correctCount: number;
  percentageScore: number;
  startingLevel: "foundational" | "intermediate" | "advanced";
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
  primaryGoal?: string,
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

  let startingLevel: AssessmentResult["startingLevel"] = "foundational";
  if (percentageScore >= 75) {
    startingLevel = "advanced";
  } else if (percentageScore >= 50) {
    startingLevel = "intermediate";
  }

  // Determine tailored starting skill based on primary goal and assessment
  let recommendedFirstSkill = "computer-basics";
  if (primaryGoal === "Network Engineer") {
    recommendedFirstSkill = weakSkills.includes("ip-addressing") ? "ip-addressing" : "subnetting";
  } else if (primaryGoal === "Cybersecurity") {
    recommendedFirstSkill = weakSkills.includes("ssh") ? "security-fundamentals" : "authentication-authorization";
  } else if (primaryGoal === "AI Automation") {
    recommendedFirstSkill = weakSkills.includes("automation-workflows") ? "python-basics" : "llm-api-basics";
  } else {
    // General IT
    recommendedFirstSkill = weakSkills.includes("processes-services") ? "linux-cli" : "filesystem-basics";
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
