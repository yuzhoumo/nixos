{ ... }:

{
  programs.firefox = {
    enable = true;

    # matches user_pref() behavior from user.js
    preferencesStatus = "user";

    preferences = {

      /*********/
      /* UI/UX */
      /*********/

      # Disable What's New toolbar icon
      "browser.messaging-system.whatsNewPanel.enabled" = false;

      # Enable dark theme
      "ui.systemUsesDarkTheme" = 1;

      # Change homepage
      "browser.startup.homepage" = "https://start.duckduckgo.com/";

      # Show and enable compact mode (FF89)
      "browser.compactmode.show" = true;
      "browser.uidensity" = 1;

      # Set bookmarks toolbar to always be visible
      "browser.toolbars.bookmarks.visibility" = "always";

      # Disable about:config warning
      "browser.aboutConfig.showWarning" = false;

      # Disable default browser check
      "browser.shell.checkDefaultBrowser" = false;

      # Configure new tab page
      "browser.newtabpage.activity-stream.enabled" = false;
      "browser.newtabpage.activity-stream.feeds.topsites" = false;
      "browser.newtabpage.activity-stream.feeds.telemetry" = false;
      "browser.newtabpage.activity-stream.telemetry" = false;
      "browser.newtabpage.activity-stream.feeds.snippets" = false;
      "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
      "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
      "browser.newtabpage.activity-stream.showSponsored" = false;
      "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" = false;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      "browser.newtabpage.activity-stream.default.sites" = "";

      # Disable "Recommend extensions"
      "browser.newtabpage.activity-stream.asrouter.userprefs.cfr" = false;
      "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
      "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;

      # Wrap long lines in source view
      "view_source.wrap_long_lines" = true;

      # Disable recommendation pane in about:addons (uses Google Analytics)
      "extensions.getAddons.showPane" = false;

      # Disable recommendations in about:addons' Extensions and Themes panes
      "extensions.htmlaboutaddons.recommendations.enabled" = false;

      # Disable Pocket
      "extensions.pocket.enabled" = false;

      /***************/
      /* GEOLOCATION */
      /***************/

      # Disable using the OS's geolocation service
      "geo.provider.ms-windows-location" = false; # Windows
      "geo.provider.use_corelocation" = false;    # macOS
      "geo.provider.use_gpsd" = false;            # Linux

      # Disable region updates
      "browser.region.network.url" = "";
      "browser.region.update.enabled" = false;

      /*************************/
      /* TELEMETRY & ANALYTICS */
      /*************************/

      # Disable telemetry
      "toolkit.telemetry.unified" = false;
      "toolkit.telemetry.enabled" = false;
      "toolkit.telemetry.server" = "data:,";
      "toolkit.telemetry.archive.enabled" = false;
      "toolkit.telemetry.newProfilePing.enabled" = false;
      "toolkit.telemetry.shutdownPingSender.enabled" = false;
      "toolkit.telemetry.updatePing.enabled" = false;
      "toolkit.telemetry.bhrPing.enabled" = false;
      "toolkit.telemetry.firstShutdownPing.enabled" = false;
      "toolkit.telemetry.coverage.opt-out" = true;
      "toolkit.coverage.opt-out" = true;
      "toolkit.coverage.endpoint.base" = "";
      "browser.ping-centre.telemetry" = false;

      # Disable Hybrid Content telemetry
      "toolkit.telemetry.hybridContent.enabled" = false;

      # Disable data & health report
      "datareporting.healthreport.service.enabled" = false;
      "datareporting.healthreport.uploadEnabled" = false;
      "datareporting.policy.dataSubmissionEnabled" = false;

      # Disable sending additional analytics to web servers
      "beacon.enabled" = false;

      # Disable Studies
      "app.shield.optoutstudies.enabled" = false;

      # Disable Normandy/Shield (telemetry system that can push and test "recipes")
      "app.normandy.enabled" = false;
      "app.normandy.api_url" = "";

      # Disable Crash Reports
      "breakpad.reportURL" = "";
      "browser.tabs.crashReporting.sendReport" = false;

      # Enforce no submission of backlogged Crash Reports
      "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

      /********************/
      /* SEARCH & URL BAR */
      /********************/

      # Disable search suggestions
      "browser.search.suggest.enabled" = false;
      "browser.urlbar.showSearchSuggestionsFirst" = false;
      "browser.urlbar.suggest.engines" = false;
      "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
      "browser.urlbar.suggest.quicksuggest.sponsored" = false;
      "browser.urlbar.suggest.searches" = false;
      "browser.urlbar.suggest.topsites" = false;

      # Disable safe browsing (sends web traffic through Google)
      "browser.safebrowsing.enabled" = false;
      "browser.safebrowsing.downloads.remote.enabled" = false;
      "browser.safebrowsing.downloads.remote.url" = "";
      "browser.safebrowsing.appRepURL" = "";
      "browser.safebrowsing.downloads.enabled" = false;
      "browser.safebrowsing.malware.enabled" = false;
      "browser.safebrowsing.phishing.enabled" = false;
      "browser.safebrowsing.blockedURIs.enabled" = false;
      "browser.safebrowsing.downloads.remote.block_potentially_unwanted" = false;
      "browser.safebrowsing.downloads.remote.block_uncommon" = false;
      "browser.safebrowsing.allowOverride" = false;

      # Disable location bar domain guessing
      "browser.fixup.alternate.enabled" = false;

      # Display all parts of the url in the location bar
      "browser.urlbar.trimURLs" = false;

      # Represent unicode with limited character subset for hostnames
      # (hardens against phishing attacks)
      "network.IDN_show_punycode" = true;

      /*****************/
      /* NETWORK & DNS */
      /*****************/

      # Disable Network Connectivity checks
      "network.connectivity-service.enabled" = false;

      # Disable link prefetching
      "network.prefetch-next" = false;

      # Disable DNS prefetching
      "network.dns.disablePrefetch" = true;

      # Disable predictor/prefetching
      "network.predictor.enabled" = false;
      "network.predictor.enable-prefetch" = false;

      # Disable link-mouseover opening connection to linked server
      "network.http.speculative-parallel-limit" = 0;

      # Disable mousedown speculative connections on bookmarks and history
      "browser.places.speculativeConnect.enabled" = false;

      # Disable DNS over HTTPS (5 = no DOH)
      "network.trr.mode" = 5;

      /*******************/
      /* HISTORY & FORMS */
      /*******************/

      # Disable autofill
      "browser.formfill.enable" = false;
      "signon.autofillForms" = false;
      "signon.generation.enabled" = false;
      "signon.management.page.breach-alerts.enabled" = false;
      "signon.rememberSignons" = false;
      "extensions.formautofill.available" = false;
      "extensions.formautofill.creditCards.available" = false;
      "extensions.formautofill.addresses.enabled" = false;
      "extensions.formautofill.creditCards.enabled" = false;
      "extensions.formautofill.heuristics.enabled" = false;

      # Disable formless login capture for Password Manager
      "signon.formlessCapture.enabled" = false;

      # Reset default "Time range to clear" for "Clear Recent History"
      # 0=everything, 1=last hour, 2=last two hours, 3=last four hours, 4=today
      "privacy.sanitize.timeSpan" = 0;

      # Reset default items to clear with Ctrl-Shift-Del
      "privacy.cpd.cache" = true;
      "privacy.cpd.formdata" = true;
      "privacy.cpd.history" = true;
      "privacy.cpd.sessions" = true;
      "privacy.cpd.offlineApps" = false;
      "privacy.cpd.cookies" = false;

      /******************/
      /* FINGERPRINTING */
      /******************/

      # Mitigate tracking through TLS session ids
      "security.ssl.disable_session_identifiers" = true;

      # Disallow reading battery status (reduce fingerprinting)
      "dom.battery.enabled" = false;

      /*********/
      /* OTHER */
      /*********/

      # Enable global privacy control
      "privacy.globalprivacycontrol" = true;
      "privacy.globalprivacycontrol.functionality.enabled" = true;

      # Disable JS in PDFs
      "pdfjs.enableScripting" = false;
    };

    policies = {
      ExtensionSettings = {
        # Bitwarden
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
        # uBlock Origin
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        # ClearURLs
        "{74145f27-f039-47ce-a470-a662b129930a}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi";
          installation_mode = "force_installed";
        };
        # Cookie AutoDelete
        "CookieAutoDelete@kennydo.com" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/cookie-autodelete/latest.xpi";
          installation_mode = "force_installed";
        };
        # DuckDuckGo Privacy Essentials
        "jid1-ZAdIEUB7XOzOJw@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/duckduckgo-for-firefox/latest.xpi";
          installation_mode = "force_installed";
        };
        # SponsorBlock
        "sponsorBlocker@ajay.app" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
          installation_mode = "force_installed";
        };
        # Unhook
        "myallychou@gmail.com" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-recommended-videos/latest.xpi";
          installation_mode = "force_installed";
        };
        # Return YouTube Dislike
        "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislikes/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };
}
