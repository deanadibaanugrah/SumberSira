import react from "@vitejs/plugin-react";
import { defineConfig } from "vitest/config";

// Tes unit (Vitest + React Testing Library) untuk komponen dan lapisan pemanggil API.
// Alias "@/..." dibaca lewat resolve.tsconfigPaths (Vite/TSConfig bawaan).
export default defineConfig({
  plugins: [react()],
  resolve: {
    tsconfigPaths: true,
  },
  test: {
    environment: "jsdom",
    include: ["tests/**/*.test.{ts,tsx}"],
    restoreMocks: true,
  },
});
