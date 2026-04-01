export default {
  context: 'This chapter covers probability distributions, statistical inference, and regression — foundational tools for engineering data analysis.',
  subtopics: [
    { id: 'descriptive-statistics', name: 'Descriptive Statistics',
      application: 'As a civil engineer, you compute means and standard deviations every time you evaluate concrete cylinder break tests, assess traffic count data, or summarize soil boring results. You fit regression curves to field data constantly \u2014 correlating SPT blow counts with soil shear strength, developing stage-discharge relationships, or establishing IDF curves for stormwater design. The spread in your data and the strength of your correlations tell you whether a design value is reliable.' },
    { id: 'probability', name: 'Probability',
      application: 'As a civil engineer, probability distributions drive design \u2014 the 100-year flood follows a log-Pearson Type III distribution, traffic arrivals follow a Poisson distribution, and concrete strengths are modeled as normal. Expected values show up when comparing alternatives in benefit-cost analyses or compositing soil properties from multiple borings. You pick design values directly from these distributions.' },
    { id: 'inferential-statistics', name: 'Inferential Statistics',
      application: 'As a civil engineer, confidence intervals tell you how much to trust your field data \u2014 reporting a soil friction angle as 32\u00b0 \u00b1 3\u00b0 at 95% confidence directly affects foundation design. Hypothesis testing tells you whether differences are real or noise: does a new concrete mix meet spec? Did a pavement treatment actually reduce accidents? These tools turn raw data into engineering decisions.' },
  ],
  formulas: [
    { latex: '\\bar{x} = \\frac{\\sum x_i}{n}', label: 'Sample Mean', page: 'p. 63' },
    { latex: 's = \\sqrt{\\frac{\\sum(x_i - \\bar{x})^2}{n-1}}', label: 'Sample Std Dev', page: 'p. 63' },
    { latex: 'P(X=k) = \\binom{n}{k}p^k(1-p)^{n-k}', label: 'Binomial Distribution', page: 'p. 66' },
    { latex: 'z = \\frac{x - \\mu}{\\sigma}', label: 'Z-Score', page: 'p. 67' },
    { latex: 'r = \\frac{\\sum(x_i-\\bar{x})(y_i-\\bar{y})}{\\sqrt{\\sum(x_i-\\bar{x})^2\\sum(y_i-\\bar{y})^2}}', label: 'Correlation Coefficient', page: 'p. 69' },
  ],
  traps: [
    'Dividing by n instead of (n\u22121) for sample standard deviation \u2014 the FE uses the sample formula.',
    'Confusing binomial and Poisson distributions \u2014 Poisson is for rare events over a continuous interval.',
    'Forgetting to square the standard deviation to get variance, or vice versa.',
    'Mixing up one-tailed and two-tailed hypothesis tests \u2014 read the problem statement carefully.',
  ],
};
