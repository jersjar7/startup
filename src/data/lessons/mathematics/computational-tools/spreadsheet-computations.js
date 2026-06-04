export default {
  "id": "spreadsheet-computations",
  "name": "Spreadsheet Computations",
  "subtopicId": "computational-tools",
  "application": "Civil engineers live in spreadsheets — earthwork volume tables, quantity takeoffs, load combinations, rebar schedules, and cost estimates are all built from cell formulas. The FE tests whether you can read a formula, apply the correct order of operations, and predict what happens to relative vs. absolute references when a formula is copied. These are quick points if you know the rules cold.",
  "content": [
    {
      "type": "text",
      "body": "A spreadsheet stores values in cells named by column-letter and row-number (A1, B2, C3). A cell that begins with an equals sign holds a formula: the cell displays the computed result, not the text. For example, if A1 = 2 and A2 = 3, then a cell containing =A1+A2 displays 5."
    },
    {
      "type": "heading",
      "body": "Order of Operations"
    },
    {
      "type": "text",
      "body": "Spreadsheets follow standard algebraic precedence (PEMDAS): parentheses first, then exponentiation (^), then multiplication and division (left to right), then addition and subtraction (left to right). So =2+3*4 is 14, not 20 — the multiplication happens before the addition. Use parentheses to force a different order: =(2+3)*4 is 20."
    },
    {
      "type": "heading",
      "body": "Relative vs. Absolute References"
    },
    {
      "type": "text",
      "body": "A plain reference like A1 is RELATIVE: when you copy the formula to another cell, the reference shifts by the same offset. Copy =A1*2 from C1 down to C2 and it becomes =A2*2. Putting a dollar sign in front of a coordinate LOCKS it (absolute): $A$1 never changes when copied, A$1 locks only the row, and $A1 locks only the column."
    },
    {
      "type": "text",
      "body": "This is the single most-tested spreadsheet idea on the FE: a unit price in one fixed cell ($D$1) multiplied down a column of quantities. The quantity reference shifts row by row while the unit-price reference stays locked."
    },
    {
      "type": "heading",
      "body": "Common Functions"
    },
    {
      "type": "text",
      "body": "SUM(range) adds a range, AVERAGE(range) means the arithmetic mean, MAX/MIN return the largest/smallest, COUNT counts numeric cells, and ROUND(value, digits) rounds. The logical function IF(test, value_if_true, value_if_false) returns one of two results based on a comparison — e.g., =IF(A1>=3000, \"PASS\", \"FAIL\")."
    },
    {
      "type": "callout",
      "variant": "tip",
      "body": "Before copying a formula, ask which references must stay fixed (constants like a unit price, an interest rate, a γ value) and put $ on those. Everything that should move with the row/column stays relative."
    },
    {
      "type": "callout",
      "variant": "warning",
      "body": "The #1 spreadsheet error is forgetting the $ — the constant reference drifts when copied and every row below the first is wrong. The #2 error is order of operations: =A1+A2/A3 divides A2 by A3 first, it does NOT add A1+A2 before dividing."
    }
  ],
  "illustration": null,
  "problems": [
    {
      "id": "math-spr-q1",
      "statement": "A spreadsheet cell contains the formula =A1+A2*A3. The cells hold A1 = 2, A2 = 3, and A3 = 4. What value does the cell display?",
      "choices": [
        { "id": "c1", "text": "14" },
        { "id": "c2", "text": "20" },
        { "id": "c3", "text": "9" },
        { "id": "c4", "text": "24" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "easy",
      "eli5": "Spreadsheets follow PEMDAS, so multiplication happens before addition. Compute A2*A3 = 3*4 = 12 first, then add A1: 2 + 12 = 14. The 20 option is the classic mistake of working strictly left to right as (2+3)*4. The 9 option just adds all three. The 24 option multiplies all three.",
      "hint": "Spreadsheets obey order of operations — do the multiplication before the addition.",
      "steps": [
        { "text": "Apply precedence: multiplication before addition. Evaluate A2*A3 first.", "latex": null },
        { "text": "A2*A3 = 3 × 4 = 12.", "latex": null },
        { "text": "Add A1: 2 + 12 = 14.", "latex": null }
      ],
      "handbookPage": null,
      "handbookFormula": null,
      "videoUrl": null,
      "traps": [
        "Evaluating left-to-right as (2+3)*4 = 20 instead of obeying precedence",
        "Adding all three values (9) and ignoring the operators"
      ],
      "diagram": null
    },
    {
      "id": "math-spr-q2",
      "statement": "Cell C1 contains the formula =A1*$B$1, where A1 = 5 and B1 = 10, so C1 displays 50. The formula in C1 is copied down into C2, and cell A2 = 8. What value does C2 display?",
      "choices": [
        { "id": "c1", "text": "80" },
        { "id": "c2", "text": "50" },
        { "id": "c3", "text": "18" },
        { "id": "c4", "text": "800" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "When you copy down one row, the RELATIVE reference A1 shifts to A2, but the ABSOLUTE reference $B$1 stays locked. So C2 becomes =A2*$B$1 = 8 × 10 = 80. The 50 option assumes the A reference didn't move (it isn't locked, so it does). The 18 option adds instead of multiplies. The 800 option shifts or multiplies the locked reference by mistake.",
      "hint": "A1 is relative (it shifts when copied); $B$1 is absolute (it stays put).",
      "steps": [
        { "text": "Copying down one row shifts relative references down one row: A1 → A2.", "latex": null },
        { "text": "The absolute reference $B$1 does not change.", "latex": null },
        { "text": "C2 = A2 × $B$1 = 8 × 10 = 80.", "latex": null }
      ],
      "handbookPage": null,
      "handbookFormula": null,
      "videoUrl": null,
      "traps": [
        "Thinking A1 stays fixed — it is relative and shifts to A2",
        "Accidentally shifting the locked $B$1 reference"
      ],
      "diagram": null
    },
    {
      "id": "math-spr-q3",
      "statement": "A cell contains =IF(A1>=10, A1*2, A1+5). Cell A1 holds the value 12. What does the cell display?",
      "choices": [
        { "id": "c1", "text": "24" },
        { "id": "c2", "text": "17" },
        { "id": "c3", "text": "10" },
        { "id": "c4", "text": "1" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "easy",
      "eli5": "IF(test, value_if_true, value_if_false) checks the test first. Here A1>=10 asks 'is 12 at least 10?' — yes, so the function returns the TRUE result, A1*2 = 12 × 2 = 24. The choice 17 is the FALSE branch A1+5, which only applies if the test fails. The choice 1 is the mistake of treating TRUE as the literal number 1.",
      "hint": "Evaluate the test (is A1 ≥ 10?) and return the matching branch.",
      "steps": [
        { "text": "Test: A1 >= 10 → 12 >= 10 → TRUE.", "latex": null },
        { "text": "Because the test is TRUE, return the second argument: A1*2.", "latex": null },
        { "text": "A1*2 = 12 × 2 = 24.", "latex": null }
      ],
      "handbookPage": null,
      "handbookFormula": null,
      "videoUrl": null,
      "traps": [
        "Returning the FALSE branch (A1+5 = 17) even though the test passes",
        "Treating the logical result TRUE as the number 1"
      ],
      "diagram": null
    }
  ]
};
