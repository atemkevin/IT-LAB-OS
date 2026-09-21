import { createClient } from "@/lib/supabase/server";
import { Award, Zap, Flame, CheckCircle, FlaskConical } from "lucide-react";

export async function AchievementsGrid({ userId }: { userId: string }) {
  const supabase = await createClient();

  const [{ data: allAchievements }, { data: userAchievements }] = await Promise.all([
    supabase.from("achievements").select("*").order("created_at"),
    supabase.from("user_achievements").select("achievement_id, earned_at").eq("user_id", userId)
  ]);

  const earnedMap = new Map();
  userAchievements?.forEach(ua => {
    earnedMap.set(ua.achievement_id, ua.earned_at);
  });

  const iconMap: Record<string, any> = {
    'flask-conical': FlaskConical,
    'flame': Flame,
    'zap': Zap,
    'award': Award,
    'check-circle': CheckCircle,
  };

  return (
    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
      {allAchievements?.map((ach) => {
        const isEarned = earnedMap.has(ach.id);
        const Icon = iconMap[ach.icon] || Award;
        const earnedDate = isEarned ? new Date(earnedMap.get(ach.id)).toLocaleDateString() : null;

        return (
          <div 
            key={ach.id} 
            className={`glass-panel p-4 flex flex-col items-center text-center transition-all ${isEarned ? 'border-[var(--color-brand)] bg-[var(--color-brand-soft)]/20' : 'opacity-60 grayscale'}`}
          >
            <div className={`h-12 w-12 rounded-full flex items-center justify-center mb-3 ${isEarned ? 'bg-[var(--color-brand)] text-white shadow-lg shadow-[var(--color-brand)]/20' : 'bg-[var(--color-surface-raised)] text-[var(--color-text-tertiary)]'}`}>
              <Icon className="h-6 w-6" />
            </div>
            <h4 className={`text-sm font-bold ${isEarned ? 'text-[var(--color-text-primary)]' : 'text-[var(--color-text-secondary)]'}`}>{ach.name}</h4>
            <p className="text-[11px] text-[var(--color-text-tertiary)] mt-1">{ach.description}</p>
            {isEarned && (
              <span className="text-[10px] text-[var(--color-text-disabled)] mt-2 tabular font-medium">Earned {earnedDate}</span>
            )}
          </div>
        );
      })}
    </div>
  );
}
