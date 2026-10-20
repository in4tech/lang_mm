# Design

## Context

See proposal.md for why. The empty home already swaps the dashboard for `SuggestionColumns` when the library has no folders. Content lives in `SuggestionTemplates` as fixed English strings; chip / Save / row taps are no-ops. Specs today lock Love/Study-style names and the featured word `student`. This change replaces that catalog and makes selection drive an in-place preview only.

## Goals / Non-Goals

**Goals:**

- Ship ten career packs with enough fixed English words to feel real in preview.
- Keep the two-column empty-home frame; enrich Suggested sets rows and the right column into a selectable preview.
- Keep zero library writes from chips, set rows, practice rows, and Save.

**Non-Goals:**

- Adding a pack to the library, Firestore, or SharedPreferences.
- Translating pack names or template words.
- Changing practice modes, Random, or the stored-library dashboard.
- Fetching vocabulary from the web at runtime.

## Decisions

### Career packs as typed template data

Replace the flat `sets` / `chips` / `practice` / single-word constants with a list of packs in `suggestion_templates.dart`:

```text
SuggestionPack { id, title, words: [SuggestionWord...] }
SuggestionWord { term, ukIpa, usIpa, gloss, saveCount }
```

Ten packs, in order:

1. Healthcare  
2. Software Engineering  
3. Finance & Banking  
4. Hospitality & Tourism  
5. Marketing & Sales  
6. Education & Teaching  
7. Law & Legal  
8. Logistics & Supply Chain  
9. Design & Creative  
10. Customer Support  

Each pack has **12** words. Lead term (first word) is also that pack’s hot-search chip and Suggested practice target. Chips and practice rows are derived from the packs so order stays consistent.

Word payload (term / UK / US / gloss). `saveCount` is `80` for every template word unless a scenario needs otherwise; featured default uses 80.

| Pack | Lead + sample terms (12 total) |
|------|--------------------------------|
| Healthcare | diagnosis, prescription, vitals, triage, outpatient, dosage, vaccine, surgery, pathology, radiology, pharmacy, referral |
| Software Engineering | deploy, refactor, pull request, latency, backlog, endpoint, commit, branch, pipeline, rollback, container, runtime |
| Finance & Banking | invoice, interest rate, portfolio, liquidity, equity, audit, ledger, collateral, dividend, bond, forex, balance sheet |
| Hospitality & Tourism | check-in, itinerary, amenity, concierge, reservation, occupancy, housekeeping, suite, layover, visa, baggage, lobby |
| Marketing & Sales | conversion, lead, funnel, campaign, CTA, retention, branding, segment, outreach, upsell, quota, pipeline |
| Education & Teaching | curriculum, assessment, rubric, enrollment, syllabus, literacy, lecture, tutor, homework, diploma, faculty, seminar |
| Law & Legal | liability, contract, plaintiff, statute, clause, deposition, affidavit, counsel, verdict, injunction, tort, jurisdiction |
| Logistics & Supply Chain | shipment, warehouse, lead time, inventory, freight, SKU, pallet, customs, carrier, fulfillment, transit, logistics |
| Design & Creative | wireframe, mockup, typography, portfolio, brief, prototype, layout, palette, storyboard, illustration, grid, brand kit |
| Customer Support | ticket, escalate, SLA, refund, troubleshooting, follow-up, chatbot, knowledge base, resolution, outage, agent, priority |

Gloss and IPA strings are authored as English template constants next to each term (same style as today’s `student` card). Exact IPA/gloss copy is fixed in code and asserted lightly in widget tests (featured default + one preview switch).

Alternative considered: keep names only and invent words in the widget. Rejected because preview needs stable, testable content.

### Preview is local widget state

`SuggestionColumns` becomes stateful (or takes a small controller owned by the home). State:

- `selectedPackIndex` (default `0` = Healthcare)
- `featuredTerm` (default first word of that pack)

Selection rules:

- Tap Suggested sets row → pack index, featured = first word.
- Tap chip / practice row → pack that owns that term, featured = that term.
- Tap a term in the preview list → featured only.

No navigation route; right column updates in place. Save remains a no-op.

Alternative considered: modal dialog preview. Rejected to stay inside the existing two-column frame and avoid a new surface.

### Layout tweaks inside the same cards

Left column: Hot search chips (10), then Suggested sets as rows with book icon, pack title, and `N words` caption using existing `HomeText` / border tokens.

Right column top: featured word card (term, UK, US, gloss, saves, Save) — same structure as today. Below: pack title, then a scrollable list of terms for the selected pack (replacing the static Suggested practice block’s role when previewing is enough for the set; Suggested practice list stays under Hot search’s sibling column per current layout — practice rows remain in the right column under the featured card, after the term list, matching the current “word then practice” order).

Order on the right:

1. Featured word + Save  
2. Selected pack title + term list (preview)  
3. Suggested practice heading + ten practice rows  

On narrow viewports, keep today’s stack: left card then right card. Term list scrolls inside the right card so the page does not grow unbounded.

### Localization

No new ARB keys required if the word-count caption can be a fixed English fragment `"12 words"` (templates stay English). If product wants a translated count later, add `suggestionWordCount` — **not** in this change; use the English fragment to match existing template policy.

Existing suggestion chrome keys unchanged; scenarios update expected template strings only.

### Tests

Update empty-home tests that assert `student`, Love vocabulary, old chips, and five practice rows. Add cases: default Healthcare/diagnosis; tap Software Engineering shows deploy terms; tap `deploy` chip features deploy; Save still leaves library empty.

## Risks / Trade-offs

- [Ten packs × 12 words makes `suggestion_templates.dart` large] → Accept; keep one file, no assets. Split later if needed.
- [Requirement still named "Suggested word shows student"] → Leave the header for MODIFIED archive safety; scenarios describe diagnosis.
- [Users may expect Add to library from preview] → Explicit non-goal; Save stays inert. A later change can add import.

## Migration Plan

No persisted data. Fresh empty libraries show the new templates. Rollback restores Love/Study placeholders. No cloud migration.

## Open Questions

None deferred; pack list, preview-only behavior, and default Healthcare/diagnosis are fixed for this change.
