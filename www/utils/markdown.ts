// Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

import Prism from "prismjs";
import "prismjs/components/prism-jsx.js";
import "prismjs/components/prism-typescript.js";
import "prismjs/components/prism-tsx.js";
import "prismjs/components/prism-diff.js";
import "prismjs/components/prism-json.js";
import "prismjs/components/prism-bash.js";
import "prismjs/components/prism-yaml.js";
import "prismjs/components/prism-gdscript.js";

// Adapted from: https://github.com/denoland/fresh

export { extractYaml as frontMatter } from "@std/front-matter";

import * as Marked from "marked";
import { escape as escapeHtml } from "@std/html";
import { mangle } from "marked-mangle";
import GitHubSlugger from "github-slugger";

Marked.marked.use(mangle());

const ADMISSION_REG = /^\[(info|warn|tip)\]:\s/;

export interface MarkdownHeading {
  id: string;
  html: string;
}

class DefaultRenderer extends Marked.Renderer {
  headings: MarkdownHeading[] = [];

  override text(
    token: Marked.Tokens.Text | Marked.Tokens.Escape | Marked.Tokens.Tag,
  ): string {
    if (
      token.type === "text" && "tokens" in token && token.tokens !== undefined
    ) {
      return this.parser.parseInline(token.tokens);
    }

    // Smartypants typography enhancement
    return token.text
      .replaceAll("...", "&#8230;")
      .replaceAll("--", "&#8212;")
      .replaceAll("---", "&#8211;")
      .replaceAll(/(\w)'(\w)/g, "$1&#8217;$2")
      .replaceAll(/s'/g, "s&#8217;")
      .replaceAll("&#39;", "&#8217;")
      .replaceAll(/["](.*?)["]/g, "&#8220;$1&#8221")
      .replaceAll(/&quot;(.*?)&quot;/g, "&#8220;$1&#8221")
      .replaceAll(/['](.*?)[']/g, "&#8216;$1&#8217;");
  }

  override heading({
    tokens,
    depth,
    raw,
  }: Marked.Tokens.Heading): string {
    const slug = new GitHubSlugger().slug(raw).replace(/^-/, "");
    const text = this.parser.parseInline(tokens);
    this.headings.push({ id: slug, html: text });
    return `<h${depth} id="${slug}"><a class="md-anchor" tabindex="-1" href="#${slug}">${text}<span aria-hidden="true">#</span></a></h${depth}>`;
  }

  override link({ href, title, tokens }: Marked.Tokens.Link) {
    const text = this.parser.parseInline(tokens);
    const titleAttr = title ? ` title="${title}"` : "";
    if (href.startsWith("#")) {
      return `<a href="${href}"${titleAttr}>${text}</a>`;
    }

    const [parsedHref, isAbsolute] = parseLink(href);
    const target = isAbsolute ? ' target="_blank"' : "";
    return `<a href="${parsedHref}"${titleAttr}${target} rel="noopener noreferrer">${text}</a>`;
  }

  override image({ href, text, title }: Marked.Tokens.Image) {
    return `<img src="${href}" alt="${text ?? ""}" title="${title ?? ""}" />`;
  }

  override code({ lang: info, text }: Marked.Tokens.Code): string {
    // format: tsx
    // format: tsx my/file.ts
    // format: tsx "This is my title"
    let lang = "";
    let title = "";
    const match = info?.match(/^([\w_-]+)\s*(.*)?$/);
    if (match) {
      lang = match[1].toLocaleLowerCase();
      title = match[2] ?? "";
    }

    let out = `<div class="fenced-code">`;

    if (title) {
      out += `<div class="fenced-code-header">
        <span class="fenced-code-title lang-${lang}">
          ${title ? escapeHtml(String(title)) : "&nbsp;"}
        </span>
      </div>`;
    }

    const grammar = lang && Object.hasOwnProperty.call(Prism.languages, lang)
      ? Prism.languages[lang]
      : undefined;

    if (grammar === undefined) {
      out += `<pre><code class="notranslate">${escapeHtml(text)}</code></pre>`;
    } else {
      const html = Prism.highlight(text, grammar, lang);
      out +=
        `<pre class="highlight highlight-source-${lang} notranslate lang-${lang}"><code>${html}</code></pre>`;
    }

    out += `</div>`;
    return out;
  }

  override blockquote({ text, tokens }: Marked.Tokens.Blockquote): string {
    const match = text.match(ADMISSION_REG);

    if (match) {
      const label: Record<string, string> = {
        tip: "Tip",
        warn: "Warning",
        info: "Info",
      };
      Marked.walkTokens(tokens, (token) => {
        if (token.type === "text" && token.text.startsWith(match[0])) {
          token.text = token.text.slice(match[0].length);
        }
        if (token.type === "link" && token.href) {
          const [parsedHref] = parseLink(token.href);
          token.href = parsedHref;
        }
      });
      const type = match[1];
      const icon = `<svg class="icon"><use href="/icons.svg#${type}" /></svg>`;
      return `<blockquote class="admonition ${type} text-foreground-tertiary">\n<span class="admonition-header">${icon}${
        label[type]
      }</span>${
        Marked.parser(tokens, { renderer: new DefaultRenderer() })
      }</blockquote>\n`;
    }
    return `<blockquote>\n${
      Marked.parser(tokens, { renderer: new DefaultRenderer() })
    }</blockquote>\n`;
  }
}

function parseLink(link: string): [parsed: string, isAbsolute: boolean] {
  let parsedHref = link;
  const isAbsolute = parsedHref.startsWith("https://");
  if (parsedHref.endsWith(".md") && !isAbsolute) {
    parsedHref = parsedHref
      .replace(/\.md$/, "")
      .replace(/\/index$/, "")
      .replace(/(\.\.\/)+/, "/docs/");
  }
  return [parsedHref, isAbsolute];
}

export interface MarkdownOptions {
  inline?: boolean;
}
export function renderMarkdown(
  _url: URL,
  input: string,
  opts: MarkdownOptions = {},
): { headings: MarkdownHeading[]; html: string } {
  const renderer = new DefaultRenderer();
  const markedOpts: Marked.MarkedOptions = {
    gfm: true,
    renderer,
  };

  // Ensure that markdown images are correctly rendered
  // but also easily reviewable
  const parsedInput = input.replace(
    /(!\[.*\]\()((\.\.\/)+www\/static\/docs)/g,
    "$1/docs",
  );

  const html = opts.inline
    ? Marked.parseInline(parsedInput, markedOpts) as string
    : Marked.parse(parsedInput, markedOpts) as string;

  return { headings: renderer.headings, html };
}
