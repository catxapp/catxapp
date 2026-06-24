# TestFlight Beta

Short beta (1–2 weeks, 3–5 testers) before App Store submission.

## Prerequisites

- [ ] Sandbox testing complete ([`SANDBOX_TESTING.md`](SANDBOX_TESTING.md))
- [ ] No critical bugs on your device
- [ ] `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` set in Xcode (currently 1.0 / 1)

## Upload build

1. Open **catxapp.xcodeproj** in Xcode
2. Select **Any iOS Device** (not Simulator)
3. **Product → Archive**
4. Organizer → **Distribute App** → **App Store Connect** → **Upload**
5. Wait for processing (15–60 minutes) — email when ready

## Add testers

### Internal (instant)

App Store Connect → your app → **TestFlight** → **Internal Testing**

- Add team members (up to 100)
- They need App Store Connect access on your team

### External (recommended for yard contacts)

**External Testing** → create a group (e.g. "Yard Beta")

- Add testers by email (no Connect account needed)
- First external build requires **Beta App Review** (usually quick)
- Testers install **TestFlight** app from App Store

## What to ask testers

Send this list:

1. Search for 5–10 real converter codes from your yard sheets — are prices close?
2. Add items to cart, adjust margin, export PDF
3. Try subscribing (sandbox) if comfortable, or report paywall clarity
4. Note any crashes, slow search, or unreadable text outdoors

## Feedback loop

| Issue severity | Action |
|----------------|--------|
| Crash / data loss | Fix before App Store submission |
| Wrong prices vs ACC sheet | Verify catalog; re-run `scripts/extract_catalog.py` if needed |
| UI polish | Fix if quick; defer minor items to v1.1 |
| Subscription confusion | Improve paywall copy in `PaywallView.swift` |

Bump `CURRENT_PROJECT_VERSION` for each new TestFlight upload.

## Website during beta

Keep waitlist live on **catxapp.com**. Optionally email waitlist: "Beta starting soon — reply if you want TestFlight access."

## When done

Proceed to [`APP_STORE_SUBMISSION.md`](APP_STORE_SUBMISSION.md).
