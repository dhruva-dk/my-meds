const fs = require('fs');
const path = require('path');
const { IOSConfig, withDangerousMod, withXcodeProject } = require('expo/config-plugins');

const NAME = 'AccentColor';

function component(hex, start) {
  return `0x${hex.slice(start, start + 2)}`;
}

function colorEntry(hex, appearances) {
  return {
    ...(appearances ? { appearances } : {}),
    color: {
      'color-space': 'srgb',
      components: {
        alpha: '1.000',
        red: component(hex, 1),
        green: component(hex, 3),
        blue: component(hex, 5),
      },
    },
    idiom: 'universal',
  };
}

/**
 * Sets the app's global accent colour, which SwiftUI and UIKit controls inherit: tab bar, alerts,
 * pickers and any control without its own tint. Keep in step with ACCENT in src/ui/theme.ts.
 */
module.exports = function withAccentColor(config, { light, dark }) {
  config = withDangerousMod(config, [
    'ios',
    (config) => {
      const sourceRoot = IOSConfig.Paths.getSourceRoot(config.modRequest.projectRoot);
      const directory = path.join(sourceRoot, 'Images.xcassets', `${NAME}.colorset`);
      fs.mkdirSync(directory, { recursive: true });
      fs.writeFileSync(
        path.join(directory, 'Contents.json'),
        JSON.stringify(
          {
            colors: [
              colorEntry(light),
              colorEntry(dark, [{ appearance: 'luminosity', value: 'dark' }]),
            ],
            info: { author: 'expo', version: 1 },
          },
          null,
          2,
        ),
      );
      return config;
    },
  ]);

  return withXcodeProject(config, (config) => {
    const configurations = config.modResults.pbxXCBuildConfigurationSection();
    for (const key of Object.keys(configurations)) {
      const settings = configurations[key].buildSettings;
      if (settings?.PRODUCT_BUNDLE_IDENTIFIER) {
        settings.ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = NAME;
      }
    }
    return config;
  });
};
