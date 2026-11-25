import { fireEvent, render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

import ErrorPage from "@/app/error";

// Error boundary tidak boleh membocorkan pesan internal ke pengguna, dan tombol
// "Coba lagi" harus memanggil reset() dari Next.js.
describe("error boundary halaman", () => {
  it("menampilkan pesan aman, kode kejadian, dan memanggil reset", () => {
    const reset = vi.fn();
    const error = Object.assign(new Error("detail internal yang rahasia"), { digest: "abc123" });

    render(<ErrorPage error={error} reset={reset} />);

    expect(screen.getByText("Halaman gagal dimuat")).toBeTruthy();
    expect(screen.getByText(/Kode kejadian: abc123/)).toBeTruthy();
    expect(screen.queryByText(/detail internal yang rahasia/)).toBeNull();

    fireEvent.click(screen.getByRole("button", { name: /coba lagi/i }));
    expect(reset).toHaveBeenCalledTimes(1);
  });
});
