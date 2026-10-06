import {
  Users, CreditCard, CurrencyDollar, Lightning, TrendUp, Compass, Timer,
} from '@phosphor-icons/react';
import { money } from './format';
import { STUDENT_PRICE, STANDARD_PRICE } from '../data/pricing';

// Every headline number the dashboard shows, with the plain-English definition
// and worked example that sits behind its info button. Keyed by id so the
// summary row and the tab panels can each pick the ones they own without a
// definition ever drifting or going missing.
export function buildMetrics(snap) {
  if (!snap) return {};
  return {
    totalUsers: {
      id: 'totalUsers', icon: Users, label: 'Total users', accent: 'ember',
      value: snap.totalUsers.toLocaleString(),
      desc: 'The all-time number of real accounts ever created, everyone who signed up, minus your own test accounts (admin & QA). It only goes up.',
      example: 'If 58 people have made an account, this shows 58, and the newest one is #58 in the Recent users table.',
    },
    activationRate: {
      id: 'activationRate', icon: Compass, label: 'Activation rate', accent: 'ember',
      value: snap.activationRate != null ? `${snap.activationRate}%` : '—',
      desc: 'Of the people who signed up since the quick-start launched, the share who actually started it (answered at least one quick-start question). Your honest "are new users engaging, not just registering?" number.',
      example: '20 people signed up since launch and 5 of them answered a quick-start question, so 5 ÷ 20 = 25%.',
    },
    cohortActivated: {
      id: 'cohortActivated', icon: Users, label: 'Activated · since launch', accent: 'forest',
      value: snap.cohortSignups != null ? `${snap.cohortActivated}/${snap.cohortSignups}` : '—',
      desc: 'The two raw numbers behind the activation rate: people who started the quick-start ÷ everyone who signed up since launch.',
      example: 'Shown as 5/20, so 5 of the 20 post-launch signups have started. That fraction is the activation rate.',
    },
    medianStart: {
      id: 'medianStart', icon: Timer, label: 'Median time to start', accent: 'info',
      value: snap.activationMedianMinutes != null ? `${snap.activationMedianMinutes} min` : '—',
      desc: 'Among users who activated, the typical wait between signing up and answering their first question. It is the median (the middle person), so one slow returner cannot skew the number.',
      example: 'If activators waited 2, 6, and 40 minutes, the median is 6 min. Half started faster, half slower. Lower is better.',
    },
    active7d: {
      id: 'active7d', icon: Lightning, label: 'Active · 7 days', accent: 'info',
      value: snap.activeUsers7d.toLocaleString(),
      desc: 'How many different people finished at least one study session in the last 7 days. The same person studying five times counts once, so it is your weekly engaged-user count.',
      example: 'If 12 distinct people studied at least once this week, this shows 12.',
    },
    totalRevenue: {
      id: 'totalRevenue', icon: CurrencyDollar, label: 'Total revenue', accent: 'forest',
      value: money(snap.totalRevenue),
      desc: 'Money actually collected for the exam simulation, all time (after Stripe). Complimentary grants and purchases we were never paid for are excluded.',
      example: `Two $${STUDENT_PRICE} student purchases plus one $${STANDARD_PRICE} standard = $${STUDENT_PRICE * 2 + STANDARD_PRICE}.`,
    },
    purchases: {
      id: 'purchases', icon: CreditCard, label: 'Purchases', accent: 'forest',
      value: snap.totalPurchases.toLocaleString(),
      desc: 'The all-time count of exam-sim purchases we were actually paid for, regardless of the price paid. Complimentary grants and unpaid grants are excluded.',
      example: 'If 3 people have bought the timed exam sim, this shows 3.',
    },
    arppu: {
      id: 'arppu', icon: TrendUp, label: 'Rev / paying user', accent: 'sunbeam',
      value: money(snap.arppu),
      desc: 'Average money per paying customer, total revenue ÷ number of purchases. (The industry name for this is ARPPU.)',
      example: '$107 in revenue from 3 purchases is about $36 per paying user.',
    },
  };
}

// The four numbers that stay visible above the tabs.
export const SUMMARY_IDS = ['totalUsers', 'active7d', 'totalRevenue', 'activationRate'];
