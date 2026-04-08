// Exam bank: statistics
// Auto-extracted from lesson files — 24 questions

const PROBLEMS = [
  {
    id: 'stat-ctd-ex1',
    type: 'computational',
    statement: 'A series of concrete cylinder tests yields compressive strengths (psi): 4200, 4350, 4100, 4500, 4250. What is the sample standard deviation?',
    choices: [
      {
        id: 'c1',
        text: '130 psi'
      },
      {
        id: 'c2',
        text: '146 psi'
      },
      {
        id: 'c3',
        text: '152 psi'
      },
      {
        id: 'c4',
        text: '164 psi'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'First find the mean: $(4200+4350+4100+4500+4250)/5 = 4280$. Then compute each deviation squared, sum them, divide by $n-1$ (since it is sample, not population), and take the square root. The answer is about 152 psi. The trap is dividing by $n$ instead of $n-1$.',
    hint: 'For sample standard deviation, divide by $n-1$, not $n$.',
    steps: [
      {
        text: 'Compute the mean:',
        latex: '\\bar{x} = \\frac{4200+4350+4100+4500+4250}{5} = 4280'
      },
      {
        text: 'Compute deviations squared:',
        latex: '(-80)^2 + 70^2 + (-180)^2 + 220^2 + (-30)^2 = 6400 + 4900 + 32400 + 48400 + 900 = 93000'
      },
      {
        text: 'Sample variance (divide by $n-1$):',
        latex: 's^2 = \\frac{93000}{4} = 23250'
      },
      {
        text: 'Standard deviation:',
        latex: 's = \\sqrt{23250} \\approx 152\\,\\text{psi}'
      }
    ],
    handbookPage: 'p. 63',
    handbookFormula: 's = \\sqrt{\\frac{\\sum(x_i - \\bar{x})^2}{n-1}}',
    videoUrl: null,
    traps: [
      'Using $n$ instead of $n-1$ for sample standard deviation',
      'Arithmetic errors in squaring deviations'
    ],
    diagram: null,
    lessonId: 'central-tendency-dispersion',
    chapterId: 'statistics'
  },
  {
    id: 'stat-ctd-ex2',
    type: 'conceptual',
    statement: 'A dataset has a mean of 50, a median of 45, and a mode of 42. What can be said about the distribution?',
    choices: [
      {
        id: 'c1',
        text: 'It is symmetric'
      },
      {
        id: 'c2',
        text: 'It is skewed left (negatively skewed)'
      },
      {
        id: 'c3',
        text: 'It is skewed right (positively skewed)'
      },
      {
        id: 'c4',
        text: 'It is bimodal'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'easy',
    eli5: 'When the mean is greater than the median and the median is greater than the mode, the distribution is skewed right (positively skewed). Think of it as a tail pulling the mean to the right. Left skew would have mean < median < mode.',
    hint: 'Compare the relative positions of mean, median, and mode.',
    steps: [
      {
        text: 'Compare: mean (50) > median (45) > mode (42).',
        latex: null
      },
      {
        text: 'When mean > median > mode, the distribution has a right tail (positive skew).',
        latex: null
      },
      {
        text: 'The distribution is positively (right) skewed.',
        latex: null
      }
    ],
    handbookPage: 'p. 63',
    handbookFormula: '\\text{Right skew: mean} > \\text{median} > \\text{mode}',
    videoUrl: null,
    traps: ['Confusing left skew with right skew direction'],
    diagram: {
      component: 'SkewnessChart',
      props: {
        mean: 50,
        median: 45,
        mode: 42
      }
    },
    lessonId: 'central-tendency-dispersion',
    chapterId: 'statistics'
  },
  {
    id: 'stat-ctd-ex3',
    type: 'computational',
    statement: 'A structural engineer weighs five steel beams from different fabricators. The weights (in kN) are: 24.2, 25.8, 23.5, 26.1, 24.9. What is the coefficient of variation of the beam weights?',
    choices: [
      {
        id: 'c1',
        text: '0.038'
      },
      {
        id: 'c2',
        text: '0.042'
      },
      {
        id: 'c3',
        text: '0.96'
      },
      {
        id: 'c4',
        text: '1.03'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'The coefficient of variation is just the standard deviation divided by the mean. First find the mean (24.9), then compute the sample standard deviation (about 1.04), then divide: $1.04/24.9 = 0.042$. Choice A (0.038) is what you get if you use the population formula (divide by $n$ instead of $n-1$). Choice C (0.96) is the sample variance, not the CV. Choice D (1.03) is the standard deviation itself before dividing by the mean.',
    hint: 'Compute $\\bar{x}$ and $s$ first, then divide: $CV = s / \\bar{x}$.',
    steps: [
      {
        text: 'Compute the mean:',
        latex: '\\bar{x} = \\frac{24.2 + 25.8 + 23.5 + 26.1 + 24.9}{5} = \\frac{124.5}{5} = 24.9'
      },
      {
        text: 'Compute the sample variance:',
        latex: 's^2 = \\frac{(24.2-24.9)^2 + (25.8-24.9)^2 + (23.5-24.9)^2 + (26.1-24.9)^2 + (24.9-24.9)^2}{4}'
      },
      {
        text: 'Evaluate:',
        latex: 's^2 = \\frac{0.49 + 0.81 + 1.96 + 1.44 + 0}{4} = \\frac{4.70}{4} = 1.175'
      },
      {
        text: 'Sample standard deviation:',
        latex: 's = \\sqrt{1.175} = 1.084'
      },
      {
        text: 'Coefficient of variation:',
        latex: 'CV = \\frac{s}{\\bar{x}} = \\frac{1.084}{24.9} \\approx 0.042'
      }
    ],
    handbookPage: 'p. 63',
    handbookFormula: 'CV = \\frac{s}{\\bar{x}}',
    videoUrl: null,
    traps: [
      'Using population std dev ($n$) instead of sample ($n-1$)',
      'Reporting the standard deviation itself instead of dividing by the mean'
    ],
    diagram: null,
    lessonId: 'central-tendency-dispersion',
    chapterId: 'statistics'
  },
  {
    id: 'stat-ctd-ex4',
    type: 'computational',
    statement: 'Eight soil permeability tests yield the following hydraulic conductivity values (in $\\times 10^{-4}$ cm/s): 3.1, 4.7, 3.8, 5.2, 3.4, 4.1, 6.3, 3.0. What is the median hydraulic conductivity?',
    choices: [
      {
        id: 'c1',
        text: '$3.80 \\times 10^{-4}\\,\\text{cm/s}$'
      },
      {
        id: 'c2',
        text: '$3.95 \\times 10^{-4}\\,\\text{cm/s}$'
      },
      {
        id: 'c3',
        text: '$4.20 \\times 10^{-4}\\,\\text{cm/s}$'
      },
      {
        id: 'c4',
        text: '$4.10 \\times 10^{-4}\\,\\text{cm/s}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'With an even number of data points, the median is the average of the two middle values. Sort the data first: 3.0, 3.1, 3.4, 3.8, 4.1, 4.7, 5.2, 6.3. With 8 values, the middle positions are 4th and 5th. Average those: $(3.8 + 4.1)/2 = 3.95$. Choice A (3.80) picks only the 4th value and ignores the 5th. Choice C (4.20) is the mean, not the median. Choice D (4.10) picks only the 5th value without averaging.',
    hint: 'Sort the data first. For an even count, average the two middle values.',
    steps: [
      {
        text: 'Sort the data in ascending order:',
        latex: '3.0,\\; 3.1,\\; 3.4,\\; 3.8,\\; 4.1,\\; 4.7,\\; 5.2,\\; 6.3'
      },
      {
        text: 'With $n = 8$ (even), the median is the average of the 4th and 5th values.',
        latex: null
      },
      {
        text: 'Identify the middle pair:',
        latex: 'x_4 = 3.8, \\quad x_5 = 4.1'
      },
      {
        text: 'Average them:',
        latex: '\\text{Median} = \\frac{3.8 + 4.1}{2} = 3.95 \\times 10^{-4}\\,\\text{cm/s}'
      }
    ],
    handbookPage: 'p. 63',
    handbookFormula: '\\text{Median} = \\frac{x_{n/2} + x_{n/2+1}}{2} \\text{ (even } n\\text{)}',
    videoUrl: null,
    traps: [
      'Forgetting to sort the data before finding the middle values',
      'Taking only one of the two middle values instead of averaging them'
    ],
    diagram: null,
    lessonId: 'central-tendency-dispersion',
    chapterId: 'statistics'
  },
  {
    id: 'stat-reg-ex1',
    type: 'computational',
    statement: 'A transportation engineer collects 5 paired measurements of vehicle speed ($x$, in km/h) and traffic density ($y$, in vehicles/km). The summary statistics are: $n = 5$, $\\sum x = 25$, $\\sum y = 35$, $\\sum x_i y_i = 205$, $\\sum x_i^2 = 145$. What is the slope $b$ of the least-squares regression line?',
    choices: [
      {
        id: 'c1',
        text: '$7.0$'
      },
      {
        id: 'c2',
        text: '$0.67$'
      },
      {
        id: 'c3',
        text: '$1.50$'
      },
      {
        id: 'c4',
        text: '$1.40$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'easy',
    eli5: 'Plug the five summary statistics straight into the slope formula. Numerator: $5(205) - 25(35) = 1025 - 875 = 150$. Denominator: $5(145) - 25^2 = 725 - 625 = 100$. Slope: $150/100 = 1.50$. Choice B (0.67) is the reciprocal — you flipped numerator and denominator ($100/150 \\approx 0.67$). Choice A (7.0) is $\\bar{y} = 35/5$ — that is just the mean of $y$, not the slope. Choice D (1.40) comes from dividing $\\Sigma y / \\Sigma x = 35/25 = 1.4$ instead of using the regression formula.',
    hint: 'Use the slope formula: numerator is $n\\sum xy - \\sum x \\sum y$, denominator is $n\\sum x^2 - (\\sum x)^2$.',
    steps: [
      {
        text: 'Apply the slope formula:',
        latex: 'b = \\frac{n\\sum x_i y_i - \\sum x_i \\sum y_i}{n\\sum x_i^2 - (\\sum x_i)^2}'
      },
      {
        text: 'Compute the numerator:',
        latex: '5(205) - 25(35) = 1{,}025 - 875 = 150'
      },
      {
        text: 'Compute the denominator:',
        latex: '5(145) - (25)^2 = 725 - 625 = 100'
      },
      {
        text: 'Divide:',
        latex: 'b = \\frac{150}{100} = 1.50'
      }
    ],
    handbookPage: 'p. 69',
    handbookFormula: 'b = \\frac{n\\sum x_i y_i - \\sum x_i \\sum y_i}{n\\sum x_i^2 - (\\sum x_i)^2}',
    videoUrl: null,
    traps: [
      'Dividing the sum totals instead of using the regression formula (gives 1.40)',
      'Flipping the fraction to get the reciprocal (gives 0.67)'
    ],
    diagram: null,
    lessonId: 'linear-regression-correlation',
    chapterId: 'statistics'
  },
  {
    id: 'stat-reg-ex2',
    type: 'computational',
    statement: 'A water-resources engineer develops a regression of river stage ($x$, in ft) versus discharge ($y$, in cfs) using 10 measurements. The regression slope is $b = 350$, and the sample means are $\\bar{x} = 4.0$ and $\\bar{y} = 1{,}500$. What is the y-intercept $a$ of the regression line?',
    choices: [
      {
        id: 'c1',
        text: '$100$'
      },
      {
        id: 'c2',
        text: '$1{,}500$'
      },
      {
        id: 'c3',
        text: '$-100$'
      },
      {
        id: 'c4',
        text: '$375$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'The intercept formula is $a = \\bar{y} - b\\bar{x}$. Plug in: $a = 1500 - 350(4) = 1500 - 1400 = 100$. Choice B (1500) is just $\\bar{y}$ — someone forgot to subtract $b\\bar{x}$. Choice C ($-100$) gets the subtraction backwards, computing $b\\bar{x} - \\bar{y} = 1400 - 1500$. Choice D (375) looks like $\\bar{y}/\\bar{x} = 1500/4 = 375$ — that is the ratio of means, not the intercept.',
    hint: 'The regression line always passes through $(\\bar{x}, \\bar{y})$. Use $a = \\bar{y} - b\\bar{x}$.',
    steps: [
      {
        text: 'Apply the intercept formula:',
        latex: 'a = \\bar{y} - b\\bar{x}'
      },
      {
        text: 'Substitute the given values:',
        latex: 'a = 1{,}500 - 350(4.0) = 1{,}500 - 1{,}400 = 100'
      },
      {
        text: 'The regression equation is:',
        latex: '\\hat{y} = 100 + 350x'
      }
    ],
    handbookPage: 'p. 69',
    handbookFormula: 'a = \\bar{y} - b\\bar{x}',
    videoUrl: null,
    traps: ['Reporting the mean of y as the intercept', 'Reversing the subtraction to get a negative intercept'],
    diagram: null,
    lessonId: 'linear-regression-correlation',
    chapterId: 'statistics'
  },
  {
    id: 'stat-reg-ex3',
    type: 'computational',
    statement: 'An environmental engineer measures dissolved oxygen ($x$, in mg/L) and BOD ($y$, in mg/L) at 5 sampling stations. The summary statistics are: $n = 5$, $\\sum x = 15$, $\\sum y = 25$, $\\sum x_i y_i = 85$, $\\sum x_i^2 = 55$, $\\sum y_i^2 = 145$. What is the sample correlation coefficient $r$?',
    choices: [
      {
        id: 'c1',
        text: '$0.50$'
      },
      {
        id: 'c2',
        text: '$0.71$'
      },
      {
        id: 'c3',
        text: '$0.90$'
      },
      {
        id: 'c4',
        text: '$1.00$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Use the correlation formula. Numerator: $5(85) - 15(25) = 425 - 375 = 50$. X-side denominator: $5(55) - 15^2 = 275 - 225 = 50$. Y-side denominator: $5(145) - 25^2 = 725 - 625 = 100$. So $r = 50 / \\sqrt{50 \\times 100} = 50 / \\sqrt{5000} = 50/70.71 \\approx 0.71$. Choice A (0.50) squares the correct answer, confusing $r$ with $R^2$. Choice C (0.90) could result from misreading the table or rounding errors in intermediate steps. Choice D (1.00) divides the numerator by itself ($50/50$), using only $S_{xx}$ in the denominator and ignoring the $y$-side term entirely.',
    hint: 'The correlation formula has the same numerator as the slope formula, but you divide by $\\sqrt{S_{xx} \\cdot S_{yy}}$ instead of just $S_{xx}$.',
    steps: [
      {
        text: 'Compute the numerator (same as slope):',
        latex: 'S_{xy} = n\\sum x_i y_i - \\sum x_i \\sum y_i = 5(85) - 15(25) = 425 - 375 = 50'
      },
      {
        text: 'Compute the x-side term:',
        latex: 'S_{xx} = n\\sum x_i^2 - (\\sum x_i)^2 = 5(55) - (15)^2 = 275 - 225 = 50'
      },
      {
        text: 'Compute the y-side term:',
        latex: 'S_{yy} = n\\sum y_i^2 - (\\sum y_i)^2 = 5(145) - (25)^2 = 725 - 625 = 100'
      },
      {
        text: 'Divide:',
        latex: 'r = \\frac{50}{\\sqrt{50 \\times 100}} = \\frac{50}{\\sqrt{5{,}000}} = \\frac{50}{70.71} \\approx 0.71'
      }
    ],
    handbookPage: 'p. 69',
    handbookFormula: 'r = \\frac{n\\sum x_i y_i - \\sum x_i \\sum y_i}{\\sqrt{[n\\sum x_i^2 - (\\sum x_i)^2][n\\sum y_i^2 - (\\sum y_i)^2]}}',
    videoUrl: null,
    traps: [
      'Forgetting to include the $y$-side denominator term',
      'Confusing $r$ with $R^2$ (squaring the result instead of reporting it directly)'
    ],
    diagram: null,
    lessonId: 'linear-regression-correlation',
    chapterId: 'statistics'
  },
  {
    id: 'stat-reg-ex4',
    type: 'conceptual',
    statement: 'A pavement engineer fits a regression model of pavement age ($x$) versus International Roughness Index ($y$). The residual for one section is $e_i = -1.8$. Which of the following correctly interprets this residual?',
    choices: [
      {
        id: 'c1',
        text: 'The predicted IRI for that section is 1.8 units below the observed value'
      },
      {
        id: 'c2',
        text: 'The pavement section is 1.8 years younger than the regression model predicts'
      },
      {
        id: 'c3',
        text: 'The observed IRI for that section is 1.8 units below the value predicted by the regression line'
      },
      {
        id: 'c4',
        text: 'The regression model overestimates age by 1.8 years for that section'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'The residual is $e_i = y_i - \\hat{y}_i$ — observed minus predicted. A negative residual means the observed value is below the regression line. So the actual IRI is 1.8 units less than the model predicted. Choice A flips the relationship — it says the predicted is below the observed, which would be a positive residual. Choices B and D reinterpret the residual as an error in the $x$-variable (age), but residuals always measure vertical distance in the $y$-direction, not the $x$-direction. This is a subtle but critical distinction.',
    hint: 'Residual = observed minus predicted ($e_i = y_i - \\hat{y}_i$). A negative value means the observation is below the line.',
    steps: [
      {
        text: 'Recall the residual definition:',
        latex: 'e_i = y_i - \\hat{y}_i'
      },
      {
        text: 'A negative residual ($e_i = -1.8$) means $y_i < \\hat{y}_i$ — the observed value is below the predicted value.',
        latex: null
      },
      {
        text: 'The residual is always in the units of the response variable ($y$), not the predictor ($x$). It measures vertical distance from the regression line.',
        latex: null
      },
      {
        text: 'Choices C and D incorrectly apply the residual to the x-variable (age). Residuals describe discrepancies in $y$ only.',
        latex: null
      }
    ],
    handbookPage: 'p. 69',
    handbookFormula: 'e_i = y_i - \\hat{y}_i',
    videoUrl: null,
    traps: [
      'Reversing the direction (thinking negative means the prediction is below the observation)',
      'Applying the residual to the $x$-variable instead of the $y$-variable'
    ],
    diagram: {
      component: 'RegressionResidual',
      props: {
        residual: -1.8
      }
    },
    lessonId: 'linear-regression-correlation',
    chapterId: 'statistics'
  },
  {
    id: 'stat-dist-ex1',
    type: 'computational',
    statement: 'A construction crew has 12 workers available, and the foreman needs to assign 4 of them to a concrete pour. How many different crews of 4 can be formed?',
    choices: [
      {
        id: 'c1',
        text: '20,736'
      },
      {
        id: 'c2',
        text: '11,880'
      },
      {
        id: 'c3',
        text: '48'
      },
      {
        id: 'c4',
        text: '495'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'You are choosing a group, not ranking people, so order does not matter. That means combinations. Plug into $C(12,4) = 12!/(4! \\times 8!) = 495$. Choice B (11,880) is the permutation $P(12,4)$, which counts ordered arrangements. Choice C (48) is $12 \\times 4$, a common mental shortcut that does not apply here. Choice A (20,736) is $12^4$, which would be picks with replacement.',
    hint: 'Are you arranging the workers in order, or just picking a group?',
    steps: [
      {
        text: 'Order does not matter, so use combinations:',
        latex: 'C(12, 4) = \\frac{12!}{4!\\,(12-4)!} = \\frac{12!}{4!\\,8!}'
      },
      {
        text: 'Simplify:',
        latex: '\\frac{12 \\times 11 \\times 10 \\times 9}{4 \\times 3 \\times 2 \\times 1} = \\frac{11{,}880}{24} = 495'
      }
    ],
    handbookPage: 'p. 64',
    handbookFormula: 'C(n, r) = \\frac{n!}{r!\\,(n-r)!}',
    videoUrl: null,
    traps: [
      'Using permutations instead of combinations (gives 11,880)',
      'Computing $n \\times r$ instead of the combination formula'
    ],
    diagram: null,
    lessonId: 'probability-distributions',
    chapterId: 'statistics'
  },
  {
    id: 'stat-dist-ex2',
    type: 'computational',
    statement: 'A quality control program tests 15 welds on a steel structure. Each weld independently has a 95% probability of passing inspection. What is the probability that exactly 14 of the 15 welds pass?',
    choices: [
      {
        id: 'c1',
        text: '0.366'
      },
      {
        id: 'c2',
        text: '0.463'
      },
      {
        id: 'c3',
        text: '0.950'
      },
      {
        id: 'c4',
        text: '0.171'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'This is a binomial problem with $n=15$, $x=14$, $p=0.95$, $q=0.05$. Compute $C(15,14) \\times 0.95^{14} \\times 0.05^{1}$. $C(15,14)=15$. Then $15 \\times 0.4877 \\times 0.05 = 0.366$. Choice B (0.463) is $P(X=15)$, the probability all 15 pass. Choice C (0.950) is just $p$ by itself. Choice D (0.171) is what you get if you use $p=0.05$ and $q=0.95$ (swapped success and failure).',
    hint: 'Identify $n$, $x$, $p$, and $q$, then plug into the binomial formula. Do not forget the $C(n,x)$ term.',
    steps: [
      {
        text: 'Identify parameters: $n = 15$, $x = 14$, $p = 0.95$, $q = 0.05$.',
        latex: null
      },
      {
        text: 'Compute the combination:',
        latex: 'C(15, 14) = 15'
      },
      {
        text: 'Apply the binomial formula:',
        latex: 'P(X = 14) = 15 \\times (0.95)^{14} \\times (0.05)^{1}'
      },
      {
        text: 'Evaluate:',
        latex: '15 \\times 0.4877 \\times 0.05 = 0.366'
      }
    ],
    handbookPage: 'p. 66',
    handbookFormula: 'P(X = x) = C(n, x)\\,p^x(1-p)^{n-x}',
    videoUrl: null,
    traps: [
      'Computing $P(\\text{all 15 pass})$ instead of $P(\\text{exactly 14 pass})$',
      'Swapping $p$ and $q$ in the formula'
    ],
    diagram: null,
    lessonId: 'probability-distributions',
    chapterId: 'statistics'
  },
  {
    id: 'stat-dist-ex3',
    type: 'computational',
    statement: 'The annual maximum discharge of a river is normally distributed with $\\mu = 850\\,\\text{m}^3\\text{/s}$ and $\\sigma = 120\\,\\text{m}^3\\text{/s}$. A flood wall is designed for a flow of $1{,}090\\,\\text{m}^3\\text{/s}$. Using the z-table where $F(2.0) = 0.9772$, what is the probability that the annual maximum discharge exceeds the design flow in any given year?',
    choices: [
      {
        id: 'c1',
        text: '97.72%'
      },
      {
        id: 'c2',
        text: '2.28%'
      },
      {
        id: 'c3',
        text: '4.56%'
      },
      {
        id: 'c4',
        text: '2.00%'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Convert the design flow to a z-score: $(1090 - 850)/120 = 2.0$. The table gives $F(2.0) = 0.9772$, which is the area to the LEFT. You want the area to the RIGHT (exceeds), so subtract from 1: $1 - 0.9772 = 0.0228 = 2.28\\%$. Choice A (97.72%) is the area below the design flow, not above it. Choice C (4.56%) doubles the tail area as if it were a two-tailed problem. Choice D (2.00%) confuses the z-score value with the probability.',
    hint: 'Compute the z-score, then use $R(z) = 1 - F(z)$ for the right-tail probability.',
    steps: [
      {
        text: 'Compute the z-score:',
        latex: 'z = \\frac{x - \\mu}{\\sigma} = \\frac{1{,}090 - 850}{120} = \\frac{240}{120} = 2.0'
      },
      {
        text: 'Look up $F(2.0) = 0.9772$ (area to the left).',
        latex: null
      },
      {
        text: 'The probability of exceeding the design flow is the right-tail area:',
        latex: 'P(X > 1{,}090) = 1 - F(2.0) = 1 - 0.9772 = 0.0228 = 2.28\\%'
      }
    ],
    handbookPage: 'p. 67',
    handbookFormula: 'z = \\frac{x - \\mu}{\\sigma}',
    videoUrl: null,
    traps: [
      'Reporting the left-tail area (97.72%) instead of the right-tail area',
      'Confusing the z-score (2.0) with a probability (2.00%)'
    ],
    diagram: null,
    lessonId: 'probability-distributions',
    chapterId: 'statistics'
  },
  {
    id: 'stat-dist-ex4',
    type: 'conceptual',
    statement: 'A quality engineer observes that out of 20 independent concrete cylinder tests, 3 fail to meet the minimum strength. She wants to model the probability of failure using a standard probability distribution. Which distribution is most appropriate?',
    choices: [
      {
        id: 'c1',
        text: 'Normal distribution'
      },
      {
        id: 'c2',
        text: 'Binomial distribution'
      },
      {
        id: 'c3',
        text: 'Poisson distribution'
      },
      {
        id: 'c4',
        text: 'Uniform distribution'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'The key clues are: fixed number of trials ($n = 20$), each trial has two outcomes (pass or fail), and the trials are independent. That is the textbook definition of a binomial setting. The normal distribution applies to continuous measurements, not discrete pass/fail counts. The Poisson distribution models the number of events in a continuous interval (like defects per meter), not a fixed number of trials. The uniform distribution means every outcome is equally likely, which does not match pass/fail with a specific probability.',
    hint: 'Look for the hallmarks: fixed trials, two outcomes, independence.',
    steps: [
      {
        text: 'Check the conditions: fixed number of trials ($n = 20$), two outcomes (pass/fail), independent tests, constant probability of failure.',
        latex: null
      },
      {
        text: 'All four conditions match the binomial distribution.',
        latex: null
      },
      {
        text: 'Normal applies to continuous measurements; Poisson applies to event counts in a continuous interval; Uniform implies equal likelihood of all outcomes.',
        latex: null
      }
    ],
    handbookPage: 'p. 66',
    handbookFormula: 'P(X = x) = C(n, x)\\,p^x(1-p)^{n-x}',
    videoUrl: null,
    traps: [
      'Choosing Poisson because it also deals with counts, but Poisson is for events in a continuous interval, not fixed trials'
    ],
    diagram: null,
    lessonId: 'probability-distributions',
    chapterId: 'statistics'
  },
  {
    id: 'stat-ev-ex1',
    type: 'computational',
    statement: 'A geotechnical contractor estimates the following costs for a slope stabilization project: 150,000 with probability 0.30, 200,000 with probability 0.50, and 280,000 with probability 0.20. What is the expected project cost?',
    choices: [
      {
        id: 'c1',
        text: '630,000'
      },
      {
        id: 'c2',
        text: '200,000'
      },
      {
        id: 'c3',
        text: '210,000'
      },
      {
        id: 'c4',
        text: '201,000'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'Multiply each cost by its probability and add. $150{,}000 \\times 0.30 = 45{,}000$. $200{,}000 \\times 0.50 = 100{,}000$. $280{,}000 \\times 0.20 = 56{,}000$. Total = 201,000. Choice B (200,000) is the most likely outcome, not the expected value. Choice C (210,000) is the simple average of the three costs ($630{,}000/3$), which ignores the probabilities. Choice A (630,000) is the sum of all costs without any probability weighting.',
    hint: 'Multiply each outcome by its probability and sum the products.',
    steps: [
      {
        text: 'Apply $E(X) = \\sum x_k \\cdot P(x_k)$:',
        latex: 'E(X) = 150{,}000(0.30) + 200{,}000(0.50) + 280{,}000(0.20)'
      },
      {
        text: 'Compute each term:',
        latex: '45{,}000 + 100{,}000 + 56{,}000 = 201{,}000'
      }
    ],
    handbookPage: 'p. 65',
    handbookFormula: 'E(X) = \\sum_{k=1}^{n} x_k \\cdot P(x_k)',
    videoUrl: null,
    traps: [
      'Picking the most likely outcome instead of computing the weighted sum',
      'Taking the simple average of all costs instead of using probabilities'
    ],
    diagram: null,
    lessonId: 'expected-value-weighted-averages',
    chapterId: 'statistics'
  },
  {
    id: 'stat-ev-ex2',
    type: 'computational',
    statement: 'A water treatment plant monitors daily turbidity readings (NTU). The probability distribution is: $x = 1$ with $P = 0.15$, $x = 2$ with $P = 0.35$, $x = 3$ with $P = 0.30$, $x = 4$ with $P = 0.15$, $x = 5$ with $P = 0.05$. What is the standard deviation of daily turbidity?',
    choices: [
      {
        id: 'c1',
        text: '2.60'
      },
      {
        id: 'c2',
        text: '1.15'
      },
      {
        id: 'c3',
        text: '1.07'
      },
      {
        id: 'c4',
        text: '7.90'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'First find $E(X)$: $1(0.15)+2(0.35)+3(0.30)+4(0.15)+5(0.05) = 2.60$. Then find $E(X^2)$: $1(0.15)+4(0.35)+9(0.30)+16(0.15)+25(0.05) = 7.90$. Variance $= 7.90 - 2.60^2 = 7.90 - 6.76 = 1.14$. Standard deviation $= \\sqrt{1.14} = 1.07$. Choice B (1.15) is a common arithmetic slip. Choice A (2.60) is the mean, not the standard deviation. Choice D (7.90) is $E(X^2)$, only half the calculation.',
    hint: 'Use the shortcut $\\text{Var}(X) = E(X^2) - [E(X)]^2$, then take the square root for the standard deviation.',
    steps: [
      {
        text: 'Compute $E(X)$:',
        latex: '1(0.15) + 2(0.35) + 3(0.30) + 4(0.15) + 5(0.05) = 2.60'
      },
      {
        text: 'Compute $E(X^2)$:',
        latex: '1(0.15) + 4(0.35) + 9(0.30) + 16(0.15) + 25(0.05) = 7.90'
      },
      {
        text: 'Variance:',
        latex: '\\text{Var}(X) = 7.90 - (2.60)^2 = 7.90 - 6.76 = 1.14'
      },
      {
        text: 'Standard deviation:',
        latex: '\\sigma = \\sqrt{1.14} = 1.07'
      }
    ],
    handbookPage: 'p. 65',
    handbookFormula: '\\text{Var}(X) = E(X^2) - [E(X)]^2',
    videoUrl: null,
    traps: ['Reporting $E(X)$ as the answer (gives 2.60)', 'Forgetting to take the square root of the variance'],
    diagram: null,
    lessonId: 'expected-value-weighted-averages',
    chapterId: 'statistics'
  },
  {
    id: 'stat-ev-ex3',
    type: 'computational',
    statement: 'A retaining wall design involves two independent soil pressure components. The active pressure $P_a$ has a mean of $40\\,\\text{kN/m}$ and standard deviation of $6\\,\\text{kN/m}$. The surcharge pressure $P_s$ has a mean of $15\\,\\text{kN/m}$ and standard deviation of $4\\,\\text{kN/m}$. The total lateral force is $F = 2P_a + P_s$. What is the standard deviation of $F$?',
    choices: [
      {
        id: 'c1',
        text: '$12.65\\,\\text{kN/m}$'
      },
      {
        id: 'c2',
        text: '$16.0\\,\\text{kN/m}$'
      },
      {
        id: 'c3',
        text: '$160\\,\\text{kN/m}$'
      },
      {
        id: 'c4',
        text: '$95.0\\,\\text{kN/m}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'When combining independent random variables with constants, the variances of the scaled variables add. The constant multiplier gets squared before multiplying the variance. $\\text{Var}(F) = 2^2 \\times 6^2 + 1^2 \\times 4^2 = 4(36) + 1(16) = 144 + 16 = 160$. Then the standard deviation is $\\sqrt{160} = 12.65$. Choice B (16.0) adds the standard deviations with the constant: $2(6) + 4 = 16$, which is wrong because standard deviations do not add that way. Choice C (160) is the variance, not the standard deviation. Choice D (95.0) is the mean of $F$, not the standard deviation.',
    hint: 'Square the constants, multiply by the respective variances, add, then take the square root.',
    steps: [
      {
        text: 'For independent variables, use:',
        latex: '\\text{Var}(F) = a_1^2\\,\\sigma_1^2 + a_2^2\\,\\sigma_2^2'
      },
      {
        text: 'With $a_1 = 2$, $\\sigma_1 = 6$, $a_2 = 1$, $\\sigma_2 = 4$:',
        latex: '\\text{Var}(F) = 2^2(6^2) + 1^2(4^2) = 4(36) + 1(16) = 144 + 16 = 160'
      },
      {
        text: 'Standard deviation:',
        latex: '\\sigma_F = \\sqrt{160} = 12.65\\,\\text{kN/m}'
      }
    ],
    handbookPage: 'p. 65',
    handbookFormula: '\\text{Var}(a_1X_1 + a_2X_2) = a_1^2\\sigma_1^2 + a_2^2\\sigma_2^2',
    videoUrl: null,
    traps: [
      'Adding scaled standard deviations directly instead of working with variances',
      'Forgetting to square the constant multiplier before applying it to the variance'
    ],
    diagram: null,
    lessonId: 'expected-value-weighted-averages',
    chapterId: 'statistics'
  },
  {
    id: 'stat-ev-ex4',
    type: 'conceptual',
    statement: 'A project has three independent cost components: materials ($X_1$), labor ($X_2$), and equipment ($X_3$). The standard deviations are $\\sigma_1 = 10{,}000$, $\\sigma_2 = 8{,}000$, and $\\sigma_3 = 5{,}000$. An engineer estimates the total project standard deviation as $\\sigma_1 + \\sigma_2 + \\sigma_3 = 23{,}000$. What is wrong with this calculation?',
    choices: [
      {
        id: 'c1',
        text: 'The costs are not independent, so neither variances nor standard deviations can be combined'
      },
      {
        id: 'c2',
        text: 'Standard deviations of independent variables do not add directly; variances must be added first, then the square root taken'
      },
      {
        id: 'c3',
        text: 'The engineer should have subtracted the standard deviations instead of adding them'
      },
      {
        id: 'c4',
        text: 'The calculation is correct because expected values and standard deviations both add linearly'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'This is one of the biggest traps in probability. Expected values add linearly, but standard deviations do NOT. You have to add the variances (the squares of the standard deviations) and then take the square root. The correct total standard deviation is $\\sqrt{10{,}000^2 + 8{,}000^2 + 5{,}000^2} = \\sqrt{189{,}000{,}000} \\approx 13{,}748$, which is much less than 23,000. Choice A is wrong because the problem states the costs are independent. Choice C makes no sense statistically. Choice D confuses linearity of expectation with standard deviation.',
    hint: 'Think about what property holds for sums: $E(X+Y) = E(X) + E(Y)$ always, but does the same hold for $\\sigma$?',
    steps: [
      {
        text: 'Linearity of expectation: $E(X_1 + X_2 + X_3) = E(X_1) + E(X_2) + E(X_3)$ always holds.',
        latex: null
      },
      {
        text: 'But for standard deviation, the rule is different:',
        latex: '\\sigma_{\\text{total}} = \\sqrt{\\sigma_1^2 + \\sigma_2^2 + \\sigma_3^2}'
      },
      {
        text: 'The correct value:',
        latex: '\\sigma_{\\text{total}} = \\sqrt{10{,}000^2 + 8{,}000^2 + 5{,}000^2} = \\sqrt{189 \\times 10^6} \\approx 13{,}748'
      },
      {
        text: 'This is much less than the naive sum of 23,000 because diversification reduces overall uncertainty.',
        latex: null
      }
    ],
    handbookPage: 'p. 65',
    handbookFormula: '\\text{Var}(X_1 + X_2 + \\cdots) = \\sigma_1^2 + \\sigma_2^2 + \\cdots',
    videoUrl: null,
    traps: [
      'Assuming standard deviations add linearly like expected values',
      'Confusing the rules for E(X) and sigma(X) when combining independent variables'
    ],
    diagram: null,
    lessonId: 'expected-value-weighted-averages',
    chapterId: 'statistics'
  },
  {
    id: 'stat-est-ex1',
    type: 'computational',
    statement: 'A materials lab tests 16 concrete cylinders and measures a mean compressive strength of $\\bar{x} = 4{,}400\\,\\text{psi}$. The population standard deviation is known to be $\\sigma = 200\\,\\text{psi}$. What is the 95% confidence interval for the true mean strength?',
    choices: [
      {
        id: 'c1',
        text: '$(4{,}008\\,\\text{psi},\\; 4{,}792\\,\\text{psi})$'
      },
      {
        id: 'c2',
        text: '$(4{,}302\\,\\text{psi},\\; 4{,}498\\,\\text{psi})$'
      },
      {
        id: 'c3',
        text: '$(4{,}376\\,\\text{psi},\\; 4{,}424\\,\\text{psi})$'
      },
      {
        id: 'c4',
        text: '$(4{,}375\\,\\text{psi},\\; 4{,}425\\,\\text{psi})$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'Since $\\sigma$ is known, use the z-interval. The standard error is $\\sigma/\\sqrt{n} = 200/\\sqrt{16} = 200/4 = 50$. The margin of error is $1.960 \\times 50 = 98$. So the interval is $4400 \\pm 98$, giving (4302, 4498). Choice A (4008, 4792) forgot to divide by $\\sqrt{n}$, using the full $\\sigma = 200$. Choice C uses $z = 1.0$ instead of 1.960. Choice D divides by $n = 16$ instead of $\\sqrt{n} = 4$.',
    hint: 'The problem gives $\\sigma$ (not $s$), so use the z-interval with $z_{\\alpha/2} = 1.960$.',
    steps: [
      {
        text: 'Identify: $\\bar{x} = 4{,}400$, $\\sigma = 200$, $n = 16$, $z_{\\alpha/2} = 1.960$.',
        latex: null
      },
      {
        text: 'Compute the standard error:',
        latex: '\\frac{\\sigma}{\\sqrt{n}} = \\frac{200}{\\sqrt{16}} = \\frac{200}{4} = 50'
      },
      {
        text: 'Margin of error:',
        latex: 'E = 1.960 \\times 50 = 98'
      },
      {
        text: 'Confidence interval:',
        latex: '4{,}400 \\pm 98 = (4{,}302,\\; 4{,}498)'
      }
    ],
    handbookPage: 'p. 74',
    handbookFormula: '\\bar{x} \\pm z_{\\alpha/2}\\frac{\\sigma}{\\sqrt{n}}',
    videoUrl: null,
    traps: ['Forgetting to divide $\\sigma$ by $\\sqrt{n}$', 'Dividing by $n$ instead of $\\sqrt{n}$'],
    diagram: null,
    lessonId: 'confidence-intervals-estimation',
    chapterId: 'statistics'
  },
  {
    id: 'stat-est-ex2',
    type: 'computational',
    statement: 'A geotechnical engineer tests 9 soil samples and obtains a sample mean friction angle of $\\bar{x} = 34^\\circ$ with a sample standard deviation of $s = 3^\\circ$. Using $t_{0.025,\\,8} = 2.306$, what is the 95% confidence interval for the true mean friction angle?',
    choices: [
      {
        id: 'c1',
        text: '$(31.69^\\circ,\\; 36.31^\\circ)$'
      },
      {
        id: 'c2',
        text: '$(32.04^\\circ,\\; 35.96^\\circ)$'
      },
      {
        id: 'c3',
        text: '$(27.08^\\circ,\\; 40.92^\\circ)$'
      },
      {
        id: 'c4',
        text: '$(33.23^\\circ,\\; 34.77^\\circ)$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'The problem gives $s$ (sample standard deviation), not $\\sigma$, so use the t-interval. The standard error is $s/\\sqrt{n} = 3/\\sqrt{9} = 3/3 = 1.0$. The margin is $2.306 \\times 1.0 = 2.306$, which rounds to 2.31. The interval is $34 \\pm 2.31 = (31.69,\\; 36.31)$. Choice B uses $z = 1.960$ instead of the given t-value. Choice C forgot to divide by $\\sqrt{n}$, using $2.306 \\times 3 = 6.92$. Choice D divides by $n = 9$ instead of $\\sqrt{9} = 3$.',
    hint: 'The problem gives $s$ (not $\\sigma$), so use the t-interval. Remember $\\sqrt{9} = 3$.',
    steps: [
      {
        text: 'Identify: $\\bar{x} = 34$, $s = 3$, $n = 9$, $v = 8$, $t_{0.025,\\,8} = 2.306$.',
        latex: null
      },
      {
        text: 'Compute the standard error:',
        latex: '\\frac{s}{\\sqrt{n}} = \\frac{3}{\\sqrt{9}} = \\frac{3}{3} = 1.0'
      },
      {
        text: 'Margin of error:',
        latex: 'E = 2.306 \\times 1.0 = 2.306'
      },
      {
        text: 'Confidence interval:',
        latex: '34 \\pm 2.31 = (31.69^\\circ,\\; 36.31^\\circ)'
      }
    ],
    handbookPage: 'p. 74',
    handbookFormula: '\\bar{x} \\pm t_{\\alpha/2,\\,n-1}\\frac{s}{\\sqrt{n}}',
    videoUrl: null,
    traps: ['Using $z = 1.960$ instead of the given t-value', 'Forgetting to divide $s$ by $\\sqrt{n}$'],
    diagram: null,
    lessonId: 'confidence-intervals-estimation',
    chapterId: 'statistics'
  },
  {
    id: 'stat-est-ex3',
    type: 'computational',
    statement: 'A structural engineer wants to estimate the mean yield strength of reinforcing steel within $\\pm 5\\,\\text{MPa}$ at 99% confidence. Historical data shows $\\sigma = 18\\,\\text{MPa}$. Using $z_{0.005} = 2.576$, how many specimens must be tested?',
    choices: [
      {
        id: 'c1',
        text: '10'
      },
      {
        id: 'c2',
        text: '85.47'
      },
      {
        id: 'c3',
        text: '86'
      },
      {
        id: 'c4',
        text: '50'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Use the sample size formula: $n = (z \\cdot \\sigma / e)^2$. Plug in: $n = (2.576 \\times 18 / 5)^2 = (46.368 / 5)^2 = 9.274^2 = 85.99$. Round up to 86 because you cannot test a fraction of a specimen. Choice B (85.47) is the raw calculation before rounding, which is not a valid sample size. Choice A (10) comes from forgetting to square the result. Choice D (50) uses $z = 1.645$ (90% confidence) instead of 2.576 (99%).',
    hint: 'Use $n = (z_{\\alpha/2} \\cdot \\sigma / e)^2$ and always round up.',
    steps: [
      {
        text: 'Identify: $e = 5$, $\\sigma = 18$, $z_{\\alpha/2} = 2.576$.',
        latex: null
      },
      {
        text: 'Apply the sample size formula:',
        latex: 'n = \\left(\\frac{z_{\\alpha/2} \\cdot \\sigma}{e}\\right)^2 = \\left(\\frac{2.576 \\times 18}{5}\\right)^2'
      },
      {
        text: 'Compute inside:',
        latex: '\\frac{46.37}{5} = 9.274'
      },
      {
        text: 'Square:',
        latex: 'n = 9.274^2 = 85.99'
      },
      {
        text: 'Round up: $n = 86$ specimens.',
        latex: null
      }
    ],
    handbookPage: 'p. 75',
    handbookFormula: 'n = \\left(\\frac{z_{\\alpha/2} \\cdot \\sigma}{e}\\right)^2',
    videoUrl: null,
    traps: [
      'Reporting the raw decimal instead of rounding up',
      'Forgetting to square the result (gives about 10)'
    ],
    diagram: null,
    lessonId: 'confidence-intervals-estimation',
    chapterId: 'statistics'
  },
  {
    id: 'stat-est-ex4',
    type: 'conceptual',
    statement: 'An engineer constructs a 95% confidence interval for the mean compressive strength of a concrete mix and obtains $(4{,}120,\\; 4{,}480)$ psi. Which of the following is the correct interpretation?',
    choices: [
      {
        id: 'c1',
        text: 'There is a 95% probability that the true mean strength is between 4,120 and 4,480 psi'
      },
      {
        id: 'c2',
        text: 'If many samples were taken and intervals constructed the same way, about 95% of those intervals would contain the true mean'
      },
      {
        id: 'c3',
        text: '95% of all individual cylinder strengths fall between 4,120 and 4,480 psi'
      },
      {
        id: 'c4',
        text: 'The sample mean falls between 4,120 and 4,480 psi with 95% certainty'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'This is one of the most commonly misunderstood concepts in statistics. A confidence interval is about the procedure, not a single interval. If you repeated the experiment many times and built a 95% CI each time, about 95% of those intervals would capture the true mean. Choice A sounds right but is technically wrong because the true mean is a fixed number, not random. Choice C confuses a confidence interval for the mean with a prediction interval for individual values. Choice D is trivially true and not what the confidence level means.',
    hint: 'The confidence level refers to the long-run success rate of the procedure, not a probability statement about one specific interval.',
    steps: [
      {
        text: 'A 95% confidence interval means: if we repeated the sampling process many times, 95% of the resulting intervals would contain the true population mean.',
        latex: null
      },
      {
        text: 'It does NOT mean there is a 95% probability that the true mean falls in this particular interval. The true mean is a fixed (unknown) value, not a random variable.',
        latex: null
      },
      {
        text: 'It also does NOT describe where individual measurements fall. That would require a prediction interval, which is always wider.',
        latex: null
      }
    ],
    handbookPage: 'p. 74',
    handbookFormula: '\\bar{x} \\pm z_{\\alpha/2}\\frac{\\sigma}{\\sqrt{n}}',
    videoUrl: null,
    traps: [
      'Interpreting the interval as a probability statement about the true mean',
      'Confusing a confidence interval for the mean with a range for individual values'
    ],
    diagram: null,
    lessonId: 'confidence-intervals-estimation',
    chapterId: 'statistics'
  },
  {
    id: 'stat-ht-ex1',
    type: 'computational',
    statement: 'A concrete supplier claims the mean 28-day compressive strength of their mix is $4{,}500\\,\\text{psi}$. A lab tests 25 cylinders and obtains $\\bar{x} = 4{,}380\\,\\text{psi}$ with a known population standard deviation $\\sigma = 300\\,\\text{psi}$. What is the z-test statistic for a two-tailed test?',
    choices: [
      {
        id: 'c1',
        text: '$z = 2.0$'
      },
      {
        id: 'c2',
        text: '$z = -0.40$'
      },
      {
        id: 'c3',
        text: '$z = -10.0$'
      },
      {
        id: 'c4',
        text: '$z = -2.0$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'Plug straight into the z-test formula: numerator is $4380 - 4500 = -120$. Denominator is the standard error: $300/\\sqrt{25} = 300/5 = 60$. So $z = -120/60 = -2.0$. The negative sign matters because the sample mean is below the claimed mean. Choice B ($-0.40$) divides by $\\sigma$ itself ($120/300$) without the $\\sqrt{n}$ correction. Choice C ($-10.0$) multiplies by $\\sqrt{n}$ instead of dividing $\\sigma$ by it. Choice A (2.0) takes the absolute value, losing the direction.',
    hint: 'Compute the standard error $\\sigma / \\sqrt{n}$ first, then divide the difference $\\bar{x} - \\mu_0$ by it.',
    steps: [
      {
        text: 'Identify: $\\bar{x} = 4{,}380$, $\\mu_0 = 4{,}500$, $\\sigma = 300$, $n = 25$.',
        latex: null
      },
      {
        text: 'Compute the standard error:',
        latex: '\\frac{\\sigma}{\\sqrt{n}} = \\frac{300}{\\sqrt{25}} = \\frac{300}{5} = 60'
      },
      {
        text: 'Compute the test statistic:',
        latex: 'z = \\frac{\\bar{x} - \\mu_0}{\\sigma / \\sqrt{n}} = \\frac{4{,}380 - 4{,}500}{60} = \\frac{-120}{60} = -2.0'
      }
    ],
    handbookPage: 'p. 72',
    handbookFormula: 'z = \\frac{\\bar{x} - \\mu_0}{\\sigma / \\sqrt{n}}',
    videoUrl: null,
    traps: [
      'Dividing by $\\sigma$ instead of $\\sigma/\\sqrt{n}$',
      'Dropping the negative sign from the test statistic'
    ],
    diagram: null,
    lessonId: 'hypothesis-testing-goodness-of-fit',
    chapterId: 'statistics'
  },
  {
    id: 'stat-ht-ex2',
    type: 'computational',
    statement: 'A transportation engineer suspects the mean speed on a highway segment exceeds the posted limit of $65\\,\\text{mph}$. She measures 20 vehicles and finds $\\bar{x} = 68.5\\,\\text{mph}$ with $s = 7\\,\\text{mph}$. Using $t_{0.05,\\,19} = 1.729$, what should she conclude at $\\alpha = 0.05$?',
    choices: [
      {
        id: 'c1',
        text: 'Reject $H_0$; evidence that $\\mu > 65\\,\\text{mph}$ ($t = 2.24$)'
      },
      {
        id: 'c2',
        text: 'Fail to reject $H_0$; insufficient evidence ($t = 2.24$)'
      },
      {
        id: 'c3',
        text: 'Reject $H_0$; evidence that $\\mu \\neq 65\\,\\text{mph}$ ($t = 2.24$)'
      },
      {
        id: 'c4',
        text: 'Fail to reject $H_0$; insufficient evidence ($t = 0.50$)'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'First compute the t-statistic: $(68.5 - 65) / (7/\\sqrt{20}) = 3.5 / 1.565 = 2.24$. Since $2.24 > 1.729$ (the critical value), reject $H_0$. The claim is one-tailed (exceeds), so use the one-tailed test. Choice B gets the comparison wrong: 2.24 is greater than 1.729, so you reject, not fail to reject. Choice C uses the wrong alternative hypothesis (two-tailed instead of one-tailed). Choice D computes $t = 3.5/7 = 0.50$, forgetting to divide $s$ by $\\sqrt{n}$.',
    hint: 'Compute the t-statistic, then compare to the given critical value. The claim is one-tailed (exceeds).',
    steps: [
      {
        text: 'Set up hypotheses: $H_0: \\mu \\leq 65$, $H_1: \\mu > 65$ (one-tailed right).',
        latex: null
      },
      {
        text: 'Compute the standard error:',
        latex: '\\frac{s}{\\sqrt{n}} = \\frac{7}{\\sqrt{20}} = \\frac{7}{4.472} = 1.565'
      },
      {
        text: 'Compute the test statistic:',
        latex: 't = \\frac{68.5 - 65}{1.565} = \\frac{3.5}{1.565} = 2.24'
      },
      {
        text: 'Compare: $t = 2.24 > t_{\\text{crit}} = 1.729$. Reject $H_0$.',
        latex: null
      }
    ],
    handbookPage: 'p. 73',
    handbookFormula: 't = \\frac{\\bar{x} - \\mu_0}{s / \\sqrt{n}}',
    videoUrl: null,
    traps: [
      'Forgetting to divide $s$ by $\\sqrt{n}$ in the denominator',
      'Confusing one-tailed with two-tailed critical values'
    ],
    diagram: null,
    lessonId: 'hypothesis-testing-goodness-of-fit',
    chapterId: 'statistics'
  },
  {
    id: 'stat-ht-ex3',
    type: 'computational',
    statement: 'A traffic engineer records accident counts at 5 intersections over a year and tests whether the data fits a uniform distribution. Observed counts: $O_1 = 18$, $O_2 = 25$, $O_3 = 12$, $O_4 = 22$, $O_5 = 23$. The total is 100 accidents. What is the chi-square test statistic?',
    choices: [
      {
        id: 'c1',
        text: '$\\chi^2 = 90$'
      },
      {
        id: 'c2',
        text: '$\\chi^2 = 5.3$'
      },
      {
        id: 'c3',
        text: '$\\chi^2 = 20$'
      },
      {
        id: 'c4',
        text: '$\\chi^2 = 0.225$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Under a uniform distribution with 5 categories and 100 total, each expected count is $E = 100/5 = 20$. Then compute $(O-E)^2/E$ for each: $(18-20)^2/20 + (25-20)^2/20 + (12-20)^2/20 + (22-20)^2/20 + (23-20)^2/20 = 4/20 + 25/20 + 64/20 + 4/20 + 9/20 = (4+25+64+4+9)/20 = 106/20 = 5.3$. The computed $\\chi^2 = 5.3$.',
    hint: 'Compute each expected count as the total divided by the number of categories, then apply $\\sum (O_i - E_i)^2 / E_i$.',
    steps: [
      {
        text: 'Under uniform distribution:',
        latex: 'E_i = \\frac{100}{5} = 20'
      },
      {
        text: 'Compute each term:',
        latex: '\\frac{(18-20)^2}{20} + \\frac{(25-20)^2}{20} + \\frac{(12-20)^2}{20} + \\frac{(22-20)^2}{20} + \\frac{(23-20)^2}{20}'
      },
      {
        text: 'Simplify:',
        latex: '\\frac{4 + 25 + 64 + 4 + 9}{20} = \\frac{106}{20} = 5.3'
      }
    ],
    handbookPage: 'p. 75',
    handbookFormula: '\\chi^2 = \\sum_{i=1}^{k} \\frac{(O_i - E_i)^2}{E_i}',
    videoUrl: null,
    traps: ['Forgetting to divide by $E$ in each term', 'Computing $(O-E)/E$ instead of $(O-E)^2/E$'],
    diagram: null,
    lessonId: 'hypothesis-testing-goodness-of-fit',
    chapterId: 'statistics'
  },
  {
    id: 'stat-ht-ex4',
    type: 'conceptual',
    statement: 'A materials engineer tests whether a new additive changes the mean setting time of concrete. She performs a hypothesis test at $\\alpha = 0.05$ and obtains a p-value of $0.08$. She concludes: "The additive has no effect on setting time." What is wrong with her conclusion?',
    choices: [
      {
        id: 'c1',
        text: 'A p-value of 0.08 means there is an 8% chance the additive has no effect'
      },
      {
        id: 'c2',
        text: 'She should have used $\\alpha = 0.10$ so the result would be significant'
      },
      {
        id: 'c3',
        text: 'She should say "fail to reject $H_0$" rather than claiming $H_0$ is true; insufficient evidence is not proof of no effect'
      },
      {
        id: 'c4',
        text: 'She should have used a one-tailed test to get a smaller p-value'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'The fundamental rule: failing to reject $H_0$ does NOT prove $H_0$ is true. It only means you did not find enough evidence to reject it. Maybe the effect is real but too small for your sample size to detect, or maybe there truly is no effect. You cannot tell. Choice B is wrong because you do not change $\\alpha$ after seeing the data to get the result you want. Choice A misinterprets the p-value: it is the probability of the observed data (or more extreme) given $H_0$ is true, not the probability that $H_0$ is true. Choice D is data-mining: you pick the test before collecting data, not after.',
    hint: 'Think carefully about what "fail to reject" means versus "accept."',
    steps: [
      {
        text: 'Since p-value (0.08) > alpha (0.05), the correct decision is to fail to reject $H_0$.',
        latex: null
      },
      {
        text: 'Failing to reject $H_0$ means insufficient evidence to conclude the additive changes setting time. It does NOT mean the additive has no effect.',
        latex: null
      },
      {
        text: 'Claiming $H_0$ is true ("no effect") is the classic error of accepting the null rather than merely failing to reject it.',
        latex: null
      }
    ],
    handbookPage: 'p. 72',
    handbookFormula: '\\text{Reject } H_0 \\text{ if } |z| > z_{\\alpha/2}',
    videoUrl: null,
    traps: [
      'Equating "fail to reject" with "$H_0$ is proven true"',
      'Misinterpreting the p-value as the probability that $H_0$ is true'
    ],
    diagram: null,
    lessonId: 'hypothesis-testing-goodness-of-fit',
    chapterId: 'statistics'
  },
];

export default PROBLEMS;
