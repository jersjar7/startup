export default {
  "id": "structured-programming",
  "name": "Structured Programming",
  "subtopicId": "computational-tools",
  "application": "Whether you script earthwork calcs, automate a hydraulic spreadsheet with a macro, or just read someone else's analysis routine, you need to trace structured logic. The FE keeps it conceptual: given a short block of pseudocode with an if-then-else or a loop, predict the output or count the iterations. No language syntax to memorize — just sequence, selection, and iteration.",
  "content": [
    {
      "type": "text",
      "body": "Structured programming builds every routine from three constructs: SEQUENCE (run statements in order), SELECTION (choose a path with IF-THEN-ELSE), and ITERATION (repeat with a loop). On the FE you trace these by hand, tracking each variable's value as the code runs."
    },
    {
      "type": "heading",
      "body": "Selection: IF-THEN-ELSE"
    },
    {
      "type": "text",
      "body": "A condition evaluates to TRUE or FALSE and decides which branch runs. Conditions chain with ELSE IF, and they are checked top to bottom — the FIRST true condition wins and the rest are skipped. Example: IF x > 10 THEN y = 1; ELSE IF x > 5 THEN y = 2; ELSE y = 3. With x = 7, the first test fails, the second (7 > 5) is true, so y = 2 and the final ELSE never runs."
    },
    {
      "type": "heading",
      "body": "Iteration: Loops"
    },
    {
      "type": "text",
      "body": "A counted FOR loop like FOR i = 1 TO 4 runs its body once for each value 1, 2, 3, 4 — that is 4 times (the endpoints are inclusive). A WHILE loop runs as long as its condition stays true and re-checks the condition before each pass; it stops the moment the condition is false."
    },
    {
      "type": "heading",
      "body": "Tracing a Loop"
    },
    {
      "type": "text",
      "body": "To trace, write the variables in a column and update them pass by pass. Example — total = 0; FOR i = 1 TO 4: total = total + i. After the passes total = 0+1+2+3+4 = 10. Accumulator problems (running sum or product) are the most common FE pseudocode question."
    },
    {
      "type": "callout",
      "variant": "tip",
      "body": "For a WHILE loop, the safest approach is a small trace table: list the variable, check the condition, update, repeat. Stop the instant the condition is false and read off the final value."
    },
    {
      "type": "callout",
      "variant": "warning",
      "body": "Off-by-one errors are the trap. FOR i = 1 TO N runs N times (inclusive), not N−1. And a WHILE loop checks its condition BEFORE the body, so the value that breaks the condition is the one left over at the end."
    }
  ],
  "illustration": null,
  "problems": [
    {
      "id": "math-prg-q1",
      "statement": "Trace this pseudocode: total = 0; FOR i = 1 TO 4: total = total + i. What is the value of total after the loop finishes?",
      "choices": [
        { "id": "c1", "text": "10" },
        { "id": "c2", "text": "6" },
        { "id": "c3", "text": "15" },
        { "id": "c4", "text": "4" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "easy",
      "eli5": "The loop runs for i = 1, 2, 3, 4 (inclusive endpoints), adding i to a running total each pass: 0+1+2+3+4 = 10. Choice B (6) stops at i = 3, the off-by-one error. Choice C (15) runs one extra pass to i = 5. Choice D (4) is just the number of iterations, not the sum.",
      "hint": "FOR i = 1 TO 4 runs four times (1,2,3,4). Add each i to the running total.",
      "steps": [
        { "text": "i = 1: total = 0 + 1 = 1.", "latex": null },
        { "text": "i = 2: total = 1 + 2 = 3. i = 3: total = 3 + 3 = 6.", "latex": null },
        { "text": "i = 4: total = 6 + 4 = 10. Loop ends (i would be 5, past 4).", "latex": null }
      ],
      "handbookPage": null,
      "handbookFormula": null,
      "videoUrl": null,
      "traps": [
        "Stopping at i = 3 (off-by-one) for a total of 6",
        "Reporting the iteration count (4) instead of the accumulated sum"
      ],
      "diagram": null
    },
    {
      "id": "math-prg-q2",
      "statement": "Given the logic: IF x > 10 THEN y = 1; ELSE IF x > 5 THEN y = 2; ELSE y = 3. If x = 7, what is the value of y?",
      "choices": [
        { "id": "c1", "text": "2" },
        { "id": "c2", "text": "1" },
        { "id": "c3", "text": "3" },
        { "id": "c4", "text": "7" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "easy",
      "eli5": "Conditions are checked top to bottom and the first true one wins. x = 7 is not greater than 10 (first test fails), but 7 > 5 is true (second test), so y = 2 and the final ELSE is skipped. Choice B (1) would require x > 10. Choice C (3) would require both tests to fail (x ≤ 5).",
      "hint": "Check conditions in order; the first TRUE branch runs and the rest are skipped.",
      "steps": [
        { "text": "First test: x > 10 → 7 > 10 → FALSE. Skip y = 1.", "latex": null },
        { "text": "Second test: x > 5 → 7 > 5 → TRUE. Set y = 2.", "latex": null },
        { "text": "The remaining ELSE branch is skipped. y = 2.", "latex": null }
      ],
      "handbookPage": null,
      "handbookFormula": null,
      "videoUrl": null,
      "traps": [
        "Falling through to the final ELSE (y = 3) instead of stopping at the first true test",
        "Confusing the strict inequality (7 is not > 10)"
      ],
      "diagram": null
    },
    {
      "id": "math-prg-q3",
      "statement": "Trace this WHILE loop: x = 1; WHILE x < 100: x = x * 2. What is the value of x when the loop stops?",
      "choices": [
        { "id": "c1", "text": "128" },
        { "id": "c2", "text": "64" },
        { "id": "c3", "text": "100" },
        { "id": "c4", "text": "256" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "A WHILE loop keeps doubling as long as x < 100, and it stops the moment the condition fails. The sequence is 1 → 2 → 4 → 8 → 16 → 32 → 64 → 128. When x = 64 the condition (64 < 100) is still true, so it doubles once more to 128. Now 128 < 100 is false, so the loop stops with x = 128. Choice B (64) stops one pass too early. Choice C (100) assumes the loop caps at the limit, which it does not.",
      "hint": "Keep doubling while x < 100; the value that breaks the condition is the final value.",
      "steps": [
        { "text": "Double while x < 100: 1, 2, 4, 8, 16, 32, 64.", "latex": null },
        { "text": "At x = 64 the condition 64 < 100 is still true, so double once more: x = 128.", "latex": null },
        { "text": "Now 128 < 100 is FALSE, so the loop exits with x = 128.", "latex": null }
      ],
      "handbookPage": null,
      "handbookFormula": null,
      "videoUrl": null,
      "traps": [
        "Stopping at 64 because it is the last value below 100, forgetting the loop doubles it again",
        "Assuming the result is capped at the limit value (100)"
      ],
      "diagram": null
    }
  ]
};
