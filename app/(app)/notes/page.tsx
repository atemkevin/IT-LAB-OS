/**
 * /notes — Lab Notes
 * Server Component. Fetches user's notes from Supabase, passes to client for interactivity.
 */
import { createClient } from "@/lib/supabase/server";
import NotesClient from "./notes-client";
import type { Note } from "@/lib/database.types";

export default async function NotesPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  let notes: Note[] = [];

  if (user) {
    const { data } = await supabase
      .from("notes")
      .select("*")
      .eq("user_id", user.id)
      .order("pinned", { ascending: false })
      .order("updated_at", { ascending: false });

    notes = (data ?? []) as Note[];
  }

  return <NotesClient initialNotes={notes} />;
}
