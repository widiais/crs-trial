import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "CRS Trial",
  description: "CRUD Application for VPS Deployment",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
