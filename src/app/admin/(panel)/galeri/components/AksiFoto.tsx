import { Check, X } from "lucide-react";

import { IconButton } from "@/components/admin/ui";

// Tombol aksi tiap foto: tampilkan (centang) atau tolak (silang).
export default function AksiFoto({ photo, onSet }) {
  return (
    <div className="flex gap-2">
      <IconButton tone="gray" label={`Tampilkan foto ${photo.owner}`} onClick={() => onSet(photo.id, "Ditampilkan")}><Check size={17} /></IconButton>
      <IconButton tone="coral" label={`Tolak foto ${photo.owner}`} onClick={() => onSet(photo.id, "Ditolak")}><X size={17} /></IconButton>
    </div>
  );
}
