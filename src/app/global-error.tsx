"use client";

import { useEffect } from "react";

// Error boundary untuk kegagalan di root layout. Karena root layout gagal,
// halaman ini harus menyediakan <html> dan <body> sendiri, dan tidak boleh
// bergantung pada stylesheet global. Karena itu gaya ditulis inline.
export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error("Galat root layout:", error);
  }, [error]);

  return (
    <html lang="id">
      <body
        style={{
          margin: 0,
          minHeight: "100vh",
          display: "grid",
          placeItems: "center",
          padding: "24px",
          background: "#f5f6f5",
          color: "#172321",
          fontFamily: "system-ui, -apple-system, Segoe UI, sans-serif",
        }}
      >
        <main
          style={{
            width: "100%",
            maxWidth: "28rem",
            padding: "32px",
            borderRadius: "24px",
            background: "#ffffff",
            textAlign: "center",
            boxShadow: "0 8px 30px rgba(23,35,33,0.06)",
          }}
        >
          <p style={{ margin: 0, fontSize: "12px", letterSpacing: "0.18em", textTransform: "uppercase", color: "#4b5a57" }}>
            Terjadi kesalahan
          </p>
          <h1 style={{ margin: "8px 0 0", fontSize: "24px", color: "#172321" }}>Aplikasi gagal dimuat</h1>
          <p style={{ marginTop: "8px", fontSize: "14px", lineHeight: 1.6, color: "#4b5a57" }}>
            Maaf, terjadi kendala saat memuat aplikasi. Coba muat ulang. Bila tetap gagal,
            hubungi pengelola dan sebutkan kode kejadian di bawah.
          </p>
          {error.digest ? (
            <p style={{ marginTop: "12px", fontSize: "11px", color: "#4b5a57" }}>
              Kode kejadian: {error.digest}
            </p>
          ) : null}
          <button
            type="button"
            onClick={() => reset()}
            style={{
              marginTop: "24px",
              height: "44px",
              padding: "0 20px",
              borderRadius: "999px",
              border: "none",
              background: "#1b4332",
              color: "#ffffff",
              fontSize: "14px",
              fontWeight: 600,
              cursor: "pointer",
            }}
          >
            Muat ulang
          </button>
        </main>
      </body>
    </html>
  );
}
