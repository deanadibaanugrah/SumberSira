/**
 * Instrumentation Next.js (App Router).
 *
 * `onRequestError` dipanggil otomatis oleh server Next.js ketika terjadi galat
 * saat render Server Component, Route Handler, Server Action, atau proxy.
 * Semua galat server jadi tercatat di satu tempat tanpa perlu try/catch di
 * setiap halaman.
 *
 * Keamanan log:
 * - Hanya path, method, jenis route, nama galat, pesan, dan digest yang dicatat.
 * - Header request (cookie, authorization), body, dan data pengguna TIDAK dicatat.
 */
export async function onRequestError(
  error: unknown,
  request: Readonly<{
    path: string;
    method: string;
    headers: Record<string, string | string[] | undefined>;
  }>,
  context: Readonly<{
    routerKind: "Pages Router" | "App Router";
    routePath: string;
    routeType: "render" | "route" | "action" | "proxy";
    renderSource?: string;
    revalidateReason?: string;
  }>
) {
  const err = (error ?? {}) as {
    name?: string;
    message?: string;
    digest?: string;
    stack?: string;
  };

  console.error(
    JSON.stringify({
      level: "error",
      scope: "next-request-error",
      time: new Date().toISOString(),
      path: request?.path,
      method: request?.method,
      routerKind: context?.routerKind,
      routePath: context?.routePath,
      routeType: context?.routeType,
      renderSource: context?.renderSource ?? null,
      name: err.name ?? "Error",
      message: err.message ?? String(error),
      digest: err.digest ?? null,
      stack: err.stack ?? null,
    })
  );
}
