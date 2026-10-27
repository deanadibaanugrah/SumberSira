import { Sparkles } from "lucide-react";

// Label kecil AI Enhanced di atas foto.
export default function AiBadge({ className = "" }) {
  return (
    <span className={`inline-flex h-[26px] items-center gap-1.5 rounded-full bg-white/90 px-2.5 text-xs font-semibold text-forest ${className}`}>
      <Sparkles size={13} aria-hidden="true" /> AI Enhanced
    </span>
  );
}
