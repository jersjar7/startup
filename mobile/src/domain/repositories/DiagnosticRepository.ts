// Per-chapter familiarity (0..1) seeded by the onboarding diagnostic. Capped low
// (familiar ≠ ready) and overtaken by real review progress over time.
export interface DiagnosticRepository {
  getFamiliarity(): Promise<Record<string, number>>;
  save(familiarity: Record<string, number>): Promise<void>;
}
