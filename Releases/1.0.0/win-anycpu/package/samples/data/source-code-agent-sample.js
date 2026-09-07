import { readFile } from "node:fs/promises";

// Searchable JavaScript fixture for coding agents.
export class OrderClient extends ApiClient {
  constructor(baseUrl) {
    super(baseUrl);
    this.baseUrl = baseUrl;
  }

  async load(id) {
    const response = await fetch(`${this.baseUrl}/orders/${id}`);
    if (!response.ok) throw new Error("request failed");
    return response.json();
  }
}

export async function loadConfig(path) {
  const text = await readFile(path, "utf8");
  return JSON.parse(text);
}

export const summarize = (orders) => {
  return orders.filter(order => order.active).map(order => order.id);
};

export function nextLine(value)
{
  return value * 2;
}

export function broken(value) {
  if (value > 0) {
    return value;
  }
