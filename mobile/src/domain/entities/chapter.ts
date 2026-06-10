export interface Chapter {
  readonly id: string;
  readonly name: string;
  readonly examWeight: number; // NCEES weighting, 0..1
}
