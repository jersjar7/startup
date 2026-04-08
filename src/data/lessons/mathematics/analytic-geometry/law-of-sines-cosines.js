export default {
  "id": "law-of-sines-cosines",
  "name": "Law of Sines & Law of Cosines",
  "subtopicId": "analytic-geometry",
  "application": "Civil engineers encounter oblique triangles — triangles with no right angle — when surveying irregular property boundaries, computing forces in non-orthogonal truss members, or triangulating positions from two known points. The Law of Sines and Law of Cosines let you solve any triangle when you can't drop a clean perpendicular. On the FE exam, if the given triangle isn't a right triangle, one of these two laws is your only path forward.",
  "content": [
    {
      "type": "text",
      "body": "Two formulas cover every oblique triangle."
    },
    {
      "type": "heading",
      "body": "Law of Sines"
    },
    {
      "type": "formula",
      "latex": "\\frac{a}{\\sin A} = \\frac{b}{\\sin B} = \\frac{c}{\\sin C}"
    },
    {
      "type": "text",
      "body": "Works when you have an angle and its opposite side plus one more piece."
    },
    {
      "type": "heading",
      "body": "Law of Cosines"
    },
    {
      "type": "formula",
      "latex": "c^2 = a^2 + b^2 - 2ab\\cos C"
    },
    {
      "type": "text",
      "body": "Works when you have two sides and the included angle (SAS) or all three sides (SSS)."
    },
    {
      "type": "callout",
      "variant": "tip",
      "body": "Decision tree: if you know a side-angle pair, start with Sines. If you know SAS or SSS, start with Cosines."
    },
    {
      "type": "callout",
      "variant": "exam",
      "body": "Watch out for the ambiguous case with Law of Sines (two possible triangles). The FE usually avoids it, but if you see SSA given, check whether a second solution exists."
    }
  ],
  "illustration": null,
  "problems": [
    {
      "id": "math-lsc-q1",
      "statement": "In triangle ABC, angle $A = 40°$, angle $B = 75°$, and side $a = 18\\,\\text{m}$. What is the length of side $b$?",
      "choices": [
        {
          "id": "c1",
          "text": "22.4 m"
        },
        {
          "id": "c2",
          "text": "27.1 m"
        },
        {
          "id": "c3",
          "text": "11.6 m"
        },
        {
          "id": "c4",
          "text": "18.7 m"
        }
      ],
      "correctAnswerId": "c2",
      "difficulty": "easy",
      "eli5": "You have a side and its opposite angle (a and A), plus another angle (B). That's a textbook Law of Sines setup. Cross-multiply to isolate b: multiply 18 by sin(75°)/sin(40°). The most common mistake is flipping the fraction and getting a smaller number instead of a bigger one.",
      "hint": "You have a complete side-angle pair (a and A) — which law lets you use that directly?",
      "steps": [
        {
          "text": "Identify the known pair: side a = 18 m is opposite angle A = 40°. We want side b opposite angle B = 75°.",
          "latex": null
        },
        {
          "text": "Apply Law of Sines:",
          "latex": "\\frac{a}{\\sin A} = \\frac{b}{\\sin B}"
        },
        {
          "text": "Solve for b:",
          "latex": "b = 18 \\times \\frac{\\sin 75°}{\\sin 40°} = 18 \\times \\frac{0.9659}{0.6428} = 27.1\\,\\text{m}"
        }
      ],
      "handbookPage": "p. 23",
      "handbookFormula": "\\frac{a}{\\sin A} = \\frac{b}{\\sin B} = \\frac{c}{\\sin C}",
      "videoUrl": null,
      "traps": [
        "Flipping the sin ratio and getting a smaller answer",
        "Using cos instead of sin"
      ],
      "diagram": null
    },
    {
      "id": "math-lsc-q2",
      "statement": "A surveyor measures two sides of a triangular lot as $85\\,\\text{m}$ and $110\\,\\text{m}$ with an included angle of $62°$. What is the length of the third side?",
      "choices": [
        {
          "id": "c1",
          "text": "139.0 m"
        },
        {
          "id": "c2",
          "text": "88.3 m"
        },
        {
          "id": "c3",
          "text": "102.7 m"
        },
        {
          "id": "c4",
          "text": "195.0 m"
        }
      ],
      "correctAnswerId": "c3",
      "difficulty": "medium",
      "eli5": "When you see two sides and the angle between them, that is SAS — go straight to Law of Cosines. It is basically the Pythagorean theorem with a correction term ($-2ab\\cos C$) for non-right triangles. The trap is forgetting to subtract that term, or accidentally using sine instead of cosine.",
      "hint": "You know two sides and the included angle — which formula generalizes the Pythagorean theorem for non-right triangles?",
      "steps": [
        {
          "text": "Two sides and included angle (SAS) → Law of Cosines.",
          "latex": null
        },
        {
          "text": "Apply the formula:",
          "latex": "c^2 = 85^2 + 110^2 - 2(85)(110)\\cos 62°"
        },
        {
          "text": "Compute:",
          "latex": "c^2 = 7225 + 12100 - 18700 \\times 0.4695 = 19325 - 8780 = 10545"
        },
        {
          "text": "Take the square root:",
          "latex": "c = \\sqrt{10545} = 102.7\\,\\text{m}"
        }
      ],
      "handbookPage": "p. 23",
      "handbookFormula": "c^2 = a^2 + b^2 - 2ab\\cos C",
      "videoUrl": null,
      "traps": [
        "Adding the cosine term instead of subtracting",
        "Using sin instead of cos in the formula"
      ],
      "diagram": null
    },
    {
      "id": "math-lsc-q3",
      "statement": "A triangular truss has sides $a = 6.0\\,\\text{m}$, $b = 8.0\\,\\text{m}$, and $c = 11.0\\,\\text{m}$. What is the measure of angle $C$ (the angle opposite the longest side)?",
      "choices": [
        {
          "id": "c1",
          "text": "97.2°"
        },
        {
          "id": "c2",
          "text": "117.3°"
        },
        {
          "id": "c3",
          "text": "82.8°"
        },
        {
          "id": "c4",
          "text": "102.6°"
        }
      ],
      "correctAnswerId": "c4",
      "difficulty": "hard",
      "eli5": "When you have all three sides but no angles, rearrange the Law of Cosines to solve for cosine of the angle. The key insight: if the numerator comes out negative, the cosine is negative, which means the angle is obtuse (bigger than 90°). Don't panic when you see a negative — just hit inverse cosine on your calculator and it handles it. The trap is second-guessing the negative and subtracting from 180°.",
      "hint": "Rearrange the Law of Cosines to isolate $\\cos C$. What does a negative value of cosine tell you about the angle?",
      "steps": [
        {
          "text": "All three sides known (SSS) → rearrange Law of Cosines to solve for the angle.",
          "latex": null
        },
        {
          "text": "Isolate cos C:",
          "latex": "\\cos C = \\frac{a^2 + b^2 - c^2}{2ab}"
        },
        {
          "text": "Plug in:",
          "latex": "\\cos C = \\frac{36 + 64 - 121}{2(6)(8)} = \\frac{-21}{96} = -0.21875"
        },
        {
          "text": "Take inverse cosine:",
          "latex": "C = \\cos^{-1}(-0.21875) = 102.6°"
        }
      ],
      "handbookPage": "p. 23",
      "handbookFormula": "\\cos C = \\frac{a^2 + b^2 - c^2}{2ab}",
      "videoUrl": null,
      "traps": [
        "Sign error using +c² in the numerator",
        "Subtracting from 180° when cosine is negative"
      ],
      "diagram": null
    }
  ],
};
