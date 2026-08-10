// Loads Meta Pixel + optional Google Ads from SITE_CONFIG.
// GA4 (G-38ZSBYS0C1) is loaded via the hardcoded gtag snippet in each page <head>.
(function () {
  var config = window.SITE_CONFIG || {};
  var pixelId = config.metaPixelId;
  if (pixelId && !window.fbq) {
    !function (f, b, e, v, n, t, s) {
      if (f.fbq) return;
      n = f.fbq = function () {
        n.callMethod ? n.callMethod.apply(n, arguments) : n.queue.push(arguments);
      };
      if (!f._fbq) f._fbq = n;
      n.push = n;
      n.loaded = !0;
      n.version = "2.0";
      n.queue = [];
      t = b.createElement(e);
      t.async = !0;
      t.src = v;
      s = b.getElementsByTagName(e)[0];
      s.parentNode.insertBefore(t, s);
    }(window, document, "script", "https://connect.facebook.net/en_US/fbevents.js");
    fbq("init", pixelId);
    fbq("track", "PageView");
  }

  // Only configure Google Ads here if set — avoid double-loading GA4.
  var adsId = config.googleAdsId;
  if (adsId && typeof window.gtag === "function") {
    gtag("config", adsId);
  } else if (adsId) {
    var gtagScript = document.createElement("script");
    gtagScript.async = true;
    gtagScript.src = "https://www.googletagmanager.com/gtag/js?id=" + encodeURIComponent(adsId);
    document.head.appendChild(gtagScript);
    window.dataLayer = window.dataLayer || [];
    window.gtag = window.gtag || function () { dataLayer.push(arguments); };
    gtag("js", new Date());
    gtag("config", adsId);
  }
})();
