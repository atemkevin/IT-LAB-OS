import { describe, it, expect } from "vitest";
import {
  cn,
  formatDuration,
  clamp,
  truncate,
} from "@/lib/utils";

describe("Shared Utilities", () => {
  it("merges class names correctly with cn()", () => {
    expect(cn("bg-red-500", "p-4")).toBe("bg-red-500 p-4");
    expect(cn("p-2", "p-4")).toBe("p-4"); // tailwind-merge resolves conflict
    expect(cn("base", false && "conditional", undefined, "active")).toBe("base active");
  });

  it("formats durations accurately", () => {
    expect(formatDuration(25)).toBe("25m");
    expect(formatDuration(60)).toBe("1h");
    expect(formatDuration(90)).toBe("1h 30m");
    expect(formatDuration(125)).toBe("2h 5m");
  });

  it("clamps values within range", () => {
    expect(clamp(50, 0, 100)).toBe(50);
    expect(clamp(-10, 0, 100)).toBe(0);
    expect(clamp(150, 0, 100)).toBe(100);
  });

  it("truncates strings properly", () => {
    expect(truncate("Short string", 20)).toBe("Short string");
    expect(truncate("This is a very long string that should be cut off", 10)).toBe("This is a…");
  });
});
