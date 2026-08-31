import { csrfToken } from "@/lib/csrf"

export type AiResult = {
  ok: boolean
  error: string | null
  description?: string | null
  tags?: string[] | null
  summary?: string | null
}

export async function requestAi(url: string): Promise<AiResult> {
  try {
    const response = await fetch(url, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "X-CSRF-Token": csrfToken(),
      },
    })
    const contentType = response.headers.get("content-type") || ""
    if (!contentType.includes("application/json")) {
      return { ok: false, error: "AI isn't available right now." }
    }
    return (await response.json()) as AiResult
  } catch {
    return { ok: false, error: "AI isn't available right now." }
  }
}
