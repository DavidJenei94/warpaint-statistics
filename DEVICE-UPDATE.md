# Device update 2.0.5

New 466 x 466 family: `resources-round-466x466`. Regenerated fonts:
- Clock: 175 px (previous 454 x 454 family: 170 px).
- Text: 39 px (previous: 38 px).
- Data: 47 px (previous: 45 px).
- Icons: 43 px (previous: 42 px).

Both percentage-based left/right round layouts are retained. Statistics' old OTF lacks the Y/Z glyphs present in its existing bitmap atlas, so the new atlas uses Motivation's current shared icon OTF and preserves all 26 original uppercase glyphs.

New profiles: Approach S72 43/47mm, D2 Mach 2 Pro, Enduro 4, fenix 9 43mm and 47/51mm, fenix 9 Pro 43/47/51mm, fenix 9 Pro Solar 47/51mm, Forerunner 70, Forerunner 170 and Forerunner 170 Music.

AMOLED targets use `resources-no_partial_update` and exclude the `partial_update` annotation. The app's low-power AMOLED clock/burn-in layout is retained. Enduro 4 and fenix 9 Pro Solar keep MIP partial updates/low-power seconds. Forerunner 70 uses `resources-no_floors`, which removes both Floors Climbed and Meters Climbed choices.

Retained exclusions: semi-octagonal monochrome Instinct/Descent watches and Instinct Crossover AMOLED (analog hands obscure the custom layout), plus the existing legacy low-memory exclusions. Statistics also retains FR735XT and Vivoactive HR exclusions.

## Simulator debug checklist

- `fenix9pro51mm`: inspect 12/24-hour time, AM/PM, seconds, all icons/data fields and both high-contrast/dark themes at 466 x 466.
- For Statistics, inspect both left/right layouts and sunrise/sunset (E/F) and the DND/Bluetooth system indicators (Y/Z).
- For Motivation, test a short quote, a long quote, long unbroken words and explicit `|` line breaks.
- Enter/exit low-power mode on an AMOLED model; check the sparse alternating burn-in layout and that the "always" seconds option is absent.
- `fenix9prosolar51mm` and `enduro4`: check always-visible seconds/partial updates on MIP.
- `fr70`: confirm Floors Climbed and Meters Climbed are absent from every field/bar picker.

Compilation and font atlas previews are automated. Native simulator interaction and physical-watch behavior still require this manual visual pass.

## Device support policy

Garmin compatibility alone does not enable a product. The manifest is the released support list. Match its app type, shape, resolution and memory, then apply the project's settings and annotation overlays. The workbook's support column follows this list exactly.

The public Description sheet is derived from the README's public description, features, FAQ, release notes and permissions. Development/build sections remain in Markdown. Device specifications come from the installed Garmin SDK compiler/simulator profiles and Garmin's official compatible-device/device-reference pages; feature availability also follows the app overlays. The local `.xlsx` is the maintained help artifact; copying it to Google Sheets remains a separate publication step.

Sources checked 2026-10-11:
- https://developer.garmin.com/connect-iq/compatible-devices/
- https://developer.garmin.com/connect-iq/device-reference/

## Release validation

Use `powershell -NoProfile -File scripts/build-release.ps1` with Java 17+ and the installed Connect IQ SDK. It keeps the original app ID/type and `../developer_key`, exports every manifest product and verifies the signed manifest, binary signatures and exact firmware/regional coverage. The versioned upload file, log and SHA-256 checksum are in `dist`.
