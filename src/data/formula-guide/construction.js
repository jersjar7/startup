// Plain-language guide to the formulas on the FE Civil Construction Engineering page,
// in the same order as chapters/construction.js. Symbols checked against the FE
// Reference Handbook 10.5.
export default [
  {
    label: 'Early Finish',
    aliases: ['early finish', 'ef', 'forward pass', 'cpm', 'critical path'],
    use: 'Forward pass of a CPM schedule: the earliest an activity can finish.',
    symbols: [
      { tex: 'EF', means: 'early finish of the activity', units: 'days (any consistent time unit)' },
      { tex: 'ES', means: 'early start, the latest early finish among all its predecessors', units: 'days' },
      { tex: 'D', means: 'duration of the activity', units: 'days' },
    ],
    trap: 'When an activity has several predecessors, its ES is the largest of their EF values, not the smallest.',
  },
  {
    label: 'Late Start',
    aliases: ['late start', 'ls', 'backward pass', 'cpm', 'late finish'],
    use: 'Backward pass of a CPM schedule: the latest an activity can start without delaying the project.',
    symbols: [
      { tex: 'LS', means: 'late start of the activity', units: 'days (any consistent time unit)' },
      { tex: 'LF', means: 'late finish, the earliest late start among all its successors', units: 'days' },
      { tex: 'D', means: 'duration of the activity', units: 'days' },
    ],
    trap: 'On the backward pass an activity with several successors takes the smallest of their LS values as its LF.',
  },
  {
    label: 'Total Float',
    aliases: ['total float', 'slack', 'critical path', 'float', 'tf'],
    use: 'How long an activity can slip without delaying the whole project; zero total float marks the critical path.',
    symbols: [
      { tex: 'TF', means: 'total float of the activity', units: 'days (any consistent time unit)' },
      { tex: 'LS', means: 'late start', units: 'days' },
      { tex: 'ES', means: 'early start', units: 'days' },
      { tex: 'LF', means: 'late finish', units: 'days' },
      { tex: 'EF', means: 'early finish', units: 'days' },
    ],
    trap: 'Total float is shared along a path, so using it on one activity can use up the float of the activities after it.',
  },
  {
    label: 'Free Float',
    aliases: ['free float', 'ff', 'slack', 'float', 'successor'],
    use: 'How long an activity can slip without delaying the early start of any activity that follows it.',
    symbols: [
      { tex: 'FF', means: 'free float of activity i', units: 'days (any consistent time unit)' },
      { tex: 'ES_j', means: 'early start of a successor activity j; take the smallest one', units: 'days' },
      { tex: 'EF_i', means: 'early finish of the activity i you are checking', units: 'days' },
    ],
    trap: 'Free float uses early dates only (successor ES minus your EF); it can never be larger than total float.',
  },
  {
    label: 'Cost Variance',
    aliases: ['cost variance', 'cv', 'earned value', 'over budget', 'evm'],
    use: 'Whether the work done so far cost more or less than budgeted.',
    symbols: [
      { tex: 'CV', means: 'cost variance; negative means over budget', units: 'dollars' },
      { tex: 'BCWP', means: 'budgeted cost of work performed (earned value)', units: 'dollars' },
      { tex: 'ACWP', means: 'actual cost of work performed (actual cost)', units: 'dollars' },
    ],
    trap: 'Both variances start with earned value (BCWP); a negative CV is bad, it means over budget.',
  },
  {
    label: 'Schedule Variance',
    aliases: ['schedule variance', 'sv', 'earned value', 'behind schedule', 'evm'],
    use: 'Whether more or less work has been done than planned by this date, measured in dollars.',
    symbols: [
      { tex: 'SV', means: 'schedule variance; negative means behind schedule', units: 'dollars' },
      { tex: 'BCWP', means: 'budgeted cost of work performed (earned value)', units: 'dollars' },
      { tex: 'BCWS', means: 'budgeted cost of work scheduled (planned value)', units: 'dollars' },
    ],
    trap: 'SV compares earned with planned, never with actual cost; actual cost belongs only in the cost measures.',
  },
  {
    label: 'Cost Performance Index',
    aliases: ['cpi', 'cost performance index', 'earned value', 'cost efficiency', 'evm'],
    use: 'Cost efficiency of the work so far, as earned value per dollar actually spent.',
    symbols: [
      { tex: 'CPI', means: 'cost performance index; below 1.0 means over budget', units: 'unitless' },
      { tex: 'BCWP', means: 'budgeted cost of work performed (earned value)', units: 'dollars' },
      { tex: 'ACWP', means: 'actual cost of work performed (actual cost)', units: 'dollars' },
    ],
    trap: 'Earned value always goes on top; flipping the ratio turns an over-budget job into one that looks under budget.',
  },
  {
    label: 'Schedule Performance Index',
    aliases: ['spi', 'schedule performance index', 'earned value', 'schedule efficiency', 'evm'],
    use: 'Schedule efficiency of the work so far, as earned value per dollar of work planned by now.',
    symbols: [
      { tex: 'SPI', means: 'schedule performance index; below 1.0 means behind schedule', units: 'unitless' },
      { tex: 'BCWP', means: 'budgeted cost of work performed (earned value)', units: 'dollars' },
      { tex: 'BCWS', means: 'budgeted cost of work scheduled (planned value)', units: 'dollars' },
    ],
    trap: 'Earned value goes on top here too; SPI below 1.0 means behind schedule.',
  },
  {
    label: 'Estimate to Complete',
    aliases: ['etc', 'estimate to complete', 'forecast', 'remaining cost', 'earned value'],
    use: 'Forecast of the cost to finish the remaining work, assuming the current cost efficiency continues.',
    symbols: [
      { tex: 'ETC', means: 'estimate to complete, the forecast cost of the remaining work', units: 'dollars' },
      { tex: 'BAC', means: 'budget at completion, the original total project budget', units: 'dollars' },
      { tex: 'BCWP', means: 'budgeted cost of work performed (earned value) to date', units: 'dollars' },
      { tex: 'CPI', means: 'cost performance index, BCWP divided by ACWP', units: 'unitless' },
    ],
    trap: 'Subtract the earned value (BCWP) from BAC, not the actual cost spent so far.',
  },
  {
    label: 'Estimate at Completion',
    aliases: ['eac', 'estimate at completion', 'forecast', 'final cost', 'earned value'],
    use: 'Forecast of the total project cost at the end: what has been spent plus what remains.',
    symbols: [
      { tex: 'EAC', means: 'estimate at completion, the forecast final cost of the project', units: 'dollars' },
      { tex: 'ACWP', means: 'actual cost of work performed to date', units: 'dollars' },
      { tex: 'ETC', means: 'estimate to complete the remaining work', units: 'dollars' },
    ],
    trap: 'Add the actual cost to date, not the earned value, to the ETC.',
  },
];
