"use client";

import { api } from "@/lib/live/http";
import { createPollStore } from "@/lib/live/poll-store";

// Data halaman Chatbot & FAQ: FAQ buatan pengelola (jawaban cepat tanpa AI), pertanyaan pengunjung yang menunggu
// jawaban pengelola, dan statistik jawaban otomatis. Diambil dari backend dan disegarkan berkala supaya pertanyaan baru muncul sendiri.

export type Faq = { id: string; question: string; answer: string; keywords: string; updatedAt: string };
export type ChatQuestion = { id: string; question: string; status: "pending" | "answered"; answer: string | null; askedAt: string; answeredAt: string | null };
export type ChatStats = {
  total: number; auto: number; byFaq: number; byAi: number; byKb: number; unknown: number;
  pending: number; answered: number; autoPercent: number; aiActive: boolean;
};
export type ChatOverview = { faqs: Faq[]; pending: ChatQuestion[]; answered: ChatQuestion[]; stats: ChatStats };

const store = createPollStore<ChatOverview>(() => api<ChatOverview>("GET", "/api/admin/chat/overview"), 10_000);

export function useChat() {
  const { data, ready, error } = store.use();
  return { data, ready, error, refresh: store.refresh };
}

type FaqInput = { question: string; answer: string; keywords?: string };

export async function saveFaq(input: FaqInput, id?: string) {
  await (id ? api("PATCH", `/api/admin/chat/faq/${id}`, input) : api("POST", "/api/admin/chat/faq", input));
  await store.refresh();
}

export async function deleteFaq(id: string) {
  await api("DELETE", `/api/admin/chat/faq/${id}`);
  await store.refresh();
}

// Jawab pertanyaan pengunjung. saveAsFaq = pertanyaan serupa berikutnya dijawab otomatis tanpa menunggu pengelola.
export async function answerQuestion(id: string, answer: string, saveAsFaq: boolean) {
  await api("POST", `/api/admin/chat/questions/${id}/answer`, { answer, saveAsFaq });
  await store.refresh();
}

export async function deleteQuestion(id: string) {
  await api("DELETE", `/api/admin/chat/questions/${id}`);
  await store.refresh();
}
