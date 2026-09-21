import { SupabaseClient } from "@supabase/supabase-js";

export async function createNotification(
  supabase: SupabaseClient,
  userId: string,
  type: string,
  title: string,
  message: string,
  link?: string,
) {

  const { error } = await supabase.from("notifications").insert({
    user_id: userId,
    type,
    title,
    message,
    link,
  });

  if (error) {
    console.error("Failed to create notification:", error);
    throw new Error("Failed to create notification");
  }
}
