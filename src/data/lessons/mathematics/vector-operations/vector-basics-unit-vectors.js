export default {
  "id": "vector-basics-unit-vectors",
  "name": "Vector Basics & Unit Vectors",
  "subtopicId": "vector-operations",
  "application": "Vectors are the language of forces in civil engineering. Every time you draw a free body diagram — resolving a cable tension into horizontal and vertical components, adding wind loads on a structure, or combining soil pressure resultants — you're doing vector math. Unit vectors let you express direction independently of magnitude, which is essential for writing force equilibrium equations in 2D and 3D. On the FE, vector basics show up directly in statics and dynamics problems. If you can add, subtract, and normalize vectors quickly, you'll save time on at least 5-10 questions.",
  "content": [
    { "type": "text", "body": "A vector has both magnitude and direction. On the FE, vectors are usually written in component form using unit vectors $\\hat{i}$, $\\hat{j}$, $\\hat{k}$ along the $x$, $y$, $z$ axes." },
    { "type": "heading", "body": "Vector in Component Form" },
    { "type": "formula", "latex": "\\vec{A} = A_x\\hat{i} + A_y\\hat{j} + A_z\\hat{k}" },
    { "type": "heading", "body": "Magnitude of a Vector" },
    { "type": "formula", "latex": "|\\vec{A}| = \\sqrt{A_x^2 + A_y^2 + A_z^2}" },
    { "type": "heading", "body": "Unit Vector" },
    { "type": "formula", "latex": "\\hat{u}_A = \\frac{\\vec{A}}{|\\vec{A}|}" },
    { "type": "text", "body": "A unit vector points in the same direction as $\\vec{A}$ but has magnitude 1. Multiply it by any scalar to get a vector of that length in that direction." },
    { "type": "heading", "body": "Vector Addition" },
    { "type": "formula", "latex": "\\vec{A} + \\vec{B} = (A_x + B_x)\\hat{i} + (A_y + B_y)\\hat{j} + (A_z + B_z)\\hat{k}" },
    { "type": "text", "body": "Add component by component. Subtraction works the same way — subtract each component." },
    { "type": "heading", "body": "Scalar Multiplication" },
    { "type": "text", "body": "Multiplying a vector by a scalar $c$ scales every component: $c\\vec{A} = cA_x\\hat{i} + cA_y\\hat{j} + cA_z\\hat{k}$. If $c$ is negative, the vector reverses direction." },
    { "type": "callout", "variant": "tip", "body": "To express a force along a known direction: find the unit vector in that direction, then multiply by the force magnitude. This is how you resolve 3D forces into components: $\\vec{F} = F\\,\\hat{u}$." },
    { "type": "callout", "variant": "warning", "body": "Don't confuse magnitude with a component. $|\\vec{A}|$ uses the square root of the sum of squares. $A_x$ alone is just the projection onto the $x$-axis — it can be negative." }
  ],
  "illustration": null,
  "problems": [
    {
      "id": "math-vbu-q1",
      "statement": "A surveyor measures a displacement of $\\vec{d} = 30\\hat{i} + 40\\hat{j}$ meters from a benchmark. What is the total distance from the benchmark?",
      "choices": [
        { "id": "c1", "text": "$70$ m" },
        { "id": "c2", "text": "$50$ m" },
        { "id": "c3", "text": "$35$ m" },
        { "id": "c4", "text": "$25$ m" }
      ],
      "correctAnswerId": "c2",
      "difficulty": "easy",
      "eli5": "Distance is the magnitude of the displacement vector. Square each component, add them, take the square root. This is a 3-4-5 right triangle scaled by 10 — if you recognize the Pythagorean triple you can skip the calculator entirely.",
      "hint": "The total distance is the magnitude of the vector, not the sum of components.",
      "steps": [
        { "text": "Apply the magnitude formula:", "latex": "|\\vec{d}| = \\sqrt{30^2 + 40^2}" },
        { "text": "Compute:", "latex": "|\\vec{d}| = \\sqrt{900 + 1600} = \\sqrt{2500} = 50 \\text{ m}" }
      ],
      "handbookPage": "p. 94",
      "handbookFormula": "|\\vec{A}| = \\sqrt{A_x^2 + A_y^2 + A_z^2}",
      "videoUrl": null,
      "traps": [
        "Adding components directly (30 + 40 = 70) instead of using the magnitude formula",
        "Forgetting to square root — 900 + 1600 = 2500 is not the answer, √2500 = 50 is"
      ],
      "diagram": null
    },
    {
      "id": "math-vbu-q2",
      "statement": "A force acts along the direction from point $A(1, 2, 2)$ to point $B(4, 6, 2)$. What is the unit vector from $A$ to $B$?",
      "choices": [
        { "id": "c1", "text": "$0.6\\hat{i} + 0.8\\hat{j} + 0\\hat{k}$" },
        { "id": "c2", "text": "$3\\hat{i} + 4\\hat{j} + 0\\hat{k}$" },
        { "id": "c3", "text": "$0.5\\hat{i} + 0.5\\hat{j} + 0\\hat{k}$" },
        { "id": "c4", "text": "$0.75\\hat{i} + 1.0\\hat{j} + 0\\hat{k}$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "Two steps: first get the direction vector by subtracting coordinates (B − A), then divide every component by the magnitude. Choice B is the direction vector before normalizing — that's the most common mistake. Always check that your unit vector's magnitude equals 1: √(0.6² + 0.8²) = √(0.36 + 0.64) = 1. ✓",
      "hint": "Subtract A from B to get the direction vector, then divide by its magnitude.",
      "steps": [
        { "text": "Find the direction vector:", "latex": "\\vec{AB} = (4-1)\\hat{i} + (6-2)\\hat{j} + (2-2)\\hat{k} = 3\\hat{i} + 4\\hat{j} + 0\\hat{k}" },
        { "text": "Find its magnitude:", "latex": "|\\vec{AB}| = \\sqrt{3^2 + 4^2 + 0^2} = \\sqrt{25} = 5" },
        { "text": "Divide by magnitude:", "latex": "\\hat{u} = \\frac{3}{5}\\hat{i} + \\frac{4}{5}\\hat{j} + 0\\hat{k} = 0.6\\hat{i} + 0.8\\hat{j}" }
      ],
      "handbookPage": "p. 94",
      "handbookFormula": "\\hat{u}_A = \\frac{\\vec{A}}{|\\vec{A}|}",
      "videoUrl": null,
      "traps": [
        "Forgetting to divide by the magnitude — choice B is the raw direction vector, not the unit vector",
        "Subtracting in the wrong order (A − B instead of B − A) — this reverses the direction"
      ],
      "diagram": null
    },
    {
      "id": "math-vbu-q3",
      "statement": "Three forces act on a gusset plate: $\\vec{F}_1 = 500\\hat{i} + 0\\hat{j}$ N, $\\vec{F}_2 = -200\\hat{i} + 300\\hat{j}$ N, and $\\vec{F}_3 = 0\\hat{i} - 400\\hat{j}$ N. What is the magnitude of the resultant force?",
      "choices": [
        { "id": "c1", "text": "$500$ N" },
        { "id": "c2", "text": "$200$ N" },
        { "id": "c3", "text": "$316$ N" },
        { "id": "c4", "text": "$412$ N" }
      ],
      "correctAnswerId": "c3",
      "difficulty": "hard",
      "eli5": "Vector addition is component-by-component — add all the x's together, add all the y's together. Then the resultant magnitude is √(Rx² + Ry²). The trap is adding magnitudes directly (500 + 500 + 400 = 1400) — that only works if all forces point the same direction, which they never do in real problems. Here √100000 = 100√10 ≈ 316 N.",
      "hint": "Add the x-components and y-components separately, then find the magnitude of the resultant vector.",
      "steps": [
        { "text": "Add $x$-components:", "latex": "R_x = 500 + (-200) + 0 = 300 \\text{ N}" },
        { "text": "Add $y$-components:", "latex": "R_y = 0 + 300 + (-400) = -100 \\text{ N}" },
        { "text": "Resultant magnitude:", "latex": "|\\vec{R}| = \\sqrt{300^2 + (-100)^2} = \\sqrt{90000 + 10000} = \\sqrt{100000} \\approx 316 \\text{ N}" }
      ],
      "handbookPage": "p. 94",
      "handbookFormula": "|\\vec{A}| = \\sqrt{A_x^2 + A_y^2}",
      "videoUrl": null,
      "traps": [
        "Adding magnitudes directly instead of adding components — forces in opposite directions partially cancel",
        "Forgetting the negative signs on components — F₂ₓ = -200 and F₃ᵧ = -400 are critical"
      ],
      "diagram": null
    }
  ],
  "examProblems": [
    {
      "id": "math-vbu-ex1",
      "type": "computational",
      "statement": "A cable exerts a force along the direction $\\vec{d} = 6\\hat{i} + 2\\hat{j} - 3\\hat{k}$ meters. What is the magnitude of this direction vector?",
      "choices": [
        { "id": "c1", "text": "$5$" },
        { "id": "c2", "text": "$7$" },
        { "id": "c3", "text": "$11$" },
        { "id": "c4", "text": "$\\sqrt{41} \\approx 6.4$" }
      ],
      "correctAnswerId": "c2",
      "difficulty": "easy",
      "eli5": "Square each component, add them up, take the square root: $\\sqrt{36 + 4 + 9} = \\sqrt{49} = 7$. Don't forget to include the negative component — squaring it makes it positive anyway ($(-3)^2 = 9$). The trap is adding the raw components ($6 + 2 - 3 = 5$) instead of using the magnitude formula.",
      "hint": "The magnitude formula uses the square root of the sum of squares — not just the sum of components.",
      "steps": [
        { "text": "Apply the magnitude formula:", "latex": "|\\vec{d}| = \\sqrt{6^2 + 2^2 + (-3)^2}" },
        { "text": "Compute:", "latex": "= \\sqrt{36 + 4 + 9} = \\sqrt{49} = 7" }
      ],
      "handbookPage": "p. 55",
      "handbookFormula": "|\\vec{A}| = \\sqrt{A_x^2 + A_y^2 + A_z^2}",
      "videoUrl": null,
      "traps": [
        "Adding components directly (6 + 2 - 3 = 5) instead of using sum of squares",
        "Forgetting to square the negative component"
      ],
      "diagram": null
    },
    {
      "id": "math-vbu-ex2",
      "type": "computational",
      "statement": "Find the unit vector in the direction of $\\vec{v} = 2\\hat{i} - 6\\hat{j} + 3\\hat{k}$.",
      "choices": [
        { "id": "c1", "text": "$\\frac{2}{7}\\hat{i} - \\frac{6}{7}\\hat{j} + \\frac{3}{7}\\hat{k}$" },
        { "id": "c2", "text": "$2\\hat{i} - 6\\hat{j} + 3\\hat{k}$" },
        { "id": "c3", "text": "$\\frac{2}{11}\\hat{i} - \\frac{6}{11}\\hat{j} + \\frac{3}{11}\\hat{k}$" },
        { "id": "c4", "text": "$\\frac{1}{3}\\hat{i} - 1\\hat{j} + \\frac{1}{2}\\hat{k}$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "First find the magnitude: $\\sqrt{4 + 36 + 9} = \\sqrt{49} = 7$. Then divide each component by 7. Choice B is the original vector — that's what you get if you skip the normalization. Choice C divides by the sum of components (11) instead of the magnitude (7). Always verify: the unit vector's magnitude should equal 1.",
      "hint": "Compute the magnitude first, then divide every component by it.",
      "steps": [
        { "text": "Magnitude:", "latex": "|\\vec{v}| = \\sqrt{4 + 36 + 9} = \\sqrt{49} = 7" },
        { "text": "Unit vector:", "latex": "\\hat{u} = \\frac{\\vec{v}}{|\\vec{v}|} = \\frac{2}{7}\\hat{i} - \\frac{6}{7}\\hat{j} + \\frac{3}{7}\\hat{k}" }
      ],
      "handbookPage": "p. 55",
      "handbookFormula": "\\hat{u}_A = \\frac{\\vec{A}}{|\\vec{A}|}",
      "videoUrl": null,
      "traps": [
        "Dividing by the sum of absolute values of components instead of the magnitude",
        "Forgetting to normalize — reporting the raw vector as the unit vector"
      ],
      "diagram": null
    },
    {
      "id": "math-vbu-ex3",
      "type": "computational",
      "statement": "A 350 N force acts along the direction from point $A(1, -1, 2)$ to point $B(3, 3, -1)$. Express the force as a vector $\\vec{F}$.",
      "choices": [
        { "id": "c1", "text": "$\\frac{2}{\\sqrt{29}}\\hat{i} + \\frac{4}{\\sqrt{29}}\\hat{j} - \\frac{3}{\\sqrt{29}}\\hat{k}$ N" },
        { "id": "c2", "text": "$700\\hat{i} + 1400\\hat{j} - 1050\\hat{k}$ N" },
        { "id": "c3", "text": "$\\frac{350}{3}(2\\hat{i} + 4\\hat{j} - 3\\hat{k})$ N" },
        { "id": "c4", "text": "$\\frac{700}{\\sqrt{29}}\\hat{i} + \\frac{1400}{\\sqrt{29}}\\hat{j} - \\frac{1050}{\\sqrt{29}}\\hat{k}$ N" }
      ],
      "correctAnswerId": "c4",
      "difficulty": "medium",
      "eli5": "Three steps: (1) direction vector $B - A = (2, 4, -3)$, (2) magnitude $= \\sqrt{4 + 16 + 9} = \\sqrt{29}$, (3) unit vector times 350. Each component of the unit vector gets multiplied by 350. Choice A is just the unit vector without the 350 multiplier. Choice B multiplied 350 by the direction vector without normalizing first.",
      "hint": "Find the unit vector from A to B, then multiply by the force magnitude.",
      "steps": [
        { "text": "Direction vector:", "latex": "\\vec{AB} = (3-1)\\hat{i} + (3-(-1))\\hat{j} + (-1-2)\\hat{k} = 2\\hat{i} + 4\\hat{j} - 3\\hat{k}" },
        { "text": "Magnitude:", "latex": "|\\vec{AB}| = \\sqrt{4 + 16 + 9} = \\sqrt{29}" },
        { "text": "Unit vector:", "latex": "\\hat{u} = \\frac{1}{\\sqrt{29}}(2\\hat{i} + 4\\hat{j} - 3\\hat{k})" },
        { "text": "Force vector:", "latex": "\\vec{F} = 350\\hat{u} = \\frac{700}{\\sqrt{29}}\\hat{i} + \\frac{1400}{\\sqrt{29}}\\hat{j} - \\frac{1050}{\\sqrt{29}}\\hat{k}" }
      ],
      "handbookPage": "p. 55",
      "handbookFormula": "\\vec{F} = F\\,\\hat{u}",
      "videoUrl": null,
      "traps": [
        "Multiplying the force magnitude by the raw direction vector instead of the unit vector",
        "Subtracting A from B in the wrong order"
      ],
      "diagram": null
    },
    {
      "id": "math-vbu-ex4",
      "type": "conceptual",
      "statement": "A vector $\\vec{A}$ has components $A_x = -5$ and $A_y = 0$. Which statement is true?",
      "choices": [
        { "id": "c1", "text": "The vector has magnitude $-5$" },
        { "id": "c2", "text": "The vector is a zero vector" },
        { "id": "c3", "text": "The vector points in the negative $x$-direction with magnitude 5" },
        { "id": "c4", "text": "The vector points in the positive $x$-direction with magnitude 5" }
      ],
      "correctAnswerId": "c3",
      "difficulty": "hard",
      "eli5": "Magnitude is always positive: $|\\vec{A}| = \\sqrt{(-5)^2 + 0^2} = 5$, not $-5$. The negative sign on the component tells you direction, not magnitude. Choice A is the most common mistake — magnitudes can never be negative. Choice D gets the magnitude right but the direction wrong. A negative $x$-component means the vector points in the negative $x$-direction. Separating magnitude from direction is fundamental to vector analysis.",
      "hint": "Magnitude is always non-negative — the sign of a component indicates direction, not size.",
      "steps": [
        { "text": "Magnitude:", "latex": "|\\vec{A}| = \\sqrt{(-5)^2 + 0^2} = \\sqrt{25} = 5" },
        { "text": "Since $A_x < 0$ and $A_y = 0$, the vector points along the negative $x$-axis.", "latex": null },
        { "text": "Magnitude is 5 (positive), direction is $-\\hat{i}$.", "latex": null }
      ],
      "handbookPage": "p. 55",
      "handbookFormula": "|\\vec{A}| = \\sqrt{A_x^2 + A_y^2}",
      "videoUrl": null,
      "traps": [
        "Reporting a negative magnitude — magnitudes are always non-negative",
        "Confusing the sign of a component with the sign of the magnitude"
      ],
      "diagram": null
    }
  ]
};
