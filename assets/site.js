<script>
(() => {
  const match = window.location.pathname.match(/\/week-(\d{2})\/?$/);
  if (!match) return;

  const activeWeek = String(Number(match[1]));
  const activeLink = document.querySelector(
    `.week-nav-link[data-week="${activeWeek}"]`,
  );
  if (!activeLink) return;

  activeLink.classList.add("is-active");
  activeLink.setAttribute("aria-current", "page");

  if (activeLink.scrollIntoView && window.matchMedia("(max-width: 767px)").matches) {
    activeLink.scrollIntoView({ block: "nearest", inline: "center" });
  }
})();
</script>
