# FE for Raccoons — Project Instructions

## What This Project Is
FE for Raccoons is a gamified study platform for the Fundamentals of Engineering (FE) Civil exam. It's a React + Vite + Tailwind app. The name comes from a YouTube video called "Raccoon Engineering" — the raccoon theme gives the brand personality but should never be cartoonish or childish.

## Tech Stack
- **Framework:** React 19 + React Router 7
- **Build:** Vite 7
- **Styling:** Tailwind CSS 4 + custom CSS variables
- **Math rendering:** KaTeX
- **Icons:** Phosphor Icons (use `@phosphor-icons/react`, Bold weight for nav/CTAs, Regular for content)
- **Fonts:** DM Sans (headings), Inter (body text), JetBrains Mono (formulas, data, code)

## Brand System — ALWAYS FOLLOW THESE

### Color Tokens (use CSS custom properties)
```css
--cream:        #FFF9F0;   /* Page background, base canvas */
--cream-dark:   #F5EDE0;   /* Hover states, subtle sections */
--charcoal:     #2C2C2C;   /* Primary text, nav, footer */
--ember:        #E8683A;   /* Primary CTA, links, focus rings */
--ember-bg:     #FEF0EA;   /* Tags, badges in ember context */
--sunbeam:      #F5B731;   /* XP, streaks, highlights, warnings */
--sunbeam-bg:   #FEF7E0;   /* Tags, badges in sunbeam context */
--forest:       #2D7A5F;   /* Success, mastery, correct answers */
--forest-bg:    #E8F5EE;   /* Tags, badges in forest context */
--error:        #D64045;   /* Error states */
--info:         #3B82B8;   /* Informational states */
```

### Typography Rules
- **Headings:** `font-family: 'DM Sans'` — weight 600-700, tight letter-spacing (-0.02em to -0.04em)
- **Body:** `font-family: 'Inter'` — weight 400-500, line-height 1.6
- **Code/Data/Formulas:** `font-family: 'JetBrains Mono'`
- **Overlines/Badges:** DM Sans 600, 0.7rem, uppercase, letter-spacing 0.08em

### Design Tokens
- **Border radius:** 6px (small/chips), 10px (buttons/inputs), 16px (cards), 24px (hero/banners)
- **Shadows:** Use subtle, warm shadows: `0 1px 3px rgba(44,44,44,0.04), 0 4px 16px rgba(44,44,44,0.06)` for cards
- **Max content width:** 1100px
- **Spacing scale:** 4px, 8px, 16px, 24px, 32px, 48px, 64px, 96px

### Layout Approach (Brilliant.org-style)
- Cream (#FFF9F0) is the main page background — let it breathe with generous whitespace
- Charcoal (#2C2C2C) for nav bar and footer to anchor the page structure
- Ember accent border (3px) on bottom of nav bar
- White (#FFFFFF) background for cards, elevated above the cream
- Feature cards use a colored 4px top accent bar (Ember, Forest, or Sunbeam)
- Topic cards use a 4px left border in Forest

### Absolute Don'ts
- NEVER use emojis — Phosphor icons replace every use case
- NEVER use purple gradients or neon colors
- NEVER use sharp corners (minimum 6px radius)
- NEVER center-align body text — left-align for readability
- NEVER use system fonts — always load DM Sans + Inter + JetBrains Mono
- NEVER make the raccoon theme cartoonish or childish
- NEVER use more than 2 accent colors in a single section

### Brand Reference
The full interactive brand deck is at: `fe4raccoons-brand-deck.html` in the project root.
For the custom design skill with more detail, see: `.claude/skills/fe4raccoons-brand/SKILL.md`
