# Al-Madina Dairy — Milk Delivery Management App — Implementation Plan

> **App name**: Al-Madina Dairy  
> **Platform**: Flutter (Android-first, mobile)  
> **Languages**: English + Urdu (RTL)  
> **Data strategy**: Offline-first (sqflite), Firebase sync added last (Phase D)

---

## 1. DESIGN SYSTEM — Single Source of Truth

All visual decisions across every milestone originate from this section. No colors, font sizes, spacing values, corner radii, or icon styles outside what is documented here may be used anywhere in the app.

### 1.1 Color Palette

| Token                  | Hex         | Usage                                                                 |
|------------------------|-------------|-----------------------------------------------------------------------|
| `brand.primary`        | `#1E40AF`   | Primary CTA backgrounds, active nav, links, brand identity            |
| `brand.primaryDark`    | `#1E3A8A`   | Pressed/hover state of primary buttons                                |
| `brand.primaryLight`   | `#60A5FA`   | Light accent highlights                                               |
| `brand.soft`           | `#EFF6FF`   | Icon containers, active nav pill bg, soft brand tint cards            |
| `brand.tint`           | `#DBEAFE`   | Hovered soft backgrounds, secondary surfaces                         |
| `brand.subtle`         | `#F1F5F9`   | Very faint backgrounds (e.g., filter section bg)                      |
| `scaffold`             | `#F8F9FA`   | Page/scaffold background, card inset backgrounds                     |
| `card`                 | `#FFFFFF`   | Card surfaces, bottom sheets, dialogs, nav bar, input fields         |
| `neutral.title`        | `#0F172A`   | Primary heading text (slate-900)                                      |
| `neutral.body`         | `#334155`   | Body/paragraph text (slate-700)                                       |
| `neutral.muted`        | `#64748B`   | Secondary/muted text, inactive nav labels (slate-500)                 |
| `neutral.faint`        | `#94A3B8`   | Placeholder text, disabled text, tertiary info (slate-400)            |
| `neutral.line`         | `#E2E8F0`   | Card borders, dividers, separator lines (slate-200)                   |
| `neutral.lineFaint`    | `#F1F5F9`   | Very faint dividers inside cards (slate-100)                          |
| `success.main`         | `#059669`   | Delivered badges, success states, cleared khata (emerald-600)         |
| `success.light`        | `#ECFDF5`   | Success badge background, advance balance bg (emerald-50)             |
| `success.text`         | `#047857`   | Success text on light bg (emerald-700)                                |
| `warning.main`         | `#D97706`   | Pending badges, overdue indicators (amber-600)                        |
| `warning.light`        | `#FEF3C7`   | Warning badge bg, pending khata bg (amber-50)                         |
| `warning.text`         | `#B45309`   | Warning text on light bg (amber-700)                                  |
| `warning.dark`         | `#92400E`   | Dark amber for high-emphasis warnings (amber-800)                     |
| `error.main`           | `#DC2626`   | Error states, skip/destructive actions, dues indicators (rose-600)    |
| `error.light`          | `#FEF2F2`   | Error badge bg, due balance bg, debit entry bg (rose-50)              |
| `error.text`           | `#B91C1C`   | Error/due text on light bg (rose-700)                                 |

### 1.2 Typography

English font: **Poppins** (Google Fonts)  
Urdu font: **Noto Nastaliq Urdu** (Google Fonts)

| Level       | EN Size | EN Weight | EN Letter-Spacing | Line Height | Urdu Size | Urdu Weight |
|-------------|---------|-----------|-------------------|-------------|-----------|-------------|
| **Display** | 28px    | 700       | -0.02em           | 34px        | 30px      | 700         |
| **Heading** | 18px    | 700       | -0.01em           | 24px        | 20px      | 700         |
| **Subhead** | 16px    | 600       | 0                 | 22px        | 18px      | 600         |
| **Body**    | 14px    | 400       | 0                 | 20px        | 16px      | 400         |
| **Caption** | 11px    | 700       | 0.06em            | 14px        | 13px      | 700         |

Additional text styles used in screens (derived from the 5 levels above):

| Style Name        | Size  | Weight | Spacing   | Usage                                          |
|-------------------|-------|--------|-----------|-------------------------------------------------|
| `displayMetric`   | 28px  | 700    | -0.02em   | Big KPI numbers (Rs. 42,650)                   |
| `headlineLg`      | 22px  | 700    | -0.01em   | Screen titles when extra prominence needed      |
| `bodyLg`          | 16px  | 400    | 0         | Larger body text                                |
| `bodySm`          | 13px  | 500    | 0         | Secondary descriptions, small card text         |
| `labelLg`         | 14px  | 600    | 0.01em    | Button labels, emphasized inline text           |
| `labelMd`         | 12px  | 700    | 0.04em    | Small labels, badge text, uppercase labels      |
| `labelSm`         | 11px  | 700    | 0.06em    | Tiny badges, status pills, uppercase tags       |

**Numeric formatting rule**: All monetary values (Rs.) and volume values (L) must use `tabular-nums` / mono-spaced digit alignment to prevent jitter in lists and steppers.

### 1.3 Spacing Scale

All spacing is on a 4px baseline grid.

| Token          | Value  | px   | Usage                                      |
|----------------|--------|------|--------------------------------------------|
| `space2xs`     | 0.25rem| 4px  | Tightest gaps (inline icon-to-text)        |
| `spaceXs`      | 0.5rem | 8px  | Small gaps (badge padding, chip padding)   |
| `spaceSm`      | 0.75rem| 12px | Card gap, between card sections            |
| `spaceMd`      | 1rem   | 16px | Screen gutter, standard section spacing    |
| `spaceLg`      | 1.25rem| 20px | Card internal padding, generous gaps       |
| `spaceXl`      | 1.5rem | 24px | Large section spacing                      |
| `space2xl`     | 2rem   | 32px | Major section breaks                       |
| `space3xl`     | 2.5rem | 40px | Top-of-page spacing                        |
| `screenGutter` | 1rem   | 16px | Horizontal page margin (left + right)      |
| `cardGap`      | 0.75rem| 12px | Vertical gap between list cards            |
| `targetMin`    | 3rem   | 48px | Minimum tap target size                    |

### 1.4 Corner Radius

| Token         | Value  | Usage                                             |
|---------------|--------|---------------------------------------------------|
| `radiusSm`    | 4px    | Small internal elements                           |
| `radiusMd`    | 8px    | Default radius                                    |
| `radiusLg`    | 12px   | Buttons, input fields, medium cards               |
| `radiusXl`    | 16px   | Primary cards, nav items, icon containers         |
| `radius2xl`   | 20px   | Bottom sheets top corners                         |
| `radius3xl`   | 24px   | Modal dialogs, hero banners                       |
| `radiusFull`  | 9999px | Pills, badges, filter chips, circular buttons     |

Specific element radii:
- **Cards**: 16px (`radiusXl`)
- **Buttons (Primary CTA)**: 16px (`radiusXl`)
- **Filter chips**: 9999px (`radiusFull`)
- **Status badges**: 9999px (`radiusFull`)
- **Text fields**: 16px (`radiusXl`)
- **Bottom sheets**: 20px top-left/top-right (`radius2xl`)
- **Dialogs**: 24px (`radius3xl`)
- **Icon containers**: 16px (`radiusXl`) for square, 9999px for circular
- **Bottom nav items (active)**: 16px (`radiusXl`)

### 1.5 Elevation & Shadows

| Level | Token          | CSS / Flutter Value                                          | Usage                         |
|-------|----------------|--------------------------------------------------------------|-------------------------------|
| 0     | `shadowNone`   | None                                                         | Flat scaffold background      |
| 1     | `shadowSoft`   | `0 4px 12px rgba(0, 0, 0, 0.035)`                          | Cards, metric tiles, inputs   |
| 2     | `shadowMedium` | `0 6px 16px rgba(0, 0, 0, 0.06)`                           | Hover/pressed cards, FABs     |
| 3     | `shadowHeavy`  | `0 -4px 16px rgba(0, 0, 0, 0.03)`                          | Bottom nav, sticky bars       |

All cards use 1px border `#E2E8F0` + `shadowSoft`. No opaque drop shadows.

### 1.6 Icon Style

- **Package**: `material_symbols_icons` (pub.dev) — maps to Google Material Symbols
- **Style**: Outlined (FILL = 0)
- **Weight**: 400 (default, matching wght 400 in the HTML)
- **Optical size**: 24px
- **Grade**: 0
- Standard icon sizes: 24px (navigation), 20px (card actions), 18px (inline small), 16px (badge inline)
- All interactive icon containers: minimum 48x48px tap target (`targetMin`)

### 1.7 Component Styling Notes

**Cards (Level 1 Surface)**:
- Background: `#FFFFFF`
- Border: 1px solid `#E2E8F0`
- Shadow: `shadowSoft`
- Corner radius: 16px
- Padding: 16px (standard), 20px (hero/summary cards)

**Bottom Sheets**:
- Background: `#FFFFFF`
- Top corner radius: 20px
- Drag handle: 40px wide x 4px tall, centered, color `#E2E8F0`, 8px top margin
- Shadow: `shadowMedium`
- Content padding: 16px horizontal, 16px bottom + safe area

**Dropdowns / Pickers**:
- Same styling as text fields (below)
- Trailing chevron icon (`expand_more`), 20px, color `#64748B`
- Dropdown menu: white card with `shadowMedium`, 12px radius, 8px vertical padding

**Dialogs**:
- Background: `#FFFFFF`
- Corner radius: 24px
- Padding: 24px
- Shadow: `shadowMedium`
- Title: Subhead (16px/600), color `#0F172A`
- Body: Body (14px/400), color `#334155`
- Buttons: right-aligned, Primary + text-only cancel

**Text Fields**:
- Background: `#F8F9FA` (scaffold)
- Border: none by default, 2px `#1E40AF` on focus
- Corner radius: 16px
- Height: 48px
- Padding: 16px horizontal
- Text: Body (14px/400), color `#0F172A`
- Placeholder: Body (14px/400), color `#94A3B8`
- Label (above): Caption (11px/700), color `#64748B`, uppercase, 0.04em tracking

**Snackbars / Toasts**:
- Background: `#0F172A` (inverse surface)
- Text: Body (14px/400), color `#FFFFFF`
- Corner radius: 12px
- Margin: 16px from edges, positioned above bottom nav
- Action text: `#60A5FA` (brand.primaryLight), 14px/600
- Duration: 3 seconds default, 5 seconds for actions

**Empty States**:
- Centered vertically in available space
- Icon: 48px, outlined, color `#94A3B8`
- Title: Subhead (16px/600), color `#0F172A`, 8px below icon
- Subtitle: Body (14px/400), color `#64748B`, 4px below title
- Optional CTA button: Primary style, 16px below subtitle

**Loading States**:
- Shimmer/skeleton placeholder matching the shape of the content it replaces
- Shimmer base color: `#E2E8F0`, highlight color: `#F1F5F9`
- Animation: 1.5s linear infinite sweep

**RTL Layout Note**: All screens must flip horizontal layout for Urdu. Padding, margins, text alignment, and icon positions must respect `Directionality`. Use `start`/`end` instead of `left`/`right`.

---

## 2. FEATURE INVENTORY

### 2.1 Home Dashboard
1. Store identity header (name, active status badge, date, current shift)
2. Language toggle (EN / Urdu) — switches app locale
3. Settings gear button — navigates to Settings
4. Active shift banner (route name, "Morning Active" pill with pulse animation)
5. "Deliveries >" link button — navigates to Deliveries screen
6. Delivery progress bar with percentage, completed/total counts
7. Remaining + skipped delivery count badges
8. Bento KPI metric grid (2x3):
   - Total Customers (count + active count)
   - Total Dues (Rs. amount + overdue count)
   - Daily Sell (litres + "Morning + Evening Quota" label)
   - Monthly Sell (litres + % change vs last month)
   - Today's Cash (Rs. amount + "Rider & counter inflow" label)
   - Advance Held (Rs. amount + prepaid count)
9. Monthly Collection Total banner (Rs. amount, date range, % of target)
10. Local Counter Sales section:
    - Today's totals (litres sold, Rs. cash)
    - Quick-tap volume buttons (+1L, +2L, +5L) with pre-computed prices
    - "Add Quick Sale (Custom Quantity / Cash)" primary button
    - Last sale entry display with undo capability
11. Delivery Schedule Overview:
    - Morning Shift card (status, departure time, lead driver, done/left/skipped counts)
    - Evening Shift card (status, start time, order count, crate status)
12. Bottom navigation bar (5 tabs: Home, Customers, Deliveries, Payments, Suppliers)

### 2.2 Customers Directory
1. Customer count in screen title
2. Summary statistics bar (Total, With Dues + Rs. amount, On Advance count)
3. Search bar (by name, phone, area)
4. Filter tune button (advanced filter icon)
5. Horizontal filter chips: All, Has Dues, On Advance, Morning Only, Evening Only
6. Customer cards with:
   - Initials avatar (2-letter, colored background)
   - Name + status badge (Active / Inactive-Paused)
   - Phone number with call icon
   - Daily quota (AM/PM litres)
   - Agreed rate per litre
   - Financial balance (Due in red / Advance in green)
7. Per-customer contextual actions:
   - "Record Payment" button (shown when customer has dues)
   - "Add Recharge" button (shown when customer is on advance)
   - "Ledger >" navigation button
   - "Resume Supply" button (shown for paused customers)
   - "History >" for paused customers
8. Call button (direct phone dial)
9. Chat/message button (for inactive customers)
10. Floating action button: "+ Add Customer"
11. Paused customer visual treatment (dimmed opacity, gray avatar, pause icon)

### 2.3 Customer Detail & Ledger
1. Back navigation button
2. Edit Profile button
3. Call button (top bar)
4. Customer profile card:
   - Person icon avatar (large, circular)
   - Name + route badge (e.g. "Daily Route #04")
   - Phone number
   - Address with location icon
5. Delivery Preference section:
   - Morning/Evening quantities
   - Rate per litre
6. Financial summary grid (2 cards):
   - Current Due (Rs. amount, "Payable Balance" label) — rose/red background
   - Advance Balance (Rs. amount, "Prepaid Reserve" label) — blue background
7. Action buttons: Record Payment, Add Advance Topup, Share Bill
8. Tab navigation (horizontal scroll): Advance Ledger, Delivery History, Payment History, Itemized Bill
9. Advance Ledger tab:
   - "Transactions & Ledger" header with month label
   - Chronological entries, each showing:
     - Type icon (delivery/payment/advance/settlement) with colored circular bg
     - Title (e.g. "Morning Delivery 2.5L", "Cash Payment Received", "Advance Topup")
     - Date/time + context info (receipt #, transfer type, route)
     - Running balance note ("Dues after charge: Rs. X Due")
     - Amount with +/- and type badge (Debit/Paid/Credit/Cleared)
10. Sticky bottom bar: Total Payable Dues amount + "Collect Payment" button

### 2.4 Today's Deliveries
1. Date selector (previous/next day arrows, calendar icon, "Today, DD MMM" label)
2. Shift selector (Morning AM / Evening PM segmented control with counts)
3. Search bar (customer, phone, house #)
4. "Mark All" bulk action button
5. Filter chips: All, Pending, Delivered, Skipped (with counts)
6. Delivery cards in 4 states:
   - **Pending**: sequence badge, name, address, product pill (volume + type), rate, total, due amount badge, quantity stepper (+/-), Skip button (X), "Deliver & Collect Cash" primary button
   - **Delivered**: dimmed card, strikethrough name, checkmark Delivered badge, product + time, "Paid Cash Rs. X" success pill
   - **Skipped**: skip reason info bar, "Undo" button
   - **Advance Deduct**: advance balance shown, "Deliver X L (Deduct from Advance)" button
7. Sticky operational summary banner (above bottom nav):
   - Remaining deliveries count + total litres left
   - "Route Map" button (icon + label)

### 2.5 Payments & Accounts
1. Store header with date, "Payments & Accounts" subtitle
2. Language toggle, month/date selector dropdown ("Oct 2024")
3. KPI metric grid (2x2):
   - Today's Inflow (Rs. amount, Cash + Raast breakdown)
   - Cash in Hand (Rs. amount, "Counter verified" note)
   - Customer Dues (Rs. amount, overdue count, "Action" badge)
   - Dairy Payables (Rs. amount, supplier names)
4. "+ Record Payment In / Out" full-width primary CTA
5. WhatsApp Reminders section:
   - "WhatsApp Reminders" header with pending count badge + chevron
   - Overdue customer card (name, days overdue badge, address, pending khata Rs.)
   - "Send Reminder" outline button + "+ Log Cash Received" filled button
6. Filter chips: All, Collections, Payables (with counts + colored dots)
7. "Today's Transactions & Ledgers" section header + "LIVE SYNC" indicator
8. Transaction cards with 4 types:
   - **Customer Collection**: customer name, "Cleared" badge, +Rs. amount, time, payment method (Cash), address + rider, clearing note
   - **Advance Deposit**: customer name, "Advance" badge, +Rs. amount, time, "Raast/Bank", Raast reference #, "Auto-Created" tag
   - **Supplier Outflow**: supplier name, "Supplier Outflow" red badge, -Rs. amount, time, "Cash Voucher", batch details, signed voucher # + receiver, "View Slip" link
   - **Counter Retail**: "Counter Walk-in Cash", "Daily Retail" badge, +Rs. amount, time range, aggregated description, customer count, "Tally Matched" status

### 2.6 Suppliers & Procurement
1. Store header with date, shift label
2. Language toggle, settings/tune button
3. Shift/Date selector card (AM/PM segmented, date picker with arrows)
4. "Live Shift" animated badge
5. KPI metric grid (2x2):
   - Total Milk Inward (litres + trend vs yesterday)
   - Avg FAT Quality (% + standard label)
   - Avg LR Density (CLR value + purity pass badge)
   - Today's Payable (Rs. amount + avg rate)
6. "+ Record Inward Milk" full-width primary button
7. "Suppliers & Milk Batches" section header + farm count badge
8. Filter chips: All, Pending Khata, Recorded, Awaiting (with counts)
9. Supplier cards in 3 states:
   - **Tested & Recorded**: name, route/milk type, call+chat buttons, "Tested & Recorded" badge, logged time, quality metrics grid (QTY, FAT%, LR, RATE/L), batch value, pending khata row (amber) or cleared khata row (green), "Pay Cash" + "View Khata" buttons (or "Daily Slips" + "View Khata" if cleared)
   - **Awaiting Drop**: amber-tinted card, ETA badge, expected quantity, "Batch In Transit" info bar (driver distance), "Quick Call" + "Log Drop" buttons
10. Floating action button: "+ Log Supply"

### 2.7 Settings (user-confirmed, no prototype screen)
1. Settings shell with navigation list
2. Store Profile sub-page (name, phone, address)
3. Products & Pricing sub-page (CRUD list of milk/product types with default rates)
4. Shifts & Routes sub-page (Morning/Evening shift config, route CRUD)
5. Drivers sub-page (CRUD list of drivers)

### 2.8 Cross-Cutting Features
1. Language switching (EN/Urdu) with RTL layout
2. Offline-first data persistence (sqflite)
3. Bottom navigation (persistent across all main screens)
4. Phone dialing (url_launcher)
5. WhatsApp deep-link for reminders (url_launcher)
6. Pull-to-refresh on list screens
7. Sync-ready data fields (id, updatedAt, syncStatus) on all models

---

## 3. DATA MODELS

All models include these sync-friendly base fields:
- `id` — `String` (UUID v4, generated on creation, primary key)
- `createdAt` — `DateTime` (set once on creation, non-null)
- `updatedAt` — `DateTime` (updated on every modification, non-null)
- `syncStatus` — `int` (0 = synced, 1 = pending_upload, 2 = pending_update, 3 = pending_delete; default 1)

### 3.1 Product

| Field              | Type     | Constraints                        |
|--------------------|----------|------------------------------------|
| `name`             | `String` | Required, non-empty                |
| `description`      | `String` | Optional, nullable                 |
| `defaultRatePerLitre` | `double` | Required, > 0                   |
| `isActive`         | `bool`   | Required, default `true`           |

**References**: None (root entity)

### 3.2 Route

| Field     | Type     | Constraints              |
|-----------|----------|--------------------------|
| `name`    | `String` | Required, non-empty      |
| `area`    | `String` | Optional, nullable       |
| `isActive`| `bool`   | Required, default `true` |

**References**: None (root entity)

### 3.3 Driver

| Field     | Type     | Constraints              |
|-----------|----------|--------------------------|
| `name`    | `String` | Required, non-empty      |
| `phone`   | `String` | Optional, nullable       |
| `isActive`| `bool`   | Required, default `true` |

**References**: None (root entity)

### 3.4 StoreProfile

| Field     | Type     | Constraints              |
|-----------|----------|--------------------------|
| `name`    | `String` | Required, non-empty      |
| `phone`   | `String` | Optional, nullable       |
| `address` | `String` | Optional, nullable       |

**References**: None (singleton entity — only one row ever exists)

### 3.5 Shift

| Field          | Type     | Constraints                                |
|----------------|----------|--------------------------------------------|
| `name`         | `String` | Required, one of: "Morning", "Evening"     |
| `startTime`    | `String` | Required, HH:mm format (e.g. "05:30")     |
| `endTime`      | `String` | Required, HH:mm format (e.g. "12:00")     |
| `leadDriverId` | `String` | Optional, nullable, FK -> Driver.id        |
| `isActive`     | `bool`   | Required, default `true`                   |

**References**: Driver (optional)

### 3.6 Customer

| Field                | Type       | Constraints                                      |
|----------------------|------------|--------------------------------------------------|
| `name`               | `String`   | Required, non-empty                              |
| `phone`              | `String`   | Required, non-empty                              |
| `address`            | `String`   | Optional, nullable                               |
| `area`               | `String`   | Optional, nullable                               |
| `routeId`            | `String`   | Optional, nullable, FK -> Route.id               |
| `deliverySequence`   | `int`      | Required, default 0, >= 0                        |
| `preferredShift`     | `String`   | Required, one of: "morning", "evening", "both"   |
| `dailyQuotaAm`      | `double`   | Required, default 0.0, >= 0                      |
| `dailyQuotaPm`      | `double`   | Required, default 0.0, >= 0                      |
| `productId`          | `String`   | Optional, nullable, FK -> Product.id             |
| `agreedRatePerLitre` | `double`   | Required, > 0                                    |
| `status`             | `String`   | Required, one of: "active", "paused", "inactive" |
| `pausedSince`        | `DateTime` | Optional, nullable (set when status -> paused)   |
| `notes`              | `String`   | Optional, nullable                               |
| `currentDue`         | `double`   | Required, default 0.0 (positive = owes money)    |
| `advanceBalance`     | `double`   | Required, default 0.0, >= 0                      |
| `lastReminderSent`   | `DateTime` | Optional, nullable                               |

**References**: Product (optional), Route (optional)

### 3.7 Delivery

| Field               | Type       | Constraints                                          |
|---------------------|------------|------------------------------------------------------|
| `customerId`        | `String`   | Required, FK -> Customer.id                          |
| `date`              | `DateTime` | Required (date only, no time)                        |
| `shift`             | `String`   | Required, one of: "morning", "evening"               |
| `productId`         | `String`   | Optional, nullable, FK -> Product.id                 |
| `productName`       | `String`   | Required (denormalized for display)                  |
| `scheduledQuantity` | `double`   | Required, > 0                                        |
| `deliveredQuantity` | `double`   | Required, default 0.0, >= 0                         |
| `ratePerLitre`      | `double`   | Required, > 0                                        |
| `totalAmount`       | `double`   | Required, computed: deliveredQuantity x ratePerLitre |
| `status`            | `String`   | Required, one of: "pending", "delivered", "skipped"  |
| `skipReason`        | `String`   | Optional, nullable (required if status = skipped)    |
| `paymentMethod`     | `String`   | Optional, one of: "cash", "advance_deduction", "credit", null |
| `amountCollected`   | `double`   | Required, default 0.0, >= 0                         |
| `deliveryTime`      | `DateTime` | Optional, nullable (set when delivered)              |
| `sequenceNumber`    | `int`      | Required, >= 1                                       |

**References**: Customer, Product (optional)

### 3.8 Payment

| Field           | Type       | Constraints                                                            |
|-----------------|------------|------------------------------------------------------------------------|
| `customerId`    | `String`   | Required, FK -> Customer.id                                           |
| `date`          | `DateTime` | Required                                                               |
| `amount`        | `double`   | Required, > 0                                                          |
| `type`          | `String`   | Required, one of: "cash_payment", "advance_topup", "advance_deduction", "auto_settlement" |
| `method`        | `String`   | Required, one of: "cash", "raast", "bank_transfer"                    |
| `receiptNumber` | `String`   | Optional, nullable (auto-generated or manual)                          |
| `raastRef`      | `String`   | Optional, nullable (e.g. "#PK-RAAST-B92147")                         |
| `notes`         | `String`   | Optional, nullable                                                     |
| `runningBalance`| `double`   | Required (customer's due balance after this transaction)               |
| `riderName`     | `String`   | Optional, nullable (who collected)                                     |

**References**: Customer

### 3.9 Supplier

| Field           | Type     | Constraints              |
|-----------------|----------|--------------------------|
| `name`          | `String` | Required, non-empty      |
| `location`      | `String` | Optional, nullable       |
| `description`   | `String` | Optional, nullable       |
| `milkType`      | `String` | Optional, nullable       |
| `phone`         | `String` | Optional, nullable       |
| `isActive`      | `bool`   | Required, default `true` |
| `pendingKhata`  | `double` | Required, default 0.0, >= 0 |

**References**: None (root entity)

### 3.10 MilkCollection

| Field            | Type       | Constraints                                      |
|------------------|------------|--------------------------------------------------|
| `supplierId`     | `String`   | Required, FK -> Supplier.id                      |
| `date`           | `DateTime` | Required                                          |
| `shift`          | `String`   | Required, one of: "morning", "evening"            |
| `quantityLitres` | `double`   | Required, > 0                                     |
| `fatPercentage`  | `double`   | Required, > 0 (e.g. 6.5)                         |
| `lrDensity`      | `double`   | Required, > 0 (e.g. 29.0)                        |
| `ratePerLitre`   | `double`   | Required, > 0                                     |
| `batchValue`     | `double`   | Required, computed: quantityLitres x ratePerLitre |
| `status`         | `String`   | Required, one of: "awaiting", "recorded", "tested"|
| `loggedTime`     | `DateTime` | Optional, nullable                                |
| `notes`          | `String`   | Optional, nullable                                |

**References**: Supplier

### 3.11 SupplierPayment

| Field          | Type       | Constraints                                |
|----------------|------------|--------------------------------------------|
| `supplierId`   | `String`   | Required, FK -> Supplier.id               |
| `date`         | `DateTime` | Required                                   |
| `amount`       | `double`   | Required, > 0                              |
| `type`         | `String`   | Required, one of: "cash_payment", "bank_transfer", "settlement" |
| `voucherNumber`| `String`   | Optional, nullable                         |
| `receivedBy`   | `String`   | Optional, nullable (driver/person name)    |
| `notes`        | `String`   | Optional, nullable                         |

**References**: Supplier

### 3.12 LocalSale

| Field            | Type       | Constraints                                      |
|------------------|------------|--------------------------------------------------|
| `date`           | `DateTime` | Required                                          |
| `quantityLitres` | `double`   | Required, > 0                                     |
| `productId`      | `String`   | Optional, nullable, FK -> Product.id              |
| `productName`    | `String`   | Required (denormalized, e.g. "Buffalo Milk")      |
| `ratePerLitre`   | `double`   | Required, > 0                                     |
| `totalAmount`    | `double`   | Required, computed: quantityLitres x ratePerLitre |

**References**: Product (optional)

### 3.13 Model Dependency Graph

```
Product <-- Customer --> Route
               ^
          Delivery --> Product
          Payment

Supplier <-- MilkCollection
         <-- SupplierPayment

Product <-- LocalSale

Driver <-- Shift

StoreProfile (independent)
```

---

## 4. STATE MANAGEMENT PLAN

**Recommended architecture: Riverpod (with code generation)**

**Justification**: This app has complex inter-model reactive relationships — marking a delivery "delivered" must simultaneously update the Customer's due balance, the Payment ledger, and the Dashboard aggregations. Riverpod's provider graph automatically propagates state changes through dependent providers (e.g. a `deliveryListProvider` that depends on `customerProvider` will auto-rebuild when customer data changes). Its `AsyncValue` type naturally handles loading/error/data states for every database query, and its `family` modifier allows parameterized providers (e.g. `customerDeliveriesProvider(customerId)`). The code generation variant (`@riverpod` annotations) reduces boilerplate and ensures compile-time safety. Compared to BLoC (which would require excessive event/state boilerplate for 13 entities) or Provider (which lacks the reactive dependency graph), Riverpod is the best fit for this app's complexity.

**Architecture layers**:
1. **Models** (`lib/models/`) — Immutable data classes with `fromMap` / `toMap` serialization for sqflite
2. **Repositories** (`lib/repositories/`) — sqflite CRUD operations per entity, pure data access
3. **Providers** (`lib/providers/`) — Riverpod providers wrapping repositories, exposing reactive state
4. **Screens** (`lib/screens/`) — Flutter widgets consuming providers, zero business logic
5. **Widgets** (`lib/widgets/`) — Reusable Design System components, stateless where possible

**Local database**: `sqflite` with a single `AppDatabase` helper managing schema, migrations, and table creation.

---

## 5. SCREEN-TO-DATA MAP

| Screen                        | Reads                                                                          | Writes / Modifies                                                    |
|-------------------------------|--------------------------------------------------------------------------------|----------------------------------------------------------------------|
| Home Dashboard                | Customer (count, active), Delivery (today's progress), Payment (today's cash, monthly total), LocalSale (today's total), Shift, StoreProfile | LocalSale (quick sale), LocalSale (undo last) |
| Customers Directory           | Customer (all, filtered), Product (for display)                                | — (navigation only)                                                  |
| Add/Edit Customer Sheet       | Product (dropdown), Route (dropdown)                                           | Customer (create / update)                                           |
| Customer Detail & Profile     | Customer (single), Payment (summary), Delivery (summary)                       | —                                                                    |
| Customer Ledger (all tabs)    | Payment (by customer), Delivery (by customer)                                  | Payment (record payment, add advance topup)                          |
| Today's Deliveries            | Delivery (by date+shift), Customer (for display), Product (for display)        | Delivery (mark delivered, skip, adjust qty), Payment (auto-create on deliver), Customer (update due/advance) |
| Payments & Accounts           | Payment (today), SupplierPayment (today), LocalSale (today), Customer (overdue dues) | Payment (record in/out), SupplierPayment (record)                   |
| Suppliers & Procurement       | Supplier (all), MilkCollection (today by supplier)                             | —                                                                    |
| Record Inward Milk Sheet      | Supplier (dropdown)                                                            | MilkCollection (create), Supplier (update pendingKhata)              |
| Supplier Khata                | Supplier (single), MilkCollection (by supplier), SupplierPayment (by supplier) | SupplierPayment (pay cash)                                           |
| Settings - Store Profile      | StoreProfile                                                                   | StoreProfile                                                         |
| Settings - Products & Pricing | Product (all)                                                                  | Product (CRUD)                                                       |
| Settings - Shifts & Routes    | Shift (all), Route (all), Driver (for dropdown)                                | Shift (CRUD), Route (CRUD)                                           |
| Settings - Drivers            | Driver (all)                                                                   | Driver (CRUD)                                                        |

---

## 6. DESIGN SYSTEM COMPONENTS

Reusable UI components to build in Phase B (all reference Section 1 for styling):

| Component          | Description                                                                                                   |
|--------------------|---------------------------------------------------------------------------------------------------------------|
| `AppCard`          | White card wrapper: `#FFFFFF` bg, 1px `#E2E8F0` border, `shadowSoft`, 16px radius, configurable padding      |
| `MetricCard`       | KPI tile: icon container (32x32, 16px radius, colored bg), label, large metric value, subtitle/badge          |
| `StatusBadge`      | Pill badge: 9999px radius, configurable bg/text color, 11px/700 text, 10px h-padding, 2px v-padding          |
| `FilterChipBar`    | Horizontal scrollable row of pill chips: active=`#1E40AF` bg/white text, inactive=white bg/`#334155` text    |
| `SearchBar`        | Text input: `#F8F9FA` bg, 16px radius, 48px height, leading search icon, optional trailing filter button     |
| `QuantityStepper`  | Pill: decrement(-) + value label + increment(+), 32x32 buttons, `#F8F9FA` bg bar, 16px radius               |
| `BottomNavBar`     | 5-tab fixed bar: 64px + safe area, `#FFFFFF` bg, active=`#EFF6FF` pill bg + `#1E40AF` icon/text              |
| `AppButton`        | 3 variants: Primary(`#1E40AF` bg, white text), Secondary(`#EFF6FF` bg, `#1E40AF` text), Destructive(`#FEF2F2` bg, `#DC2626` text). All 48px height, 16px radius, 14px/600 label |
| `AppBottomSheet`   | Modal sheet wrapper: white bg, 20px top radius, drag handle, configurable content                            |
| `AppDialog`        | Confirmation dialog: white bg, 24px radius, title + body + action buttons                                    |
| `AppTextField`     | Form input: `#F8F9FA` bg, 16px radius, 48px height, optional label/prefix/suffix, focus ring `#1E40AF`      |
| `AppDropdown`      | Select input: same style as TextField, trailing chevron, opens bottom sheet picker on mobile                  |
| `AppSnackBar`      | Toast: `#0F172A` bg, white text, 12px radius, optional action button                                        |
| `EmptyState`       | Centered: 48px icon + title + subtitle + optional CTA                                                        |
| `LoadingState`     | Shimmer skeleton placeholder matching content shape                                                          |
| `DateSelector`     | Pill: left arrow + calendar icon + date label + right arrow, `#FFFFFF` bg, `shadowSoft`                      |
| `ShiftSelector`    | Segmented control: 2 segments (AM/PM), active=`#1E40AF` bg/white text, inactive=transparent/`#64748B`       |
| `LanguageToggle`   | Pill: EN/Urdu, active segment=`#EFF6FF` bg/`#1E40AF` text, 11px/500, `#FFFFFF` outer bg                     |

---

## 7. MILESTONE DETAIL REQUIREMENT — Template

Every milestone below uses this exact template:

```
### [Phase]-M[N]: [Title]
- **Goal**: [one sentence]
- **Depends on**: [milestone IDs or "none"]
- **Exact scope**: [file paths]
- **Full field/detail list**: [every field, element, or value]
- **Behavior/logic details**: [rules, calculations, edge cases, validation]
- **Out of scope**: [what this milestone must NOT touch]
- **Localization requirement** (Phase C only): [ARB keys in both languages]
- **Definition of done**: [checklist]
```

---

## 8. MILESTONE BREAKDOWN

---

### PHASE A — Data & Logic (no UI)

---

### A-M1: Project Scaffolding & Database Setup    **Status:** ✅ Done 

- **Goal**: Create the Flutter project skeleton, install all dependencies, and set up the sqflite database helper with schema versioning.
- **Depends on**: none
- **Exact scope**:
  - Create Flutter project (if not existing) at workspace root
  - `pubspec.yaml` — add dependencies
  - `lib/main.dart` — minimal app entry
  - `lib/app.dart` — MaterialApp shell with Riverpod ProviderScope
  - `lib/core/database/app_database.dart` — singleton database helper
  - `lib/core/database/database_constants.dart` — table names, column names
  - `lib/core/utils/id_generator.dart` — UUID v4 generation utility
  - `lib/repositories/base_repository.dart` — abstract base with common CRUD
- **Full field/detail list**:
  - Dependencies: `flutter_riverpod` ^2.5.x, `riverpod_annotation` ^2.3.x, `sqflite` ^2.3.x, `path_provider` ^2.1.x, `uuid` ^4.x, `intl` ^0.19.x, `url_launcher` ^6.2.x, `flutter_localizations` (SDK), `google_fonts` ^6.x, `material_symbols_icons` ^4.x, `shimmer` ^3.x
  - Dev dependencies: `riverpod_generator` ^2.4.x, `build_runner` ^2.4.x, `riverpod_lint` ^2.3.x, `flutter_lints` ^3.x
  - `AppDatabase` class: private constructor, static `instance` getter, `_initDb()` opens/creates DB at `al_madina_dairy.db`, `onCreate` creates all 12 tables (empty at this milestone — tables added per subsequent model milestone), `onUpgrade` with version tracking
  - `BaseRepository<T>`: abstract class with `tableName`, `fromMap(Map)->T`, `toMap(T)->Map`, `getAll()`, `getById(String id)`, `insert(T)`, `update(T)`, `delete(String id)` — all using `AppDatabase.instance`
  - `IdGenerator.generate()`: returns `uuid.v4()` string
- **Behavior/logic details**:
  - Database version starts at 1
  - All timestamps stored as ISO 8601 strings in SQLite
  - `syncStatus` stored as integer (0-3)
  - `bool` fields stored as integer (0/1) in SQLite
  - `BaseRepository.insert()` must set `createdAt` and `updatedAt` to `DateTime.now()` if not already set
  - `BaseRepository.update()` must always overwrite `updatedAt` to `DateTime.now()` and set `syncStatus` to 2 (pending_update) if currently 0 (synced)
  - `BaseRepository.delete()` performs a hard delete for now (Phase D will change to soft delete)
- **Out of scope**: Any UI, any specific model table creation (done in subsequent milestones), Firebase, localization setup
- **Definition of done**:
  - `flutter analyze` reports zero errors/warnings
  - `AppDatabase.instance.database` returns a valid `Database` object
  - `BaseRepository` can be subclassed without errors
  - `IdGenerator.generate()` returns unique 36-char UUID strings
  - App launches without crashing (blank screen is expected)

---

### A-M2: Product Model + Repository + Provider  **Status:** ✅ Done 

- **Goal**: Implement the Product data model, its SQLite table, repository, and Riverpod provider for managing milk product types.
- **Depends on**: A-M1
- **Exact scope**:
  - `lib/models/product.dart`
  - `lib/repositories/product_repository.dart`
  - `lib/providers/product_provider.dart`
  - Modify `lib/core/database/app_database.dart` — add `products` table creation
- **Full field/detail list**:
  - Table `products`: columns `id TEXT PRIMARY KEY`, `name TEXT NOT NULL`, `description TEXT`, `defaultRatePerLitre REAL NOT NULL`, `isActive INTEGER NOT NULL DEFAULT 1`, `createdAt TEXT NOT NULL`, `updatedAt TEXT NOT NULL`, `syncStatus INTEGER NOT NULL DEFAULT 1`
  - `Product` class: immutable with `const` constructor, all fields from Section 3.1 + base fields, `copyWith()`, `fromMap(Map<String, dynamic>)` factory, `toMap()` method, `==` and `hashCode` overrides
  - `ProductRepository extends BaseRepository<Product>`: `tableName = 'products'`, `getActiveProducts()` returns only `isActive = 1` sorted by `name ASC`
  - `productListProvider`: `FutureProvider<List<Product>>` fetches all active products
  - `productRepositoryProvider`: `Provider<ProductRepository>` singleton instance
- **Behavior/logic details**:
  - `defaultRatePerLitre` must be > 0; the repository `insert()` should validate this and throw `ArgumentError` if violated
  - `name` must be non-empty; throw `ArgumentError` if empty string
  - Default seed data: on first app launch (when table is empty), insert 4 products: "Cow Milk (Pure)" Rs.200/L, "Buffalo Milk" Rs.200/L, "Special Cow Milk" Rs.200/L, "Cow & Buffalo Blend" Rs.168/L (prices from delivery screen)
  - `isActive` soft-delete: setting to false hides from dropdowns but preserves historical records
- **Out of scope**: UI, Customer or Delivery models, pricing rules, quantity management
- **Definition of done**:
  - `flutter analyze` clean
  - Can programmatically: insert a Product, retrieve it by ID, update its name, list all active products, soft-delete (set `isActive=false`) and confirm it's excluded from `getActiveProducts()`
  - Seed data appears on fresh database creation
  - All fields serialize/deserialize correctly to/from Map

---

### A-M3: Route Model + Repository + Provider **Status:** ✅ Done 

- **Goal**: Implement the Route data model for organizing customers by delivery area/route.
- **Depends on**: A-M1
- **Exact scope**:
  - `lib/models/route_model.dart` (named `route_model.dart` to avoid conflict with Flutter's `Route`)
  - `lib/repositories/route_repository.dart`
  - `lib/providers/route_provider.dart`
  - Modify `lib/core/database/app_database.dart` — add `routes` table creation
- **Full field/detail list**:
  - Table `routes`: `id TEXT PRIMARY KEY`, `name TEXT NOT NULL`, `area TEXT`, `isActive INTEGER NOT NULL DEFAULT 1`, `createdAt TEXT NOT NULL`, `updatedAt TEXT NOT NULL`, `syncStatus INTEGER NOT NULL DEFAULT 1`
  - `DeliveryRoute` class (named to avoid conflict): immutable, `copyWith()`, `fromMap()`, `toMap()`, `==`, `hashCode`
  - `RouteRepository extends BaseRepository<DeliveryRoute>`: `getActiveRoutes()` sorted by `name ASC`
  - `routeListProvider`: `FutureProvider<List<DeliveryRoute>>`
  - `routeRepositoryProvider`: `Provider<RouteRepository>`
- **Behavior/logic details**:
  - `name` must be non-empty
  - Default seed: insert 1 route: "Route A - Civil Lines" with area "Civil Lines"
  - Routes can be deactivated but not deleted if customers reference them
- **Out of scope**: Customer assignment to routes, map/geo features, delivery ordering
- **Definition of done**:
  - `flutter analyze` clean
  - CRUD operations work: insert, getById, getActiveRoutes, update, soft-delete
  - Seed data present on fresh DB

---

### A-M4: Driver Model + Repository + Provider **Status:** ✅ Done 

- **Goal**: Implement the Driver data model for tracking delivery personnel.
- **Depends on**: A-M1
- **Exact scope**:
  - `lib/models/driver.dart`
  - `lib/repositories/driver_repository.dart`
  - `lib/providers/driver_provider.dart`
  - Modify `lib/core/database/app_database.dart` — add `drivers` table
- **Full field/detail list**:
  - Table `drivers`: `id TEXT PRIMARY KEY`, `name TEXT NOT NULL`, `phone TEXT`, `isActive INTEGER NOT NULL DEFAULT 1`, `createdAt TEXT NOT NULL`, `updatedAt TEXT NOT NULL`, `syncStatus INTEGER NOT NULL DEFAULT 1`
  - `Driver` class: immutable, `copyWith()`, `fromMap()`, `toMap()`
  - `DriverRepository`: `getActiveDrivers()` sorted by `name ASC`
  - `driverListProvider`, `driverRepositoryProvider`
- **Behavior/logic details**:
  - `name` must be non-empty
  - `phone` is optional but if provided should be non-empty
  - Default seed: insert 1 driver: "Rashid" (from dashboard screen)
- **Out of scope**: Shift assignment, delivery tracking per driver, GPS
- **Definition of done**:
  - `flutter analyze` clean
  - CRUD operations verified programmatically
  - Seed data present

---

### A-M5: StoreProfile Model + Repository + Provider **Status:** ✅ Done 

- **Goal**: Implement the StoreProfile singleton model for the dairy shop's own information.
- **Depends on**: A-M1
- **Exact scope**:
  - `lib/models/store_profile.dart`
  - `lib/repositories/store_profile_repository.dart`
  - `lib/providers/store_profile_provider.dart`
  - Modify `lib/core/database/app_database.dart` — add `store_profile` table
- **Full field/detail list**:
  - Table `store_profile`: `id TEXT PRIMARY KEY`, `name TEXT NOT NULL`, `phone TEXT`, `address TEXT`, `createdAt TEXT NOT NULL`, `updatedAt TEXT NOT NULL`, `syncStatus INTEGER NOT NULL DEFAULT 1`
  - `StoreProfile` class: immutable, `copyWith()`, `fromMap()`, `toMap()`
  - `StoreProfileRepository`: `getProfile()` returns the single row or null, `upsertProfile(StoreProfile)` inserts if none exists, updates otherwise
  - `storeProfileProvider`: `FutureProvider<StoreProfile?>`
- **Behavior/logic details**:
  - Only one row should ever exist in this table
  - `upsertProfile()`: check if any row exists — if yes, update; if no, insert
  - Default seed: insert profile "Al-Madina Dairy" (from screen headers)
- **Out of scope**: Logo/image, multi-store support, Firebase auth user linkage
- **Definition of done**:
  - `flutter analyze` clean
  - Can create, read, and update the single store profile
  - Attempting to insert a second profile overwrites the first
  - Seed data present

---

### A-M6: Shift Model + Repository + Provider **Status:** ✅ Done 

- **Goal**: Implement the Shift model for managing morning/evening delivery shift configurations.
- **Depends on**: A-M1, A-M4 (Driver)
- **Exact scope**:
  - `lib/models/shift.dart`
  - `lib/repositories/shift_repository.dart`
  - `lib/providers/shift_provider.dart`
  - Modify `lib/core/database/app_database.dart` — add `shifts` table
- **Full field/detail list**:
  - Table `shifts`: `id TEXT PRIMARY KEY`, `name TEXT NOT NULL`, `startTime TEXT NOT NULL`, `endTime TEXT NOT NULL`, `leadDriverId TEXT`, `isActive INTEGER NOT NULL DEFAULT 1`, `createdAt TEXT NOT NULL`, `updatedAt TEXT NOT NULL`, `syncStatus INTEGER NOT NULL DEFAULT 1`, `FOREIGN KEY (leadDriverId) REFERENCES drivers(id)`
  - `Shift` class: immutable, `copyWith()`, `fromMap()`, `toMap()`
  - `ShiftRepository`: `getActiveShifts()`, `getShiftByName(String name)`
  - `shiftListProvider`, `shiftRepositoryProvider`
- **Behavior/logic details**:
  - `name` restricted to "Morning" or "Evening"
  - `startTime`/`endTime` validated as HH:mm format
  - `leadDriverId` is a FK to drivers table; if driver is deleted, this should be set to null
  - Default seed: "Morning" (05:30-12:00, leadDriver=Rashid's ID), "Evening" (16:30-20:00, no lead driver)
- **Out of scope**: Multi-route shifts, shift scheduling calendar, driver assignment UI
- **Definition of done**:
  - `flutter analyze` clean
  - CRUD verified, FK to Driver resolves correctly
  - `getShiftByName("Morning")` returns the morning shift
  - Seed data present

---

### A-M7: Customer Model + Repository + Provider **Status:** ✅ Done 

- **Goal**: Implement the Customer data model with all profile, delivery preference, and financial balance fields.
- **Depends on**: A-M1, A-M2 (Product), A-M3 (Route)
- **Exact scope**:
  - `lib/models/customer.dart`
  - `lib/repositories/customer_repository.dart`
  - `lib/providers/customer_provider.dart`
  - Modify `lib/core/database/app_database.dart` — add `customers` table
- **Full field/detail list**:
  - Table `customers`: `id TEXT PRIMARY KEY`, `name TEXT NOT NULL`, `phone TEXT NOT NULL`, `address TEXT`, `area TEXT`, `routeId TEXT`, `deliverySequence INTEGER NOT NULL DEFAULT 0`, `preferredShift TEXT NOT NULL DEFAULT 'morning'`, `dailyQuotaAm REAL NOT NULL DEFAULT 0.0`, `dailyQuotaPm REAL NOT NULL DEFAULT 0.0`, `productId TEXT`, `agreedRatePerLitre REAL NOT NULL`, `status TEXT NOT NULL DEFAULT 'active'`, `pausedSince TEXT`, `notes TEXT`, `currentDue REAL NOT NULL DEFAULT 0.0`, `advanceBalance REAL NOT NULL DEFAULT 0.0`, `lastReminderSent TEXT`, `createdAt TEXT NOT NULL`, `updatedAt TEXT NOT NULL`, `syncStatus INTEGER NOT NULL DEFAULT 1`, `FOREIGN KEY (productId) REFERENCES products(id)`, `FOREIGN KEY (routeId) REFERENCES routes(id)`
  - `Customer` class: immutable, all fields from Section 3.6 + base fields, `copyWith()`, `fromMap()`, `toMap()`, computed getter `initials` (first letter of first two name words, e.g. "Tariq Mehmood" -> "TM"), computed getter `hasOutstandingDues` (`currentDue > 0`), computed getter `isOnAdvance` (`advanceBalance > 0`), computed getter `totalDailyQuota` (`dailyQuotaAm + dailyQuotaPm`)
  - `CustomerRepository`: `getActiveCustomers()`, `getCustomersWithDues()` (currentDue > 0), `getCustomersOnAdvance()` (advanceBalance > 0), `getCustomersByShift(String shift)` (filters by preferredShift = shift or "both"), `searchCustomers(String query)` (LIKE on name, phone, address, area), `getCustomersByRoute(String routeId)`, `updateBalance(String id, double newDue, double newAdvance)` (updates only financial fields + updatedAt), `getOverdueCustomers()` (currentDue > 0, sorted by currentDue DESC)
  - `customerListProvider`: `FutureProvider<List<Customer>>` all active
  - `customerByIdProvider(String id)`: `FutureProvider.family<Customer?, String>`
  - `customerSearchProvider(String query)`: `FutureProvider.family`
  - `customerRepositoryProvider`
  - `customerStatsProvider`: `FutureProvider` returning `({int total, int active, int withDues, double totalDues, int onAdvance})`
- **Behavior/logic details**:
  - `name` and `phone` must be non-empty
  - `agreedRatePerLitre` must be > 0
  - `dailyQuotaAm` and `dailyQuotaPm` must be >= 0
  - `status` must be one of: "active", "paused", "inactive"
  - When `status` changes to "paused", `pausedSince` is auto-set to `DateTime.now()`; when changed back to "active", `pausedSince` is set to null
  - `currentDue` can be positive (owes money) or zero; it should never go negative — excess payments go to `advanceBalance`
  - `advanceBalance` is always >= 0
  - `initials`: take first character of first word + first character of second word; if single-word name, use first two characters; always uppercase
  - Search is case-insensitive using SQLite `LOWER()` function
  - Default seed: insert 4 customers matching the prototype screens (Tariq Mehmood, Zubair Ansari, Malik Kamran paused, Bilal Ahmed)
- **Out of scope**: Delivery creation, payment recording, ledger entries — those are separate model milestones. No UI.
- **Definition of done**:
  - `flutter analyze` clean
  - Full CRUD works; all query methods return correct filtered results
  - `initials` computed correctly for 1-word and 2+ word names
  - Balance update method works correctly
  - Search returns matching results for name, phone, and area
  - Seed data present with 4 customers

---

### A-M8: Supplier Model + Repository + Provider  **Status:** ✅ Done 

- **Goal**: Implement the Supplier data model for dairy farm suppliers.
- **Depends on**: A-M1
- **Exact scope**:
  - `lib/models/supplier.dart`
  - `lib/repositories/supplier_repository.dart`
  - `lib/providers/supplier_provider.dart`
  - Modify `lib/core/database/app_database.dart` — add `suppliers` table
- **Full field/detail list**:
  - Table `suppliers`: `id TEXT PRIMARY KEY`, `name TEXT NOT NULL`, `location TEXT`, `description TEXT`, `milkType TEXT`, `phone TEXT`, `isActive INTEGER NOT NULL DEFAULT 1`, `pendingKhata REAL NOT NULL DEFAULT 0.0`, `createdAt TEXT NOT NULL`, `updatedAt TEXT NOT NULL`, `syncStatus INTEGER NOT NULL DEFAULT 1`
  - `Supplier` class: immutable, `copyWith()`, `fromMap()`, `toMap()`, computed getter `hasKhataPending` (`pendingKhata > 0`)
  - `SupplierRepository`: `getActiveSuppliers()`, `getSuppliersWithPendingKhata()`, `updateKhata(String id, double amount)` adjusts pendingKhata
  - `supplierListProvider`, `supplierByIdProvider`, `supplierRepositoryProvider`
- **Behavior/logic details**:
  - `name` must be non-empty
  - `pendingKhata` is always >= 0
  - Default seed: 4 suppliers from screen (Haji Bashir Dairy Farm, Tariq Gujjar, Ghulam Rasool Cattle, Malik Farm Vehari)
- **Out of scope**: MilkCollection, SupplierPayment, quality testing, batch tracking
- **Definition of done**:
  - `flutter analyze` clean
  - CRUD verified; khata update works; seed data present

---

### A-M9: Delivery Model + Repository + Provider **Status:** ✅ Done 

- **Goal**: Implement the Delivery data model for daily milk delivery records with status tracking.
- **Depends on**: A-M1, A-M7 (Customer), A-M2 (Product)
- **Exact scope**:
  - `lib/models/delivery.dart`
  - `lib/repositories/delivery_repository.dart`
  - `lib/providers/delivery_provider.dart`
  - Modify `lib/core/database/app_database.dart` — add `deliveries` table
- **Full field/detail list**:
  - Table `deliveries`: `id TEXT PRIMARY KEY`, `customerId TEXT NOT NULL`, `date TEXT NOT NULL`, `shift TEXT NOT NULL`, `productId TEXT`, `productName TEXT NOT NULL`, `scheduledQuantity REAL NOT NULL`, `deliveredQuantity REAL NOT NULL DEFAULT 0.0`, `ratePerLitre REAL NOT NULL`, `totalAmount REAL NOT NULL DEFAULT 0.0`, `status TEXT NOT NULL DEFAULT 'pending'`, `skipReason TEXT`, `paymentMethod TEXT`, `amountCollected REAL NOT NULL DEFAULT 0.0`, `deliveryTime TEXT`, `sequenceNumber INTEGER NOT NULL`, `createdAt TEXT NOT NULL`, `updatedAt TEXT NOT NULL`, `syncStatus INTEGER NOT NULL DEFAULT 1`, `FOREIGN KEY (customerId) REFERENCES customers(id)`, `FOREIGN KEY (productId) REFERENCES products(id)`
  - `Delivery` class: immutable, all fields, `copyWith()`, `fromMap()`, `toMap()`, computed getters: `isPending` (`status == 'pending'`), `isDelivered` (`status == 'delivered'`), `isSkipped` (`status == 'skipped'`)
  - `DeliveryRepository`: `getDeliveriesByDate(DateTime date)`, `getDeliveriesByDateAndShift(DateTime date, String shift)`, `getDeliveriesByCustomer(String customerId)`, `getDeliveriesByCustomerAndDateRange(String customerId, DateTime start, DateTime end)`, `markDelivered(String id, double quantity, String paymentMethod, double amountCollected)`, `markSkipped(String id, String reason)`, `undoSkip(String id)` (reverts to pending), `adjustQuantity(String id, double newQuantity)`, `generateDailyDeliveries(DateTime date, String shift, List<Customer> customers)` (creates pending deliveries for all active customers matching that shift), `getDeliveryStats(DateTime date, String shift)` returns `({int total, int delivered, int pending, int skipped, double totalLitresDelivered, double totalLitresRemaining, double totalCashCollected})`
  - Providers: `deliveryListProvider(DateTime date, String shift)` family, `deliveryStatsProvider(DateTime date, String shift)` family, `customerDeliveryHistoryProvider(String customerId)` family, `deliveryRepositoryProvider`
- **Behavior/logic details**:
  - `scheduledQuantity` must be > 0
  - `ratePerLitre` must be > 0
  - `totalAmount` = `deliveredQuantity x ratePerLitre`, recalculated on quantity change
  - When `markDelivered()` is called: set `status = 'delivered'`, `deliveredQuantity` to the provided quantity, `deliveryTime` to now, recalculate `totalAmount`, and update the Customer's `currentDue` or `advanceBalance` accordingly:
    - If `paymentMethod = 'cash'`: customer's due unchanged (paid on spot)
    - If `paymentMethod = 'credit'`: customer's `currentDue += totalAmount`
    - If `paymentMethod = 'advance_deduction'`: customer's `advanceBalance -= totalAmount`; if advance < totalAmount, remainder goes to `currentDue`
  - When `markSkipped()`: `skipReason` is required; customer balance is NOT affected
  - When `undoSkip()`: only works if current status is 'skipped'; reverts to 'pending', clears skipReason
  - `generateDailyDeliveries()`: for each active customer with quota > 0 for the given shift, create one Delivery record with the customer's `agreedRatePerLitre`, `productId`, `productName`, and scheduled quantity from their AM/PM quota; `sequenceNumber` from customer's `deliverySequence`; skip customers with `status != 'active'`
  - `adjustQuantity()`: only works if status is 'pending'; updates `scheduledQuantity`
  - Date comparisons use date-only (ignore time component)
- **Out of scope**: UI, payment recording (that's A-M10), route optimization, delivery ordering algorithm
- **Definition of done**:
  - `flutter analyze` clean
  - Can generate deliveries for a date/shift from seeded customers
  - Can mark delivered (cash, credit, advance_deduction) and verify customer balance updates
  - Can skip with reason and undo skip
  - Can adjust quantity on pending delivery
  - Stats provider returns correct counts
  - Date-based filtering works correctly

---

### A-M10: Payment Model + Repository + Provider **Status:** ✅ Done

- **Goal**: Implement the Payment data model for tracking all customer financial transactions (cash payments, advance topups, advance deductions, auto-settlements).
- **Depends on**: A-M1, A-M7 (Customer)
- **Exact scope**:
  - `lib/models/payment.dart`
  - `lib/repositories/payment_repository.dart`
  - `lib/providers/payment_provider.dart`
  - Modify `lib/core/database/app_database.dart` — add `payments` table
- **Full field/detail list**:
  - Table `payments`: `id TEXT PRIMARY KEY`, `customerId TEXT NOT NULL`, `date TEXT NOT NULL`, `amount REAL NOT NULL`, `type TEXT NOT NULL`, `method TEXT NOT NULL`, `receiptNumber TEXT`, `raastRef TEXT`, `notes TEXT`, `runningBalance REAL NOT NULL`, `riderName TEXT`, `createdAt TEXT NOT NULL`, `updatedAt TEXT NOT NULL`, `syncStatus INTEGER NOT NULL DEFAULT 1`, `FOREIGN KEY (customerId) REFERENCES customers(id)`
  - `Payment` class: immutable, all fields, `copyWith()`, `fromMap()`, `toMap()`, computed getters: `isInflow` (type is cash_payment or advance_topup), `isOutflow` (type is advance_deduction), `typeLabel` (human-readable "Cash Payment", "Advance Topup", etc.), `displayAmount` (prefixed with +/- based on type)
  - `PaymentRepository`: `getPaymentsByCustomer(String customerId)` sorted by date DESC, `getPaymentsByDate(DateTime date)`, `getPaymentsByDateRange(DateTime start, DateTime end)`, `getTodayCashTotal(DateTime date)` (sum of cash_payment amounts), `getMonthlyCollectionTotal(int year, int month)`, `recordCashPayment(String customerId, double amount, String method, {String? riderName, String? raastRef})` (creates payment + updates customer's currentDue), `recordAdvanceTopup(String customerId, double amount, String method, {String? raastRef})` (creates payment + updates customer's advanceBalance), `autoSettleFromAdvance(String customerId, double dueAmount)` (if customer has advance >= dueAmount, create auto_settlement payment + adjust both currentDue and advanceBalance)
  - Providers: `paymentListByCustomerProvider(String customerId)` family, `todayPaymentsProvider(DateTime date)` family, `todayCashTotalProvider`, `monthlyCollectionProvider(int year, int month)` family, `paymentRepositoryProvider`
- **Behavior/logic details**:
  - `amount` must be > 0
  - `type` must be one of: "cash_payment", "advance_topup", "advance_deduction", "auto_settlement"
  - `method` must be one of: "cash", "raast", "bank_transfer"
  - `receiptNumber`: auto-generated as "REC-{timestamp_millis}" if not provided
  - `runningBalance`: calculated as customer's `currentDue` AFTER this transaction is applied
  - `recordCashPayment()`: reduces customer's `currentDue` by `amount`; if `currentDue` goes below 0, the excess is added to `advanceBalance` and `currentDue` set to 0
  - `recordAdvanceTopup()`: increases customer's `advanceBalance` by `amount`; then if customer has `currentDue > 0`, auto-settle: reduce `currentDue` from `advanceBalance` (creating an auto_settlement payment record)
  - `autoSettleFromAdvance()`: only runs if `advanceBalance >= dueAmount`; reduces `advanceBalance` by dueAmount, reduces `currentDue` by dueAmount
  - All balance-modifying operations must be transactional (use `db.transaction()`)
- **Out of scope**: UI, supplier payments, local sales, WhatsApp reminders
- **Definition of done**:
  - `flutter analyze` clean
  - Can record cash payment and verify customer due reduced
  - Can record advance topup and verify auto-settlement triggers when customer has existing dues
  - Running balance calculated correctly
  - Receipt numbers auto-generated
  - Monthly and daily totals calculated correctly
  - Transaction atomicity: if balance update fails, payment record is rolled back

---

### A-M11: MilkCollection Model + Repository + Provider **Status:** ✅ Done

- **Goal**: Implement the MilkCollection data model for recording inward milk batches from suppliers with quality metrics.
- **Depends on**: A-M1, A-M8 (Supplier)
- **Exact scope**:
  - `lib/models/milk_collection.dart`
  - `lib/repositories/milk_collection_repository.dart`
  - `lib/providers/milk_collection_provider.dart`
  - Modify `lib/core/database/app_database.dart` — add `milk_collections` table
- **Full field/detail list**:
  - Table `milk_collections`: `id TEXT PRIMARY KEY`, `supplierId TEXT NOT NULL`, `date TEXT NOT NULL`, `shift TEXT NOT NULL`, `quantityLitres REAL NOT NULL`, `fatPercentage REAL NOT NULL`, `lrDensity REAL NOT NULL`, `ratePerLitre REAL NOT NULL`, `batchValue REAL NOT NULL`, `status TEXT NOT NULL DEFAULT 'recorded'`, `loggedTime TEXT`, `notes TEXT`, `createdAt TEXT NOT NULL`, `updatedAt TEXT NOT NULL`, `syncStatus INTEGER NOT NULL DEFAULT 1`, `FOREIGN KEY (supplierId) REFERENCES suppliers(id)`
  - `MilkCollection` class: immutable, all fields, `copyWith()`, `fromMap()`, `toMap()`
  - `MilkCollectionRepository`: `getCollectionsByDate(DateTime date)`, `getCollectionsBySupplier(String supplierId)`, `getCollectionsByDateAndShift(DateTime date, String shift)`, `getDailyStats(DateTime date)` returns `({double totalLitres, double avgFat, double avgLr, double totalPayable, double avgRate})`, `recordCollection(MilkCollection collection)` (inserts + updates supplier's pendingKhata += batchValue)
  - Providers: `milkCollectionListProvider(DateTime date)` family, `milkCollectionStatsProvider(DateTime date)` family, `supplierCollectionsProvider(String supplierId)` family
- **Behavior/logic details**:
  - `quantityLitres`, `fatPercentage`, `lrDensity`, `ratePerLitre` must all be > 0
  - `batchValue` = `quantityLitres x ratePerLitre`, calculated on insert
  - `recordCollection()` must also increase the supplier's `pendingKhata` by `batchValue` (transactional)
  - `avgFat` and `avgLr` in stats are weighted averages by quantity (not simple averages)
  - `status` values: "awaiting" (expected but not arrived), "recorded" (arrived and logged), "tested" (quality tested)
- **Out of scope**: UI, quality testing forms, lab integration, supplier payments
- **Definition of done**:
  - `flutter analyze` clean
  - Can record a collection and verify supplier's `pendingKhata` increases
  - Daily stats calculate correct weighted averages
  - Batch value auto-calculated

---

### A-M12: SupplierPayment Model + Repository + Provider **Status:** ✅ Done

- **Goal**: Implement the SupplierPayment model for tracking payments made TO suppliers (khata clearing).
- **Depends on**: A-M1, A-M8 (Supplier)
- **Exact scope**:
  - `lib/models/supplier_payment.dart`
  - `lib/repositories/supplier_payment_repository.dart`
  - `lib/providers/supplier_payment_provider.dart`
  - Modify `lib/core/database/app_database.dart` — add `supplier_payments` table
- **Full field/detail list**:
  - Table `supplier_payments`: `id TEXT PRIMARY KEY`, `supplierId TEXT NOT NULL`, `date TEXT NOT NULL`, `amount REAL NOT NULL`, `type TEXT NOT NULL`, `voucherNumber TEXT`, `receivedBy TEXT`, `notes TEXT`, `createdAt TEXT NOT NULL`, `updatedAt TEXT NOT NULL`, `syncStatus INTEGER NOT NULL DEFAULT 1`, `FOREIGN KEY (supplierId) REFERENCES suppliers(id)`
  - `SupplierPayment` class: immutable, all fields, `copyWith()`, `fromMap()`, `toMap()`
  - `SupplierPaymentRepository`: `getPaymentsBySupplier(String supplierId)`, `getPaymentsByDate(DateTime date)`, `recordPayment(SupplierPayment payment)` (inserts + decreases supplier's pendingKhata), `getTotalPaidToday(DateTime date)`
  - Providers: `supplierPaymentListProvider(String supplierId)` family, `todaySupplierPaymentsProvider(DateTime date)` family
- **Behavior/logic details**:
  - `amount` must be > 0
  - `type` one of: "cash_payment", "bank_transfer", "settlement"
  - `recordPayment()`: must decrease supplier's `pendingKhata` by `amount`; if `pendingKhata` would go below 0, cap at 0 (transactional)
  - `voucherNumber`: auto-generated as "VCH-{sequential_number}" if not provided (e.g. "VCH-402")
- **Out of scope**: UI, milk collections, supplier profiles
- **Definition of done**:
  - `flutter analyze` clean
  - Can record payment and verify supplier khata decreases
  - Voucher numbers auto-generated
  - Payment list by supplier sorted by date DESC

---

### A-M13: LocalSale Model + Repository + Provider **Status:** ✅ Done

- **Goal**: Implement the LocalSale data model for walk-in counter milk sales.
- **Depends on**: A-M1, A-M2 (Product)
- **Exact scope**:
  - `lib/models/local_sale.dart`
  - `lib/repositories/local_sale_repository.dart`
  - `lib/providers/local_sale_provider.dart`
  - Modify `lib/core/database/app_database.dart` — add `local_sales` table
- **Full field/detail list**:
  - Table `local_sales`: `id TEXT PRIMARY KEY`, `date TEXT NOT NULL`, `quantityLitres REAL NOT NULL`, `productId TEXT`, `productName TEXT NOT NULL`, `ratePerLitre REAL NOT NULL`, `totalAmount REAL NOT NULL`, `createdAt TEXT NOT NULL`, `updatedAt TEXT NOT NULL`, `syncStatus INTEGER NOT NULL DEFAULT 1`, `FOREIGN KEY (productId) REFERENCES products(id)`
  - `LocalSale` class: immutable, all fields, `copyWith()`, `fromMap()`, `toMap()`
  - `LocalSaleRepository`: `getSalesByDate(DateTime date)`, `getTodayTotals(DateTime date)` returns `({double totalLitres, double totalAmount, int saleCount})`, `getLastSale()` (most recent sale by createdAt), `deleteLastSale()` (deletes the most recent sale — undo), `addQuickSale(double litres, String productName, double ratePerLitre, {String? productId})`
  - Providers: `todayLocalSalesProvider`, `todayLocalSaleTotalsProvider`, `lastLocalSaleProvider`, `localSaleRepositoryProvider`
- **Behavior/logic details**:
  - `quantityLitres` must be > 0
  - `ratePerLitre` must be > 0
  - `totalAmount` = `quantityLitres x ratePerLitre`, calculated on insert
  - `addQuickSale()`: sets `date` to today, auto-calculates total
  - `deleteLastSale()`: only deletes the single most recent sale — if no sales exist, no-op
  - Quick sale presets from dashboard: 1L/Rs.200, 2L/Rs.400, 5L/Rs.1000 (using default buffalo milk rate)
- **Out of scope**: UI, receipt printing, inventory management, yogurt product types
- **Definition of done**:
  - `flutter analyze` clean
  - Can add quick sales and verify totals
  - `getLastSale()` returns the most recent entry
  - `deleteLastSale()` removes only the last entry
  - Today's totals correctly sum litres and amounts

---

### A-M14: Dashboard Aggregation Service  **Status:** ✅ Done

- **Goal**: Create a centralized provider that computes all dashboard KPI metrics from underlying data sources.
- **Depends on**: A-M7 (Customer), A-M9 (Delivery), A-M10 (Payment), A-M11 (MilkCollection), A-M13 (LocalSale), A-M6 (Shift)
- **Exact scope**:
  - `lib/providers/dashboard_provider.dart`
- **Full field/detail list**:
  - `DashboardData` class (immutable):
    - `totalCustomers` (int), `activeCustomers` (int), `totalDues` (double, sum of all customers' currentDue), `overdueCount` (int, customers with currentDue > 0), `dailySellLitres` (double, today's total delivered litres AM+PM), `monthlySellLitres` (double, current month total delivered litres), `monthlyGrowthPercent` (double, % change vs previous month), `todayCash` (double, sum of today's cash payments + local sales), `advanceHeld` (double, sum of all customers' advanceBalance), `prepaidCount` (int, customers with advanceBalance > 0), `monthlyCollectionTotal` (double, current month total payments received), `monthlyTarget` (double, estimated based on daily average x days in month), `monthlyTargetPercent` (double), `deliveryProgress` (`({int total, int completed, int remaining, int skipped, double percent})`), `activeShiftName` (String, Morning/Evening based on current time), `activeRouteName` (String)
  - `dashboardProvider`: `FutureProvider<DashboardData>` that aggregates from all repositories
- **Behavior/logic details**:
  - `activeShiftName`: if current time < 14:00, show "Morning"; else "Evening"
  - `monthlyGrowthPercent`: compare current month's litres to previous month's; if previous = 0, show 0%
  - `todayCash`: sum of Payment.amount where date=today AND (type=cash_payment), PLUS LocalSale.totalAmount where date=today
  - `deliveryProgress`: from today's deliveries for the active shift
  - All calculations use the current date (`DateTime.now()`)
  - If any sub-query fails, the dashboard should still load with zeros for the failed section (graceful degradation)
- **Out of scope**: UI rendering, historical dashboard data, charts/graphs, caching
- **Definition of done**:
  - `flutter analyze` clean
  - With seeded data, all dashboard metrics return plausible non-zero values
  - With empty database, all metrics return 0 without errors
  - Shift detection works correctly based on time of day

---

### PHASE B — Design System Components (placeholder data only)

Every milestone in Phase B must strictly follow the Design System section (Section 1) — no new colors, font sizes, spacing values, corner radii, or icon styles outside what is documented there.

---

### B-M1: App Theme & Design Tokens  **Status:** ✅ Done
- **Goal**: Create the Flutter ThemeData, color scheme, text theme, and spacing constants that encode every value from Section 1.
- **Depends on**: A-M1
- **Exact scope**: `lib/core/theme/app_colors.dart`, `lib/core/theme/app_typography.dart`, `lib/core/theme/app_spacing.dart`, `lib/core/theme/app_shadows.dart`, `lib/core/theme/app_theme.dart`, `lib/core/l10n/app_en.arb`, `lib/core/l10n/app_ur.arb`, `l10n.yaml`, modify `pubspec.yaml` (enable `generate: true`), modify `lib/app.dart` (apply theme + localization delegates)
- **Full field/detail list**: `AppColors` (static const for every color in 1.1), `AppTypography` (TextStyles for all 5 levels + derived, Poppins EN + Noto Nastaliq UR), `AppSpacing` (all spacing tokens from 1.3), `AppShadows` (BoxShadow for each elevation from 1.5), `AppTheme.lightTheme` (ThemeData with cardTheme 16px, inputDecoration scaffold bg, bottomSheet 20px, dialog 24px, snackBar), ARB files with `@@locale` key, l10n.yaml config
- **Behavior/logic details**: Theme supports RTL font switching. All numeric TextStyles include `fontFeatures: [FontFeature.tabularFigures()]`. Does NOT use Material 3 dynamic color.
- **Out of scope**: Any widgets, screens, dark theme, actual ARB string entries (added in Phase C)
- **Definition of done**: `flutter analyze` clean, app launches with custom theme (bg `#F8F9FA`), `AppColors.brandPrimary == Color(0xFF1E40AF)`, Poppins renders, localization delegates configured

---

### B-M2: AppCard  **Status:** ✅ Done
- **Goal**: Build a reusable card wrapper matching Level 1 surface styling.
- **Depends on**: B-M1
- **Exact scope**: `lib/widgets/app_card.dart`
- **Full field/detail list**: Props: `child`, `padding` (default 16px), `margin`, `onTap`, `borderColor` (default `#E2E8F0`), `borderRadius` (default 16px), `elevation` (0/1/2). Container with white bg, border, shadow, rounded corners. If tappable: InkWell + scale 0.99 animation on press.
- **Behavior/logic details**: Shadow from Section 1.5, scale animation 100ms `AnimatedScale`.
- **Out of scope**: MetricCard, data binding
- **Definition of done**: `flutter analyze` clean, renders white card with correct shadow/border/radius, tap works

---

### B-M3: MetricCard  **Status:** ✅ Done
- **Goal**: Build a reusable KPI metric tile for Dashboard and Suppliers bento grids.
- **Depends on**: B-M1, B-M2
- **Exact scope**: `lib/widgets/metric_card.dart`
- **Full field/detail list**: Props: `label`, `value`, `valueSuffix`, `valuePrefix`, `subtitle`, `subtitleColor`, `icon`, `iconBgColor` (default `#EFF6FF`), `iconColor` (default `#1E40AF`), `onTap`. Layout: AppCard with label (13px/w500/`#64748B`) + icon container (32x32, 16px radius) top row, value (24px/w600/`#0F172A`) with prefix/suffix, optional subtitle.
- **Behavior/logic details**: Tabular figures for values. Icon container 32x32 with 16px radius.
- **Out of scope**: Data fetching, dashboard layout
- **Definition of done**: `flutter analyze` clean, renders with all prop combinations

---

### B-M4: StatusBadge  **Status:** ✅ Done
- **Goal**: Build a pill-shaped status badge with preset factories for all app states.
- **Depends on**: B-M1
- **Exact scope**: `lib/widgets/status_badge.dart`
- **Full field/detail list**: Props: `label`, `backgroundColor`, `textColor`, `icon`, `iconSize` (14px). Pill container 9999px radius, 10px h-padding, 2px v-padding, text 11px/w700/0.06em. Factory constructors: `.active()` (bg `#ECFDF5`, text `#047857`), `.pending()` (bg `#FEF3C7`, text `#B45309`), `.delivered()` (bg `#ECFDF5`, text `#047857`, icon done), `.skipped()` (bg `#FEF2F2`, text `#DC2626`), `.paused()` (bg `#F1F5F9`, text `#64748B`), `.overdue({days})` (bg `#FEF2F2`, text `#DC2626`), `.cleared()` (bg `#ECFDF5`, text `#047857`, icon done), `.advance()` (bg `#EFF6FF`, text `#1E40AF`), `.supplierOutflow()` (bg `#FEF2F2`, text `#DC2626`), `.dailyRetail()` (bg `#FEF3C7`, text `#92400E`)
- **Behavior/logic details**: Uses exact colors from Section 1.1 per preset.
- **Out of scope**: Interactive chips, data binding
- **Definition of done**: `flutter analyze` clean, all presets render correctly, custom colors work

---

### B-M5: FilterChipBar  **Status:** ✅ Done
- **Goal**: Build horizontal scrollable filter pills with single-select behavior.
- **Depends on**: B-M1
- **Exact scope**: `lib/widgets/filter_chip_bar.dart`
- **Full field/detail list**: Props: `chips` (List of FilterChipData with label, count, dotColor), `selectedIndex`, `onSelected`. Active chip: bg `#1E40AF`, text white, 12px/w600, shadow. Inactive: bg white, text `#334155`, 12px/w500. 9999px radius, 16px h-padding, 6px v-padding, 8px gaps.
- **Behavior/logic details**: Single select, auto-scroll to active chip, 48px min tap target.
- **Out of scope**: Multi-select, chip removal
- **Definition of done**: `flutter analyze` clean, scrollable, active/inactive states, tap callback works

---

### B-M6: SearchBar  **Status:** ✅ Done
- **Goal**: Build search input with optional trailing filter button.
- **Depends on**: B-M1
- **Exact scope**: `lib/widgets/app_search_bar.dart`
- **Full field/detail list**: Props: `hintText`, `onChanged`, `onFilterTap`, `controller`. Field: bg `#F8F9FA`, 16px radius, 48px height, search icon 20px `#94A3B8`, hint 14px/w400 `#94A3B8`, text 14px/w400 `#0F172A`, focus ring 2px `#1E40AF`. Filter button: 48x48, bg `#F8F9FA`, 16px radius, tune icon 20px `#64748B`.
- **Behavior/logic details**: 300ms debounce on `onChanged`. Clear button when text non-empty.
- **Out of scope**: Filter bottom sheet
- **Definition of done**: `flutter analyze` clean, debounced input, clear button, optional filter button

---

### B-M7: QuantityStepper **Status:** ✅ Done
- **Goal**: Build quantity adjustment stepper (-/value/+).
- **Depends on**: B-M1
- **Exact scope**: `lib/widgets/quantity_stepper.dart`
- **Full field/detail list**: Props: `value`, `unit` ("L"), `step` (0.5), `min` (0.0), `max` (99.0), `onChanged`. Container bg `#F8F9FA`, 16px radius. Buttons: 32x32, bg white, shadowSoft, 12px radius. Value: 13px/w500 `#0F172A`, 40px width, tabular figures.
- **Behavior/logic details**: Step by 0.5L, min/max bounds, haptic feedback, long-press repeat 200ms.
- **Out of scope**: Price calculation, card integration
- **Definition of done**: `flutter analyze` clean, increment/decrement works, bounds respected, haptic works

---

### B-M8: BottomNavBar
- **Goal**: Build 5-tab bottom navigation bar.
- **Depends on**: B-M1
- **Exact scope**: `lib/widgets/bottom_nav_bar.dart`
- **Full field/detail list**: Props: `currentIndex`, `onTap`. 5 tabs: Home (storefront), Customers (group), Deliveries (local_shipping), Payments (payments), Suppliers (inventory_2). Container: 64px + safe area, white bg 95% opacity + blur 12px, top border `#F1F5F9`. Active: `#EFF6FF` pill bg + `#1E40AF` icon/label. Inactive: `#64748B` icon/label. Icons 22px, labels 11px.
- **Behavior/logic details**: Smooth 200ms transition, 48px min tap width, works correctly in RTL.
- **Out of scope**: Navigation routing, badges
- **Definition of done**: `flutter analyze` clean, 5 tabs render, active state works, safe area respected

---

### B-M9: AppButton Variants
- **Goal**: Build Primary, Secondary, Destructive buttons plus icon-only button.
- **Depends on**: B-M1
- **Exact scope**: `lib/widgets/app_button.dart`
- **Full field/detail list**: `AppButton` props: `label`, `onPressed`, `variant` (primary/secondary/destructive), `icon`, `isFullWidth`, `isLoading`, `height` (48px). Primary: bg `#1E40AF`, text white, pressed `#1E3A8A`. Secondary: bg `#EFF6FF`, text `#1E40AF`. Destructive: bg `#FEF2F2`, text `#DC2626`. All: 16px radius, 14px/w600, disabled opacity 0.5, loading spinner, scale 0.97 on press. `AppIconButton`: props `icon`, `onPressed`, `backgroundColor`, `iconColor`, `size` (40px), `iconSize` (20px), `borderRadius` (16px).
- **Behavior/logic details**: 48px min tap target, AnimatedScale on press.
- **Out of scope**: Text-only buttons, FABs
- **Definition of done**: `flutter analyze` clean, all variants render, disabled/loading/icon states work

---

### B-M10: AppBottomSheet
- **Goal**: Build modal bottom sheet wrapper with consistent styling.
- **Depends on**: B-M1
- **Exact scope**: `lib/widgets/app_bottom_sheet.dart`
- **Full field/detail list**: Static `show()` method. Sheet: white bg, 20px top radius, max 90% height. Drag handle: 40px x 4px, `#E2E8F0`, 9999px radius, 12px top margin. Optional title: 16px/w600 `#0F172A`, divider. Content: 16px h-padding + bottom safe area. Barrier: black 30%.
- **Behavior/logic details**: `isScrollControlled: true`, dismissible by drag or barrier tap.
- **Out of scope**: Specific form content, persistent sheets
- **Definition of done**: `flutter analyze` clean, opens/dismisses, handle/title work, respects safe area

---

### B-M11: AppDialog
- **Goal**: Build confirmation dialog.
- **Depends on**: B-M1, B-M9
- **Exact scope**: `lib/widgets/app_dialog.dart`
- **Full field/detail list**: Static `showConfirmation()`. Dialog: white bg, 24px radius, 24px padding. Title: 16px/w600 `#0F172A`. Message: 14px/w400 `#334155`. Buttons: cancel text button + confirm AppButton. Returns bool.
- **Behavior/logic details**: Cannot dismiss by tapping outside. `isDestructive` flag shows red confirm.
- **Out of scope**: Form dialogs, custom content
- **Definition of done**: `flutter analyze` clean, returns true/false, destructive variant works

---

### B-M12: AppTextField & AppDropdown
- **Goal**: Build form text input and dropdown selection components.
- **Depends on**: B-M1, B-M10
- **Exact scope**: `lib/widgets/app_text_field.dart`, `lib/widgets/app_dropdown.dart`
- **Full field/detail list**: `AppTextField` props: `label`, `hintText`, `controller`, `onChanged`, `keyboardType`, `prefixIcon`, `suffixIcon`, `suffixText`, `errorText`, `isRequired`, `maxLines`, `textInputAction`. Label: 11px/w700 `#64748B` uppercase. Field: bg `#F8F9FA`, 16px radius, 48px height, text 14px `#0F172A`, hint `#94A3B8`, focus 2px `#1E40AF`, error 2px `#DC2626`. `AppDropdown<T>`: same visual, non-editable, chevron icon, opens bottom sheet picker.
- **Behavior/logic details**: RTL text support. Dropdown selection dismisses sheet.
- **Out of scope**: Date/time pickers, multi-select
- **Definition of done**: `flutter analyze` clean, text input + dropdown render, error state, RTL works

---

### B-M13: AppSnackBar
- **Goal**: Build toast/snackbar notification.
- **Depends on**: B-M1
- **Exact scope**: `lib/widgets/app_snack_bar.dart`
- **Full field/detail list**: Static `show()`. Container: bg `#0F172A` (or `#DC2626` if error), 12px radius, 16px margin. Message: 14px/w400 white. Action: 14px/w600 `#60A5FA`.
- **Behavior/logic details**: Auto-dismiss 3s (5s with action). One at a time. Slide-up entry 200ms.
- **Out of scope**: Persistent, multi-line, rich content
- **Definition of done**: `flutter analyze` clean, appears/dismisses, action works, error variant works

---

### B-M14: EmptyState
- **Goal**: Build centered empty-state placeholder for empty lists.
- **Depends on**: B-M1, B-M9
- **Exact scope**: `lib/widgets/empty_state.dart`
- **Full field/detail list**: Props: `icon`, `title`, `subtitle`, `actionLabel`, `onAction`. Center column: 48px icon `#94A3B8`, title 16px/w600 `#0F172A`, subtitle 14px/w400 `#64748B`, optional secondary AppButton. Max width 280px.
- **Behavior/logic details**: Vertically centered in available space.
- **Out of scope**: Error states, skeleton loading
- **Definition of done**: `flutter analyze` clean, renders centered, action button works

---

### B-M15: LoadingState (Shimmer)
- **Goal**: Build shimmer skeleton loading placeholder.
- **Depends on**: B-M1
- **Exact scope**: `lib/widgets/loading_state.dart`
- **Full field/detail list**: `ShimmerCard` props: `height` (120px), `count` (3). Placeholder rectangles (title 60% width, subtitle 40%, body 80%) with shimmer base `#E2E8F0`, highlight `#F8F9FA`, 1.5s. `ShimmerMetricGrid`: 2x2 grid.
- **Behavior/logic details**: Continuous shimmer animation. 12px gaps between cards.
- **Out of scope**: Content-specific skeletons
- **Definition of done**: `flutter analyze` clean, shimmer animates smoothly

---

### B-M16: DateSelector
- **Goal**: Build date navigation pill with prev/next arrows.
- **Depends on**: B-M1
- **Exact scope**: `lib/widgets/date_selector.dart`
- **Full field/detail list**: Props: `selectedDate`, `onDateChanged`, `showToday`. Container white bg, shadowSoft, 16px radius. Left/right arrows: 28x28, chevron 16px `#94A3B8`. Center: calendar icon 14px `#1E40AF` + date label 12px/w600 `#1E40AF`. Format: "Today, DD MMM" or "Day, DD MMM".
- **Behavior/logic details**: Urdu uses intl ur locale for day/month names. Future dates beyond today+7 disabled.
- **Out of scope**: Calendar picker, date range, month view
- **Definition of done**: `flutter analyze` clean, arrows navigate, "Today" label, future limit works

---

### B-M17: ShiftSelector
- **Goal**: Build AM/PM segmented control.
- **Depends on**: B-M1
- **Exact scope**: `lib/widgets/shift_selector.dart`
- **Full field/detail list**: Props: `selectedShift`, `onShiftChanged`, `morningCount`, `eveningCount`. Container white bg, shadowSoft, 4px padding, 16px outer radius. Active segment: bg `#1E40AF`, white text, 12px radius. Inactive: transparent, `#64748B` text. Morning: wb_sunny + "Morning (AM)" 12px/w600. Evening: nights_stay + "Evening (PM)". Count pill if > 0. Each segment 50% width, 36px height.
- **Behavior/logic details**: Animated transition 200ms. Count badges optional.
- **Out of scope**: Multi-shift, shift config
- **Definition of done**: `flutter analyze` clean, segments render, tap switches, counts display

---

### B-M18: LanguageToggle
- **Goal**: Build EN/Urdu language switching pill.
- **Depends on**: B-M1
- **Exact scope**: `lib/widgets/language_toggle.dart`, `lib/providers/locale_provider.dart`
- **Full field/detail list**: Container white bg, shadowSoft, 4px padding, 16px radius. Active segment: bg `#EFF6FF`, text `#1E40AF`, 12px radius. Inactive: transparent, `#64748B`. EN: "EN" 11px/w500. Urdu: "اردو" 11px/w400. `localeProvider`: StateProvider<Locale> default `Locale('en')`, persisted to SharedPreferences.
- **Behavior/logic details**: Switches between en and ur locale. Full app rebuild on change. Persist via shared_preferences. Add `shared_preferences` dependency.
- **Out of scope**: Translation strings (Phase C), complex locale detection
- **Definition of done**: `flutter analyze` clean, toggle switches locale, RTL applies for Urdu, persists across restart

---

### PHASE C — Screen Wiring (assembly only)

Every milestone in Phase C must strictly follow Section 1, must include both EN and UR ARB keys, and must be verified in RTL layout.

---

### C-M1: App Shell & Routing
- **Goal**: Wire the main app scaffold with bottom navigation, 5 tab routing, and locale-aware MaterialApp.
- **Depends on**: B-M1, B-M8, B-M18
- **Exact scope**: `lib/app.dart`, `lib/screens/app_shell.dart`, `lib/core/routes/app_routes.dart`
- **Full field/detail list**: AppShell with IndexedStack (5 main screens) + AppBottomNavBar. Routes: `/`, `/customer/:id`, `/supplier/:id/khata`, `/settings`, `/settings/profile`, `/settings/products`, `/settings/shifts`, `/settings/drivers`. MaterialApp with localization delegates, supported locales [en, ur], theme from AppTheme.
- **Behavior/logic details**: Tab state preserved via IndexedStack. Deep routes push on current tab navigator. Status bar dark icons.
- **Out of scope**: Individual screen content (placeholders), auth flow
- **Localization**: `navHome`/`navCustomers`/`navDeliveries`/`navPayments`/`navSuppliers` in both languages
- **Definition of done**: `flutter analyze` clean, 5-tab nav works, locale switches, RTL applies, tab state preserved

---

### C-M2: Home Dashboard Screen
- **Goal**: Assemble the complete Home Dashboard connecting all dashboard data to KPI grid, shift banner, local sales, and delivery schedule.
- **Depends on**: C-M1, A-M14, B-M2, B-M3, B-M4, B-M9, B-M18
- **Exact scope**: `lib/screens/home/home_screen.dart`, `lib/screens/home/widgets/shift_banner.dart`, `lib/screens/home/widgets/local_sales_section.dart`, `lib/screens/home/widgets/delivery_schedule_section.dart`
- **Full field/detail list**: Header (store icon+name+status+date+settings+language toggle), Shift Banner (route+active pill+progress bar+remaining+skipped), Bento Grid (6 MetricCards + Monthly Collection), Local Sales (today totals+quick-tap buttons+CTA+last entry+undo), Delivery Schedule (morning+evening shift cards). All styled per Section 1.
- **Behavior/logic details**: KPIs from dashboardProvider. Quick sale creates LocalSale + snackbar. Undo deletes last sale. Pull-to-refresh. Loading shimmer. Graceful empty states.
- **Out of scope**: Custom sale sheet (C-M3), settings screen content
- **Localization**: ~30 ARB keys covering all dashboard text in EN + UR
- **Definition of done**: `flutter analyze` clean, all KPIs render, quick sale works, undo works, shimmer loading, pull-to-refresh, EN+UR+RTL verified

---

### C-M3: Quick Sale Bottom Sheet
- **Goal**: Build the custom quantity/cash sale bottom sheet for walk-in counter sales.
- **Depends on**: C-M2, B-M10, B-M12, B-M9, A-M13
- **Exact scope**: `lib/screens/home/widgets/quick_sale_sheet.dart`
- **Full field/detail list**: Product dropdown, Quantity field (numeric, suffix "L"), Rate field (prefix "Rs.", auto-filled from product), Total display (auto-calculated), Save button.
- **Behavior/logic details**: Total recalculates live. Save creates LocalSale, dismisses, snackbar. Validation: qty>0, rate>0.
- **Out of scope**: Receipt generation, inventory tracking
- **Localization**: `quickSaleTitle`/`milkType`/`quantity`/`ratePerLitre`/`total`/`recordSale`/`saleRecorded` in EN+UR
- **Definition of done**: `flutter analyze` clean, form validates, total auto-calculates, saves correctly, EN+UR verified

---

### C-M4: Customers Directory Screen
- **Goal**: Assemble the customers list with search, filters, and customer cards.
- **Depends on**: C-M1, A-M7, B-M2, B-M4, B-M5, B-M6, B-M9, B-M14
- **Exact scope**: `lib/screens/customers/customers_screen.dart`, `lib/screens/customers/widgets/customer_card.dart`
- **Full field/detail list**: Header (customer count+stats bar), SearchBar, FilterChipBar (All/Has Dues/On Advance/Morning/Evening), Customer cards (initials avatar, name+badge, phone+call, quota grid, financial balance, action buttons), FAB "Add Customer", paused customer dimming.
- **Behavior/logic details**: Search debounced 300ms, filter chips filter list, "Resume Supply" updates status, call button opens dialer, pull-to-refresh, empty state.
- **Out of scope**: Add/Edit form (C-M5), Customer Detail (C-M6)
- **Localization**: ~20 ARB keys for all customer screen text in EN+UR
- **Definition of done**: `flutter analyze` clean, cards render, search+filters work, call opens dialer, FAB visible, EN+UR+RTL verified

---

### C-M5: Add/Edit Customer Bottom Sheet
- **Goal**: Build the customer creation/editing form.
- **Depends on**: C-M4, B-M10, B-M12, B-M9, A-M7, A-M2, A-M3
- **Exact scope**: `lib/screens/customers/widgets/add_customer_sheet.dart`
- **Full field/detail list**: Fields: Name, Phone, Address, Route dropdown, Delivery Sequence, Preferred Shift dropdown, Morning Quota, Evening Quota, Product dropdown, Agreed Rate (auto-fills from product), Notes. Save button.
- **Behavior/logic details**: Validation (name+phone required, rate>0, at least one quota>0). Product selection auto-fills rate. Edit mode pre-populates. Snackbar on save.
- **Out of scope**: Customer deletion, profile photo
- **Localization**: ~15 ARB keys for form labels and messages in EN+UR
- **Definition of done**: `flutter analyze` clean, add+edit modes work, validation prevents bad data, EN+UR+RTL verified

---

### C-M6: Customer Detail & Profile Screen
- **Goal**: Build the customer detail screen with profile, financial summary, and action buttons.
- **Depends on**: C-M1, A-M7, A-M10, B-M2, B-M4, B-M9
- **Exact scope**: `lib/screens/customers/customer_detail_screen.dart`
- **Full field/detail list**: AppBar (back+edit+call), Profile card (avatar+name+route badge+phone+address), Delivery Preference box, Financial grid (Current Due red + Advance Balance blue), Action buttons (Record Payment+Add Advance+Share Bill), Tab bar (4 tabs), Sticky bottom bar (Total Dues + Collect Payment CTA).
- **Behavior/logic details**: Data from customerByIdProvider. Edit opens C-M5 in edit mode. Record Payment opens amount input sheet. Tab navigation. Sticky bar always visible.
- **Out of scope**: Ledger tab contents (C-M7 to C-M10)
- **Localization**: ~18 ARB keys in EN+UR
- **Definition of done**: `flutter analyze` clean, profile renders, financial cards correct colors, buttons work, tab bar renders, EN+UR+RTL verified

---

### C-M7: Customer Advance Ledger Tab
- **Goal**: Build the Advance Ledger tab with chronological transaction entries.
- **Depends on**: C-M6, A-M10, A-M9
- **Exact scope**: `lib/screens/customers/widgets/ledger_tab.dart`, `lib/screens/customers/widgets/ledger_entry_card.dart`
- **Full field/detail list**: Section header with month. LedgerEntryCard per transaction: type icon circle (40x40, colored bg per type), title, subtitle (date+context), running balance, amount (+/- colored), type badge (Debit/Paid/Credit/Cleared).
- **Behavior/logic details**: Combined Payment+Delivery records sorted by date DESC. Infinite scroll (20 per page). Empty state.
- **Out of scope**: Other 3 tabs, payment recording
- **Localization**: ~12 ARB keys in EN+UR
- **Definition of done**: `flutter analyze` clean, entries render with correct icons/colors, sorted correctly, empty state, EN+UR verified

---

### C-M8: Customer Delivery History Tab
- **Goal**: Build the Delivery History tab showing past deliveries.
- **Depends on**: C-M6, A-M9
- **Exact scope**: `lib/screens/customers/widgets/delivery_history_tab.dart`
- **Full field/detail list**: Delivery entries grouped by date: date, shift badge, product, quantity, rate, total, status badge (Delivered/Skipped), time. AppCard per entry.
- **Behavior/logic details**: Data from customerDeliveryHistoryProvider. Infinite scroll. Empty state.
- **Out of scope**: Delivery recording, quantity adjustment
- **Localization**: `deliveryHistoryTitle`/`delivered`/`noDeliveries` in EN+UR
- **Definition of done**: `flutter analyze` clean, entries render, date grouping, empty state, EN+UR verified

---

### C-M9: Customer Payment History Tab
- **Goal**: Build the Payment History tab showing all payments from this customer.
- **Depends on**: C-M6, A-M10
- **Exact scope**: `lib/screens/customers/widgets/payment_history_tab.dart`
- **Full field/detail list**: Payment entries: date, amount, method badge (Cash/Raast/Bank), receipt number, type badge. Grouped by month.
- **Behavior/logic details**: Data from paymentListByCustomerProvider. Cash_payment + advance_topup types only. Empty state.
- **Out of scope**: Payment recording
- **Localization**: `paymentHistoryTitle`/`noPayments` in EN+UR
- **Definition of done**: `flutter analyze` clean, entries render, empty state, EN+UR verified

---

### C-M10: Customer Itemized Bill Tab
- **Goal**: Build the Itemized Bill tab with monthly charge/payment breakdown.
- **Depends on**: C-M6, A-M9, A-M10
- **Exact scope**: `lib/screens/customers/widgets/itemized_bill_tab.dart`
- **Full field/detail list**: Monthly summary card: month header, total deliveries, total litres, total charges, total payments, net balance. Line items per delivery (date, qty, rate, amount). Month selector.
- **Behavior/logic details**: Aggregated from Delivery+Payment. Default current month. Empty state for inactive months.
- **Out of scope**: PDF export, printing
- **Localization**: `itemizedBillTitle`/`totalDeliveries`/`totalCharges`/`totalPayments`/`netBalance` in EN+UR
- **Definition of done**: `flutter analyze` clean, monthly aggregation correct, line items display, EN+UR verified

---

### C-M11: Today's Deliveries Screen
- **Goal**: Build the full deliveries screen with date/shift selection, delivery cards in all states, and operational summary.
- **Depends on**: C-M1, A-M9, A-M7, B-M2, B-M4, B-M5, B-M6, B-M7, B-M9, B-M16, B-M17
- **Exact scope**: `lib/screens/deliveries/deliveries_screen.dart`, `lib/screens/deliveries/widgets/delivery_card.dart`
- **Full field/detail list**: Header (title+DateSelector), ShiftSelector, SearchBar, "Mark All" button, FilterChipBar (All/Pending/Delivered/Skipped), Delivery cards in 4 states (Pending with stepper+skip+deliver, Delivered dimmed, Skipped with undo, Advance Deduct), Sticky summary (remaining count+litres+Route Map button).
- **Behavior/logic details**: Auto-generate deliveries if none exist for today. Deliver creates Payment + updates customer balance. Skip requires reason via dialog. Mark All with confirmation. Quantity stepper adjusts pending. Search+filter. Pull-to-refresh. Live summary updates.
- **Out of scope**: Route map, GPS, multi-product per delivery
- **Localization**: ~25 ARB keys in EN+UR
- **Definition of done**: `flutter analyze` clean, all 4 card states render, deliver/skip/undo work, balance updates, auto-generation, search+filters, EN+UR+RTL verified

---

### C-M12: Payments & Accounts Screen
- **Goal**: Build the Payments screen with financial KPIs, payment recording, WhatsApp reminders, and unified transaction feed.
- **Depends on**: C-M1, A-M10, A-M12, A-M13, A-M7, B-M2, B-M3, B-M4, B-M5, B-M9, B-M10, B-M16
- **Exact scope**: `lib/screens/payments/payments_screen.dart`, `lib/screens/payments/widgets/transaction_card.dart`, `lib/screens/payments/widgets/record_payment_sheet.dart`, `lib/screens/payments/widgets/whatsapp_reminder_card.dart`
- **Full field/detail list**: Header (store+date+language+month selector), KPI grid 2x2 (Today's Inflow, Cash in Hand, Customer Dues, Dairy Payables), "+ Record Payment In/Out" CTA, WhatsApp Reminders section (overdue cards with Send Reminder+Log Cash buttons), FilterChipBar (All/Collections/Payables), Transaction cards (4 types: Collection, Advance, Supplier Outflow, Counter Retail). Record Payment Sheet: customer dropdown, amount, type selector, method selector, Raast ref field, save.
- **Behavior/logic details**: KPIs from today's data. WhatsApp opens via url_launcher. Record Payment creates Payment+updates balance. Filter shows inflow/outflow. Unified transaction feed from Payment+SupplierPayment+LocalSale. "LIVE SYNC" static indicator (Phase D activates). Pull-to-refresh.
- **Out of scope**: Actual Firebase sync, PDF receipts
- **Localization**: ~25 ARB keys in EN+UR
- **Definition of done**: `flutter analyze` clean, KPIs display, record payment works, WhatsApp opens, transaction feed renders, filters work, EN+UR+RTL verified

---

### C-M13: Suppliers & Procurement Screen
- **Goal**: Build the suppliers screen with procurement KPIs, supplier cards in all states, and filter chips.
- **Depends on**: C-M1, A-M8, A-M11, B-M2, B-M3, B-M4, B-M5, B-M9, B-M16, B-M17, B-M18
- **Exact scope**: `lib/screens/suppliers/suppliers_screen.dart`, `lib/screens/suppliers/widgets/supplier_card.dart`
- **Full field/detail list**: Header (store+date+shift+language+settings), Shift/Date selector, KPI grid 2x2 (Total Milk Inward, Avg FAT, Avg LR Density, Today's Payable), "+Record Inward Milk" CTA, section header with farm count, FilterChipBar (All/Pending Khata/Recorded/Awaiting), Supplier cards (3 states: Tested & Recorded with quality metrics, All Cleared green, Awaiting Drop amber), FAB "+Log Supply".
- **Behavior/logic details**: KPIs from milkCollectionStatsProvider. "Pay Cash" opens amount sheet + creates SupplierPayment. "View Khata" navigates to C-M15. Call/WhatsApp via url_launcher. Filter by khata status. Pull-to-refresh.
- **Out of scope**: Supplier CRUD (Settings), quality testing lab
- **Localization**: ~30 ARB keys in EN+UR
- **Definition of done**: `flutter analyze` clean, all 3 card states render, KPIs computed, pay cash works, call/WhatsApp work, filters work, EN+UR+RTL verified

---

### C-M14: Record Inward Milk Bottom Sheet
- **Goal**: Build the form for logging a new milk delivery from a supplier.
- **Depends on**: C-M13, B-M10, B-M12, B-M9, A-M11, A-M8
- **Exact scope**: `lib/screens/suppliers/widgets/record_milk_sheet.dart`
- **Full field/detail list**: Supplier dropdown (pre-selectable), Quantity field (numeric, suffix "L"), FAT% field, LR Density field, Rate/L field (prefix "Rs."), Batch Value (auto-calc, read-only, 18px/w700), Notes (multiline, optional), "Record Batch" save button.
- **Behavior/logic details**: Batch value = qty x rate. Save creates MilkCollection + updates supplier khata. Validation: all numeric > 0.
- **Out of scope**: Photo attachment, lab integration
- **Localization**: ~8 ARB keys in EN+UR
- **Definition of done**: `flutter analyze` clean, form validates, batch value auto-calculates, saves correctly, EN+UR verified

---

### C-M15: Supplier Khata Screen
- **Goal**: Build the supplier ledger screen showing collection and payment history.
- **Depends on**: C-M1, A-M8, A-M11, A-M12, B-M2
- **Exact scope**: `lib/screens/suppliers/supplier_khata_screen.dart`
- **Full field/detail list**: AppBar (back+name+call), Supplier summary card (name, location, milk type, pending khata), Two tabs (Collections list + Payments list), "Pay Cash" CTA.
- **Behavior/logic details**: Data from supplier+milkCollection+supplierPayment providers. Sorted by date DESC. Empty states per tab.
- **Out of scope**: Supplier editing, collection editing
- **Localization**: `supplierKhata`/`collectionHistory`/`paymentsMade` in EN+UR
- **Definition of done**: `flutter analyze` clean, both tabs render, empty states, EN+UR verified

---

### C-M16: Settings Shell & Store Profile
- **Goal**: Build settings navigation and store profile editing.
- **Depends on**: C-M1, A-M5, B-M2, B-M12, B-M9
- **Exact scope**: `lib/screens/settings/settings_screen.dart`, `lib/screens/settings/store_profile_screen.dart`
- **Full field/detail list**: Settings list (4 items: Store Profile, Products & Pricing, Shifts & Routes, Drivers, each as AppCard with icon+label+chevron). Store Profile form (Name, Phone, Address + Save button).
- **Behavior/logic details**: Tapping navigates to sub-page. Store Profile saves via storeProfileRepository.
- **Out of scope**: Other settings sub-pages (C-M17 to C-M19)
- **Localization**: `settings`/`storeProfile`/`productsPricing`/`shiftsRoutes`/`drivers`/`save`/`storeName`/`storePhone`/`storeAddress`/`profileSaved` in EN+UR
- **Definition of done**: `flutter analyze` clean, settings list navigates, profile saves, EN+UR verified

---

### C-M17: Settings — Products & Pricing
- **Goal**: Build product management sub-page with CRUD operations.
- **Depends on**: C-M16, A-M2, B-M2, B-M12, B-M9, B-M11
- **Exact scope**: `lib/screens/settings/products_pricing_screen.dart`
- **Full field/detail list**: Product list (name, description, rate/L, active badge). FAB "+Add Product". Tap to edit (bottom sheet: name, description, rate). Swipe to deactivate with confirmation.
- **Behavior/logic details**: CRUD via productRepository. Cannot deactivate if customers reference product (show warning).
- **Out of scope**: Product categories, images
- **Localization**: `addProduct`/`productName`/`description`/`defaultRate`/`productSaved`/`cannotDeactivate` in EN+UR
- **Definition of done**: `flutter analyze` clean, CRUD works, validation works, EN+UR verified

---

### C-M18: Settings — Shifts & Routes
- **Goal**: Build shift configuration and route management sub-page.
- **Depends on**: C-M16, A-M6, A-M3, A-M4, B-M2, B-M12, B-M9
- **Exact scope**: `lib/screens/settings/shifts_routes_screen.dart`
- **Full field/detail list**: Shifts section (Morning/Evening cards: start/end time, lead driver dropdown, active toggle). Routes section (list with name+area+active toggle, FAB to add).
- **Behavior/logic details**: Shifts pre-seeded, edit-only. Routes CRUD. Driver dropdown from driverListProvider.
- **Out of scope**: Route ordering, map integration
- **Localization**: `shifts`/`routes`/`startTime`/`endTime`/`leadDriver`/`addRoute`/`routeName`/`area`/`shiftSaved`/`routeSaved` in EN+UR
- **Definition of done**: `flutter analyze` clean, shifts editable, routes CRUD, EN+UR verified

---

### C-M19: Settings — Drivers
- **Goal**: Build driver management sub-page.
- **Depends on**: C-M16, A-M4, B-M2, B-M12, B-M9
- **Exact scope**: `lib/screens/settings/drivers_screen.dart`
- **Full field/detail list**: Driver list (name, phone, active badge). FAB "+Add Driver". Tap to edit. Swipe to deactivate. Add/Edit sheet (name+phone fields).
- **Behavior/logic details**: CRUD via driverRepository. Cannot deactivate if assigned as lead driver (show warning).
- **Out of scope**: Driver GPS, attendance
- **Localization**: `addDriver`/`driverName`/`driverPhone`/`driverSaved`/`cannotDeactivateDriver` in EN+UR
- **Definition of done**: `flutter analyze` clean, CRUD works, EN+UR verified

---

### PHASE D — Firebase Integration

The app must remain OFFLINE-FIRST: local sqflite database is the primary source of truth. Firebase is a sync/backup layer.

---

### D-M1: Firebase Auth (Login / Signup)
- **Goal**: Add Firebase Authentication with email/password login, isolated from existing data logic.
- **Depends on**: All Phase A, B, C milestones complete
- **Exact scope**: `lib/core/firebase/firebase_config.dart`, `lib/screens/auth/login_screen.dart`, `lib/screens/auth/signup_screen.dart`, `lib/providers/auth_provider.dart`, modify `lib/app.dart` (auth gate), `android/` (google-services.json), `pubspec.yaml` (firebase_core, firebase_auth)
- **Full field/detail list**: Login screen (email+password+login button+create account link), Signup screen (email+password+confirm+create button), authProvider (StreamProvider from authStateChanges), Auth gate (redirect logic), Logout in Settings.
- **Behavior/logic details**: Firebase init in main.dart. If init fails: allow offline-only mode. Password min 6 chars. Error messages for all auth failures. Auth state persisted. Existing local data unaffected.
- **Out of scope**: Social login, phone auth, password reset, data migration
- **Definition of done**: `flutter analyze` clean, signup+login+logout work, offline fallback works, auth persists

---

### D-M2: Cloud Sync Layer
- **Goal**: Add background sync service pushing local data to Firestore and pulling remote changes.
- **Depends on**: D-M1
- **Exact scope**: `lib/core/firebase/sync_service.dart`, `lib/core/firebase/firestore_collections.dart`, `lib/core/firebase/conflict_resolver.dart`, modify all repositories (add `getPendingSyncItems()`), `pubspec.yaml` (cloud_firestore, connectivity_plus)
- **Full field/detail list**: Firestore collections per model under `users/{userId}/`. SyncService: `pushLocalChanges()`, `pullRemoteChanges(lastSyncTime)`, `resolveConflict()` (last-write-wins by updatedAt), `fullSync()`, `startPeriodicSync()` (every 5 min). Soft delete support (syncStatus=3). lastSyncTime in SharedPreferences. Network check via connectivity_plus.
- **Behavior/logic details**: Sync runs in background, never blocks UI. Failures silently retry. All CRUD continues via local sqflite. First sync uploads all local data. Conflict resolution: later updatedAt wins. "LIVE SYNC" indicator shows actual status.
- **Out of scope**: Real-time listeners, multi-device conflict beyond last-write-wins, data encryption, Firestore security rules
- **Definition of done**: `flutter analyze` clean, local CRUD works without internet, records sync to Firestore within 5 min, remote changes appear locally, UI never blocked, LIVE SYNC indicator works, app works toggling airplane mode

---

## 9. FLAGGED ITEMS REQUIRING CONFIRMATION

> **F1**: The Payments screen was provided after initial analysis. The plan above incorporates all visible features from the screenshot. Please confirm the Payments screen design is fully captured in Section 2.5 and C-M12.

> **F2**: The design prototype uses `#1E40AF` (deep blue) as the primary brand color throughout ALL HTML screens, while the DESIGN.md document specifies `#15803D` (pasture green). This plan uses **blue** (`#1E40AF`) since the screens are the authoritative visual reference. Please confirm this is the intended brand color.

> **F3**: The Customer Detail / Ledger screen screenshot was entirely **black** (rendering error), but the HTML code was readable. The plan is based on the HTML code specification. Please confirm the design in Section 2.3 matches your intent.

> **F4**: Settings screens have no Stitch prototype — they are designed by inference based on the data requirements and user confirmation. Please review the scope in C-M16 through C-M19 and confirm the feature set.

> **F5**: The Payments screen shows "yogurt sales" in the counter walk-in entry. This implies additional product types beyond milk. The current plan treats yogurt as just another Product entry (Section 3.1). Please confirm whether yogurt or other dairy products require special handling or a separate model.
