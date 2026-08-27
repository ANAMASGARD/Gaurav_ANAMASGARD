(() => {
  const configurePlots = () => {
    document.querySelectorAll('svg[id^="plot_"]').forEach((plot) => {
      if (plot.hasAttribute("viewBox")) return;

      const width = Number(plot.getAttribute("width"));
      const height = Number(plot.getAttribute("height"));
      if (!Number.isFinite(width) || !Number.isFinite(height)) return;

      plot.setAttribute("viewBox", `0 0 ${width} ${height}`);
      plot.setAttribute("preserveAspectRatio", "xMidYMid meet");
    });
  };

  const reportHeight = () => {
    configurePlots();
    const content = document.getElementById("plot") ?? document.body;
    const height = Math.ceil(
      (content?.getBoundingClientRect().bottom ?? 0) + window.scrollY
    );
    window.parent.postMessage(
      { type: "animint:resize", height },
      window.location.origin
    );
  };

  window.addEventListener("load", () => {
    requestAnimationFrame(() => requestAnimationFrame(reportHeight));
  });
  window.addEventListener("resize", reportHeight);

  if (typeof ResizeObserver === "function") {
    const observer = new ResizeObserver(reportHeight);
    observer.observe(document.documentElement);
    if (document.body) observer.observe(document.body);
  }

  new MutationObserver(() => requestAnimationFrame(reportHeight)).observe(
    document.documentElement,
    { childList: true, subtree: true }
  );
})();
