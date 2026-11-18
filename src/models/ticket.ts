// Model: bentuk data yang dipakai View dan ViewModel.
// Bentuk satu tiket untuk tampilan: status berbahasa Indonesia dan jam berformat 10.42 (WIB).
export type Ticket = {
  id: string; code: string; name: string; whatsapp: string; adults: number; kids: number; parking: string;
  payment: string; paymentStatus: string; total: number;
  status: "Belum masuk" | "Di dalam" | "Keluar"; boughtAt: string; checkInAt: string | null; checkOutAt: string | null;
  boughtAtMs: number; checkInMs: number | null; checkOutMs: number | null; fromApp: boolean; visitDate: string;
};
