import LogoMark from "@/components/Logo";

import { CrowdChip } from "./LoginWidgets";

// Layar kecil: logo, nama, dan chip keramaian di atas form (bagian kiri disembunyikan).
export default function BrandMobile() {
  return (
    <div className="mb-5 flex w-full max-w-[440px] flex-wrap items-center justify-between gap-3 text-white lg:hidden">
      <span className="flex items-center gap-2.5">
        <LogoMark size={40} ring label="" />
        <span className="font-display text-xl font-semibold">Sumber Sira</span>
      </span>
      <CrowdChip />
    </div>
  );
}
