// Judul tab untuk halaman admin.
export const metadata = {
  title: "Admin Panel · Sumber Sira",
};

// Kerangka paling luar URL /admin/... Halaman login tampil sendiri; halaman yang wajib login
// ada di grup (panel) yang punya sidebar dan pengecekan sesi.
export default function AdminLayout({ children }) {
  return children;
}
