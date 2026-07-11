import { marked } from 'marked';
import katex from 'katex';
import 'katex/dist/katex.min.css';

marked.use({ breaks: true, gfm: true });

function renderContent(text) {
  const store = [];

  // Protect LaTeX with simple placeholders (no special Markdown chars)
  let src = text
    .replace(/\$\$([\s\S]+?)\$\$/g, (_, math) => {
      const id = store.length;
      store.push({ math: math.trim(), display: true });
      return `XLATEXDX${id}X`;
    })
    .replace(/\$([^$\n]+?)\$/g, (_, math) => {
      const id = store.length;
      store.push({ math: math.trim(), display: false });
      return `XLATEXI${id}X`;
    });

  // Render Markdown
  let html = marked.parse(src);

  // Restore LaTeX
  html = html.replace(/XLATEXDX(\d+)X/g, (_, i) => {
    const { math } = store[+i];
    try {
      return `<div class="math-display">${katex.renderToString(math, { throwOnError: false, displayMode: true })}</div>`;
    } catch { return `<span class="math-error">${math}</span>`; }
  });
  html = html.replace(/XLATEXI(\d+)X/g, (_, i) => {
    const { math } = store[+i];
    try {
      return katex.renderToString(math, { throwOnError: false, displayMode: false });
    } catch { return `<span class="math-error">${math}</span>`; }
  });

  return html;
}

export default function ContentRenderer({ text, style = {} }) {
  if (!text) return null;
  return (
    <div className="cr-body" style={{ lineHeight: 1.75, ...style }}
      dangerouslySetInnerHTML={{ __html: renderContent(text) }} />
  );
}
