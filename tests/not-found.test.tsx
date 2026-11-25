import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";

import NotFound from "@/app/not-found";

// Halaman 404 harus tampil jelas dan punya jalan kembali ke dashboard.
describe("halaman 404", () => {
  it("menampilkan pesan tidak ditemukan dan tautan dashboard", () => {
    render(<NotFound />);

    expect(screen.getByText("Halaman tidak ditemukan")).toBeTruthy();

    const tautan = screen.getByRole("link", { name: /buka dashboard/i });
    expect(tautan.getAttribute("href")).toBe("/admin");
  });
});
