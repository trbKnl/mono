export const GetText = (function() {
    'use strict';

    const defaultLocale = "nl"

    /* PUBLIC */

    function resolve(translatable, locale){
      if (typeof translatable === 'object' && translatable !== null) {

        if (translatable[locale]) {
          return translatable[locale]
        }

        if (defaultLocale in translatable) {
          return translatable[defaultLocale]
        }

        if (Object.values(translatable).length > 0) {
          return Object.values(translatable)[0]
        }
      }

      console.log("[GetText] Invalid translatable", translatable)
      return "?text?"
    }

    /* PRIVATE */

    /* MODULE INTERFACE */

    return {
      resolve,
    }
})();