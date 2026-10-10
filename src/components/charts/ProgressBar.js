// Batang progres beranimasi (mengisi dari kiri). value: 0-100.
export default function ProgressBar({ value, fillClass = "bg-leaf", trackClass = "bg-leaf/15", height = "h-2.5", delay = 0 }) {
  return (
    <div className={`w-full overflow-hidden rounded-full ${trackClass} ${height}`} role="progressbar"
         aria-valuenow={value} aria-valuemin={0} aria-valuemax={100}>
      <div className={`h-full origin-left rounded-full animate-fill-x ${fillClass}`}
           style={{ width: `${value}%`, animationDelay: `${delay}ms` }} />
    </div>
  );
}
