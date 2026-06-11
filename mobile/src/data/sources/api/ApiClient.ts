import { API_BASE_URL } from '@/core/config';

export class ApiError extends Error {
  constructor(
    readonly status: number,
    message: string,
  ) {
    super(message);
  }
}

// Thin fetch wrapper for the fe4raccoons service. Mobile authenticates with a
// bearer token (the web's httpOnly cookie jar isn't reliable in RN).
export class ApiClient {
  constructor(private readonly getToken: () => Promise<string | null>) {}

  async request<T>(method: string, path: string, body?: unknown): Promise<T> {
    const token = await this.getToken();
    const res = await fetch(`${API_BASE_URL}${path}`, {
      method,
      headers: {
        'Content-Type': 'application/json',
        'X-Client': 'mobile',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
      body: body === undefined ? undefined : JSON.stringify(body),
    });
    if (!res.ok) {
      const msg = await res
        .json()
        .then((j: { msg?: string }) => j.msg ?? `Request failed (${res.status})`)
        .catch(() => `Request failed (${res.status})`);
      throw new ApiError(res.status, msg);
    }
    if (res.status === 204) return undefined as T;
    return (await res.json()) as T;
  }
}
