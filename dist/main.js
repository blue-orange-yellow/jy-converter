// Tauri Bridge for Elm
// YAML is loaded from CDN in index.html

// Elmアプリの初期化を待つ
window.addEventListener('DOMContentLoaded', () => {
  // Wait for YAML to be loaded
  const YAML = window.YAML;
  if (!YAML) {
    console.error('YAML library not loaded');
    return;
  }

  const app = window.Elm.Main.init({ node: document.getElementById("app") });

  // Elm -> JS: JSON to YAML変換リクエスト
  app.ports.jsonToYaml.subscribe((jsonStr) => {
    try {
      const obj = JSON.parse(jsonStr);
      const yaml = YAML.stringify(obj);
      app.ports.onJsonToYaml.send(yaml);
    } catch (e) {
      app.ports.onError.send(formatError("JSON parse/convert", e));
    }
  });

  // Elm -> JS: YAML to JSON変換リクエスト
  app.ports.yamlToJson.subscribe((yamlStr) => {
    try {
      const obj = YAML.parse(yamlStr);
      const json = JSON.stringify(obj, null, 2);
      app.ports.onYamlToJson.send(json);
    } catch (e) {
      app.ports.onError.send(formatError("YAML parse/convert", e));
    }
  });

  // Elm -> JS: クリップボードコピー
  app.ports.copyToClipboard.subscribe(async (text) => {
    try {
      await navigator.clipboard.writeText(text || "");
    } catch (e) {
      app.ports.onError.send("Failed to copy to clipboard.");
    }
  });

  function formatError(context, e) {
    if (!e) return `${context} error.`;
    const loc = (e.line != null && e.col != null) ? ` (line ${e.line}, col ${e.col})` : "";
    return `${context} error${loc}: ${e.message || String(e)}`;
  }
});
