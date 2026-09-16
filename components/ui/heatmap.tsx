import React from "react";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";

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
    <TooltipProvider delayDuration={120}>
      <div className="flex flex-col gap-2">
        <div
          className="grid grid-flow-col gap-1"
          style={{
            gridTemplateRows: "repeat(7, minmax(0, 1fr))",
            gridTemplateColumns: `repeat(${Math.ceil(days / 7)}, minmax(0, 1fr))`,
          }}
        >
          {dateArray.map((date) => {
            const count = countMap.get(date) || 0;
            return (
              <Tooltip key={date}>
                <TooltipTrigger asChild>
                  <div
                    className={`w-3 h-3 rounded-sm ${getColor(count)}`}
                    aria-label={`${date}: ${count} ${count === 1 ? "activity" : "activities"}`}
                  />
                </TooltipTrigger>
                <TooltipContent>
                  <span className="font-mono">{date}</span>
                  <span className="ml-2 text-[var(--color-text-tertiary)]">
                    {count} {count === 1 ? "activity" : "activities"}
                  </span>
                </TooltipContent>
              </Tooltip>
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
    </TooltipProvider>
  );
}
