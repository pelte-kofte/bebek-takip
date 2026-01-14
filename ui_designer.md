# UI DESIGN SPEC – Baby Activity App

## Design Pillars
- Calm, emotional, reassuring
- No dashboard feeling
- No strong pink blocks
- Pastel, airy, breathable

## Color System
- Background: Warm Cream #FFFBF5
- Primary Accent (rare): Peach #FFB4A2
- Secondary Surface: Lavender #E5E0F7
- Text Primary: #2F2F2F
- Text Secondary: #8A8A8A

## Icon System
- Segment icons: 72–88px PNG illustrations
- Log icons: 36–40px
- Summary icons: 28–32px
- All icons sit on solid containers (never floating on background)

## Segment Control (NOT TabBar)
- Custom Row-based segmented control
- GestureDetector + Container
- Active:
  - Warm cream background
  - Peach 1px border
  - Soft lavender shadow
- Inactive:
  - Transparent
  - Smaller icon

## Layout Rules
- No gradients
- No heavy color blocks
- Vertical spacing preferred over borders
- Content always scrollable (SafeArea + SingleChildScrollView)

## PNG Icon Integration Rules

- PNG icons are pastel and detailed; they must never be placed directly on the background.
- Every PNG icon must be wrapped in a solid surface container.
- Containers use warm cream or soft lavender backgrounds.
- No gradients behind PNG icons.
- PNG size is controlled by layout, not image scaling tricks.
- Icons should feel embedded into the UI, not floating.


## iOS Priority
- iOS Safari safe
- No bottom overflow
- Touch-friendly spacing
