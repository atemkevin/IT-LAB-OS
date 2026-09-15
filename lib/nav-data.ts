import {
  LayoutDashboard,
  Map,
  Zap,
  Target,
  FlaskConical,
  FolderOpen,
  FileText,
  BarChart3,
  Bot,
  User,
  Settings,
  type LucideIcon,
} from "lucide-react";

export interface NavItem {
  label: string;
  href: string;
  icon: LucideIcon;
  description?: string;
}

export interface NavGroup {
  label: string;
  items: NavItem[];
}

/**
 * Primary navigation — matches spec (03_SCREEN_UX_SPEC.md):
 * Dashboard, Learning Path, Skills, Daily Mission, Labs, Projects, Notes, Progress
 */
export const primaryNav: NavItem[] = [
  {
    label: "Dashboard",
    href: "/dashboard",
    icon: LayoutDashboard,
    description: "Overview and today's focus",
  },
  {
    label: "Learning Path",
    href: "/learn",
    icon: Map,
    description: "Your skill progression map",
  },
  {
    label: "Skills",
    href: "/skills",
    icon: Zap,
    description: "Browse all skills and domains",
  },
  {
    label: "Daily Mission",
    href: "/mission",
    icon: Target,
    description: "Today's focused learning task",
  },
  {
    label: "Labs",
    href: "/labs",
    icon: FlaskConical,
    description: "Troubleshooting simulator",
  },
  {
    label: "Projects",
    href: "/projects",
    icon: FolderOpen,
    description: "Applied projects and builds",
  },
  {
    label: "Notes",
    href: "/notes",
    icon: FileText,
    description: "Your knowledge base",
  },
  {
    label: "Progress",
    href: "/progress",
    icon: BarChart3,
    description: "Mastery analytics and history",
  },
];

/**
 * Secondary navigation — shown below the primary nav.
 */
export const secondaryNav: NavItem[] = [
  {
    label: "AI Mentor",
    href: "/ai",
    icon: Bot,
    description: "Tutor, Coach, and Troubleshooter",
  },
  {
    label: "Profile",
    href: "/profile",
    icon: User,
    description: "Account and preferences",
  },
  {
    label: "Settings",
    href: "/settings",
    icon: Settings,
    description: "App settings",
  },
];

/**
 * Mobile bottom navigation — 5 items max per spec (03_SCREEN_UX_SPEC.md):
 * Home, Learn, Mission, AI, More
 */
export const mobileBottomNav: NavItem[] = [
  { label: "Home", href: "/dashboard", icon: LayoutDashboard },
  { label: "Learn", href: "/learn", icon: Map },
  { label: "Mission", href: "/mission", icon: Target },
  { label: "AI", href: "/ai", icon: Bot },
  // "More" is a trigger for a sheet/drawer containing the rest
];
