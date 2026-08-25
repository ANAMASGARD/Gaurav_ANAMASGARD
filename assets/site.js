<script>
window.addEventListener("DOMContentLoaded", () => {
  const toggle = document.querySelector(".quarto-color-scheme-toggle");
  const clickSoundUrl = "/assets/click-003.mp3";
  const AudioContextConstructor = window.AudioContext || window.webkitAudioContext;
  const clickableSelector = [
    "a[href]",
    "button",
    "summary",
    'input[type="button"]',
    'input[type="submit"]',
    'input[type="reset"]',
    'input[type="checkbox"]',
    'input[type="radio"]',
    "label[for]",
    '[role="button"]',
    '[role="link"]',
    '[role="switch"]',
    '[role="tab"]',
  ].join(", ");
  const fallbackSound = new Audio(clickSoundUrl);
  const clickBytesPromise = fetch(clickSoundUrl, { cache: "force-cache" })
    .then((response) => {
      if (!response.ok) throw new Error(`Unable to load click sound: ${response.status}`);
      return response.arrayBuffer();
    });
  let audioContext;
  let clickBufferPromise;

  fallbackSound.preload = "auto";
  fallbackSound.volume = 1;
  fallbackSound.load();
  void clickBytesPromise.catch(() => {
    // The preloaded HTML audio remains available if Web Audio decoding fails.
  });

  const findClickableControl = (target) =>
    target instanceof Element ? target.closest(clickableSelector) : null;

  const isUnavailable = (control) => {
    if (control.matches(':disabled, [aria-disabled="true"]')) return true;

    if (control.matches("label[for]")) {
      const labelledControl = document.getElementById(control.htmlFor);
      return labelledControl?.matches(':disabled, [aria-disabled="true"]') ?? false;
    }

    return false;
  };

  const playFallbackSound = () => {
    const sound = fallbackSound.cloneNode();
    sound.volume = 1;
    void sound.play().catch(() => {
      // The browser, tab, or operating system may be muted.
    });
  };

  const playClickSound = () => {
    if (!AudioContextConstructor) {
      playFallbackSound();
      return;
    }

    try {
      audioContext ??= new AudioContextConstructor();
    } catch {
      playFallbackSound();
      return;
    }

    const startSound = async () => {
      if (audioContext.state === "suspended") await audioContext.resume();
      if (audioContext.state !== "running") throw new Error("Audio context is unavailable");

      clickBufferPromise ??= clickBytesPromise.then((bytes) =>
        audioContext.decodeAudioData(bytes.slice(0))
      );

      const source = audioContext.createBufferSource();
      const gain = audioContext.createGain();
      source.buffer = await clickBufferPromise;
      gain.gain.value = 1;
      source.connect(gain);
      gain.connect(audioContext.destination);
      source.start(0);
    };

    void startSound().catch(playFallbackSound);
  };

  document.addEventListener("pointerdown", (event) => {
    if (!event.isPrimary || event.button !== 0) return;

    const control = findClickableControl(event.target);
    if (!control || isUnavailable(control)) return;

    playClickSound();
  }, { capture: true });

  document.addEventListener("keydown", (event) => {
    if (event.repeat) return;

    const control = findClickableControl(event.target);
    if (!control || isUnavailable(control)) return;

    const supportsEnter = control.matches(
      'a[href], button, summary, input[type="button"], input[type="submit"], input[type="reset"], [role="button"], [role="link"], [role="switch"], [role="tab"]'
    );
    const supportsSpace = control.matches(
      'button, summary, input[type="button"], input[type="submit"], input[type="reset"], input[type="checkbox"], input[type="radio"], [role="button"], [role="switch"], [role="tab"]'
    );
    if (!(event.key === "Enter" && supportsEnter) && !(event.key === " " && supportsSpace)) return;

    playClickSound();
  }, { capture: true });

  if (!toggle || typeof window.quartoToggleColorScheme !== "function") return;

  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  toggle.classList.add("theme-switch");
  toggle.setAttribute("role", "switch");
  toggle.innerHTML = [
    '<span class="theme-switch-icon" aria-hidden="true">☀</span>',
    '<span class="theme-switch-icon" aria-hidden="true">☾</span>',
    '<span class="theme-switch-thumb" aria-hidden="true"></span>',
  ].join("");

  const updateState = () => {
    const isDark = document.body.classList.contains("quarto-dark");
    const destination = isDark ? "light" : "dark";
    toggle.setAttribute("aria-checked", String(isDark));
    toggle.setAttribute("aria-label", `Switch to ${destination} theme`);
    toggle.setAttribute("title", `Switch to ${destination} theme`);
  };

  toggle.addEventListener("click", (event) => {
    if (typeof document.startViewTransition !== "function" || reducedMotion.matches) {
      window.setTimeout(updateState, 0);
      return;
    }

    event.preventDefault();
    event.stopImmediatePropagation();
    document.startViewTransition(() => window.quartoToggleColorScheme());
  }, { capture: true });

  toggle.addEventListener("keydown", (event) => {
    if (event.key === " " || event.key === "Enter") {
      event.preventDefault();
      toggle.click();
    }
  });

  new MutationObserver(updateState).observe(document.body, {
    attributes: true,
    attributeFilter: ["class"],
  });
  updateState();
});
</script>
