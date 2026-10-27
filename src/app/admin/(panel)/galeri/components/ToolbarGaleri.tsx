import { ChevronDown, LayoutGrid, List } from "lucide-react";

import { FilterPills } from "@/components/admin/ui";

// Pilihan filter status foto.
const FILTERS = ["Semua", "Baru", "Ditampilkan", "Ditolak"];

type ToolbarGaleriProps = {
  filter: string;
  onFilter: (value: string) => void;
  sort: string;
  onSort: (value: string) => void;
  view: string;
  onView: (value: string) => void;
};

// Baris filter, urutan, dan tombol ganti tampilan grid atau list.
export default function ToolbarGaleri({ filter, onFilter, sort, onSort, view, onView }: ToolbarGaleriProps) {
  return (
    <div className="mt-6 flex flex-wrap items-center justify-between gap-4">
      <FilterPills options={FILTERS} value={filter} onChange={onFilter} label="Filter status foto" />
      <div className="flex items-center gap-4">
        <label className="relative">
          <span className="sr-only">Urutkan</span>
          <ChevronDown size={16} className="pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-ink" aria-hidden="true" />
          <select value={sort} onChange={(e) => onSort(e.target.value)}
                  className="h-10 appearance-none rounded-full border border-ink/10 bg-white pl-10 pr-5 text-sm text-ink outline-none focus:ring-2 focus:ring-leaf/30">
            <option>Terbaru</option>
            <option>Terlama</option>
          </select>
        </label>
        <div className="flex rounded-full bg-white p-1" role="group" aria-label="Tampilan">
          {([["grid", LayoutGrid, "Tampilan grid"], ["list", List, "Tampilan daftar"]] as const).map(([key, Icon, label]) => (
            <button key={key} type="button" aria-label={label} aria-pressed={view === key} onClick={() => onView(key)}
                    className={`grid size-9 place-items-center rounded-full transition ${view === key ? "bg-forest text-white" : "text-ink hover:bg-paper"}`}>
              <Icon size={18} />
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
