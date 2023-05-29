// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//

import "@ryangjchandler/spruce";
import "alpine-magic-helpers/dist/component";
import Alpine from "alpinejs";
import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import { decode } from "blurhash";
import { urlBase64ToUint8Array } from "./tools";
import { registerAPNSDeviceToken } from "./apns";
import "./100vh-fix";
import { ViewportResize } from "./viewport_resize";
import { Toggle } from "./toggle";
import { LiveContent, LiveField } from "./live_content";
import { Tabbar, TabbarItem, TabbarFooterItem } from "./tabbar";
import { PythonUploader } from "./python_uploader";
import { Clipboard } from "./clipboard";
import { DataDonationHook } from "./data_donation_hook";
import { Port } from "./port";

window.registerAPNSDeviceToken = registerAPNSDeviceToken;

window.blurHash = () => {
  return {
    show: true,
    rendered: false,
    showBlurHash() {
      return this.show !== false;
    },
    reset() {
      console.log("Reset blurhash");
    },
    hideBlurHash() {
      if (!liveSocket.socket.isConnected()) {
        return;
      }
      this.show = false;
    },
    render() {
      console.log("Render blurhash");
      const img = this.$el.getElementsByTagName("img")[0];
      if (img.complete) {
        this.show = false;
        return;
      }
      if (this.rendered) {
        return;
      }
      this.rendered = true;
      const canvas = this.$el.getElementsByTagName("canvas")[0];
      const blurhash = canvas.dataset.blurhash;
      const width = parseInt(canvas.getAttribute("width"), 10);
      const height = parseInt(canvas.getAttribute("height"), 10);
      const pixels = decode(blurhash, width, height);
      const ctx = canvas.getContext("2d");
      const imageData = ctx.createImageData(width, height);
      imageData.data.set(pixels);
      ctx.putImageData(imageData, 0, 0);
    },
  };
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

const NativeWrapper = {
  mounted() {
    console.log("NativeWrapper mounted");
    window.nativeWrapperHook = this;
  },
  toggleSidePanel() {
    console.log("NativeWrapper::toggleSidePanel");
    nativeWrapper.toggleSidePanel({ origin: "right" });
    window.dispatchEvent(new CustomEvent("toggle-native-menu", {}));
  },
};

let Hooks = {
  Clipboard,
  ViewportResize,
  Toggle,
  LiveContent,
  LiveField,
  Tabbar,
  TabbarItem,
  TabbarFooterItem,
  NativeWrapper,
  PythonUploader,
  DataDonationHook,
  Port,
};

let liveSocket = new LiveSocket("/live", Socket, {
  dom: {
    onBeforeElUpdated(from, to) {
      if (from.__x) {
        window.Alpine.clone(from.__x, to);
      } else {
        LiveContent.onBeforeElUpdated(from, to);
      }
    },
  },
  params: {
    _csrf_token: csrfToken,
    viewport: {
      width: window.innerWidth,
      height: window.innerHeight,
    },
  },
  hooks: Hooks,
});

const nativeIOSWrapper = {
  // The native code bridge assumes that handlers have been setup. Seethe docs for more info:
  // https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537172-add
  //
  // Uncomment each section to enable it.
  setScreenState: (id, state) => {
    window.webkit.messageHandlers.Native.postMessage({
      type: "setScreenState",
      id,
      state,
    });
  },
  openScreen: (info) => {
    if (info.subtype === "push") {
      window.scrollTo(0, -100); // TBD: makes sure new page is scrolled to top, even with transparant top bar (ios)
    }

    window.webkit.messageHandlers.Native.postMessage({
      type: "openScreen",
      ...info,
    });
  },
  pushModal: () => {
    window.webkit.messageHandlers.Native.postMessage({
      type: "pushModal",
    });
  },
  popModal: () => {
    window.webkit.messageHandlers.Native.postMessage({
      type: "popModal",
    });
  },
  updateScreenInfo: (info) => {
    window.webkit.messageHandlers.Native.postMessage({
      type: "updateScreen",
      ...info,
    });
  },
  webReady: (id) => {
    window.webkit.messageHandlers.Native.postMessage({
      type: "webReady",
      id,
    });
  },
  toggleSidePanel: (info) => {
    window.webkit.messageHandlers.Native.postMessage({
      type: "toggleSidePanel",
      ...info,
    });
  },
};

const loggingWrapper = {
  setScreenState: (id, info) => {
    console.log(id, info);
  },
  openScreen: (info) => {
    console.log("open screen", info);
  },
  pushModal: () => {
    console.log("push modal screen");
  },
  popModal: () => {
    console.log("pop modal screen");
  },
  updateScreenInfo: (info) => {
    console.log("set screen info", info);
  },
  webReady: (id) => {
    console.log("web ready", id);
  },
  toggleSidePanel: (info) => {
    console.log("toggle side panel", info);
  },
};

const nativeWrapper =
  window.webkit && window.webkit.messageHandlers !== undefined
    ? nativeIOSWrapper
    : loggingWrapper;

const screenId = (urlString) => {
  const url = new URL(urlString);
  const params = new URLSearchParams(url.search);
  params.delete("_no");
  return `${url.protocol}//${url.host}${url.pathname}?${params.toString()}`;
};

window.addEventListener("phx:page-loading-start", (info) => {
  // other kind options are "error" and "initial"
  console.log("phx:page-loading-start");
  if (info.detail.kind === "redirect") {
    const to = new URL(info.detail.to);
    const nativeOperation = to.searchParams.get("_no");
    console.log("nativeOperation", nativeOperation);
    nativeWrapper.setScreenState(screenId(window.location), {
      scrollPosition: window.scrollY,
    });
    if (nativeOperation === "replace") {
      nativeWrapper.openScreen({
        id: screenId(info.detail.to),
        subtype: "replace",
      });
    } else {
      nativeWrapper.openScreen({
        id: screenId(info.detail.to),
        subtype: "push",
      });
    }
  }
});

const updateState = (state) => {
  window.scroll(0, state ? state.scrollPosition : 0);
};

window.addEventListener("phx:page-loading-stop", (info) => {
  if (info.detail.kind !== "initial") {
    return;
  }
  const titleNode = document.querySelector("[data-native-title]");
  const title = titleNode ? titleNode.dataset.nativeTitle : "- no title set -";
  nativeWrapper.updateScreenInfo({
    title,
    id: screenId(info.detail.to),
    rightBarButtons: [
      {
        title: "Menu",
        action: { id: "toggle-native-menu" },
      },
    ],
  });
  nativeWrapper.webReady(screenId(info.detail.to));
});

window.setScreenFromNative = (screenId, state) => {
  liveSocket.replaceMain(screenId, null, () => {
    setTimeout(() => {
      updateState(state);
    }, 0);
  });
};
window.handleActionFromNative = (action) => {
  if (action.id === "toggle-native-menu") {
    nativeWrapper.toggleSidePanel({ origin: "right" });
    window.dispatchEvent(new CustomEvent("toggle-native-menu", {}));
  }
};

window.setStateFromNative = (state) => {
  updateState(state);
};

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// PWA
//
const pushStore = Spruce.store("push", { registration: "pending" });
const getExistingSubscription = () => {
  return navigator.serviceWorker.ready.then((registration) => {
    return registration.pushManager.getSubscription().then((subscription) => {
      return { registration, subscription };
    });
  });
};
const registerPushSubscription = (subscription) => {
  console.log("Server", subscription);
  return fetch("/web-push/register", {
    method: "post",
    headers: {
      "Content-type": "application/json",
    },
    body: JSON.stringify({
      subscription: subscription,
    }),
  }).then(() => {
    pushStore.registration = "registered";
  });
};

window.registerForPush = () => {
  if (!("serviceWorker" in navigator)) {
    alert("Sorry, your browser does not support push");
    return;
  }
  pushStore.registration = "registering";
  getExistingSubscription()
    .then(({ registration, subscription }) => {
      if (subscription) {
        // already registered
        return subscription;
      }

      return fetch("/web-push/vapid-public-key")
        .then((response) => {
          console.log("Vapid", response);
          return response.text();
        })
        .then((vapidPublicKey) => {
          // Chrome doesn’t accept the base64-encoded (string) vapidPublicKey yet urlBase64ToUint8Array() is defined in /tools.js
          const convertedVapidKey = urlBase64ToUint8Array(vapidPublicKey);

          return registration.pushManager.subscribe({
            userVisibleOnly: true,
            applicationServerKey: convertedVapidKey,
          });
        });
    })
    .then(registerPushSubscription)
    .catch((e) => {
      pushStore.registration = "denied";
    });
};
if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("/sw.js", { scope: "./" }).catch((error) => {
    // registration failed
    console.log("Registration failed with " + error);
  });

  getExistingSubscription().then(({ subscription }) => {
    if (subscription) {
      return registerPushSubscription(subscription);
    } else {
      pushStore.registration = "not-registered";
    }
  });
} else {
  Spruce.store("push", { registration: "unavailable" });
}
