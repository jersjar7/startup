// A signed-in fe4raccoons account (same identity as the website).
export interface Account {
  readonly email: string;
  readonly displayName: string;
  readonly examDate: string | null; // ISO yyyy-mm-dd, from the web profile
}
