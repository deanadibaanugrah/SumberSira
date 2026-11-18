import { Check, X } from "lucide-react";

import { IconButton } from "@/components/admin/ui";
import type { AdminGalleryPhoto } from "@/lib/auth/dal";

import HapusFoto from "./HapusFoto";

// Tombol aksi tiap foto: setujui (centang), tolak (silang), atau hapus permanen.
export default function AksiFoto({
  photo,
  busy,
  onSet,
}: {
  photo: AdminGalleryPhoto;
  busy: boolean;
  onSet: (id: string, status: "approved" | "rejected") => void;
}) {
  return (
    <div className="flex gap-2">
      <IconButton
        tone="gray"
        label={`Tampilkan foto ${photo.title}`}
        disabled={busy || photo.status === "approved"}
        onClick={() => onSet(photo.id, "approved")}
      >
        <Check size={17} />
      </IconButton>
      <IconButton
        tone="coral"
        label={`Tolak foto ${photo.title}`}
        disabled={busy || photo.status === "rejected"}
        onClick={() => onSet(photo.id, "rejected")}
      >
        <X size={17} />
      </IconButton>
      <HapusFoto id={photo.id} title={photo.title} owner={photo.owner} />
    </div>
  );
}
