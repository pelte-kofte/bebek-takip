# UI DESIGN SYSTEM – Baby Tracking App

## Design Philosophy
- Calm, reassuring, privacy-first.
- No loud colors, no harsh contrasts.
- UI should feel like a trusted notebook, not a dashboard.
- Focus on spacing, softness, and visual hierarchy.

## Color System
- Background (primary): Warm cream #FFFBF5
- Surface cards: White / very light cream
- Secondary surface: Soft lavender #E5E0F7
- Accent (only for highlights): Peach #FFB4A2
- Text primary: Near-black warm tone
- Text secondary: Muted gray

❗ Peach is accent-only. Never large backgrounds.

## Icons & PNG Usage
- All activity icons use custom PNG illustrations.
- PNGs must NEVER sit directly on patterned or gradient backgrounds.
- Always wrap PNG icons in a solid container:
  - Background: warm cream or white
  - Border radius: 12–16
  - Optional thin border (low opacity)

### Icon Sizes
- Main activity selector (top segments): 72–88px
- Log list icons: 52–56px
- Summary icons: 28–36px

## Background Decoration
- Use 1–2 large circular pale shapes only.
- Colors: peach or lavender at 2–4% opacity.
- Place in corners only.
- Never center.
- Must stay behind all content.
- Non-interactive, purely decorative.

## Typography Hierarchy
- Section titles:
  - Uppercase
  - Small
  - Muted
  - Examples:
    - "QUICK SUMMARY"
    - "RECENT ACTIVITIES"
    - "BABY HAS BEEN SLEEPING..."

- Card titles: medium weight
- Secondary text: smaller, muted

## Layout Rules
- Mobile-first.
- No overflow on iOS Safari.
- Use SafeArea + scroll where needed.
- Avoid tall empty states.
- Reduce vertical padding before adding scroll.

## Activity Summary Pattern
Use compact cards similar to:
- LAST FED → "2h 15m ago"
- LAST DIAPER → "45m ago"
- LAST SLEEP → "2h ago"
- DAILY TOTALS where relevant

These summaries should always reflect the most recent activity data.

## Privacy-Friendly Photo Handling (Milestones)
- Milestone photos support optional visual styles:
  - Original photo
  - Soft illustration (hand-drawn pastel look)
  - Pastel blur
- Default selection: Soft illustration
- Purpose: parents who don’t want to share clear facial details
- UI includes a simple style selector below the image preview

## Add Screens
- No timers required.
- Manual input first.
- User can log past activities (e.g. “slept 2 hours ago”).
- Forms must fit without forced scrolling where possible.

## Consistency Rules
- Do not redesign components arbitrarily.
- Follow this system for ALL screens:
  - Home
  - Activities
  - Add Activity
  - Milestones
  - Settings

UI changes should feel like refinement, not redesign.
