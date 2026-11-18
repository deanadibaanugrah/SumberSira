import { requirePermission } from "@/lib/auth/dal";
import { can } from "@/lib/auth/roles";

import BookingView from "./components/BookingView";

// Halaman server: cek login dan izin "booking" dulu (DAL), baru tampilkan halaman Booking.
// canKelola: hanya pengelola yang boleh menandai lunas / membatalkan pembayaran (petugas hanya memantau).
export default async function BookingPage() {
  const admin = await requirePermission("booking");
  return <BookingView canKelola={can(admin.role, "booking:kelola")} />;
}
