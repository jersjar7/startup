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
          "text": "102.6°"
        },
        {
          "id": "c3",
          "text": "82.8°"
        },
        {
          "id": "c4",
          "text": "117.3°"
        }
      ],
      "correctAnswerId": "c2",
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
  "examProblems": [
    {
      "id": "math-lsc-ex1",
      "type": "computational",
      "statement": "In triangle $PQR$, angle $P = 50°$, angle $Q = 65°$, and side $p = 24\\,\\text{m}$ (opposite angle $P$). What is the length of side $q$ (opposite angle $Q$)?",
      "choices": [
        { "id": "c1", "text": "$28.4\\,\\text{m}$" },
        { "id": "c2", "text": "$20.3\\,\\text{m}$" },
        { "id": "c3", "text": "$31.7\\,\\text{m}$" },
        { "id": "c4", "text": "$22.1\\,\\text{m}$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "easy",
      "eli5": "You have a complete side-angle pair ($p$ and $P$) plus another angle ($Q$), so Law of Sines is your move. Set up the proportion and cross-multiply to solve for $q$. The bigger angle ($65°$ vs $50°$) should give a bigger side, so $q > 24$ is a quick sanity check. If your answer came out smaller, you probably flipped the fraction.",
      "hint": "You have a side-angle pair — which law works directly with that setup?",
      "steps": [
        { "text": "Set up Law of Sines:", "latex": "\\frac{p}{\\sin P} = \\frac{q}{\\sin Q}" },
        { "text": "Solve for $q$:", "latex": "q = 24 \\times \\frac{\\sin 65°}{\\sin 50°} = 24 \\times \\frac{0.9063}{0.7660}" },
        { "text": "Compute:", "latex": "q = 24 \\times 1.1832 = 28.4\\,\\text{m}" }
      ],
      "handbookPage": "p. 38",
      "handbookFormula": "\\frac{a}{\\sin A} = \\frac{b}{\\sin B} = \\frac{c}{\\sin C}",
      "videoUrl": null,
      "traps": [
        "Flipping the sine ratio and dividing instead of multiplying",
        "Using cosine instead of sine in the Law of Sines"
      ],
      "diagram": null
    },
    {
      "id": "math-lsc-ex2",
      "type": "computational",
      "statement": "Two sides of a triangular parcel measure $a = 120\\,\\text{m}$ and $b = 95\\,\\text{m}$, with an included angle $C = 48°$. What is the length of the third side $c$?",
      "choices": [
        { "id": "c1", "text": "$78.4\\,\\text{m}$" },
        { "id": "c2", "text": "$91.8\\,\\text{m}$" },
        { "id": "c3", "text": "$105.3\\,\\text{m}$" },
        { "id": "c4", "text": "$152.6\\,\\text{m}$" }
      ],
      "correctAnswerId": "c2",
      "difficulty": "medium",
      "eli5": "Two sides and the angle between them (SAS) means Law of Cosines. Plug in, compute each piece, then take the square root. The included angle is less than $90°$, so $\\cos 48°$ is positive and the correction term subtracts from $a^2 + b^2$. If the angle were obtuse, $\\cos C$ would be negative and you would actually add — that is a subtlety to watch for.",
      "hint": "Two sides with their included angle — which formula generalizes the Pythagorean theorem?",
      "steps": [
        { "text": "Apply Law of Cosines:", "latex": "c^2 = a^2 + b^2 - 2ab\\cos C" },
        { "text": "Substitute:", "latex": "c^2 = 120^2 + 95^2 - 2(120)(95)\\cos 48°" },
        { "text": "Compute:", "latex": "c^2 = 14400 + 9025 - 22800 \\times 0.6691 = 23425 - 15256 = 8169" },
        { "text": "Take the square root:", "latex": "c = \\sqrt{8169} = 91.8\\,\\text{m}" }
      ],
      "handbookPage": "p. 38",
      "handbookFormula": "c^2 = a^2 + b^2 - 2ab\\cos C",
      "videoUrl": null,
      "traps": [
        "Adding the cosine correction instead of subtracting it",
        "Forgetting to take the square root at the end"
      ],
      "diagram": null
    },
    {
      "id": "math-lsc-ex3",
      "type": "computational",
      "statement": "A triangular truss has sides $a = 7.5\\,\\text{m}$, $b = 9.0\\,\\text{m}$, and $c = 5.0\\,\\text{m}$. What is angle $A$ (opposite side $a$)?",
      "choices": [
        { "id": "c1", "text": "$42.3°$" },
        { "id": "c2", "text": "$56.3°$" },
        { "id": "c3", "text": "$81.4°$" },
        { "id": "c4", "text": "$67.8°$" }
      ],
      "correctAnswerId": "c2",
      "difficulty": "medium",
      "eli5": "All three sides, no angles — SSS situation. Rearrange the Law of Cosines to isolate $\\cos A$. Plug in the sides, do the arithmetic, and take inverse cosine. The numerator here comes out positive, so the angle is acute (less than $90°$). If it had come out negative, the angle would be obtuse. Always let the sign of the cosine tell you the story.",
      "hint": "Rearrange the Law of Cosines to solve for the angle: $\\cos A = \\frac{b^2 + c^2 - a^2}{2bc}$.",
      "steps": [
        { "text": "Rearrange for $\\cos A$:", "latex": "\\cos A = \\frac{b^2 + c^2 - a^2}{2bc}" },
        { "text": "Substitute:", "latex": "\\cos A = \\frac{81 + 25 - 56.25}{2(9)(5)} = \\frac{49.75}{90} = 0.5528" },
        { "text": "Take inverse cosine:", "latex": "A = \\cos^{-1}(0.5528) = 56.3°" }
      ],
      "handbookPage": "p. 38",
      "handbookFormula": "\\cos A = \\frac{b^2 + c^2 - a^2}{2bc}",
      "videoUrl": null,
      "traps": [
        "Mixing up which side to subtract in the numerator — always subtract the side opposite the angle you want",
        "Squaring side lengths incorrectly (7.5² = 56.25, not 52.5)"
      ],
      "diagram": null
    },
    {
      "id": "math-lsc-ex4",
      "type": "conceptual",
      "statement": "A surveyor knows two angles and the side between them (ASA). Which is the most efficient approach to solve the triangle?",
      "choices": [
        { "id": "c1", "text": "Apply the Law of Cosines directly" },
        { "id": "c2", "text": "Find the third angle, then use the Law of Sines" },
        { "id": "c3", "text": "Use the Pythagorean theorem" },
        { "id": "c4", "text": "Convert to an SAS case and apply the Law of Cosines" }
      ],
      "correctAnswerId": "c2",
      "difficulty": "hard",
      "eli5": "With ASA you know two angles — and since the angles in a triangle sum to 180°, the third angle is free. Now you have a complete side-angle pair, which is exactly what the Law of Sines needs. The Law of Cosines requires SAS or SSS, and the Pythagorean theorem only works for right triangles. The decision tree is simple: if you can form a side-angle pair, use Sines; if you have SAS or SSS, use Cosines.",
      "hint": "The three angles of a triangle sum to 180°. Once you know all three angles, which law uses a side-angle pair?",
      "steps": [
        { "text": "Two known angles means you can find the third: $C = 180° - A - B$.", "latex": null },
        { "text": "Now you have a complete side-angle pair (the given side and its opposite angle).", "latex": null },
        { "text": "Apply the Law of Sines to find the remaining sides.", "latex": "\\frac{a}{\\sin A} = \\frac{b}{\\sin B} = \\frac{c}{\\sin C}" }
      ],
      "handbookPage": "p. 38",
      "handbookFormula": "\\frac{a}{\\sin A} = \\frac{b}{\\sin B} = \\frac{c}{\\sin C}",
      "videoUrl": null,
      "traps": [
        "Trying to use the Law of Cosines without having two sides",
        "Forgetting to compute the third angle first"
      ],
      "diagram": null
    }
  ]
};
