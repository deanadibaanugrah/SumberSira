import { Modal, PrimaryButton, SecondaryButton, inputClass, labelClass } from "@/components/admin/ui";

// Isi form: "faq" = tambah/ubah FAQ, "jawab" = membalas pertanyaan pengunjung yang menunggu pengelola.
export type FormState =
  | { mode: "faq"; id?: string; question: string; answer: string; keywords: string }
  | { mode: "jawab"; id: string; question: string; answer: string; saveAsFaq: boolean };

type FormFaqProps = {
  form: FormState;
  saving: boolean;
  notice: string | null;
  onChange: (form: FormState) => void;
  onSave: (e) => void;
  onClose: () => void;
};

// Jendela form tambah, edit, atau jawab FAQ.
export default function FormFaq({ form, saving, notice, onChange, onSave, onClose }: FormFaqProps) {
  const jawab = form.mode === "jawab";
  return (
    <Modal title={jawab ? "Jawab Pertanyaan" : form.id ? "Edit FAQ" : "Tambah FAQ"} onClose={onClose}>
      <form onSubmit={onSave} className="space-y-3">
        <label className={labelClass}>Pertanyaan
          {jawab
            ? <p className="mt-1 rounded-xl bg-paper px-4 py-3 text-sm text-ink">{form.question}</p>
            : <input value={form.question} onChange={(e) => onChange({ ...form, question: e.target.value })} className={`${inputClass} mt-1`} maxLength={200} required />}
        </label>
        <label className={labelClass}>Jawaban
          <textarea value={form.answer} onChange={(e) => onChange({ ...form, answer: e.target.value })} rows={4} maxLength={1000}
                    className={`${inputClass} mt-1 h-auto! resize-none py-2.5`} required autoFocus />
        </label>
        {form.mode === "faq" && (
          <label className={labelClass}>Kata kunci tambahan (opsional, pisahkan dengan koma)
            <input value={form.keywords} onChange={(e) => onChange({ ...form, keywords: e.target.value })} className={`${inputClass} mt-1`} maxLength={200}
                   placeholder="mis. makanan, bekal, bawa makanan" />
          </label>
        )}
        {jawab && (
          <label className="flex items-start gap-2.5 rounded-xl bg-leaf/12 px-4 py-3 text-sm text-ink">
            <input type="checkbox" checked={form.saveAsFaq} onChange={(e) => onChange({ ...form, saveAsFaq: e.target.checked })} className="mt-0.5 size-4 accent-forest" />
            <span>Simpan juga sebagai FAQ, jadi pertanyaan serupa berikutnya langsung dijawab otomatis tanpa menunggu pengelola.</span>
          </label>
        )}
        {notice && <p role="alert" className="rounded-xl bg-coral/12 px-4 py-2.5 text-sm text-coral">{notice}</p>}
        <div className="flex justify-end gap-3 pt-2">
          <SecondaryButton onClick={onClose}>Batal</SecondaryButton>
          <PrimaryButton type="submit" className="h-11!" disabled={saving}>{saving ? "Menyimpan..." : jawab ? "Kirim Jawaban" : "Simpan"}</PrimaryButton>
        </div>
      </form>
    </Modal>
  );
}
