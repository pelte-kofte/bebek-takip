# Bebek Takip App – Global Rules

## Design System (LOCKED)
- Background (warm cream): Color(0xFFFFFBF5)
- Primary accent (peach): Color(0xFFFFB4A2)
  - Accent only, never dominant
- Secondary surface (lavender): Color(0xFFE5E0F7)
- No strong pinks
- No aggressive gradients unless explicitly requested

## Icons & Assets
- All activity icons are PNG illustrations
- Emoji icons are NOT allowed (except user-generated content)
- PNG icons must:
  - Be visually dominant
  - Sit inside solid containers
  - Never blend into background
  - Never rely on padding that shrinks the image

## Layout Rules
- Mobile-first
- SafeArea respected
- No bottom overflow on iOS Safari
- No magic numbers without reason
- Prefer Container size > Image size (not equal)

## Behavior Rules for Claude
- Do NOT “polish” UI unless asked
- Do NOT resize icons arbitrarily
- Do NOT touch summary widgets when fixing log widgets
- Do NOT refactor unrelated code

If unsure:
STOP and ask before changing.
