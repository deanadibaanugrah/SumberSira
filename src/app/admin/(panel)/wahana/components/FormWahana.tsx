import { Modal, PrimaryButton, SecondaryButton, inputClass, labelClass } from "@/components/admin/ui";

type FormWahanaProps = {
  form;
  onChange: (form) => void;
  error: string;
  pending: boolean;
  onSave: (e) => void;
  onClose: () => void;
};

// Jendela form tambah atau edit wahana.
export default function FormWahana({ form, onChange, error, pending, onSave, onClose }: FormWahanaProps) {
  return (
    <Modal title={form.id ? "Edit Wahana" : "Tambah Wahana"} onClose={onClose}>
      <form onSubmit={onSave} className="space-y-3">
        <label className={labelClass}>Nama wahana
          <input value={form.name} onChange={(e) => onChange({ ...form, name: e.target.value })} className={`${inputClass} mt-1`} required autoFocus />
        </label>
        <div className="grid grid-cols-2 gap-3">
          <label className={labelClass}>Kategori
            <select value={form.category} onChange={(e) => onChange({ ...form, category: e.target.value })} className={`${inputClass} mt-1`}>
              <option>Wahana</option><option>Sewa Alat</option>
            </select>
          </label>
          <label className={labelClass}>Status
            <select value={form.status} onChange={(e) => onChange({ ...form, status: e.target.value })} className={`${inputClass} mt-1`}>
              <option>Aktif</option><option>Nonaktif</option>
            </select>
          </label>
          <label className={labelClass}>Harga (Rp)
            <input type="number" min="0" step="500" value={form.price} onChange={(e) => onChange({ ...form, price: e.target.value })}
                   className={`${inputClass} mt-1`} required />
          </label>
          <label className={labelClass}>Satuan (opsional)
            <input value={form.unit} onChange={(e) => onChange({ ...form, unit: e.target.value })} placeholder="kepala / 15 menit"
                   className={`${inputClass} mt-1`} />
          </label>
        </div>
        {error && <p role="alert" className="rounded-2xl bg-coral/12 px-4 py-2.5 text-sm text-coral">{error}</p>}
        <div className="flex justify-end gap-3 pt-2">
          <SecondaryButton onClick={onClose}>Batal</SecondaryButton>
          <PrimaryButton type="submit" className="h-11!" disabled={pending}>{pending ? "Menyimpan..." : "Simpan"}</PrimaryButton>
        </div>
      </form>
    </Modal>
  );
}
