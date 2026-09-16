"use client";

import { useState, useCallback, useRef } from "react";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Plus, Search, FileText, Pin, Trash2, X, Pencil } from "lucide-react";
import type { Note } from "@/lib/database.types";
import { formatRelativeTime } from "@/lib/utils";

interface NotesClientProps {
  initialNotes: Note[];
}

export default function NotesClient({ initialNotes }: NotesClientProps) {
  const [notes, setNotes] = useState<Note[]>(initialNotes);
  const [searchQuery, setSearchQuery] = useState("");
  const [editing, setEditing] = useState<Note | null>(null);
  const [showEditor, setShowEditor] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const searchTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  const handleSearch = useCallback(
    async (q: string) => {
      setSearchQuery(q);
      if (searchTimer.current) clearTimeout(searchTimer.current);
      searchTimer.current = setTimeout(async () => {
        try {
          const params = q ? `?q=${encodeURIComponent(q)}` : "";
          const res = await fetch(`/api/notes${params}`);
          if (!res.ok) return;
          const data = await res.json();
          setNotes(data.notes ?? []);
        } catch {
          // silently fail — keep existing notes visible
        }
      }, 300);
    },
    [],
  );

  async function handleSave(data: {
    id?: string;
    title: string;
    content_markdown: string;
    tags: string[];
    pinned: boolean;
  }) {
    setLoading(true);
    setError(null);
    try {
      const method = data.id ? "PATCH" : "POST";
      const url = data.id ? `/api/notes/${data.id}` : "/api/notes";
      const res = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          title: data.title,
          content_markdown: data.content_markdown,
          tags: data.tags,
          pinned: data.pinned,
        }),
      });
      if (!res.ok) {
        const errData = await res.json().catch(() => ({}));
        throw new Error(errData.error || "Failed to save note");
      }
      const result = await res.json();
      if (data.id) {
        setNotes((prev) =>
          prev.map((n) => (n.id === data.id ? result.note : n)),
        );
      } else {
        setNotes((prev) => [result.note, ...prev]);
      }
      setEditing(null);
      setShowEditor(false);
    } catch (err: any) {
      setError(err.message || "Failed to save. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  async function handleDelete(id: string) {
    try {
      const res = await fetch(`/api/notes/${id}`, { method: "DELETE" });
      if (!res.ok) throw new Error("Failed to delete");
      setNotes((prev) => prev.filter((n) => n.id !== id));
    } catch {
      setError("Failed to delete note");
    }
  }

  async function handleTogglePin(note: Note) {
    try {
      const res = await fetch(`/api/notes/${note.id}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ pinned: !note.pinned }),
      });
      if (!res.ok) throw new Error("Failed to update");
      const result = await res.json();
      setNotes((prev) =>
        prev
          .map((n) => (n.id === note.id ? result.note : n))
          .sort((a, b) => {
            if (a.pinned !== b.pinned) return a.pinned ? -1 : 1;
            return new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime();
          }),
      );
    } catch {
      setError("Failed to update note");
    }
  }

  if (showEditor || editing) {
    return (
      <NoteEditor
        note={editing}
        onSave={handleSave}
        onCancel={() => {
          setEditing(null);
          setShowEditor(false);
        }}
        loading={loading}
        error={error}
      />
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">Lab Notes</h1>
          <p className="text-sm text-[var(--color-text-tertiary)]">
            Personal engineering notebook, command cheatsheets, and post-mortems.
          </p>
        </div>
        <Button onClick={() => setShowEditor(true)}>
          <Plus className="h-4 w-4" />
          New Note
        </Button>
      </div>

      <div className="flex items-center gap-2">
        <div className="relative flex-1">
          <Input
            placeholder="Search notes, commands, tags..."
            className="pl-9"
            value={searchQuery}
            onChange={(e) => handleSearch(e.target.value)}
          />
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-[var(--color-text-tertiary)]" />
        </div>
      </div>

      {error && <p className="text-xs text-red-400 font-medium">{error}</p>}

      {notes.length === 0 ? (
        <div className="text-center py-12">
          <FileText className="h-12 w-12 text-[var(--color-text-disabled)] mx-auto mb-3" />
          <p className="text-sm text-[var(--color-text-tertiary)]">
            {searchQuery ? "No notes match your search." : "No notes yet. Create your first note!"}
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
          {notes.map((note) => (
            <Card
              key={note.id}
              className="flex flex-col justify-between hover:border-[var(--color-brand)]/50 transition-colors"
            >
              <CardHeader>
                <div className="flex items-start justify-between gap-2">
                  <div className="flex items-center gap-2 flex-1 min-w-0">
                    <FileText className="h-4 w-4 shrink-0 text-[var(--color-brand)]" />
                    <CardTitle className="text-sm truncate">{note.title}</CardTitle>
                  </div>
                  <div className="flex items-center gap-1 shrink-0">
                    <Button
                      variant="ghost"
                      size="icon-sm"
                      onClick={() => handleTogglePin(note)}
                      title={note.pinned ? "Unpin" : "Pin"}
                    >
                      <Pin
                        className={`h-3.5 w-3.5 ${note.pinned ? "fill-[var(--color-brand)] text-[var(--color-brand)]" : "text-[var(--color-text-tertiary)]"}`}
                      />
                    </Button>
                    <Button
                      variant="ghost"
                      size="icon-sm"
                      onClick={() => setEditing(note)}
                      title="Edit"
                    >
                      <Pencil className="h-3.5 w-3.5 text-[var(--color-text-tertiary)]" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="icon-sm"
                      onClick={() => handleDelete(note.id)}
                      title="Delete"
                    >
                      <Trash2 className="h-3.5 w-3.5 text-[var(--color-negative)]" />
                    </Button>
                  </div>
                </div>
              </CardHeader>
              <CardContent className="flex-1">
                {note.content_markdown && (
                  <p className="text-xs text-[var(--color-text-tertiary)] line-clamp-3 whitespace-pre-wrap">
                    {note.content_markdown}
                  </p>
                )}
                {Array.isArray(note.tags) && note.tags.length > 0 && (
                  <div className="flex flex-wrap gap-1 mt-2">
                    {(note.tags as string[]).map((tag, i) => (
                      <span
                        key={i}
                        className="rounded bg-[var(--color-surface-raised)] px-1.5 py-0.5 text-[10px] text-[var(--color-text-secondary)]"
                      >
                        {tag}
                      </span>
                    ))}
                  </div>
                )}
              </CardContent>
              <div className="px-4 pb-3">
                <span className="text-[10px] text-[var(--color-text-disabled)]">
                  {note.pinned ? "Pinned • " : ""}
                  {formatRelativeTime(note.updated_at)}
                </span>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}

function NoteEditor({
  note,
  onSave,
  onCancel,
  loading,
  error,
}: {
  note: Note | null;
  onSave: (data: {
    id?: string;
    title: string;
    content_markdown: string;
    tags: string[];
    pinned: boolean;
  }) => void;
  onCancel: () => void;
  loading: boolean;
  error: string | null;
}) {
  const [title, setTitle] = useState(note?.title ?? "");
  const [content, setContent] = useState(note?.content_markdown ?? "");
  const [tagsInput, setTagsInput] = useState(
    Array.isArray(note?.tags) ? (note!.tags as string[]).join(", ") : "",
  );
  const [pinned, setPinned] = useState(note?.pinned ?? false);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const tags = tagsInput
      .split(",")
      .map((t) => t.trim())
      .filter(Boolean)
      .slice(0, 10);
    onSave({
      id: note?.id,
      title: title.trim(),
      content_markdown: content,
      tags,
      pinned,
    });
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">
          {note ? "Edit Note" : "New Note"}
        </h1>
        <Button variant="ghost" size="icon" onClick={onCancel}>
          <X className="h-4 w-4" />
        </Button>
      </div>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="space-y-2">
          <label className="text-sm font-medium text-[var(--color-text-primary)]">Title</label>
          <Input
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="e.g. Troubleshooting Playbook: Systemd"
            required
            maxLength={200}
          />
        </div>

        <div className="space-y-2">
          <label className="text-sm font-medium text-[var(--color-text-primary)]">Content</label>
          <textarea
            className="w-full rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] p-3 text-sm text-[var(--color-text-primary)] placeholder:text-[var(--color-text-disabled)] focus:border-[var(--color-brand)] focus:outline-none focus:ring-1 focus:ring-[var(--color-brand)] min-h-[300px] font-mono"
            value={content}
            onChange={(e) => setContent(e.target.value)}
            placeholder="Write your notes in markdown..."
            maxLength={50000}
          />
        </div>

        <div className="space-y-2">
          <label className="text-sm font-medium text-[var(--color-text-primary)]">
            Tags <span className="text-[var(--color-text-tertiary)]">(comma-separated, max 10)</span>
          </label>
          <Input
            value={tagsInput}
            onChange={(e) => setTagsInput(e.target.value)}
            placeholder="linux, systemd, troubleshooting"
          />
        </div>

        <label className="flex items-center gap-2 cursor-pointer">
          <input
            type="checkbox"
            checked={pinned}
            onChange={(e) => setPinned(e.target.checked)}
            className="h-4 w-4 rounded border-[var(--color-border)]"
          />
          <span className="text-sm text-[var(--color-text-secondary)]">Pin to top</span>
        </label>

        {error && <p className="text-xs text-red-400 font-medium">{error}</p>}

        <div className="flex gap-3">
          <Button type="submit" disabled={loading || !title.trim()}>
            {loading ? "Saving..." : note ? "Save Changes" : "Create Note"}
          </Button>
          <Button type="button" variant="outline" onClick={onCancel}>
            Cancel
          </Button>
        </div>
      </form>
    </div>
  );
}
