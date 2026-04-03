export default {
  "id": "circles-conics",
  "name": "Circles & Conic Sections",
  "subtopicId": "analytic-geometry",
  "application": "Conic sections appear in civil engineering more than you'd expect — circular curves on highway alignments, parabolic profiles for vertical road curves, and elliptical arches in bridge design. On the FE exam, you need to recognize the standard equation of a circle, identify its center and radius, and know the basic forms of parabolas and ellipses. Most FE problems stick to circles, but an occasional parabola or ellipse shows up in the math section.",
  "content": [
    {
      "type": "heading",
      "body": "Circle"
    },
    {
      "type": "formula",
      "latex": "(x-h)^2 + (y-k)^2 = r^2",
      "label": "Center (h, k), radius r"
    },
    {
      "type": "text",
      "body": "If the equation is in general form $x^2 + y^2 + Dx + Ey + F = 0$, complete the square to convert to standard form."
    },
    {
      "type": "heading",
      "body": "Parabola"
    },
    {
      "type": "formula",
      "latex": "y = a(x-h)^2 + k",
      "label": "Vertical — sign of a sets direction"
    },
    {
      "type": "formula",
      "latex": "x = a(y-k)^2 + h",
      "label": "Horizontal"
    },
    {
      "type": "heading",
      "body": "Ellipse"
    },
    {
      "type": "formula",
      "latex": "\\frac{(x-h)^2}{a^2} + \\frac{(y-k)^2}{b^2} = 1",
      "label": "Larger denominator = major axis"
    },
    {
      "type": "callout",
      "variant": "tip",
      "body": "The key FE skill is converting from general form to standard form by completing the square — practice until it's automatic."
    }
  ],
  "illustration": null,
  "problems": [
    {
      "id": "math-cc-q1",
      "statement": "A circular retention pond is modeled by the equation $(x - 5)^2 + (y + 3)^2 = 64$. What are the center and radius of the pond?",
      "choices": [
        {
          "id": "c1",
          "text": "Center (5, 3), radius 32"
        },
        {
          "id": "c2",
          "text": "Center (5, -3), radius 8"
        },
        {
          "id": "c3",
          "text": "Center (-5, 3), radius 8"
        },
        {
          "id": "c4",
          "text": "Center (5, -3), radius 64"
        }
      ],
      "correctAnswerId": "c2",
      "difficulty": "easy",
      "eli5": "Read the center straight from the equation: $(x - 5)$ means $h = 5$, and $(y + 3)$ means $k = -3$ because $y + 3 = y - (-3)$. The number on the right is $r^2$, not $r$ — so take the square root. The two traps are getting the sign of $k$ wrong and forgetting to square-root the radius.",
      "hint": "The sign inside the parentheses is opposite to the coordinate — $(y + 3)$ means $k = -3$. And 64 is $r^2$, not $r$.",
      "steps": [
        {
          "text": "Match to standard form $(x-h)^2 + (y-k)^2 = r^2$:",
          "latex": null
        },
        {
          "text": "Read the center:",
          "latex": "h = 5,\\quad k = -3 \\quad\\text{(since } y+3 = y-(-3)\\text{)}"
        },
        {
          "text": "Find the radius:",
          "latex": "r^2 = 64 \\quad\\Rightarrow\\quad r = 8"
        }
      ],
      "handbookPage": "p. 24",
      "handbookFormula": "(x-h)^2 + (y-k)^2 = r^2",
      "videoUrl": null,
      "traps": [
        "Flipping the sign of $k$",
        "Giving $r^2$ instead of $r$"
      ],
      "diagram": null
    },
    {
      "id": "math-cc-q2",
      "statement": "A tunnel cross-section is described by $x^2 + y^2 - 10x + 6y + 18 = 0$. What is the radius of the circular cross-section?",
      "choices": [
        {
          "id": "c1",
          "text": "4"
        },
        {
          "id": "c2",
          "text": "16"
        },
        {
          "id": "c3",
          "text": "√18"
        },
        {
          "id": "c4",
          "text": "2"
        }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "Move the constant to the right side, then complete the square for both $x$ and $y$. For $x^2 - 10x$, half of 10 is 5, squared is 25 — add 25 to both sides. For $y^2 + 6y$, half of 6 is 3, squared is 9 — add 9 to both sides. Now you have standard form and can read off the radius. The trap is forgetting to add the completing-the-square values to both sides, or giving $r^2$ as the answer.",
      "hint": "Group the x and y terms, then complete the square for each — remember to add the same values to both sides.",
      "steps": [
        {
          "text": "Move the constant and group:",
          "latex": "(x^2 - 10x) + (y^2 + 6y) = -18"
        },
        {
          "text": "Complete the square for both variables:",
          "latex": "(x^2 - 10x + 25) + (y^2 + 6y + 9) = -18 + 25 + 9"
        },
        {
          "text": "Simplify to standard form:",
          "latex": "(x - 5)^2 + (y + 3)^2 = 16"
        },
        {
          "text": "Read the radius:",
          "latex": "r = \\sqrt{16} = 4"
        }
      ],
      "handbookPage": "p. 24",
      "handbookFormula": "(x-h)^2 + (y-k)^2 = r^2",
      "videoUrl": null,
      "traps": [
        "Forgetting to add completing-the-square values to both sides",
        "Giving $r^2$ instead of $r$"
      ],
      "diagram": null
    },
    {
      "id": "math-cc-q3",
      "statement": "A vertical highway curve is modeled by $y = -0.004x^2 + 2.4x - 200$. At what horizontal distance $x$ does the curve reach its maximum elevation, and what is that elevation?",
      "choices": [
        {
          "id": "c1",
          "text": "x = 300 m, y = 160 m"
        },
        {
          "id": "c2",
          "text": "x = 600 m, y = 160 m"
        },
        {
          "id": "c3",
          "text": "x = 300 m, y = -200 m"
        },
        {
          "id": "c4",
          "text": "x = 200 m, y = 140 m"
        }
      ],
      "correctAnswerId": "c1",
      "difficulty": "hard",
      "eli5": "For a parabola $y = ax^2 + bx + c$, the vertex is at $x = -b/(2a)$. Plug in $a = -0.004$ and $b = 2.4$ to get $x = 300$. Then substitute $x = 300$ back into the equation to get $y = 160$. The big trap is forgetting the 2 in the denominator and using $-b/a = 600$ instead. Always double-check by plugging the $x$ value back in.",
      "hint": "The vertex of $y = ax^2 + bx + c$ is at $x = -b/(2a)$ — do not forget the 2 in the denominator.",
      "steps": [
        {
          "text": "Since a = -0.004 < 0, the parabola opens downward — the vertex is the maximum.",
          "latex": null
        },
        {
          "text": "Find the vertex x-coordinate:",
          "latex": "x = -\\frac{b}{2a} = -\\frac{2.4}{2(-0.004)} = -\\frac{2.4}{-0.008} = 300"
        },
        {
          "text": "Plug x = 300 back in to find y:",
          "latex": "y = -0.004(300)^2 + 2.4(300) - 200 = -360 + 720 - 200 = 160"
        }
      ],
      "handbookPage": "p. 24",
      "handbookFormula": "x_{vertex} = -\\frac{b}{2a}",
      "videoUrl": null,
      "traps": [
        "Forgetting the 2 in the denominator and using -b/a",
        "Reading the constant term as the max y value"
      ],
      "diagram": null
    }
  ],
  examProblems: [
    {
      id: 'math-cc-ex1',
      type: 'computational',
      statement: 'A circular water tank has an equation $(x + 2)^2 + (y - 7)^2 = 36$. What is the diameter of the tank?',
      choices: [
        { id: 'c1', text: '6' },
        { id: 'c2', text: '12' },
        { id: 'c3', text: '36' },
        { id: 'c4', text: '18' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'easy',
      eli5: 'Read the standard form: the right side is $r^2$, so $r = \\sqrt{36} = 6$. The diameter is twice the radius, so 12. Choice A is the radius, not the diameter. Choice C is $r^2$. Always check whether the question asks for radius or diameter.',
      hint: 'The right side of the circle equation is $r^2$, not $r$. And diameter is twice the radius.',
      steps: [
        { text: 'Identify $r^2 = 36$ from the standard form:', latex: 'r = \\sqrt{36} = 6' },
        { text: 'Diameter is twice the radius:', latex: 'd = 2r = 2(6) = 12' },
      ],
      handbookPage: 'p. 24',
      handbookFormula: '(x-h)^2 + (y-k)^2 = r^2',
      videoUrl: null,
      traps: ['Giving the radius instead of the diameter', 'Giving $r^2$ as the answer'],
      diagram: null,
    },
    {
      id: 'math-cc-ex2',
      type: 'computational',
      statement: 'Convert the equation $x^2 + y^2 + 8x - 6y = 0$ to standard form and find the center of the circle.',
      choices: [
        { id: 'c1', text: 'Center $(-4, 3)$' },
        { id: 'c2', text: 'Center $(4, -3)$' },
        { id: 'c3', text: 'Center $(-8, 6)$' },
        { id: 'c4', text: 'Center $(8, -6)$' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'medium',
      eli5: 'Complete the square for both $x$ and $y$. For $x$: half of 8 is 4, squared is 16. For $y$: half of $-6$ is $-3$, squared is 9. Add both to each side. You get $(x+4)^2 + (y-3)^2 = 25$. The center is $(-4, 3)$ because $x + 4 = x - (-4)$. Choice B flips the signs — that is the most common error with completing the square.',
      hint: 'Complete the square for x and y separately. Remember the sign convention: $(x - h)$ means center coordinate $h$.',
      steps: [
        { text: 'Group and complete the square:', latex: '(x^2 + 8x + 16) + (y^2 - 6y + 9) = 0 + 16 + 9' },
        { text: 'Write in standard form:', latex: '(x + 4)^2 + (y - 3)^2 = 25' },
        { text: 'Read the center: $h = -4$, $k = 3$.', latex: null },
      ],
      handbookPage: 'p. 24',
      handbookFormula: '(x-h)^2 + (y-k)^2 = r^2',
      videoUrl: null,
      traps: ['Flipping the sign of h and k when reading from the standard form', 'Forgetting to add the completing-the-square constants to both sides'],
      diagram: null,
    },
    {
      id: 'math-cc-ex3',
      type: 'computational',
      statement: 'An elliptical culvert has the equation $\\frac{x^2}{16} + \\frac{y^2}{9} = 1$. What is the length of the major axis?',
      choices: [
        { id: 'c1', text: '4' },
        { id: 'c2', text: '8' },
        { id: 'c3', text: '3' },
        { id: 'c4', text: '6' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'medium',
      eli5: 'The larger denominator tells you which axis is major. Here $16 > 9$, so the major axis is along $x$. The semi-major axis is $a = \\sqrt{16} = 4$, but the FULL major axis is $2a = 8$. Choice A is the semi-major axis — the question asks for the full length. Choice D is the minor axis length ($2 \\times 3 = 6$).',
      hint: 'The semi-axis is the square root of the denominator. The full axis length is twice that.',
      steps: [
        { text: 'Identify the larger denominator: $a^2 = 16 > b^2 = 9$.', latex: null },
        { text: 'Find the semi-major axis:', latex: 'a = \\sqrt{16} = 4' },
        { text: 'Major axis length is $2a$:', latex: '2a = 2(4) = 8' },
      ],
      handbookPage: 'p. 24',
      handbookFormula: '\\frac{(x-h)^2}{a^2} + \\frac{(y-k)^2}{b^2} = 1',
      videoUrl: null,
      traps: ['Giving the semi-axis instead of the full axis length', 'Confusing major and minor axes'],
      diagram: null,
    },
    {
      id: 'math-cc-ex4',
      type: 'conceptual',
      statement: 'A conic section has the general equation $Ax^2 + Bxy + Cy^2 + Dx + Ey + F = 0$. If $A = C$ and $B = 0$, what type of conic is it?',
      choices: [
        { id: 'c1', text: 'Parabola' },
        { id: 'c2', text: 'Ellipse' },
        { id: 'c3', text: 'Circle' },
        { id: 'c4', text: 'Hyperbola' },
      ],
      correctAnswerId: 'c3',
      difficulty: 'hard',
      eli5: 'When $A = C$ and $B = 0$, the $x^2$ and $y^2$ terms have the same coefficient and there is no $xy$ term. That is the definition of a circle — both axes are scaled the same, so the curve has equal "width" in every direction. An ellipse would have $A \\neq C$. A parabola has only one squared term (either $A$ or $C$ is zero). A hyperbola has opposite signs for $A$ and $C$.',
      hint: 'Think about what makes a circle different from an ellipse — it is the relationship between the coefficients of $x^2$ and $y^2$.',
      steps: [
        { text: 'When $A = C$ and $B = 0$, the equation becomes $A(x^2 + y^2) + Dx + Ey + F = 0$.', latex: null },
        { text: 'Dividing through by $A$ gives $x^2 + y^2 + \\ldots = 0$, which is a circle.', latex: null },
        { text: 'Equal coefficients on $x^2$ and $y^2$ with no $xy$ term defines a circle.', latex: null },
      ],
      handbookPage: 'p. 24',
      handbookFormula: '(x-h)^2 + (y-k)^2 = r^2',
      videoUrl: null,
      traps: ['Confusing circle (A = C) with ellipse (A ≠ C)', 'Forgetting that B must be zero for the standard circle form'],
      diagram: null,
    },
  ],
};
