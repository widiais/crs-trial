import { NextResponse } from "next/server";
import { createSession } from "@/lib/session";

export async function POST() {
  try {
    // Simple login without authentication (for learning purposes)
    await createSession("user-1");
    
    return NextResponse.json(
      { success: true, message: "Logged in successfully" },
      { status: 200 }
    );
  } catch {
    return NextResponse.json(
      { success: false, message: "Login failed" },
      { status: 500 }
    );
  }
}
