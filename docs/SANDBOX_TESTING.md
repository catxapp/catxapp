# Sandbox Subscription Testing

Run this checklist on a **physical iPhone** after App Store Connect products and the Paid Applications agreement are active.

## Setup

1. **App Store Connect** → Users and Access → **Sandbox** → Testers → **+**
   - Use a **new** email (not your real Apple ID)
   - Set password and security questions
2. On test iPhone: **Settings → App Store → Sandbox Account** → sign in with sandbox tester
3. Install a **Release** or **TestFlight** build (sandbox does not work reliably with debug StoreKit config)

## Test matrix

| # | Test | Expected result | Pass |
|---|------|-----------------|------|
| 1 | Fresh install, open app | Paywall until subscription; search blocked | [ ] |
| 2 | Paywall → Pro Monthly (start trial) | Sandbox purchase completes; "Free Trial" with days remaining; cart works | [ ] |
| 3 | Paywall → Essential Monthly | Search works; cart shows Pro upgrade | [ ] |
| 4 | Settings → Debug → Subscription Required (debug build only) | Paywall on search; cart blocked | [ ] |
| 5 | Delete app, reinstall, Restore Purchases | Trial/subscription restored without new charge | [ ] |
| 6 | Paywall → Essential or Pro Annual | Annual plan active in Settings | [ ] |
| 7 | Settings → Manage Subscription | Opens Apple subscription management | [ ] |
| 8 | Settings → Privacy Policy | Opens `https://catxapp.com/privacy.html` | [ ] |
| 9 | Settings → Support | Opens `https://catxapp.com/support.html` | [ ] |

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Products empty on paywall | Paid Applications agreement not active; products not created; wait 15–30 min after creating products |
| Purchase fails immediately | Wrong sandbox account; sign out of real Apple ID in Media & Purchases, use Sandbox Account only |
| "Cannot connect to iTunes Store" | Network issue; retry; check Apple System Status |
| Restore finds nothing | Ensure same sandbox Apple ID used for original purchase |

## When done

Proceed to [`TESTFLIGHT.md`](TESTFLIGHT.md) to distribute to external testers.
