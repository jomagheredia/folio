export function csrfToken(): string {
  if (typeof document === "undefined") return ""
  return document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") ?? ""
}
