import { Lock } from "lucide-react";

// Pemberitahuan untuk peran tanpa izin ubah dan pesan error dari server.
// Peran tanpa izin ubah: diberi tahu di tampilan, tapi penolakan sebenarnya tetap dari server.
export default function PesanAkses({ canEdit, error }: { canEdit: boolean; error: string }) {
  return (
    <>
      {!canEdit && (
        <p className="mt-5 flex items-start gap-2 rounded-2xl bg-leaf/[0.08] px-4 py-3 text-sm text-forest">
          <Lock size={16} className="mt-0.5 shrink-0" />
          Akun Petugas Loket hanya bisa melihat daftar harga. Tombol ubah tetap ditampilkan untuk demo:
          server akan menolaknya dengan FORBIDDEN.
        </p>
      )}
      {error && <p role="alert" className="mt-5 rounded-2xl bg-coral/12 px-4 py-3 text-sm text-coral">{error}</p>}
    </>
  );
}
