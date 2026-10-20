# Tasks

## 1. Random draw plumbing

- [x] 1.1 Add an injectable exercise draw (Flashcard / Quiz / Typing, uniform) on the study page, wire it when entering Random and when advancing under Random, and verify a unit or widget test can force Quiz then Typing for two successive words.
- [x] 1.2 Track `effective` exercise separately from the Random menu mode so the mode chip stays Random while the body uses the draw, and verify choosing Quiz from the menu shows fixed Quiz and choosing Random again redraws.

## 2. Render and retire browse Random

- [x] 2.1 Route the practice body and rating controls through the effective exercise type under Random (reuse Flashcard / Quiz / Typing paths), remove full-face browse lines, peek, and prev/next for Random, and verify Random+forced Flashcard flips/rates like Flashcard and Random+forced Quiz settles then rates like Quiz.
- [x] 2.2 Replace the browse Random widget test with mix scenarios (forced Quiz, forced Typing, advance redraw, menu leave mix) in `test/features/home/vocabulary_home_test.dart`, and verify that file’s Random-related cases pass.

## Workflow follow-up

- Archive after review when implementation is complete.
- Keep separate from `career-suggestion-previews` apply/archive.
