/** @type {import('next').NextConfig} */
const securityHeaders = [
  // Jangan biarkan browser menebak tipe file (mencegah HTML/JS disisipkan lewat unggahan).
  { key: "X-Content-Type-Options", value: "nosniff" },
  // Halaman tidak boleh dibingkai situs lain (anti clickjacking).
  { key: "X-Frame-Options", value: "DENY" },
  // Kirim referrer secukupnya, jangan seluruh URL saat pindah ke situs lain.
  { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
  // Matikan fitur perangkat yang tidak dipakai aplikasi.
  { key: "Permissions-Policy", value: "camera=(), microphone=(), geolocation=()" },
  // Pisahkan browsing context dari situs lain.
  { key: "Cross-Origin-Opener-Policy", value: "same-origin" },
];

const nextConfig = {
  // Sembunyikan tombol bulat "N" di pojok kiri bawah saat `npm run dev` supaya tidak menutupi
  // navigasi bawah aplikasi mobile. Pesan error build tetap muncul.
  devIndicators: false,
  // Jangan bocorkan "X-Powered-By: Next.js".
  poweredByHeader: false,
  experimental: {
    // Mengaktifkan forbidden() (halaman 403) yang dipakai DAL saat peran admin tidak punya izin.
    authInterrupts: true,
  },
  async headers() {
    return [
      {
        // Semua route, termasuk halaman admin dan API internal.
        source: "/:path*",
        headers: [
          ...securityHeaders,
          // HSTS hanya saat produksi (butuh HTTPS). Di localhost jangan dikirim.
          ...(process.env.NODE_ENV === "production"
            ? [{ key: "Strict-Transport-Security", value: "max-age=31536000; includeSubDomains" }]
            : []),
        ],
      },
    ];
  },
};

export default nextConfig;
