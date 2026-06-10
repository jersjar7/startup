// Maps domain enums to UI labels/colors — keeps the "color = signal" discipline
// in one place (docs/mobile/visual-language.md).

import type { Theme } from '@/core/theme/theme';
import type { InteractionMode } from '@/domain/entities/tiers';
import type { MasteryState } from '@/domain/entities/mastery';

export function masteryColor(state: MasteryState, t: Theme): string {
  switch (state) {
    case 'mastered':
      return t.palette.forest;
    case 'familiar':
      return t.palette.sunbeamInk;
    case 'building':
      return t.palette.ember;
    default:
      return t.palette.ink4;
  }
}

export function masteryLabel(state: MasteryState): string {
  switch (state) {
    case 'mastered':
      return 'Mastered';
    case 'familiar':
      return 'Familiar';
    case 'building':
      return 'Building';
    default:
      return 'New';
  }
}

export function interactionLabel(kind: InteractionMode): string {
  switch (kind) {
    case 'tapTheTrap':
      return 'Trap';
    case 'recallReveal':
      return 'Recall';
    case 'formulaFirst':
      return 'Formula';
    case 'setupNotSolve':
      return 'Setup';
    case 'mcq':
      return 'Choice';
  }
}

export function interactionColor(kind: InteractionMode, t: Theme): string {
  switch (kind) {
    case 'tapTheTrap':
      return t.palette.ember;
    case 'recallReveal':
      return t.palette.sunbeamInk;
    case 'formulaFirst':
      return t.palette.forest;
    default:
      return t.palette.ink3;
  }
}
