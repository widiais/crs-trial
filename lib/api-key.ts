import { db } from "@/lib/db";
import { randomBytes, createHash } from "crypto";

/**
 * Generate a new API key
 * Format: crs_<random_32_chars>
 */
export function generateApiKey(): string {
  const randomPart = randomBytes(16).toString("hex");
  return `crs_${randomPart}`;
}

/**
 * Hash API key untuk disimpan di database
 */
export function hashApiKey(key: string): string {
  return createHash("sha256").update(key).digest("hex");
}

/**
 * Validasi API key dari request header
 * Mencari API key di header 'X-API-Key' atau 'Authorization: Bearer <key>'
 */
export async function validateApiKey(
  apiKey: string | null
): Promise<{ valid: boolean; keyId?: string }> {
  if (!apiKey) {
    return { valid: false };
  }

  try {
    // Hash the provided key
    const keyHash = hashApiKey(apiKey);

    // Cari di database
    const apiKeyRecord = await db.apiKey.findUnique({
      where: { keyHash },
      select: { id: true, active: true, expiresAt: true },
    });

    if (!apiKeyRecord) {
      return { valid: false };
    }

    // Check if key is active
    if (!apiKeyRecord.active) {
      return { valid: false };
    }

    // Check if key has expired
    if (apiKeyRecord.expiresAt && apiKeyRecord.expiresAt < new Date()) {
      return { valid: false };
    }

    // Update last used timestamp
    await db.apiKey.update({
      where: { id: apiKeyRecord.id },
      data: { lastUsedAt: new Date() },
    });

    return { valid: true, keyId: apiKeyRecord.id };
  } catch (error) {
    console.error("Error validating API key:", error);
    return { valid: false };
  }
}

/**
 * Extract API key dari request headers
 * Support format:
 * - X-API-Key: <key>
 * - Authorization: Bearer <key>
 */
export function extractApiKeyFromRequest(
  headers: Headers
): string | null {
  // Try X-API-Key header first
  const apiKeyHeader = headers.get("x-api-key");
  if (apiKeyHeader) {
    return apiKeyHeader;
  }

  // Try Authorization header
  const authHeader = headers.get("authorization");
  if (authHeader && authHeader.startsWith("Bearer ")) {
    return authHeader.substring(7);
  }

  return null;
}