# Modernization log — 2026-11-17

- Cloned a clean `master` at `15d9ae9`; inspected all Dart sources, manifests and native identities before choosing the migration. No pre-existing local edits existed.
- Applied make-it-work → improve → verify. Preserved Flutter, Sembast, native identifiers, `borrowed_stuff.db`, `Stuff` and record keys. Read the real Portuguese Medium article in the project's own browser tab; preserved the historical README and original MIT notice.
- Replaced Dart 2 APIs and obsolete UI plugins; resolved dependencies on Flutter 3.41.9 / Dart 3.11.5. Resolution rejected Sembast Web 2.4.7 (requires Dart 3.12); pinned compatible 2.4.4+1 instead of changing the shared SDK.
- Test-first migration: domain/repository contracts initially failed compilation against old null-unsafe APIs; passed after migration. A separate runtime red test proved that `--------` was wrongly accepted as a phone; digit-count validation made it pass. The mobile widget test caught a real metric overflow; corrected the layout. An initial widget test used real Sembast with a simulated clock and stalled; replaced its dependency with a deterministic repository fake, while keeping real Sembast integration and disk reopen tests separate.
- Corrected duplicate-description identity corruption by using Sembast keys. Added lazy schema 2 writes, calendar dates, returns, optional phones and embedded photos; kept legacy photo paths. Tested old-format data, key mismatch, duplicated descriptions, same-key updates, deletes and close/reopen persistence.
- Delivered a responsive Material 3 journal, summary, search, filters, visible return/re-lend actions, confirmed deletion, gallery/form, input validation, discard dialog, error/retry and local demo data. Browser images are bytes, not native file paths.
- Updated Android Gradle/plugin configuration from the installed Flutter template, preserving app identity. Added Web. Raised iOS deployment settings and gallery purpose; allowed Flutter's normal Xcode/UIScene migration.
- Ran Crapper/Dryer/Mutator against `lib`; each reported no supported files. Their documented language lists exclude Dart, so no CRAP, duplication or mutation metrics are invented.
- GitHub About updated in English; retained `dart`, `education`, `flutter`, `lending`, `mobile-development` and added `sembast` (six topics), verified in the actual repository page.
- Browser: opened the compiled app at `http://127.0.0.1:8767`; enabled semantics; loaded examples; marked a return and reloaded to verify IndexedDB persistence. Captured actual desktop/mobile screens. Automated gallery selection was blocked by the extension's disabled local-file access; no setting was changed and no successful manual photo selection is claimed.

Final command results, native limitations and publication evidence follow.

- Native fixes from real builds: Android's updated manifest required NormalTheme absent from the old resources; added current launch/normal resources. Gradle automatically installed Android platform 35 using an already accepted license during the first check; added `android.builder.sdkDownload=false` to prevent further implicit SDK provisioning. No Flutter SDK update or license acceptance was performed.
- Xcode 27 rejected iOS 13 targets; raised app and pod targets to iOS 15. Its lipo also rejects Flutter 3.41's multi-architecture verification (https://github.com/flutter/flutter/issues/188461). Scoped Debug simulator ARCHS to the host architecture, leaving device release settings intact.
- Web build detected the missing Cupertino icon font used by adaptive Flutter controls; restored a current compatible cupertino_icons dependency and repeated analysis/tests/build.

## Final local results

- `dart format --output=none --set-exit-if-changed lib test`: unchanged formatting.
- `flutter analyze`: no issues.
- `flutter test --coverage`: **8 tests passed**. LCOV is generated, without a coverage-percentage claim.
- `flutter build web`: passed, including Wasm dry run; the delivered browser preview uses the standard JavaScript build. Actual Wasm execution was not tested.
- `flutter build apk --debug`: passed after the Android theme fix, then passed again with the final icon dependency. Artifact: `build/app/outputs/flutter-apk/app-debug.apk`.
- `flutter build ios --simulator --no-codesign`: passed with iOS 15 and the scoped host-architecture workaround, then passed again with the final dependency. Artifact: `build/ios/iphonesimulator/Runner.app`. No simulator launch or physical-device execution is claimed.
- Final Chrome checks: empty journal, transactional examples, return followed by reload, editing a fictional contact followed by reload, search by borrower, delete confirmation canceled, form presentation and 390 × 844 responsive viewport. Desktop, mobile, form and search screenshots are real captures under `docs/screenshots/`.
- Gallery file selection remains unverified end-to-end: the browser extension refused access to local files. Embedded payload roundtrip is covered by Sembast tests. Camera/phone/location APIs are not implemented.

## Medium and repository publication

- The Medium session initially appeared signed out; after the session became authenticated, the article's normal menu exposed **Edit story**. Updated only this project's own article, keeping its Portuguese title, subtitle, author, publication and story ID `6dbf350a7a56`.
- Replaced obsolete Dart 2 technical instructions/Gist embeds with the current dependency manifest, APIs, code excerpts, source links, compatibility guidance, validation and classroom extensions. Preserved third-party references and original MIT authorship; archived the old README separately.
- Used **Save and publish** in the existing article. The public story returned with `postPublishedType=repub`; reloaded and verified the update dated 17/11/2026 and the final credits section. No email/subscriber action was used.
- Published article: https://medium.com/flutter-comunidade-br/criando-um-aplicativo-para-lembrar-dos-objetos-emprestados-com-flutter-e-sembast-6dbf350a7a56
- Local article text: `docs/medium-update.pt-BR.md`; actual publication capture: `docs/screenshots/medium-published.jpg`.
- Commits: `70b920d` (domain, persistence, UI and tests); `36d5d05` (platforms and CI); documentation/evidence in the following commit. GitHub's default branch was confirmed as `master`, initially at `15d9ae9`, with no active branch protection or rulesets. Push follows the user's explicit authorization, without force or protection changes. The final CI result is reported in the delivery with its run URL; live status remains available in Actions.
