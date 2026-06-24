# App Store Connect Setup for CatXapp

Use this checklist when your Apple Developer Program enrollment is **Active** and App Store Connect loads successfully.

**URLs (custom domain):**

| Field | URL |
|-------|-----|
| Privacy Policy | `https://catxapp.com/privacy.html` |
| Support | `https://catxapp.com/` |

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
| Support URL | `https://catxapp.com/` |

## 4. Subscription group

1. Open your app → **Subscriptions**.
2. Create a subscription group: **CatXapp Premium**.

## 5. Products (must match the app exactly)

Create two auto-renewable subscriptions in the same group:

| Product ID | Price | Duration | Display name (suggested) |
|------------|-------|----------|--------------------------|
| `quantumficial.catxapp.monthly` | $7.99 | 1 month | CatXapp Monthly |
| `quantumficial.catxapp.annual` | $69.99 | 1 year | CatXapp Annual |

For each product:

- Add English display name and description
- Set pricing for your primary territory (United States)
- Add subscription localization for App Review
- Submit subscription metadata **with** your app binary

Product IDs are defined in [`catxapp/Services/SubscriptionManager.swift`](../catxapp/Services/SubscriptionManager.swift). If you change them in Connect, update the Swift constants.

## 6. Free trial (in-app, not StoreKit intro offer)

CatXapp uses a **14-day local trial** after first install. Users get full access without payment info. After 14 days, the in-app paywall appears.

You do **not** need a StoreKit introductory offer unless you later switch to Apple’s subscription trial flow.

**Review notes (paste when submitting):**

> CatXapp includes a 14-day free trial managed locally on device. No payment is required during the trial. After 14 days, users see an in-app paywall to subscribe via StoreKit. Sandbox testers can use Settings → Debug → Access → Trial Ended (debug builds) or wait 14 days to test the paywall.

## 7. Simulator testing (no Connect required)

The project includes [`Products.storekit`](../Products.storekit). The shared Xcode scheme uses it.

1. Open the project in Xcode
2. Press **⌘R** in Simulator
3. Open **Settings → Subscribe** or trigger the paywall
4. Test **Restore Purchases**

## 8. Debug access states

In Debug builds: **Settings → Debug → Access**

- **Free Trial** — full access with countdown
- **Subscribed** — full access, no paywall
- **Trial Ended** — paywall on search/cart

## 9. Before TestFlight

- [ ] Paid Applications agreement active
- [ ] Banking and tax complete
- [ ] Both subscription products created in Connect
- [ ] Privacy policy live at `https://catxapp.com/privacy.html`
- [ ] Sandbox purchase tested on device (see [`SANDBOX_TESTING.md`](SANDBOX_TESTING.md))

## 10. Screenshots (prepare before submission)

Capture on **6.7" iPhone** simulator or device (1290 × 2796 px):

| # | Screen | What to show |
|---|--------|--------------|
| 1 | Search | Code lookup with results and PGM strip |
| 2 | Cart | Cart with items and total |
| 3 | Pricing | Settings → Pricing with margin controls |
| 4 | Paywall | Subscription options (monthly + annual) |

Optional: Saved carts, PDF export preview.

## 11. App Privacy questionnaire

CatXapp stores data **on device only** (cart, settings, trial date). Declare accordingly:

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
