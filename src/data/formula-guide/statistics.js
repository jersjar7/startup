// Plain-language guide to the formulas on the FE Civil Probability and
// Statistics page, in the same order as chapters/statistics.js. Symbols
// checked against the FE Reference Handbook 10.5.
export default [
  {
    label: 'Sample Mean',
    aliases: ['mean', 'average', 'sample mean', 'arithmetic mean'],
    use: 'Find the average of a set of measured values.',
    symbols: [
      { tex: '\\bar{x}', means: 'sample mean, the average of the values', units: 'same unit as the data' },
      { tex: 'x_i', means: 'each individual value in the sample', units: 'same unit as the data' },
      { tex: 'n', means: 'number of values in the sample', units: 'unitless (a count)' },
    ],
  },
  {
    label: 'Sample Std Dev',
    aliases: ['standard deviation', 'sample standard deviation', 'spread', 'variance'],
    use: 'Measure how spread out a sample of values is around its mean.',
    symbols: [
      { tex: 's', means: 'sample standard deviation', units: 'same unit as the data' },
      { tex: 'x_i', means: 'each individual value in the sample', units: 'same unit as the data' },
      { tex: '\\bar{x}', means: 'sample mean', units: 'same unit as the data' },
      { tex: 'n', means: 'number of values in the sample', units: 'unitless (a count)' },
    ],
    trap: 'A sample divides by n minus 1; a whole population divides by N, so pick sx, not σx, on the calculator for a sample.',
  },
  {
    label: 'Binomial Distribution',
    aliases: ['binomial', 'probability of k successes', 'success failure', 'trials'],
    use: 'Find the chance of exactly k successes in n independent tries, each with the same chance of success.',
    symbols: [
      { tex: 'P(X=k)', means: 'probability of exactly k successes', units: 'unitless, 0 to 1' },
      { tex: 'n', means: 'number of independent trials', units: 'unitless (a count)' },
      { tex: 'k', means: 'number of successes you are asking about', units: 'unitless (a count)' },
      { tex: 'p', means: 'probability of success on one trial (1 minus p is the probability of failure)', units: 'unitless, 0 to 1' },
      { tex: '\\binom{n}{k}', means: 'number of ways to choose k successes out of n trials, n! divided by k!(n minus k)!', units: 'unitless' },
    ],
    trap: 'The formula gives exactly k; an "at least" or "at most" question needs a sum of terms, or 1 minus the complement.',
  },
  {
    label: 'Z-Score',
    aliases: ['z score', 'standard normal', 'normal distribution', 'standardize'],
    use: 'Convert a value from any normal distribution to the unit normal so you can read probabilities from the table.',
    symbols: [
      { tex: 'z', means: 'number of standard deviations the value sits above (or below, if negative) the mean', units: 'unitless' },
      { tex: 'x', means: 'the value you are checking', units: 'same unit as the data' },
      { tex: '\\mu', means: 'population mean', units: 'same unit as the data' },
      { tex: '\\sigma', means: 'population standard deviation', units: 'same unit as the data' },
    ],
    trap: 'The handbook table has four columns: F(x) is the area to the left, R(x) the area to the right, W(x) the area between minus x and x; read the one the question asks for.',
  },
  {
    label: 'Correlation Coefficient',
    aliases: ['correlation', 'r value', 'linear regression', 'goodness of fit'],
    use: 'Measure how closely two sets of paired data follow a straight line.',
    symbols: [
      { tex: 'r', means: 'correlation coefficient, from minus 1 (perfect falling line) through 0 (no linear trend) to plus 1 (perfect rising line)', units: 'unitless' },
      { tex: 'x_i', means: 'each x value in the paired data', units: 'same unit as x' },
      { tex: 'y_i', means: 'each y value paired with x_i', units: 'same unit as y' },
      { tex: '\\bar{x}', means: 'mean of the x values', units: 'same unit as x' },
      { tex: '\\bar{y}', means: 'mean of the y values', units: 'same unit as y' },
    ],
    trap: 'r is not the slope of the line, and the coefficient of determination R² is r squared.',
  },
];
