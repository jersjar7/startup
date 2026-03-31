export default {
  context: 'This chapter covers probability distributions, statistical inference, and regression — foundational tools for engineering data analysis.',
  subtopics: [
    { id: 'central-tendency',   name: 'Measures of Central Tendency & Dispersion' },
    { id: 'distributions',      name: 'Probability Distributions' },
    { id: 'expected-value',     name: 'Expected Value & Weighted Averages' },
    { id: 'estimation',         name: 'Estimation & Confidence Intervals' },
    { id: 'regression',         name: 'Regression & Curve Fitting' },
    { id: 'hypothesis-testing', name: 'Goodness of Fit & Hypothesis Testing' },
  ],
  formulas: [
    { latex: '\\bar{x} = \\frac{\\sum x_i}{n}', label: 'Sample Mean', page: 'p. 37' },
    { latex: 's = \\sqrt{\\frac{\\sum(x_i - \\bar{x})^2}{n-1}}', label: 'Sample Std Dev', page: 'p. 37' },
    { latex: 'P(X=k) = \\binom{n}{k}p^k(1-p)^{n-k}', label: 'Binomial Distribution', page: 'p. 38' },
    { latex: 'z = \\frac{x - \\mu}{\\sigma}', label: 'Z-Score', page: 'p. 38' },
    { latex: 'r = \\frac{\\sum(x_i-\\bar{x})(y_i-\\bar{y})}{\\sqrt{\\sum(x_i-\\bar{x})^2\\sum(y_i-\\bar{y})^2}}', label: 'Correlation Coefficient', page: 'p. 39' },
  ],
  traps: [
    'Dividing by n instead of (n−1) for sample standard deviation — the FE uses the sample formula.',
    'Confusing binomial and Poisson distributions — Poisson is for rare events over a continuous interval.',
    'Forgetting to square the standard deviation to get variance, or vice versa.',
    'Mixing up one-tailed and two-tailed hypothesis tests — read the problem statement carefully.',
  ],
};
