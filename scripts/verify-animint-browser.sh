#!/usr/bin/env bash
set -euo pipefail

base_url="${1:-http://127.0.0.1:4311}"

cleanup() {
  browse stop >/dev/null 2>&1 || true
}
trap cleanup EXIT

assert_eval() {
  local expression="$1"
  local description="$2"
  local output
  output="$(browse eval "$expression")"
  if ! printf '%s' "$output" | jq -e '.result.pass == true' >/dev/null; then
    printf 'FAIL: %s\n%s\n' "$description" "$output" >&2
    exit 1
  fi
  printf 'PASS: %s\n' "$description"
}

open_demo() {
  local route="$1"
  browse open "$base_url$route" --local >/dev/null
  browse eval 'document.querySelector(".animint-live-demo iframe").scrollIntoView({block:"center"}); true' >/dev/null
  browse wait timeout 1800 >/dev/null

  assert_eval '(() => {
    const frame = document.querySelector(".animint-live-demo iframe");
    const plot = frame.contentDocument.querySelector("#plot");
    const contentBottom = Math.ceil(plot.getBoundingClientRect().bottom);
    const excess = frame.clientHeight - contentBottom;
    return {
      pass: excess >= 0 && excess <= 16,
      frameHeight: frame.clientHeight,
      contentBottom,
      excess
    };
  })()' "Animint iframe fits its rendered content without excess blank space for $route"
}

open_demo "/journal/week-1/"
assert_eval '(() => {
  const d = document.querySelector(".animint-live-demo iframe").contentDocument;
  return { pass:
    !!d.querySelector(".geom1_line_default path") &&
    !!d.querySelector(".geom4_point_optedout circle") &&
    !!d.querySelector("#plot_default_comparison_variable_treatment")
  };
})()' "Week 1 Animint marks and legend are ready before interaction"
assert_eval '(() => {
  try {
    const d = document.querySelector(".animint-live-demo iframe").contentDocument;
    window.__week1Before = {
      path: d.querySelector(".geom1_line_default path").getAttribute("d"),
      optedCount: d.querySelectorAll(".geom4_point_optedout circle").length
    };
    d.querySelector("#plot_default_comparison_variable_treatment")
      .dispatchEvent(new d.defaultView.MouseEvent("click", {
        bubbles: true,
        view: d.defaultView
      }));
    return { pass: true };
  } catch (error) {
    return { pass: false, error: String(error), stack: error.stack };
  }
})()' "Week 1 legend interaction dispatches in the Animint iframe"
browse wait timeout 700 >/dev/null
assert_eval '(() => {
  const d = document.querySelector(".animint-live-demo iframe").contentDocument;
  const afterPath = d.querySelector(".geom1_line_default path").getAttribute("d");
  return { pass:
    afterPath !== window.__week1Before.path &&
    d.querySelectorAll(".geom4_point_optedout circle").length === window.__week1Before.optedCount &&
    d.querySelector(".comparison_variable_input .item").textContent.trim() === "treatment"
  };
})()' "Week 1 legend changes the default plot while the historical opt-out plot remains complete"

open_demo "/journal/week-2/"
browse eval '(() => {
  const d = document.querySelector(".animint-live-demo iframe").contentDocument;
  window.__week2Before = Array.from(d.querySelectorAll(".geom1_point_scatter circle"))
    .map((node) => node.getAttribute("cx") + "," + node.getAttribute("cy"))
    .join("|");
  d.querySelector(".year_variable_input").selectize.setValue("year___1970");
  return true;
})()' >/dev/null
browse wait timeout 900 >/dev/null
assert_eval '(() => {
  const d = document.querySelector(".animint-live-demo iframe").contentDocument;
  const after = Array.from(d.querySelectorAll(".geom1_point_scatter circle"))
    .map((node) => node.getAttribute("cx") + "," + node.getAttribute("cy"))
    .join("|");
  return { pass:
    after !== window.__week2Before &&
    d.querySelector(".year_variable_selector_widget .item").textContent.trim() === "1970" &&
    !d.querySelector(".region_variable_selector_widget") &&
    !!d.querySelector(".scatter_legend .region_variable")
  };
})()' "Week 2 keeps explicit year filtering and a visible legend without injecting a region selector"

open_demo "/journal/week-10/"
assert_eval '(() => {
  const frame = document.querySelector(".animint-live-demo iframe");
  const d = frame.contentDocument;
  const plots = Array.from(d.querySelectorAll("svg[id^=\"plot_\"]"));
  const inside = plots.every((plot) => {
    const rect = plot.getBoundingClientRect();
    return rect.left >= -1 && rect.right <= frame.clientWidth + 1 && rect.width > 300;
  });
  return { pass:
    plots.length === 3 && inside &&
    !d.querySelector("[class$=\"_variable_selector_widget\"]")
  };
})()' "Week 10 renders all three large panel-margin plots without a fabricated selector"

open_demo "/journal/final-submission/"
assert_eval '(() => {
  const frame = document.querySelector(".animint-live-demo iframe");
  const d = frame.contentDocument;
  const plot = d.querySelector("svg[id^=\"plot_\"]");
  const plotRect = plot.getBoundingClientRect();
  const legend = d.querySelector(".multiline_legend");
  const legendRect = legend.getBoundingClientRect();
  const expected = ["Multi-line text in Animint2", "Feature", "workstream", "Interactive labels", "Renderer output"];
  const text = d.body.textContent;
  const textInside = Array.from(plot.querySelectorAll("text")).every((node) => {
    const rect = node.getBoundingClientRect();
    return rect.left >= plotRect.left - 2 && rect.right <= plotRect.right + 2;
  });
  return { pass:
    expected.every((value) => text.includes(value)) &&
    plotRect.right <= frame.clientWidth + 1 &&
    legendRect.right <= frame.clientWidth + 1 &&
    textInside
  };
})()' "Final Submission renders multiline titles, axes, legend, and labels without horizontal cropping"

browse viewport 390 844 >/dev/null
for route in /journal/week-1/ /journal/week-2/ /journal/week-10/ /journal/final-submission/; do
  browse open "$base_url$route" >/dev/null
  browse eval 'document.querySelector(".animint-live-demo iframe").scrollIntoView({block:"center"}); true' >/dev/null
  browse wait timeout 1200 >/dev/null
  assert_eval '(() => {
    const frame = document.querySelector(".animint-live-demo iframe");
    const d = frame.contentDocument;
    const frameRect = frame.getBoundingClientRect();
    const plots = Array.from(d.querySelectorAll("svg[id^=\"plot_\"]"));
    return { pass:
      plots.length > 0 &&
      plots.every((plot) => plot.getBoundingClientRect().right <= frame.clientWidth + 1) &&
      frameRect.left >= -1 &&
      frameRect.right <= document.documentElement.clientWidth + 1 &&
      d.documentElement.scrollWidth <= d.documentElement.clientWidth + 1
    };
  })()' "Mobile geometry remains inside the viewport for $route"
done

browse eval 'document.querySelector(".quarto-color-scheme-toggle").click(); true' >/dev/null
browse wait timeout 300 >/dev/null
assert_eval '(() => {
  const frame = document.querySelector(".animint-live-demo iframe");
  return { pass:
    document.body.classList.contains("quarto-dark") &&
    getComputedStyle(frame.contentDocument.body).backgroundColor === "rgb(255, 255, 255)"
  };
})()' "Dark mode preserves the white Animint plotting canvas"

printf 'Verified all responsive Animint demos in local desktop/mobile and light/dark modes.\n'
