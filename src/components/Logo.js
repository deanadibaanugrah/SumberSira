// Logo Sumber Sira (sama dengan komponen "Logo / Mark" di Figma):
// tetes air putih = mata air, tiga lapis sawah bertingkat = arti "sirah" (awal aliran air ke sawah),
// di dalam lingkaran Hijau Tua. Hanya memakai dua hijau dari palet.
// ring = garis tepi putih tipis untuk dipasang di atas latar gelap atau foto (varian "latar gelap").
// label kosong = logo hanya hiasan (mis. di samping tulisan "Sumber Sira"), jadi disembunyikan dari pembaca layar.
export default function LogoMark({ size = 40, ring = false, label = "Logo Sumber Sira", className = "" }) {
  const a11y = label ? { role: "img", "aria-label": label } : { "aria-hidden": true };
  return (
    <span {...a11y} style={{ width: size, height: size }}
          className={`relative inline-block shrink-0 overflow-hidden rounded-full ${className}`}>
      <svg viewBox="0 0 120 120" className="block size-full" aria-hidden="true">
        <rect width="120" height="120" fill="#1b4332" />
        <path d="M-4 74 C22 64 46 70 60 70 C76 70 98 62 124 70 L124 124 L-4 124Z" fill="#40916c" fillOpacity="0.45" />
        <path d="M-4 88 C24 78 44 86 62 85 C80 84 100 76 124 84 L124 124 L-4 124Z" fill="#40916c" fillOpacity="0.72" />
        <path d="M-4 102 C26 92 46 100 64 99 C84 98 102 92 124 98 L124 124 L-4 124Z" fill="#40916c" />
        <path d="M60 17 C60 17 43 37 43 50 A17 17 0 0 0 77 50 C77 37 60 17 60 17Z" fill="#ffffff" />
        <path d="M53 49 A8 8 0 0 0 58 58" fill="none" stroke="#40916c" strokeWidth="3" strokeLinecap="round" />
      </svg>
      {ring && (
        <span aria-hidden="true" className="absolute inset-0 rounded-full border-white/40"
              style={{ borderWidth: Math.max(1, Math.round((size * 4) / 120)), borderStyle: "solid" }} />
      )}
    </span>
  );
}
