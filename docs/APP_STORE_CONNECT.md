# App Store Connect Setup for CatXapp

Use this checklist when you are ready to test subscriptions on a real device or submit to TestFlight.

## 1. App record

1. Sign in to [App Store Connect](https://appstoreconnect.apple.com).
2. Create an app with bundle ID: `quantumficial.catxapp`
3. Set the display name to **CatXapp**.

## 2. Subscription group

1. Open your app → **Subscriptions**.
2. Create a subscription group named **CatXapp Premium**.

## 3. Products (must match the app exactly)

Create two auto-renewable subscriptions in the same group:

| Product ID | Price | Duration |
|------------|-------|----------|
| `quantumficial.catxapp.monthly` | $7.99 | 1 month |
| `quantumficial.catxapp.annual` | $69.99 | 1 year |

For each product:
- Add English display name and description
- Set pricing for your primary territory
- Submit subscription metadata for review with your app

## 4. Free trial (in-app, not StoreKit intro offer)

CatXapp uses a **14-day local trial** after first install. Users get full access without entering payment info. After 14 days, the in-app paywall appears.

You do **not** need a StoreKit introductory offer for the trial unless you later switch to Apple’s subscription trial flow.

## 5. Agreements and tax

1. Complete **Paid Applications** agreement in App Store Connect
2. Add banking and tax information

Without this, StoreKit products will not load on device.

## 6. Sandbox testing

1. Create a **Sandbox Apple ID** under Users and Access → Sandbox Testers
2. On your test iPhone: Settings → App Store → Sandbox Account
3. Build to device from Xcode and purchase using the sandbox account

## 7. Simulator testing (local)

The project includes [`Products.storekit`](../Products.storekit). The shared Xcode scheme is already configured to use it.

1. Open the project in Xcode
2. Press **⌘R** to run in Simulator
3. Open **Settings → Subscribe** or trigger the paywall after trial expires
4. Use **Restore Purchases** to test entitlement recovery

## 8. Debug access states

In Debug builds, open **Settings → Debug → Access** to simulate:
- **Free Trial** — full access with trial countdown
- **Subscribed** — full access, no paywall
- **Trial Ended** — paywall on search/cart actions

## 9. Before TestFlight

- [ ] Both products approved in App Store Connect
- [ ] Paid Applications agreement active
- [ ] Privacy Policy URL ready (required for subscriptions)
- [ ] Test monthly purchase, annual purchase, and restore on a sandbox device
- [ ] Verify trial countdown and paywall after 14 days (or use Debug → Trial Ended)

## 10. Product IDs in code

These IDs are defined in [`catxapp/Services/SubscriptionManager.swift`](../catxapp/Services/SubscriptionManager.swift):

- `quantumficial.catxapp.monthly`
- `quantumficial.catxapp.annual`

If you change them in App Store Connect, update the Swift constants to match.
