import React from "react";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip"; // Note: might need to ensure tooltip is installed, we'll check later. Let's just use title if tooltip is not imported.

// Wait, I saw radix-ui/react-tooltip in package.json! So tooltip should exist. Let's assume it exists or use basic title for now.
// Actually, let's use a native title attribute to be safe and avoid missing component errors if tooltip.tsx doesn't exist.
// Checking components/ui/ list from earlier, tooltip.tsx wasn't in the root of components/ui. It might be there, but native title is safest.

interface HeatmapProps {
  data: Array<{ date: string; count: number }>;
  days?: number;
}

export function Heatmap({ data, days = 90 }: HeatmapProps) {
  // Generate the last `days` dates
  const today = new Date();
  const dateArray = Array.from({ length: days }, (_, i) => {
    const d = new Date(today);
    d.setDate(today.getDate() - (days - 1 - i));
    return d.toISOString().split("T")[0];
  });

  const countMap = new Map(data.map((item) => [item.date, item.count]));

  const getColor = (count: number) => {
    if (count === 0) return "bg-[var(--color-background-secondary)]";
    if (count === 1) return "bg-[var(--color-mastery-developing)] opacity-60";
    if (count === 2) return "bg-[var(--color-mastery-practicing)] opacity-80";
    if (count === 3) return "bg-[var(--color-mastery-proficient)]";
    return "bg-[var(--color-mastery-strong)]";
  };

  return (
    <div className="flex flex-col gap-2">
      <div 
        className="grid grid-flow-col gap-1"
        style={{ 
          gridTemplateRows: "repeat(7, minmax(0, 1fr))",
          // Calculate approx columns needed
          gridTemplateColumns: `repeat(${Math.ceil(days / 7)}, minmax(0, 1fr))`
        }}
      >
        {dateArray.map((date) => {
          const count = countMap.get(date) || 0;
          return (
            <div
              key={date}
              className={`w-3 h-3 rounded-sm ${getColor(count)}`}
              title={`${date}: ${count} activities`}
            />
          );
        })}
      </div>
      <div className="flex justify-end items-center gap-1 text-xs text-[var(--color-text-tertiary)]">
        <span>Less</span>
        <div className="w-3 h-3 rounded-sm bg-[var(--color-background-secondary)]"></div>
        <div className="w-3 h-3 rounded-sm bg-[var(--color-mastery-developing)] opacity-60"></div>
        <div className="w-3 h-3 rounded-sm bg-[var(--color-mastery-practicing)] opacity-80"></div>
        <div className="w-3 h-3 rounded-sm bg-[var(--color-mastery-proficient)]"></div>
        <div className="w-3 h-3 rounded-sm bg-[var(--color-mastery-strong)]"></div>
        <span>More</span>
      </div>
    </div>
  );
}
