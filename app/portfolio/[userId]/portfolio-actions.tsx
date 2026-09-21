"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Share2, Download, Check } from "lucide-react";
import type { PublicPortfolioData } from "@/lib/portfolio/service";

export function PortfolioActions({ portfolio }: { portfolio: PublicPortfolioData }) {
  const [copied, setCopied] = useState(false);

  function handleShare() {
    if (typeof window !== "undefined") {
      navigator.clipboard.writeText(window.location.href);
      setCopied(true);
      setTimeout(() => setCopied(false), 2500);
    }
  }

  function handleExport() {
    const dataStr =
      "data:text/json;charset=utf-8," +
      encodeURIComponent(
        JSON.stringify(
          {
            platform: "IT Lab OS",
            issuedAt: new Date().toISOString(),
            certificateType: "Verified Technical Competence",
            ...portfolio,
          },
          null,
          2,
        ),
      );
    const downloadAnchor = document.createElement("a");
    downloadAnchor.setAttribute("href", dataStr);
    downloadAnchor.setAttribute(
      "download",
      `it-lab-os-portfolio-${portfolio.learner.id.substring(0, 8)}.json`,
    );
    document.body.appendChild(downloadAnchor);
    downloadAnchor.click();
    downloadAnchor.remove();
  }

  return (
    <div className="flex items-center gap-2">
      <Button
        variant="secondary"
        size="sm"
        onClick={handleShare}
        className="h-8 gap-1.5 text-xs"
      >
        {copied ? (
          <>
            <Check className="h-3.5 w-3.5 text-[var(--color-positive)]" />
            Copied
          </>
        ) : (
          <>
            <Share2 className="h-3.5 w-3.5" />
            Share Link
          </>
        )}
      </Button>

      <Button
        variant="default"
        size="sm"
        onClick={handleExport}
        className="h-8 gap-1.5 text-xs"
      >
        <Download className="h-3.5 w-3.5" />
        Export Proof of Skill
      </Button>
    </div>
  );
}
