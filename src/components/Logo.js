// Logo Sumber Sira (sama dengan komponen "Logo / Mark" di Figma):
// tetes air putih = mata air, tiga lapis sawah bertingkat = arti "sirah" (awal aliran air ke sawah),
// di dalam lingkaran Hijau Tua. Hanya memakai dua hijau dari palet.
// animated (bawaan aktif) = logo bergerak seperti GIF: tetes air naik turun, riak air melebar,
// dan lapisan sawah bergoyang pelan. Gerakan otomatis berhenti bila pengguna memilih "kurangi gerakan".
// ring = garis tepi putih tipis untuk dipasang di atas latar gelap atau foto (varian "latar gelap").
// label kosong = logo hanya hiasan (mis. di samping tulisan "Sumber Sira"), jadi disembunyikan dari pembaca layar.
// Pengaturan supaya animasi berputar dan bergeser dari titik tengah bentuknya sendiri.
const fillBox = { transformBox: "fill-box", transformOrigin: "center" };
// Memasang animasi CSS hanya kalau animated aktif.
const anim = (on, value, extra = {}) => (on ? { ...fillBox, animation: value, ...extra } : undefined);

// Komponen logo: lingkaran hijau berisi sawah, riak air, dan tetes air yang bergerak.
export default function LogoMark({ size = 40, ring = false, animated = true, label = "Logo Sumber Sira", className = "" }) {
  // Kalau label diisi, logo dibacakan pembaca layar. Kalau kosong, logo dianggap hiasan.
  const a11y = label ? { role: "img", "aria-label": label } : { "aria-hidden": true };
  return (
    <span {...a11y} style={{ width: size, height: size }}
          className={`relative inline-block shrink-0 overflow-hidden rounded-full ${className}`}>
      <svg viewBox="0 0 120 120" className="block size-full" aria-hidden="true">
        <rect width="120" height="120" fill="#1b4332" />
        {/* Lapisan sawah dibuat lebih lebar dari lingkaran supaya tidak terlihat ujungnya saat bergoyang. */}
        <path d="M-16 74 C10 64 46 70 60 70 C76 70 110 62 136 70 L136 124 L-16 124Z" fill="#40916c" fillOpacity="0.45"
              style={anim(animated, "logo-sway-a 6s ease-in-out infinite")} />
        <path d="M-16 88 C12 78 44 86 62 85 C80 84 112 76 136 84 L136 124 L-16 124Z" fill="#40916c" fillOpacity="0.72"
              style={anim(animated, "logo-sway-b 5s ease-in-out infinite")} />
        <path d="M-16 102 C14 92 46 100 64 99 C84 98 114 92 136 98 L136 124 L-16 124Z" fill="#40916c"
              style={anim(animated, "logo-sway-a 7s ease-in-out infinite reverse")} />
        {/* Dua riak air bergantian melebar dan memudar */}
        {animated && (
          <>
            <ellipse cx="60" cy="74" rx="16" ry="3.5" fill="none" stroke="#ffffff" strokeOpacity="0.85" strokeWidth="2"
                     style={anim(true, "logo-ripple 3s ease-out infinite")} />
            <ellipse cx="60" cy="74" rx="16" ry="3.5" fill="none" stroke="#ffffff" strokeOpacity="0.85" strokeWidth="2"
                     style={anim(true, "logo-ripple 3s ease-out 1.5s infinite")} />
          </>
        )}
        {/* Tetes air naik turun */}
        <g style={anim(animated, "logo-bob 3s ease-in-out infinite")}>
          <path d="M60 17 C60 17 43 37 43 50 A17 17 0 0 0 77 50 C77 37 60 17 60 17Z" fill="#ffffff" />
          <path d="M53 49 A8 8 0 0 0 58 58" fill="none" stroke="#40916c" strokeWidth="3" strokeLinecap="round" />
        </g>
      </svg>
      {/* Garis tepi putih untuk varian latar gelap */}
      {ring && (
        <span aria-hidden="true" className="absolute inset-0 rounded-full border-white/40"
              style={{ borderWidth: Math.max(1, Math.round((size * 4) / 120)), borderStyle: "solid" }} />
      )}
    </span>
  );
}
