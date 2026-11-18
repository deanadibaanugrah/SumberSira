// Model: bentuk data yang dipakai View dan ViewModel.
export type WahanaItem = {
  id: string;
  name: string;
  category: string;
  price: number;
  unit: string;
  icon: string;
  status: string;
};

export type WahanaInput = { id?: string; name: string; category: string; price: number; unit: string; status: string };
