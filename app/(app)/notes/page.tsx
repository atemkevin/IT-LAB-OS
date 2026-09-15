import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Plus, Search, FileText } from "lucide-react";

export default function NotesPage() {
  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">Lab Notes</h1>
          <p className="text-sm text-[var(--color-text-tertiary)]">
            Personal engineering notebook, command cheatsheets, and post-mortems.
          </p>
        </div>
        <Button>
          <Plus className="h-4 w-4" />
          New Note
        </Button>
      </div>

      <div className="flex items-center gap-2">
        <div className="relative flex-1">
          <Input placeholder="Search notes, commands, tags..." className="pl-9" />
          <Search className="absolute left-3 top-3 h-4 w-4 text-[var(--color-text-tertiary)]" />
        </div>
      </div>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
        <Card className="hover:border-[var(--color-brand)]/50 transition-colors cursor-pointer">
          <CardHeader>
            <div className="flex items-center gap-2">
              <FileText className="h-4 w-4 text-[var(--color-brand)]" />
              <CardTitle className="text-sm">Troubleshooting Playbook: Systemd</CardTitle>
            </div>
            <CardDescription className="line-clamp-2">
              journalctl -xeu service-name cheatsheet and cgroup debugging notes.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <span className="text-[10px] text-[var(--color-text-disabled)]">Pinned • 2 days ago</span>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
