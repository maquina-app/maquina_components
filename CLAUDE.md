# maquina_components

Rails engine of server-rendered shadcn/ui-style components (ERB partials + Tailwind v4 + Stimulus). The gem is `maquina-components`; the repo and Ruby namespace are `maquina_components`.

## Partials (`app/views/components/`)

Canonical example: `_badge.html.erb`.
- Strict locals with symbol defaults; symbol-valued locals also accept strings (`.to_sym` before comparing)
- `css_classes:` (never `class:`), rendered as `class: css_classes.presence`, so no empty `class=""` is output
- Always `**html_options` passthrough
- Merge `data:` with `merge_component_data` (`components_helper.rb`), never by hand. The component keeps `component`/`variant`/`size`; a user's `controller`/`action` is appended
- No inline Tailwind utilities in partials; styling goes through data attributes

## CSS (`app/assets/stylesheets/`)

The contract is at the top of `form.css`; canonical example: `badge.css`. `test/stylesheets/css_conventions_test.rb` enforces it.
- Every rule in `@layer components`, flattened to 0,1,0 with `:where()`, so a caller's `css_classes:` utility wins
- Order inside a file: base → sizes → variants → states
- Colors via theme variables; `--success`/`--warning`/`--info` always need a fallback
- Radius/elevation/focus/weight come from tokens (`tokens.css`), never `rounded-*`/`shadow-*`
- Focus rings are outlines (never box-shadows), and never transition `outline-color`
- No `.dark` or `prefers-color-scheme` in component CSS; dark mode comes from tokens only
- `engine.css` import order is load-bearing: **never alphabetize**. Put a new import in its group (Primitives/Composites), after everything it overrides

## Definition of Done (new or changed component)

1. Follows the Partials and CSS rules above; focus/hover/disabled states and SVG sizing covered
2. Imported in `engine.css` in the right place; CSS rebuilt; `bin/test` green
3. `docs/{component}.md` has a parameters table, variants/sizes, usage and real-world examples
4. **Any API change** (locals, variants, sizes, data attributes, sub-partials, helper signatures, Stimulus targets/values/actions) updates `docs/{component}.md` and `references/available_components.md` in the same change, including renamed or removed options
5. Ruby/ERB reviewed with the `rails-simplifier:simplify` skill; UI checked with the `maquina-ui-standards:ui` skill
6. Preview added and verified in a browser; existing previews unchanged and still rendering

## Previews (`test/dummy/app/views/previews/`)

**Never edit or delete an existing preview.** https://maquina.app/documentation/components/ embeds them as iframes; fix the component, not the preview. New examples need no approval but must:
- Live at `previews/{component}/{example}.html.erb` (`{component}` = docs basename, snake_case example)
- Use the `previews_helper.rb` layout helpers (`preview_container`/`row`/`stack`/`grid`/`section`)
- Render real engine partials/helpers, never imitation HTML (`previews_smoke_test.rb`)
- Be embedded in the doc with `<!-- preview:{example} height:{px} -->`; height is required (`docs_previews_contract_test.rb`)
- Be checked in light and dark (`?theme=dark`)

**Docs site contract (`../maquina_site`).** The site iframes `{demo_url}/previews/{component}/{example}?color_theme=rose`; `demo_url` is `https://demo.maquina.app` in production and `http://127.0.0.1:5300` locally, so keep the dummy app on 5300 when previewing the site. Don't break:
- `layouts/preview.html.erb` posting `{type: "maquina:resize", height, component, example}` (the site sizes iframes from it)
- The `theme` / `color_theme` / `shape_theme` params and the `frame-ancestors` list in `PreviewsController`
- The `previews/theming/*` shims to `previews/specimen/*` (the site's theming page uses `specimen`)

The site's component pages are hand-maintained copies of `docs/*.md` (`maquina_site/src/documentation/components/<slug>/index.erb`). Changing a doc here doesn't update the site; tell the user which pages need syncing. New or changed previews only go live after the dummy app is deployed (`test/dummy/config/deploy.yml`, Kamal).

## Testing & Browser Verification

- `bin/test` from the repo root. `test/stylesheets/` reads the compiled `test/dummy/app/assets/builds/tailwind.css`: run `cd test/dummy && bin/rails tailwindcss:build` after any CSS change
- Dummy app: `cd test/dummy && bin/dev` (port 5300). **Without a TTY `bin/dev` exits immediately** (the Tailwind watcher stops, foreman kills the server). In the background use `bin/rails tailwindcss:build`, then `bin/rails server -p <port> -P tmp/pids/server-<port>.pid` (own pid file so parallel servers don't clash)
- Previews: `/previews/{component}/{example}`, with params `?theme=light|dark`, `?color_theme=neutral|green|rose|blue`, `?shape_theme=brutal|soft`
- No JS test runner: verify Stimulus behavior in a real browser with the `rails-hotwire-driver` skill (agent-browser or Playwright), including no console errors

## References

| File | Read when |
|------|-----------|
| `references/available_components.md` | Index of every component, helper and controller |
| `references/component_template.md` | Starting a new component |
| `references/erb_patterns.md` / `css_patterns.md` | Partial and stylesheet details |
| `references/engine_architecture.md` | Engine layout, generators, `rake maquina:doctor` |
| `references/stimulus_patterns.md` | Interactive components, Turbo/morph handling |
| `references/theme_variables.md` | Theme and role tokens |
| `references/tailwind_v4_reference.md` | Tailwind v4 directives and pitfalls |
| `references/form_components.md` / `compound_components.md` | Form primitives; card/alert/sidebar structure |
| `references/component_analysis_template.md` | Analyzing a shadcn component before converting |
| `references/mcp_server_reference.md` | Rails MCP and Neovim MCP usage |
| `docs/{component}.md`, `docs/upgrading.md` | Public API docs; breaking changes per release |
