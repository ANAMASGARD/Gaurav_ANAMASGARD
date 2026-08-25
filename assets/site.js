<script>
window.addEventListener("DOMContentLoaded", () => {
  const toggle = document.querySelector(".quarto-color-scheme-toggle");
  const clickSound = new Audio("/assets/click-003.mp3");

  clickSound.preload = "auto";
  clickSound.volume = 0.5;

  const playClickSound = () => {
    clickSound.currentTime = 0;
    void clickSound.play().catch(() => {
      // Browsers may block audio until the page receives a user gesture.
    });
  };

  document
    .querySelectorAll(
      ".navbar-nav .nav-link, .week-nav-link, .quarto-color-scheme-toggle"
    )
    .forEach((control) =>
      control.addEventListener("click", playClickSound, { capture: true })
    );

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
