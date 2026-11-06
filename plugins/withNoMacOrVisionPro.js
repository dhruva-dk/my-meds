const { withXcodeProject } = require('expo/config-plugins');

/**
 * Keeps 1.x's opt-out from running as a "Designed for iPhone" app on Apple silicon Macs
 * and Apple Vision Pro. 2.0 is only built and tested for iPhone.
 */
module.exports = function withNoMacOrVisionPro(config) {
  return withXcodeProject(config, (config) => {
    const configurations = config.modResults.pbxXCBuildConfigurationSection();
    for (const key of Object.keys(configurations)) {
      const settings = configurations[key].buildSettings;
      if (settings?.PRODUCT_BUNDLE_IDENTIFIER) {
        settings.SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD = 'NO';
        settings.SUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD = 'NO';
      }
    }
    return config;
  });
};
