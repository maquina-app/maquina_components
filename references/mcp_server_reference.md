# MCP Server Reference for maquina_components

> Quick reference guide for using Rails MCP and Neovim MCP servers with the maquina_components engine.

## Overview

Two MCP servers are available for working with maquina_components:

| Server | Purpose |
|--------|---------|
| **railsMcpServer** | Read project files, execute Ruby code, analyze Rails structure |
| **nvimMcpServer** | Read/update files open in Neovim |

---

## Rails MCP Server

### Initial Setup

**Always switch to the project first:**

```
railsMcpServer:switch_project
  project_name: "maquina_components"
```

This must be done at the start of every conversation. The server will respond with available tools and helpers.

### Core Tools

#### execute_ruby

Run read-only Ruby code in the Rails context (executes in test/dummy environment).

```
railsMcpServer:execute_ruby
  code: "puts read_file('app/views/components/_badge.html.erb')"
```

**Built-in helper methods:**

| Method | Description | Example |
|--------|-------------|---------|
| `read_file(path)` | Read file contents | `read_file("app/views/components/_card.html.erb")` |
| `file_exists?(path)` | Check if file exists | `file_exists?("app/assets/stylesheets/button.css")` |
| `list_files(pattern)` | Glob files | `list_files("app/views/**/*.erb")` |
| `project_root` | Get project root path | `project_root` |

**Important:** Always use `puts` to see output.

#### execute_tool

Run specialized analyzers.

```
railsMcpServer:execute_tool
  tool_name: "project_info"
```

Available tools:
- `project_info` — Project overview
- `get_routes` — List routes
- `analyze_models` — Model analysis
- `get_schema` — Database schema

#### search_tools

Discover available tools by category or keyword.

```
railsMcpServer:search_tools
  category: "files"
```

Categories: `models`, `database`, `routing`, `controllers`, `files`, `project`, `guides`

### Common Patterns

#### List All Components

```ruby
puts "=== ERB Partials ==="
puts list_files("app/views/components/**/*.erb").sort.join("\n")

puts "\n=== CSS Files ==="
puts list_files("app/assets/stylesheets/*.css").sort.join("\n")

puts "\n=== Stimulus Controllers ==="
puts list_files("app/javascript/controllers/*.js").sort.join("\n")
```

#### Read Component Files

```ruby
puts "=== PARTIAL ==="
puts read_file("app/views/components/_badge.html.erb")

puts "\n=== CSS ==="
puts read_file("app/assets/stylesheets/badge.css")
```

#### Check Component Structure

```ruby
component = "card"

puts "=== Main Partial ==="
main = "app/views/components/_#{component}.html.erb"
puts file_exists?(main) ? read_file(main) : "Not found"

puts "\n=== Sub-partials ==="
list_files("app/views/components/#{component}/*.erb").each do |f|
  puts "\n--- #{File.basename(f)} ---"
  puts read_file(f)
end

puts "\n=== CSS ==="
css = "app/assets/stylesheets/#{component}.css"
puts file_exists?(css) ? read_file(css) : "Not found"
```

#### Find Helper Methods

```ruby
list_files("app/helpers/**/*.rb").each do |f|
  puts "\n=== #{File.basename(f)} ==="
  puts read_file(f)
end
```

#### Check engine.css Imports

```ruby
puts read_file("app/assets/tailwind/maquina_components_engine/engine.css")
```

#### Read Documentation

```ruby
puts list_files("docs/*.md").join("\n")

# Read specific doc
puts read_file("docs/badge.md")
```

### Restrictions

The execute_ruby tool is **read-only** and blocks:
- File creation/modification/deletion
- Reading .env, credentials, or .gitignore'd files
- Accessing files outside project directory
- Shell commands or system calls
- Environment variable access

### Error Handling

If you see errors like:
- `REJECTED: Code contains forbidden pattern` — The code tried to do something blocked
- `file_exists?` returns `false` for sensitive files — Expected behavior for credentials, etc.

---

## Neovim MCP Server

### Purpose

Read and update files that are currently open in Neovim. Useful for:
- Seeing what files the user is working on
- Making edits to files the user has open
- Coordinating changes across multiple files

### Tools

#### get_project_buffers

Get list of files open in Neovim for this project.

```
nvimMcpServer:get_project_buffers
  project_name: "maquina_components"
```

**Returns:** List of absolute file paths for buffers containing "maquina_components" in their path.

**Requirements:** Neovim must be running with socket at `/tmp/nvim-maquina_components.sock`

#### update_buffer

Update a file's contents, save to disk, and reload in Neovim.

```
nvimMcpServer:update_buffer
  project_name: "maquina_components"
  file_path: "/Users/mariochavez/Development/maquina/maquina_components/app/views/components/_badge.html.erb"
  content: "<%# locals: (variant: :default, size: :md, css_classes: \"\", **html_options) %>\n..."
```

**Parameters:**
| Parameter | Required | Description |
|-----------|----------|-------------|
| `project_name` | Yes | Project directory name (for socket lookup) |
| `file_path` | Yes | Absolute or relative path to file |
| `content` | Yes | Complete new content for the file |

**Behavior:**
1. Replaces entire buffer content
2. Writes to disk (`:w`)
3. Reloads buffer (`:e`)

### Common Patterns

#### Check What User Is Working On

```
nvimMcpServer:get_project_buffers
  project_name: "maquina_components"
```

Then use Rails MCP to read file contents:

```ruby
# After getting buffer list
puts read_file("app/views/components/_badge.html.erb")
```

#### Update Multiple Related Files

When updating a component, often need to update:
1. ERB partial
2. CSS file
3. Documentation

```
# First update: ERB partial
nvimMcpServer:update_buffer
  project_name: "maquina_components"
  file_path: "app/views/components/_new_component.html.erb"
  content: "..."

# Second update: CSS file
nvimMcpServer:update_buffer
  project_name: "maquina_components"
  file_path: "app/assets/stylesheets/new_component.css"
  content: "..."

# Third update: Documentation
nvimMcpServer:update_buffer
  project_name: "maquina_components"
  file_path: "docs/new_component.md"
  content: "..."
```

### Requirements

- Neovim must be running with RPC socket enabled
- Socket path: `/tmp/nvim-{project_name}.sock`
- Start Neovim with: `nvim --listen /tmp/nvim-maquina_components.sock`

---

## Workflow Examples

### Analyze Existing Component

```
1. Switch to project:
   railsMcpServer:switch_project project_name: "maquina_components"

2. List component files:
   railsMcpServer:execute_ruby
     code: |
       puts "=== Partial ==="
       puts read_file("app/views/components/_badge.html.erb")
       puts "\n=== CSS ==="
       puts read_file("app/assets/stylesheets/badge.css")
       puts "\n=== Docs ==="
       puts read_file("docs/badge.md")

3. Web search shadcn/ui for comparison:
   web_search query: "shadcn ui badge component"
```

### Add New Component

```
1. Check what files user has open:
   nvimMcpServer:get_project_buffers project_name: "maquina_components"

2. Create ERB partial:
   nvimMcpServer:update_buffer
     project_name: "maquina_components"
     file_path: "app/views/components/_new_component.html.erb"
     content: "<%# locals: (...) %>..."

3. Create CSS file:
   nvimMcpServer:update_buffer
     project_name: "maquina_components"
     file_path: "app/assets/stylesheets/new_component.css"
     content: "/* ... */"

4. Update engine.css to import new CSS:
   - First read current content
   - Then update with new import added

5. Create documentation:
   nvimMcpServer:update_buffer
     project_name: "maquina_components"
     file_path: "docs/new_component.md"
     content: "# New Component\n..."
```

### Review Component Quality

```
1. Load component files via Rails MCP
2. Check ERB conventions:
   - Strict locals with symbol defaults?
   - Data attribute merging pattern?
   - **html_options passthrough?

3. Check CSS conventions:
   - Data attribute selectors?
   - Theme variables for colors?
   - @apply for spacing/typography?
   - Focus/disabled states?

4. Generate improvement report
```

### Update Component Based on shadcn/ui Changes

```
1. Web search for latest shadcn/ui component
2. Load current maquina_components version via Rails MCP
3. Compare and identify differences
4. Update files via Neovim MCP
5. Update documentation
```

---

## Quick Command Reference

### Rails MCP

| Action | Command |
|--------|---------|
| Switch project | `switch_project project_name: "maquina_components"` |
| Read file | `execute_ruby code: "puts read_file('path')"` |
| List files | `execute_ruby code: "puts list_files('pattern').join('\\n')"` |
| Check exists | `execute_ruby code: "puts file_exists?('path')"` |
| Project info | `execute_tool tool_name: "project_info"` |
| Search tools | `search_tools category: "files"` |

### Neovim MCP

| Action | Command |
|--------|---------|
| Get buffers | `get_project_buffers project_name: "maquina_components"` |
| Update file | `update_buffer project_name: "...", file_path: "...", content: "..."` |

---

## Troubleshooting

### "Project not found"

Run `switch_project` first:
```
railsMcpServer:switch_project project_name: "maquina_components"
```

### "Socket not found" (Neovim)

Start Neovim with socket:
```bash
nvim --listen /tmp/nvim-maquina_components.sock
```

### "REJECTED: Code contains forbidden pattern"

The Ruby code tried to do something blocked (write files, access env vars, etc.). Rewrite to use only read operations.

### Empty file list

Check the glob pattern. Common patterns:
- `app/views/**/*.erb` — All ERB files
- `app/assets/stylesheets/*.css` — CSS in stylesheets folder
- `docs/*.md` — Markdown docs

### File content not showing

Always use `puts`:
```ruby
# Wrong
read_file("path")

# Correct
puts read_file("path")
```
