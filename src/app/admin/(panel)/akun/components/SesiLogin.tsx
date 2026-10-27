import { Card, CardTitle } from "@/components/admin/ui";

import SesiList, { type Sesi } from "./SesiList";

// Kartu Sesi Login Aktif: daftar perangkat yang sedang login dengan akun ini.
export default function SesiLogin({ sessions }: { sessions: Sesi[] }) {
  return (
    <Card>
      <CardTitle>Sesi Login Aktif</CardTitle>
      <SesiList sessions={sessions} />
    </Card>
  );
}
