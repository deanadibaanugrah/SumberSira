// Tujuan setelah login hanya boleh halaman di dalam /admin (mencegah open redirect ke situs lain lewat ?next=).
export function safeAdminPath(next: unknown): string {
  if (typeof next !== "string") return "/admin";
  return /^\/admin(\/[\w-]+)*\/?$/.test(next) && !next.startsWith("/admin/login") ? next : "/admin";
}
