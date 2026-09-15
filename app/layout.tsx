import type { Metadata, Viewport } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "IT Lab OS",
    template: "%s | IT Lab OS",
  },
  description:
    "A personal technical learning operating system. Learn → Practice → Test → Troubleshoot → Build → Review.",
  robots: {
    index: false, // Private single-user app
    follow: false,
  },
};

export const viewport: Viewport = {
  themeColor: "#0d0f14",
  width: "device-width",
  initialScale: 1,
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className="antialiased">{children}</body>
    </html>
  );
}
