This project contains a ui_designer.md file.
That file is the SINGLE SOURCE OF TRUTH for all UI rules.
You MUST strictly follow it. Do not reinterpret or redesign.

Below is an HTML file that represents the FINAL and ONLY visual reference
for the Activities screen.

Your task:
- Translate the HTML layout to Flutter widgets
- Apply spacing, hierarchy, proportions, and visual weight as literally as possible
- This is a TRANSLATION task, not a redesign task
- Do NOT invent styles, colors, or layouts
- Do NOT change business logic or data models
- Update ONLY activities_screen.dart

Design rules:
- Follow ui_designer.md exactly
- Background: warm cream (#FFFBF5)
- Primary color (accent only): peach (#FFB4A2)
- Secondary surface: lavender soft (#E5E0F7)
- No gradients
- No heavy pink fills
- Soft surfaces only

Icons (CRITICAL):
- Replace ALL Material icons with PNG assets:
  - Feeding → assets/icons/illustration/bottle2.png
  - Diaper → assets/icons/illustration/diaper_clean.png
  - Sleep → assets/icons/illustration/sleeping_moon2.png
- PNG icons MUST NEVER be placed directly on the background
- Every PNG icon MUST be inside a solid warm-cream container
- Icon sizes must visually match the HTML:
  - Hero segments: ~80px
  - Inactive segments: ~64px
  - Log list icons: 48–56px
- Do not shrink icons due to constraints — fix constraints instead

Layout rules:
- DO NOT use TabBar or TabBarView
- Use a custom segmented control as shown in the HTML
- Use SafeArea
- No bottom overflow on mobile (iOS Safari included)
- Text must wrap or ellipsis, NEVER overflow

Scope:
- activities_screen.dart ONLY
- Layout + visuals ONLY
- No refactors outside this screen
- No new abstractions unless strictly required by Flutter

Process:
1. Map HTML sections to Flutter widgets one by one
2. Preserve visual hierarchy exactly
3. Validate no overflow, no clipped icons

Below is the HTML reference. This HTML is FINAL.
Do not deviate from its structure or intent.

[PASTE THE FULL STITCH HTML HERE]
