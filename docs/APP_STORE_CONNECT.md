# App Store Connect Setup for CatXapp

Use this checklist when your Apple Developer Program enrollment is **Active** and App Store Connect loads successfully.

**URLs (custom domain):**

| Field | URL |
|-------|-----|
| Privacy Policy | `https://catxapp.com/privacy.html` |
| Support | `https://catxapp.com/support.html` |

See [`DOMAIN_SETUP.md`](DOMAIN_SETUP.md) if the site is not live yet.

---

## 1. Certificates and bundle ID

1. Sign in to [Apple Developer](https://developer.apple.com/account).
2. **Certificates, Identifiers & Profiles → Identifiers** — confirm `quantumficial.catxapp` exists (App ID).
3. In Xcode, select the **catxapp** target → **Signing & Capabilities** → choose your team. Automatic signing should provision profiles.

## 2. Agreements, tax, and banking

1. [App Store Connect](https://appstoreconnect.apple.com) → **Business** (or Agreements tab).
2. Complete **Paid Applications** agreement.
3. Add **banking** and **tax** information.

Without this, StoreKit products will not load on a real device.

## 3. App record

1. **Apps** → **+** → New App.
2. Platform: **iOS**
3. Name: **CatXapp**
4. Primary language: **English (U.S.)**
5. Bundle ID: `quantumficial.catxapp`
6. SKU: `catxapp` (any unique string)
7. User access: Full Access

**App Information:**

| Field | Value |
|-------|-------|
| Category (primary) | Business or Utilities |
| Privacy Policy URL | `https://catxapp.com/privacy.html` |
| Support URL | `https://catxapp.com/support.html` |

## 4. Subscription group

1. Open your app → **Subscriptions**.
2. Create a subscription group: **CatXapp Premium**.

## 5. Products (must match the app exactly)

Create **four** auto-renewable subscriptions in the same group:

| Product ID | Price | Duration | Display name (suggested) | Tier |
|------------|-------|----------|--------------------------|------|
| `quantumficial.catxapp.monthly` | $7.99 | 1 month | CatXapp Essential Monthly | Essential |
| `quantumficial.catxapp.annual` | $69.99 | 1 year | CatXapp Essential Annual | Essential |
| `quantumficial.catxapp.pro.monthly` | $13.99 | 1 month | CatXapp Pro Monthly | Pro |
| `quantumficial.catxapp.pro.annual` | $119.99 | 1 year | CatXapp Pro Annual | Pro |

**Essential** — unlimited code lookup and live PGM-adjusted prices.

**Pro** — everything in Essential plus cart, margin control, saved carts, and PDF export.

For each product:

- Add English display name and description
- Set pricing for your primary territory (United States)
- Add subscription localization for App Review
- Submit subscription metadata **with** your app binary

Product IDs are defined in [`catxapp/Services/SubscriptionManager.swift`](../catxapp/Services/SubscriptionManager.swift). If you change them in Connect, update the Swift constants.

## 6. Free trial (StoreKit introductory offer)

CatXapp uses a **14-day free trial** via Apple’s **introductory subscription offer** on **Pro monthly only**. Users start the trial through the App Store; Apple enforces one trial per Apple ID per subscription group (survives reinstall).

**App Store Connect setup (Pro monthly product):**
1. Open **CatXapp Pro Monthly** → **Subscription Prices**
2. Add **Introductory Offer** → **Free** → **2 weeks** (14 days)
3. Submit with your app for review

Essential plans and Pro annual have no introductory offer (standard subscribe price).

**Review notes (paste when submitting):**

> CatXapp offers Essential ($7.99/mo) for code lookup and Pro ($13.99/mo) for cart and margin tools. A 14-day free trial is available on Pro monthly via StoreKit introductory offer. Users subscribe through the App Store. Sandbox testers can subscribe with a sandbox Apple ID. To test without subscribing in debug builds: Settings → Debug → Access.

## 7. Simulator testing (no Connect required)

The project includes [`Products.storekit`](../Products.storekit). The shared Xcode scheme uses it.

1. Open the project in Xcode
2. Press **⌘R** in Simulator
3. Open **Settings → Subscribe** or trigger the paywall
4. Test **Restore Purchases**

## 8. Debug access states

In Debug builds: **Settings → Debug → Access** and **Tier**

- **Free Trial** — lookup or Pro access with countdown (depends on Tier)
- **Subscribed** — active plan, no paywall for included features
- **Subscription Required** — paywall on search; cart requires Pro

## 9. Before TestFlight

- [ ] Paid Applications agreement active
- [ ] Banking and tax complete
- [ ] All four subscription products created in Connect
- [ ] Pro monthly has 14-day free introductory offer
- [ ] Privacy policy live at `https://catxapp.com/privacy.html`
- [ ] Sandbox purchase tested on device (see [`SANDBOX_TESTING.md`](SANDBOX_TESTING.md))

## 10. Screenshots (prepare before submission)

Capture on **6.7" iPhone** simulator or device (1290 × 2796 px):

| # | Screen | What to show |
|---|--------|--------------|
| 1 | Search | Code lookup with results and PGM strip |
| 2 | Cart | Cart with items and total |
| 3 | Pricing | Settings → Pricing with margin controls |
| 4 | Paywall | Essential and Pro subscription options |

Optional: Saved carts, PDF export preview.

## 11. App Privacy questionnaire

CatXapp stores data **on device only** (cart, settings, subscription state). Declare accordingly:

- No data linked to user identity collected by you
- Precise location: No
- Subscriptions: handled by Apple (not collected by app)

Adjust answers if Apple’s questionnaire changes.

## 12. Related guides

| Phase | Doc |
|-------|-----|
| Domain + website | [`DOMAIN_SETUP.md`](DOMAIN_SETUP.md) |
| Sandbox purchases | [`SANDBOX_TESTING.md`](SANDBOX_TESTING.md) |
| TestFlight beta | [`TESTFLIGHT.md`](TESTFLIGHT.md) |
| App Store submission | [`APP_STORE_SUBMISSION.md`](APP_STORE_SUBMISSION.md) |
| Launch day | [`LAUNCH_DAY.md`](LAUNCH_DAY.md) |
