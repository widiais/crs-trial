"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";

export default function LoginPage() {
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const handleLogin = async () => {
    setLoading(true);
    try {
      const response = await fetch("/api/auth/login", {
        method: "POST",
      });

      if (response.ok) {
        router.push("/dashboard");
      } else {
        console.error("Login failed");
      }
    } catch (error) {
      console.error("Login error:", error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-background">
      <div className="w-full max-w-md space-y-8 rounded-lg border bg-card p-8 shadow-lg">
        <div className="text-center">
          <h1 className="text-3xl font-bold">Welcome</h1>
          <p className="mt-2 text-muted-foreground">
            Click the button below to login
          </p>
        </div>
        <Button
          onClick={handleLogin}
          disabled={loading}
          className="w-full"
          size="lg"
        >
          {loading ? "Logging in..." : "Login"}
        </Button>
      </div>
    </div>
  );
}
