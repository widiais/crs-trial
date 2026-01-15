import { NextRequest, NextResponse } from "next/server";
import { db } from "@/lib/db";
import { isAuthenticated } from "@/lib/session";
import { generateApiKey, hashApiKey } from "@/lib/api-key";
import { z } from "zod";

// Schema untuk validasi create API key
const createApiKeySchema = z.object({
  name: z.string().min(1, "Name is required").max(100),
  expiresAt: z.string().datetime().optional().nullable(),
});

// GET - List semua API keys (hanya tampilkan info, tidak tampilkan key yang sebenarnya)
export async function GET() {
  try {
    // Hanya bisa diakses via session (admin/dashboard)
    const authenticated = await isAuthenticated();
    if (!authenticated) {
      return NextResponse.json(
        { error: "Unauthorized" },
        { status: 401 }
      );
    }

    const apiKeys = await db.apiKey.findMany({
      select: {
        id: true,
        name: true,
        active: true,
        lastUsedAt: true,
        expiresAt: true,
        createdAt: true,
        updatedAt: true,
        // Jangan return key atau keyHash untuk security
      },
      orderBy: { createdAt: "desc" },
    });

    return NextResponse.json(apiKeys);
  } catch (error) {
    console.error("Error fetching API keys:", error);
    return NextResponse.json(
      { error: "Failed to fetch API keys" },
      { status: 500 }
    );
  }
}

// POST - Create new API key
export async function POST(request: NextRequest) {
  try {
    // Hanya bisa diakses via session (admin/dashboard)
    const authenticated = await isAuthenticated();
    if (!authenticated) {
      return NextResponse.json(
        { error: "Unauthorized" },
        { status: 401 }
      );
    }

    const body = await request.json();
    const validatedData = createApiKeySchema.parse(body);

    // Generate API key
    const apiKey = generateApiKey();
    const keyHash = hashApiKey(apiKey);

    // Simpan ke database
    const apiKeyRecord = await db.apiKey.create({
      data: {
        name: validatedData.name,
        key: apiKey, // Simpan plain key hanya sekali (untuk ditampilkan ke user)
        keyHash: keyHash, // Hash untuk validasi
        expiresAt: validatedData.expiresAt
          ? new Date(validatedData.expiresAt)
          : null,
      },
      select: {
        id: true,
        name: true,
        key: true, // Return plain key hanya saat create
        active: true,
        expiresAt: true,
        createdAt: true,
      },
    });

    // ⚠️ PENTING: Key hanya ditampilkan sekali saat create
    // Simpan key ini dengan baik, karena tidak akan ditampilkan lagi
    return NextResponse.json(
      {
        ...apiKeyRecord,
        message:
          "⚠️ Simpan API key ini dengan baik! Key ini tidak akan ditampilkan lagi.",
      },
      { status: 201 }
    );
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: "Validation error", details: error.errors },
        { status: 400 }
      );
    }
    console.error("Error creating API key:", error);
    return NextResponse.json(
      { error: "Failed to create API key" },
      { status: 500 }
    );
  }
}

// DELETE - Delete API key
export async function DELETE(request: NextRequest) {
  try {
    // Hanya bisa diakses via session (admin/dashboard)
    const authenticated = await isAuthenticated();
    if (!authenticated) {
      return NextResponse.json(
        { error: "Unauthorized" },
        { status: 401 }
      );
    }

    const { searchParams } = new URL(request.url);
    const id = searchParams.get("id");

    if (!id) {
      return NextResponse.json(
        { error: "API key ID is required" },
        { status: 400 }
      );
    }

    await db.apiKey.delete({
      where: { id },
    });

    return NextResponse.json({ success: true, message: "API key deleted" });
  } catch (error) {
    console.error("Error deleting API key:", error);
    return NextResponse.json(
      { error: "Failed to delete API key" },
      { status: 500 }
    );
  }
}

// PATCH - Update API key (activate/deactivate)
export async function PATCH(request: NextRequest) {
  try {
    // Hanya bisa diakses via session (admin/dashboard)
    const authenticated = await isAuthenticated();
    if (!authenticated) {
      return NextResponse.json(
        { error: "Unauthorized" },
        { status: 401 }
      );
    }

    const body = await request.json();
    const { id, active } = body;

    if (!id || typeof active !== "boolean") {
      return NextResponse.json(
        { error: "ID and active status are required" },
        { status: 400 }
      );
    }

    const apiKey = await db.apiKey.update({
      where: { id },
      data: { active },
      select: {
        id: true,
        name: true,
        active: true,
        updatedAt: true,
      },
    });

    return NextResponse.json(apiKey);
  } catch (error) {
    console.error("Error updating API key:", error);
    return NextResponse.json(
      { error: "Failed to update API key" },
      { status: 500 }
    );
  }
}