// Backend membatasi setiap kata kunci FAQ maksimal 30 karakter (dan maksimal 10 kunci per FAQ),
// lalu mencocokkan pesan dengan cara "pesan memuat kata kunci". Jadi pertanyaan panjang tidak boleh
// dikirim utuh sebagai satu kunci; ambil frasa pendek dari pertanyaan supaya tetap bisa dicocokkan.

const MAKS_PANJANG_KUNCI = 30;
const MAKS_KUNCI = 10;

// Kata yang terlalu umum untuk dijadikan kunci sendiri; tanpa ini FAQ mudah menjawab pertanyaan lain.
const KATA_UMUM = new Set([
  "apakah", "apa", "adakah", "ada", "itu", "ini", "di", "ke", "dari", "yang", "untuk", "buat",
  "bisa", "boleh", "kah", "nya", "saya", "aku", "kami", "kita", "mau", "ingin", "dan", "atau",
  "dengan", "berapa", "bagaimana", "gimana", "kapan", "dimana", "mana", "siapa", "mengapa", "kenapa",
  "jika", "kalau", "juga", "saja", "dong", "ya", "nih", "sih", "tolong", "minta", "mohon",
]);

// Huruf kecil, tanda baca menjadi spasi, spasi ganda dirapikan.
function rapikan(teks: string): string {
  return teks.toLowerCase().replace(/[^\p{L}\p{N}\s]/gu, " ").replace(/\s+/g, " ").trim();
}

// Kata kunci untuk FAQ baru: kata kunci tambahan dari admin lebih dulu, lalu pertanyaan.
// Pertanyaan pendek dipakai utuh; pertanyaan panjang dipecah menjadi frasa 2 kata dan kata khas.
export function kunciFaq(pertanyaan: string, tambahan: string[]): string[] {
  const hasil: string[] = [];
  const tambah = (nilai: string) => {
    const kunci = rapikan(nilai);
    if (kunci && kunci.length <= MAKS_PANJANG_KUNCI && !hasil.includes(kunci)) hasil.push(kunci);
  };

  for (const k of tambahan) tambah(k);

  const bersih = rapikan(pertanyaan);
  if (bersih.length <= MAKS_PANJANG_KUNCI) {
    tambah(bersih);
    return hasil.slice(0, MAKS_KUNCI);
  }

  const kata = bersih.split(" ").filter((k) => k.length >= 3 && !KATA_UMUM.has(k));
  for (let i = 0; i + 1 < kata.length; i++) tambah(`${kata[i]} ${kata[i + 1]}`);
  for (const k of kata) if (k.length >= 5) tambah(k);
  return hasil.slice(0, MAKS_KUNCI);
}
