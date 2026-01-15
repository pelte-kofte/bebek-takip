# 🎨 UI DESIGNER RULES  
### Baby Tracker App – Single Source of Truth

This document defines **STRICT UI RULES** for the entire app.  
All screens must follow these rules **literally**.  
This is **not inspiration**, this is **law**.

---

## 1️⃣ CORE DESIGN PHILOSOPHY

- Calm
- Emotional
- Soft
- Trustworthy
- Premium but warm
- Never “dashboard-like”
- Never aggressive or loud

This is a **care app**, not a data app.

---

## 2️⃣ COLOR SYSTEM (STRICT)

### Backgrounds
- **Main background:** `#FFFBF5` (Warm Cream)
- This is the default background for ALL screens

### Surfaces (Cards / Containers)
- **Primary surface:** Warm Cream
- **Secondary surface:** Lavender Soft `#E5E0F7`
- No pure white surfaces unless explicitly needed

### Accent
- **Primary accent:** Peach `#FFB4A2`
- Accent usage ONLY for:
  - Active states
  - Borders
  - Small highlights
  - Dots / indicators
- Peach must NEVER dominate the screen

### Forbidden
- ❌ Heavy pink fills
- ❌ Strong gradients
- ❌ High contrast neon colors

---

## 3️⃣ ICON SYSTEM (CRITICAL)

### Global Rules
- ALL activity icons are **PNG illustrations**
- Icons must NEVER float directly on the background
- Icons must ALWAYS sit inside a **solid container**

### Icon Containers
- Background: Warm Cream or Lavender Soft
- Border radius: `16–999`
- Optional border:
  - 1px
  - Alpha: `0.12–0.18`
- Shadows:
  - Very soft
  - Optional
  - Never heavy

---

### Icon Sizes by Context

#### Hero / Main Activity Icons
(Top of Activities, Home highlights)
- Icon: `72–88px`
- Container: `96–104px`
- Shape: Circle
- Visually dominant

#### Summary Cards
- Icon: `28–36px`
- Container: `44–52px`
- Secondary emphasis

#### Log List / History Items
- Icon: `48–56px`
- Container: `64–68px`
- Clear and readable

#### Empty States
- Icon: `56–72px`
- Friendly, emotional

---

## 4️⃣ SEGMENT / TAB BEHAVIOR

- DO NOT use TabBar or TabBarView
- Use **custom segmented controls**
- Segments must:
  - Feel like big tap targets
  - Be icon-first
  - Text is secondary or optional
- Active state:
  - Border (peach)
  - Slight emphasis
- Inactive:
  - Same background
  - No border

---

## 5️⃣ TYPOGRAPHY RULES

### Section Headers
Used for:
- “ÖZET”
- “SON AKTİVİTELER”
- Similar sections

Rules:
- Uppercase
- Small font
- Letter spacing
- Calm presence

Example:
```dart
fontSize: 12
fontWeight: FontWeight.w700
letterSpacing: 1.2

### Body Text

- Readable
- Calm
- Never cramped

## Important Rule
- Text must wrap or ellipsis
- Text must NEVER overflow

---

## 6️⃣ CARDS & LISTS

### Cards

- Background: Warm Cream
- Border radius: 16–20
- Padding:
  - Horizontal: 16
  - Vertical: 16–20
- Shadow:
  - Soft
  - Lavender-tinted
  - Optional

### Lists

- Icon on left (inside solid container)
- Text center
- Time / meta info right
- No dividers unless necessary

---

## 7️⃣ STATUS & INFO BANNERS

- Used for:

  - “Baby has been sleeping…”

  - Passive information

- Rules:

  - Rounded container
  - Soft peach background (low opacity)
  - Small dot indicator
  - Secondary importance
  - Calm tone

---

## 8️⃣ EMPTY STATES

- Friendly
- Emotional
- Encouraging
- Never cold or technical

- Rules:

  - Large icon
  - Short text
  - One soft CTA
  - No dense layouts

---

## 9️⃣ LAYOUT & SPACING

- Mobile-first
- SafeArea ALWAYS
- No bottom overflow (iOS Safari safe)
- Vertical rhythm:
  -Compact
  -Breathing
  -Never tight

- Decorative elements:

- Allowed
- Very low opacity (2–4%)
- Never interfere with content

---

## 🔟 BEHAVIOR RULES (VERY IMPORTANT)

- Claude MUST:
  -Apply rules, not reinterpret
  - Match Activities screen as visual reference
  - Keep layouts stable
  - Only adjust visuals when asked

- Claude MUST NOT:

  - Invent new UI styles
  - Change data logic
  - Introduce new colors
  - Resize icons arbitrarily
  - “Improve” things creatively

---

## ✅ GOLDEN RULE

- If unsure:
   - Do it the same way as Activities screen.

---

## 🧠 HOW TO USE THIS FILE

- For every screen update, use this prompt pattern:
Use ui_designer.md as strict rules.

Update ONLY <screen_name>.dart.

Make it visually consistent with Activities screen.
No redesign. No logic changes.

---



