"use client";

import { useEffect, useState, useRef } from "react";
import { Bell, Check, Trash } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import type { Database } from "@/lib/database.types";
import { useRouter } from "next/navigation";

type Notification = Database["public"]["Tables"]["notifications"]["Row"];

export function NotificationBell() {
  const router = useRouter();
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const unreadCount = notifications.filter((n) => !n.is_read).length;

  useEffect(() => {
    const supabase = createClient();
    
    // Fetch initial notifications
    async function fetchNotifications() {
      const { data: { session } } = await supabase.auth.getSession();
      if (!session) return;

      const { data, error } = await supabase
        .from("notifications")
        .select("*")
        .order("created_at", { ascending: false })
        .limit(20);

      if (!error && data) {
        setNotifications(data);
      }
    }
    
    fetchNotifications();

    // Subscribe to realtime changes
    const channel = supabase
      .channel("notifications_channel")
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "notifications" },
        (payload) => {
          if (payload.eventType === "INSERT") {
            setNotifications((prev) => [payload.new as Notification, ...prev].slice(0, 20));
          } else if (payload.eventType === "UPDATE") {
            setNotifications((prev) =>
              prev.map((n) => (n.id === payload.new.id ? (payload.new as Notification) : n))
            );
          }
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, []);

  // Handle clicking outside to close
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  async function markAsRead(id: string) {
    const supabase = createClient();
    await supabase.from("notifications").update({ is_read: true }).eq("id", id);
    // Realtime will update the state, but we can optimistically update
    setNotifications((prev) =>
      prev.map((n) => (n.id === id ? { ...n, is_read: true } : n))
    );
  }

  async function markAllAsRead() {
    const supabase = createClient();
    const unreadIds = notifications.filter(n => !n.is_read).map(n => n.id);
    if (unreadIds.length === 0) return;

    await supabase.from("notifications").update({ is_read: true }).in("id", unreadIds);
    setNotifications((prev) =>
      prev.map((n) => ({ ...n, is_read: true }))
    );
  }

  function handleNotificationClick(notification: Notification) {
    if (!notification.is_read) {
      markAsRead(notification.id);
    }
    if (notification.link) {
      setIsOpen(false);
      router.push(notification.link);
    }
  }

  return (
    <div className="relative" ref={dropdownRef}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="relative flex h-9 w-9 items-center justify-center rounded-lg hover:bg-[var(--color-surface-raised)] transition-colors text-[var(--color-text-secondary)]"
        aria-label="Notifications"
      >
        <Bell className="h-5 w-5" />
        {unreadCount > 0 && (
          <span className="absolute right-2 top-2 flex h-2 w-2 items-center justify-center rounded-full bg-[var(--color-negative)] ring-2 ring-[var(--color-surface)]">
            <span className="sr-only">{unreadCount} unread</span>
          </span>
        )}
      </button>

      {isOpen && (
        <div className="absolute right-0 top-full mt-2 w-80 rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] shadow-lg sm:w-96 glass-panel p-0 overflow-hidden">
          <div className="flex items-center justify-between border-b border-[var(--color-border)] p-3">
            <h3 className="text-sm font-semibold text-[var(--color-text-primary)]">Notifications</h3>
            {unreadCount > 0 && (
              <button
                onClick={markAllAsRead}
                className="text-[11px] font-medium text-[var(--color-brand)] hover:underline flex items-center gap-1"
              >
                <Check className="h-3 w-3" />
                Mark all as read
              </button>
            )}
          </div>
          
          <div className="max-h-[60vh] overflow-y-auto">
            {notifications.length === 0 ? (
              <div className="p-6 text-center text-xs text-[var(--color-text-tertiary)]">
                You have no notifications.
              </div>
            ) : (
              <div className="flex flex-col">
                {notifications.map((notification) => (
                  <button
                    key={notification.id}
                    onClick={() => handleNotificationClick(notification)}
                    className={`flex flex-col items-start gap-1 border-b border-[var(--color-border)] p-3 text-left transition-colors last:border-0 hover:bg-[var(--color-surface-raised)] ${
                      !notification.is_read ? "bg-[var(--color-brand-soft)]/30" : ""
                    }`}
                  >
                    <div className="flex w-full items-start justify-between gap-2">
                      <span className={`text-sm ${!notification.is_read ? 'font-semibold text-[var(--color-text-primary)]' : 'font-medium text-[var(--color-text-secondary)]'}`}>
                        {notification.title}
                      </span>
                      {!notification.is_read && (
                        <span className="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-[var(--color-brand)]" />
                      )}
                    </div>
                    <span className="text-xs text-[var(--color-text-tertiary)] line-clamp-2">
                      {notification.message}
                    </span>
                    <span className="mt-1 text-[10px] text-[var(--color-text-disabled)] tabular">
                      {new Date(notification.created_at).toLocaleDateString()}
                    </span>
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
