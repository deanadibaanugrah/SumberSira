import { Modal, PrimaryButton, SecondaryButton, inputClass, labelClass } from "@/components/admin/ui";
import { PASSWORD_HINT } from "@/lib/validation/password";

// Isi form akun: id kosong = tambah akun baru (butuh email dan password).
export type FormStaff = {
  id?: string;
  name: string;
  email: string;
  role: "admin" | "petugas";
  active: boolean;
  password: string;
};

type FormStaffProps = {
  form: FormStaff;
  saving: boolean;
  notice: string | null;
  onChange: (form: FormStaff) => void;
  onSave: (e: React.FormEvent<HTMLFormElement>) => void;
  onClose: () => void;
};

// Jendela tambah atau ubah akun. Email hanya bisa diisi saat membuat akun baru.
export default function FormStaff({ form, saving, notice, onChange, onSave, onClose }: FormStaffProps) {
  const baru = !form.id;
  return (
    <Modal title={baru ? "Tambah Akun" : "Ubah Akun"} onClose={onClose}>
      <form onSubmit={onSave} className="space-y-3">
        <label className={labelClass}>Nama
          <input value={form.name} onChange={(e) => onChange({ ...form, name: e.target.value })} className={`${inputClass} mt-1`} maxLength={60} required autoFocus />
        </label>
        {baru ? (
          <>
            <label className={labelClass}>Email
              <input type="email" value={form.email} onChange={(e) => onChange({ ...form, email: e.target.value })} className={`${inputClass} mt-1`} required />
            </label>
            <label className={labelClass}>Password awal
              <input type="password" value={form.password} onChange={(e) => onChange({ ...form, password: e.target.value })} className={`${inputClass} mt-1`} minLength={8} maxLength={72} autoComplete="new-password" aria-describedby="syarat-password-staff" required />
              <span id="syarat-password-staff" className="mt-1 block font-sans text-[11px] font-normal text-abu">{PASSWORD_HINT}</span>
            </label>
          </>
        ) : (
          <p className="rounded-xl bg-paper px-4 py-3 text-sm text-abu">Email: <span className="font-semibold text-ink">{form.email}</span></p>
        )}
        <label className={labelClass}>Peran
          <select value={form.role} onChange={(e) => onChange({ ...form, role: e.target.value as "admin" | "petugas" })} className={`${inputClass} mt-1`}>
            <option value="petugas">Petugas Loket</option>
            <option value="admin">Pengelola (admin)</option>
          </select>
        </label>
        {!baru && (
          <label className="flex items-start gap-2.5 rounded-xl bg-leaf/12 px-4 py-3 text-sm text-ink">
            <input type="checkbox" checked={form.active} onChange={(e) => onChange({ ...form, active: e.target.checked })} className="mt-0.5 size-4 accent-forest" />
            <span>Aktif. Menonaktifkan akun langsung mencabut semua sesinya.</span>
          </label>
        )}
        {notice && <p role="alert" className="rounded-xl bg-coral/12 px-4 py-2.5 text-sm text-coral">{notice}</p>}
        <div className="flex justify-end gap-3 pt-2">
          <SecondaryButton disabled={saving} onClick={onClose}>Batal</SecondaryButton>
          <PrimaryButton type="submit" className="h-11!" disabled={saving}>{saving ? "Menyimpan..." : "Simpan"}</PrimaryButton>
        </div>
      </form>
    </Modal>
  );
}
