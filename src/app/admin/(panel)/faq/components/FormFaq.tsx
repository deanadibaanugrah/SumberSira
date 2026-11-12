import { Modal, PrimaryButton, SecondaryButton, inputClass, labelClass } from "@/components/admin/ui";

type FormFaqProps = {
  form; // { id?, q, a, fromPending? }
  onChange: (form) => void;
  onSave: (e) => void;
  onClose: () => void;
};

// Jendela form tambah, edit, atau jawab FAQ.
export default function FormFaq({ form, onChange, onSave, onClose }: FormFaqProps) {
  return (
    <Modal title={form.fromPending ? "Jawab Pertanyaan" : form.id ? "Edit FAQ" : "Tambah FAQ"} onClose={onClose}>
      <form onSubmit={onSave} className="space-y-3">
        <label className={labelClass}>Pertanyaan
          <input value={form.q} onChange={(e) => onChange({ ...form, q: e.target.value })} className={`${inputClass} mt-1`} required />
        </label>
        <label className={labelClass}>Jawaban
          <textarea value={form.a} onChange={(e) => onChange({ ...form, a: e.target.value })} rows={4}
                    className={`${inputClass} mt-1 h-auto! resize-none py-2.5`} required autoFocus />
        </label>
        <div className="flex justify-end gap-3 pt-2">
          <SecondaryButton onClick={onClose}>Batal</SecondaryButton>
          <PrimaryButton type="submit" className="h-11!">Simpan</PrimaryButton>
        </div>
      </form>
    </Modal>
  );
}
