// Model: bentuk data yang dipakai View dan ViewModel.
export type ApiBookingLine = { rideId: string; name: string; qty: number; unitPrice: number; subtotal: number };

export type ApiPayment = {
  id: string; method: string; status: string; amount: number;
  qrString?: string | null; qrUrl?: string | null; expiresAt?: string | null;
};

export type ApiBooking = {
  code: string; name: string; whatsapp: string; slot: string; slotLabel: string; visitDate: string;
  amount: number; paymentStatus: string; createdAt: string;
  lines: ApiBookingLine[]; payment: ApiPayment | null;
};

// Bentuk satu booking untuk tampilan.
export type Booking = {
  code: string; name: string; whatsapp: string; slot: string; slotLabel: string; visitDate: string;
  amount: number; paymentStatus: string; status: string; time: string; createdAtMs: number;
  lines: ApiBookingLine[]; payment: ApiPayment | null;
};
