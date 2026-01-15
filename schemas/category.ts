import { z } from "zod";

export const categorySchema = z.object({
  name: z.string().min(1, "Name is required").max(255, "Name is too long"),
  active: z.boolean().default(true),
});

export const categoryUpdateSchema = categorySchema.partial();

export type CategoryInput = z.infer<typeof categorySchema>;
export type CategoryUpdateInput = z.infer<typeof categoryUpdateSchema>;
