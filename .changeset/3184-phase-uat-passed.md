---
type: Added
pr: TBD
---
**`phase.uat-passed` query and `isPhaseUatPassed` SDK export** — adds canonical read-only query `phase.uat-passed` (alias `phase uat-passed`) and programmatic export `isPhaseUatPassed(projectDir, phase, workstream?)` returning typed `{ passed, reasons, reasonsHuman, items }`. Predicate consumes `*-HUMAN-UAT.md` files; hardens against markdown injection (YAML frontmatter, fenced code blocks, HTML comments, blockquote-prefixed lines); surfaces operator-mistake signals as typed `REASON_CODE` frozen enum values (`CASE_MISMATCH`, `ORPHAN_ITEM_MISSING_RESULT`, `BRACKETED_PLACEHOLDER`, `NO_ITEMS_EXTRACTED`). Typed `PhaseUatPassedError extends GSDError` for invalid arguments. Refs #3184.
