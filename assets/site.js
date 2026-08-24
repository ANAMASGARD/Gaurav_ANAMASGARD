<script>
window.addEventListener("DOMContentLoaded", () => {
  const toggle = document.querySelector(".quarto-color-scheme-toggle");
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
