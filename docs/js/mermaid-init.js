/* docs/js/mermaid-init.js */
(function () {
  function convertCodeFencesToMermaid() {
    // Turn ```mermaid fenced blocks (rendered as <pre><code class="language-mermaid">)
    // into <div class="mermaid"> so Mermaid can render them.
    document.querySelectorAll('pre > code.language-mermaid').forEach(function (code) {
      var pre = code.parentElement;
      var container = document.createElement('div');
      container.className = 'mermaid';
      container.textContent = code.textContent;
      pre.replaceWith(container);
    });
  }

  function init() {
    convertCodeFencesToMermaid();
    if (window.mermaid) {
      window.mermaid.initialize({ startOnLoad: true, securityLevel: "loose" });
      // In case the page swaps content dynamically:
      window.mermaid.init(undefined, document.querySelectorAll('.mermaid'));
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
