import { requirePermission } from "@/lib/auth/dal";

import BookingView from "./components/BookingView";

// Halaman server: cek login dan izin "booking" dulu (DAL), baru tampilkan halaman Booking.
export default async function BookingPage() {
  await requirePermission("booking");
  return <BookingView />;
}
