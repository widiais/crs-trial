import { cookies } from "next/headers";
import { headers } from "next/headers";
import {
  extractApiKeyFromRequest,
  validateApiKey,
} from "@/lib/api-key";

const SESSION_COOKIE_NAME = "session";
const SESSION_MAX_AGE = 60 * 60 * 24 * 7; // 7 days

// Allow secure cookie to be configured via env (default: true in production)
const getSecureCookie = () => {
  if (process.env.COOKIE_SECURE !== undefined) {
    return process.env.COOKIE_SECURE === "true";
  }
  return process.env.NODE_ENV === "production";
};

export async function createSession(userId: string = "default") {
  const cookieStore = await cookies();
  cookieStore.set(SESSION_COOKIE_NAME, userId, {
    httpOnly: true,
    secure: getSecureCookie(),
    sameSite: "lax",
    maxAge: SESSION_MAX_AGE,
    path: "/",
  });
}

export async function getSession(): Promise<string | null> {
  const cookieStore = await cookies();
  const session = cookieStore.get(SESSION_COOKIE_NAME);
  return session?.value ?? null;
}

export async function deleteSession() {
  const cookieStore = await cookies();
  cookieStore.delete(SESSION_COOKIE_NAME);
}

export async function isAuthenticated(): Promise<boolean> {
  const session = await getSession();
  return session !== null;
}

/**
 * Check authentication via session OR API key
 * Support untuk aplikasi web (session) dan aplikasi eksternal (API key)
 */
export async function isAuthenticatedOrHasApiKey(): Promise<boolean> {
  // Check session first (untuk aplikasi web)
  const session = await getSession();
  if (session) {
    return true;
  }

  // Check API key (untuk aplikasi eksternal)
  const headersList = await headers();
  const apiKey = extractApiKeyFromRequest(headersList);
  if (apiKey) {
    const validation = await validateApiKey(apiKey);
    return validation.valid;
  }

  return false;
}
