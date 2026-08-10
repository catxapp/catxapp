// Loads Meta Pixel + Google Analytics / Ads from SITE_CONFIG.
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

  var gaId = config.googleAnalyticsId;
  var adsId = config.googleAdsId;
  var primaryGtagId = gaId || adsId;
  if (primaryGtagId && typeof window.gtag !== "function") {
    var gtagScript = document.createElement("script");
    gtagScript.async = true;
    gtagScript.src = "https://www.googletagmanager.com/gtag/js?id=" + encodeURIComponent(primaryGtagId);
    document.head.appendChild(gtagScript);
    window.dataLayer = window.dataLayer || [];
    window.gtag = function () { dataLayer.push(arguments); };
    gtag("js", new Date());
    if (gaId) gtag("config", gaId);
    if (adsId) gtag("config", adsId);
  }
})();
