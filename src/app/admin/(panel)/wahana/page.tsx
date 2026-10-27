import { getWahanaForAdmin } from "@/lib/auth/dal";

import WahanaView from "./components/WahanaView";

// Halaman server: data wahana dibaca lewat DAL (izin "wahana:lihat" dicek di sana),
// lalu dikirim ke tampilan beserta tanda boleh-tidaknya mengubah data.
export default async function WahanaPage() {
  const { items, canEdit } = await getWahanaForAdmin();
  return <WahanaView initialItems={items} canEdit={canEdit} />;
}
