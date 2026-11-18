// Kerangka yang tampil seketika saat pindah halaman admin, selagi server menyiapkan halaman berikutnya.
// Sidebar tidak ikut dimuat ulang (ada di layout), jadi pindah halaman terasa langsung merespons.
export default function PanelLoading() {
  return (
    <div role="status" aria-busy="true" aria-label="Memuat halaman" className="animate-pulse">
      <div className="glass-light flex h-[76px] items-center rounded-[28px] pl-[72px] pr-6 lg:pl-6">
        <div className="space-y-2.5">
          <div className="h-5 w-48 rounded-full bg-ink/10" />
          <div className="h-3 w-72 max-w-[60vw] rounded-full bg-ink/[0.07]" />
        </div>
      </div>
      <div className="mt-6 grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
        {[0, 1, 2, 3].map((i) => <div key={i} className="h-28 rounded-3xl bg-white" />)}
      </div>
      <div className="mt-5 grid grid-cols-1 gap-5 xl:grid-cols-[736fr_380fr]">
        <div className="h-80 rounded-3xl bg-white" />
        <div className="h-80 rounded-3xl bg-white" />
      </div>
      <span className="sr-only">Memuat halaman...</span>
    </div>
  );
}
