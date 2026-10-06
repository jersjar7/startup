import { shouldAskSource } from './acquisitionGate';

// Decides whether we may ask "where do you study, and when do you finish?".
//
// Same one sentence as its sibling: ask until resolved, never after. Registration
// (src/login/login.jsx) is the primary ask because it is the one point every new
// user passes through; the dashboard is the safety net for anyone who closed the
// tab mid-signup or registered before the question existed.
//
// "Resolved" is server-side (`schoolResolved` on /me): they answered, or they
// skipped. Not a localStorage flag, so it holds across devices, browser profiles
// and cleared site data. That is what stops the same person being asked twice.
//
// `schoolResolved` must be an explicit `false` to trigger the ask. While /me is
// still loading it is undefined, and the callers seed it as true, so a slow or
// failed request shows nothing rather than risking a duplicate.
//
// The attribution question wins any tie. Two modals stacked on a new account is
// an interrogation, and attribution is the more perishable of the two: a user
// forgets which link brought them here within days, while their school does not
// change. Deferring to shouldAskSource() rather than re-deriving the condition
// keeps that ordering true even if the acquisition rule changes.
export function shouldAskSchool({ acquisitionResolved, schoolResolved } = {}) {
  if (shouldAskSource({ acquisitionResolved })) return false;
  return schoolResolved === false;
}
