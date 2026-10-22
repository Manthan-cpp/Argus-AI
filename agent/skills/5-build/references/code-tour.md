# Learning Wrap-Up and App Map — Agent Reference

One brief, useful connection between this project and a practice the learner can reuse. This happens after revisions in both build modes, before submission chores. Budget three to five minutes total, less when the relevant practice already happened. Not a quiz, another interview, or an extra product feature.

## Choose From What Actually Happened

Read the profile's **Desired Learning Outcome** and any **Learning Moments**, the spec's **Decisions and Open Issues**, and relevant build evidence. Pick one connection, not a recap of all six skills:

- Wanted to understand generated code → follow a real action to its implementation and verification.
- Wanted to scope better → revisit one actual cut and the working kernel it protected.
- Wanted clearer requirements → connect one acceptance criterion to its test and observed result.
- Had a technical unknown → trace how a concrete example, investigation, or test clarified it; distinguish resolved questions from remaining uncertainty.

These are agent guidance, not a questionnaire or required categories. If a learning intention was never established, default to the code route below. Don't make up a goal or add a new technology. Keep any personal learning notes in the ignored learner profile; public artifacts describe the project, not the person.

Say briefly why this example is useful. Suggest one activity tailored to them and let them redirect naturally. A person new to planning first gets the guided route by default; an experienced plan-first user can use the focused alternative. Coding seniority alone is not a reason to skip guidance.

## Guided Route — Default for Newcomers

Prepare from the current implementation, not just the planned file tree. Choose one core action with a visible result and 2–3 meaningful code locations. These can be functions in the same file; never invent layers for a small app.

1. **Connect and open (~30 seconds).** Explain the connection to their goal or the value of knowing where a future change belongs. Have them open the project in their editor and run it using its documented command. No long cognitive-debt preamble.
2. **Follow one action (~2 minutes).** Have them perform an action they've already tried, then navigate to the input/entry point, important logic or storage if present, and result/output. Give real relative paths and stable function/symbol or search anchors; line numbers are optional conveniences. At each stop, explain the connection to the visible behavior in one or two sentences. Group navigation instructions naturally; no approval at each stop.
3. **Optional small edit (~1 minute).** Invite one safe, incidental change, such as a label or harmless default. Help them anticipate the visible effect conversationally, not as a test. No kernel changes, credentials, data deletion, dependencies, or debugging infrastructure. Let them rerun or refresh and see the result. If they decline, move on without a replacement exercise. If stuck, show the change rather than grilling them. Verify and commit a kept change; never silently undo their work or overwrite unrelated edits. Update plans only if a retained change affects a documented decision.
4. **Takeaway and map (~1 minute).** Use the shared ending below.

If the app/editor cannot run, use real source excerpts and explicitly call this a static walkthrough. Don't claim observed execution. Avoid setup detours. On interruption, record completed stops and resume there.

## Focused Alternative — For Familiar Plan-First Users

Use one real uncertainty, change, or planning/verification decision instead of a redundant code tour. Keep it within the same time budget and existing scope. For example:

- Trace the cause of a failure already encountered and the evidence that distinguished it from another plausible cause.
- Make a safe, small change and identify which existing check establishes that it worked.
- Compare an original vague requirement with its agreed criterion, the corresponding implementation/test, and the observed outcome.

Anchor the activity in actual document headings, code, tests, or results—not a generic engineering lecture. Invite one useful contribution (an observation, trying the change, or identifying what the evidence does and doesn't establish). Don't require a correct answer or make them invent an uncertainty. Explain/help directly when needed.

If this already happened during planning or build, cite that moment and move straight to the ending. Don't repeat the activity to satisfy a ritual. A learner who wants no extra exercise can use a brief evidence-based recap and the map; record that honestly as a recap, not hands-on practice. Prepare a simple code route for the map even when it was not toured interactively.

## Shared Ending — A Takeaway, Not a Test

Briefly connect **a real project decision or action → the evidence → a reusable practice**. For example, point to the actual acceptance criterion and test that exposed a mismatch, explaining that specifying an observable result made the problem easier to catch. Use this project's details, not canned praise or a claim of mastery.

Offer at most one optional question: "What would you do differently next time you start with an agent?" Skip it if they already expressed the takeaway. A short answer, uncertainty, or declining is complete. Don't demand they teach the concept back or require the reflection to proceed. Record personal responses only in the ignored profile, in their words, distinguishing them from your explanation. Never turn this into drafted submission or exit-survey copy.

Show `devpost/app-map.html` and how to reopen it. Record under **Code Tour and App Map**: activity type and actual evidence, completed route/stops if applicable, edit outcome including declined/not applicable, and reflection offered/answered/declined/already covered. Check completion only for what actually happened. Sending instructions alone isn't a completed guided activity. No extra sign-off.

## The App Map

Generate a compact standalone `devpost/app-map.html` in both modes, regardless of planning review-format preference. It is not an HTML build checklist or a new page in the learner's app. Use actual post-revision, post-edit code.

Include:
- A plain-language overview of the app's purpose and few main pieces.
- A small inline SVG or HTML/CSS diagram connecting one real action, its code locations, and visible result. Include storage/external services only if present.
- A 2–3-stop route with actual relative paths, stable symbols/search anchors, and brief explanations. Label it as a reference route if it wasn't toured; don't imply the learner completed it.
- A few concrete **“To change this, start here”** pointers, including a kept tiny edit if relevant. No exhaustive file tree or code dump.
- A short **“A practice to reuse”** note grounded in project evidence: the decision or action, a document/test/code reference, and how the same approach could help on another project. This is factual technical guidance, not a personal learning testimonial or submission prose.
- How to run the app again and the source commit used for the map when available; explain that it is a snapshot and can drift.

Keep it readable and keyboard-accessible, with optional native `<details>` reveals. No build step, framework, CDN, network dependency, analytics, or secrets. Essential content must work with scripts disabled. Escape code snippets so source text cannot become executable HTML. Don't embed learner-profile details or private sample data; the repository will be public.

Check all paths and anchors against actual source, and confirm the map is useful offline. Open/check it where tools allow; be honest about browser checks you can't perform. Record its path and commit the map and public-safe wrap-up record. If shipping fixes affect mapped behavior, refresh the map without repeating the activity.
