import { CrowdWidget, RatingWidget, TiketWidget } from "./LoginWidgets";

// Layar sedang (tablet/laptop kecil): widget live ditampilkan di bawah form.
export default function WidgetTablet() {
  return (
    <div className="mt-6 hidden w-full max-w-[720px] grid-cols-3 gap-4 md:grid lg:hidden">
      <CrowdWidget />
      <TiketWidget />
      <RatingWidget />
    </div>
  );
}
