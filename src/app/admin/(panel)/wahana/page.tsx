import { getPricingForAdmin, getWahanaForAdmin } from "@/lib/auth/dal";

import WahanaView from "./components/WahanaView";

// Halaman server: data wahana dan harga dibaca lewat DAL (izin dicek di sana),
// lalu dikirim ke tampilan beserta tanda boleh-tidaknya mengubah data.
export default async function WahanaPage() {
  const { items, canEdit } = await getWahanaForAdmin();
  const { pricing, canEdit: canEditPricing, error: pricingError } = await getPricingForAdmin();
  return <WahanaView initialItems={items} canEdit={canEdit} initialPricing={pricing} pricingError={pricingError} canEditPricing={canEditPricing} />;
}
