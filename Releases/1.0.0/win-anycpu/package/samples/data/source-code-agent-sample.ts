import type { Disposable } from "./contracts";

// Searchable TypeScript fixture for coding agents.
export interface Repository<T> extends Disposable {
  get(id: string): Promise<T>;
}

export type Result<T> =
  | { ok: true; value: T }
  | { ok: false; error: Error };

export enum Status {
  Pending,
  Complete
}

export class UserService<T extends User> extends BaseService<T> implements Repository<T>, Disposable {
  constructor(private readonly baseUrl: string) {
    super();
  }

  public async get(id: string): Promise<T> {
    const response: Response = await fetch(`${this.baseUrl}/${id}`);
    if (!response.ok) throw new Error("Request failed");
    return response.json() as Promise<T>;
  }
}

export const normalize = (value: string): string => {
  return value.trim().toLowerCase();
};

export interface Broken {
  value: string;
