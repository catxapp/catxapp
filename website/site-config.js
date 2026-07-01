// Flip `launched` to true and set `appStoreURL` when CatXapp is live on the App Store.
// Set `metaPixelId` from Meta Events Manager for waitlist conversion tracking (see docs/FACEBOOK_ADS.md).
window.SITE_CONFIG = {
  launched: false,
  appStoreURL: "https://apps.apple.com/app/id0000000000",
  metaPixelId: "1412894813980599",

  // Support contact form — create a Google Form, then paste formResponse URL and entry.* IDs.
  // Setup: website/README.md → "Support / Google Form"
  supportForm: {
    action: "https://docs.google.com/forms/d/e/1FAIpQLSf4BEX7i4K_7oZ46Vx36lUcFxj3B2w5Jup9au2Gg_a5AYKyNw/formResponse",
    fields: {
      name: "entry.2005620554",
      email: "entry.1045781291",
      phone: "entry.1166974658",
      message: "entry.839337160"
    }
  }
};
