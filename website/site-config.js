// Post-launch site config. Leave googleAds* empty until Ads conversion is set up.
window.SITE_CONFIG = {
  launched: true,
  appStoreURL: "https://apps.apple.com/us/app/catxapp/id6784522794",
  metaPixelId: "1320758736438025",

  // Optional Google Ads conversion (gtag). Fill when ready in Google Ads → Conversions.
  googleAdsId: "",
  googleAdsConversionLabel: "",

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
