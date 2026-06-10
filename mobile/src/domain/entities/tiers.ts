// Mobile classification of a problem (see docs/mobile/content-plan.md).

export type MobileTier = 'concept' | 'phoneCalc' | 'paper';

export type InteractionMode =
  | 'recallReveal'
  | 'formulaFirst'
  | 'tapTheTrap'
  | 'setupNotSolve'
  | 'mcq';

/** Only `paper` problems require leaving the phone to finish solving. */
export const needsPaper = (tier: MobileTier): boolean => tier === 'paper';
