import { afterEach, describe, expect, it, vi } from "vitest";

import { ApiError, api } from "@/repositories/http-client";

// api() dipakai panel admin untuk memanggil Route Handler Next.js. Saat jaringan
// atau backend gagal, pemanggil harus menerima kode yang jelas (bukan crash).
afterEach(() => {
  vi.unstubAllGlobals();
});

function balasan(body: unknown, status: number): Response {
  return new Response(body === undefined ? null : JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}

describe("api() saat API gagal", () => {
  it("jaringan tidak terjangkau menjadi NETWORK (status 0)", async () => {
    vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new TypeError("failed to fetch")));

    const galat = await api("GET", "/api/admin/dashboard").catch((err) => err);

    expect(galat).toBeInstanceOf(ApiError);
    expect(galat).toMatchObject({ status: 0, code: "NETWORK" });
  });

  it("respons 500 memakai kode error dari backend", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(balasan({ error: "INTERNAL" }, 500)));

    await expect(api("GET", "/api/admin/dashboard")).rejects.toMatchObject({
      status: 500,
      code: "INTERNAL",
    });
  });

  it("respons gagal tanpa body JSON tetap memberi kode umum", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(balasan(undefined, 502)));

    await expect(api("GET", "/api/admin/dashboard")).rejects.toMatchObject({
      status: 502,
      code: "ERROR",
    });
  });

  it("respons sukses mengembalikan data", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(balasan({ ok: true, items: [1, 2] }, 200)));

    await expect(api("GET", "/api/admin/dashboard")).resolves.toEqual({ ok: true, items: [1, 2] });
  });
});
