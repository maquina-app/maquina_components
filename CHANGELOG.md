# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.1] - 2025-01-19

### Added

#### Interactive Components
- **Calendar** — Inline date picker calendar
  - Single and range date selection modes
  - Min/max date constraints
  - Disabled dates support
  - Configurable week start (Sunday/Monday)
  - Show/hide outside days
  - Hidden inputs for form integration
  - Full keyboard navigation (arrow keys, Home, End)
  - Stimulus controller with month navigation
  - ARIA-compliant accessibility (`role="grid"`)

- **Date Picker** — Popover-based date selection
  - Uses native HTML5 Popover API for light-dismiss behavior
  - Wraps Calendar component in a popover
  - Single and range selection modes
  - Customizable placeholder text
  - Size variants (sm, default, lg)
  - Full-width option
  - Error state styling
  - Auto-close on selection (single mode) or range completion
  - Smooth open/close animations with CSS transitions
  - Fallback positioning for browsers without anchor positioning

### Technical Details
- Calendar uses CSS custom property `--cell-size` for responsive sizing
- Date Picker uses `position-area` with fallbacks for cross-browser support
- Both components support dark mode via CSS variables
- Added `chevron_left` and `calendar` icons to icons helper

## [0.3.0] - 2025-01-07

### Added

#### Interactive Components
- **Combobox** — Searchable dropdown selection with keyboard navigation
  - HTML5 Popover API for native light-dismiss behavior
  - Filtering/search functionality
  - Support for grouped options with labels and separators
  - Width variants (sm, default, md, lg, full)
  - Helper methods: `combobox` (builder pattern) and `combobox_simple` (data-driven)
  - Full keyboard navigation (arrow keys, enter, escape, home, end)
  - ARIA-compliant accessibility (`role="combobox"`, `role="listbox"`)

#### Feedback Components
- **Toast** — Non-intrusive notification system
  - Five variants: default, success, info, warning, error
  - Six position options: top-left, top-center, top-right, bottom-left, bottom-center, bottom-right
  - Auto-dismiss with configurable duration
  - Pause timer on hover
  - Global JavaScript API (`Toast.success()`, `Toast.error()`, etc.)
  - Flash message integration via `toast_flash_messages` helper
  - Action button support
  - Enter/exit animations based on position
  - Maximum visible toasts enforcement

### Technical Details
- Combobox uses HTML5 Popover API with `@oddbird/popover-polyfill` recommended for older browsers
- Toast system includes two Stimulus controllers: `toaster` (container/API) and `toast` (individual lifecycle)

## [0.2.0] - 2025-01-01

### Added

#### Layout Components
- **Sidebar** — Collapsible navigation sidebar with cookie persistence for state
- **Header** — Top navigation bar component

#### Content Components
- **Card** — Content container with header, title, description, content, action, and footer slots
- **Alert** — Callout messages with title and description slots, supports default and destructive variants
- **Badge** — Status indicators with variants (default, primary, secondary, destructive, success, warning, outline) and sizes (sm, md, lg)
- **Table** — Data tables with header, body, row, cell, and head partials
- **Empty State** — Placeholder component for empty lists and no-data scenarios

#### Navigation Components
- **Breadcrumbs** — Navigation trail with overflow handling, keyboard navigation, and customizable separators
- **Dropdown Menu** — Accessible dropdown with keyboard navigation, focus management, and variant support
- **Pagination** — Page navigation with Pagy integration (full and simple variants)

#### Interactive Components
- **Toggle Group** — Single/multiple selection button groups with Stimulus controller

#### Form Components (CSS-only with data attributes)
- **Button** — Variants: default, primary, secondary, destructive, outline, ghost, link; Sizes: sm, default, lg, icon
- **Input** — Text input with validation error states
- **Textarea** — Multi-line text input
- **Select** — Dropdown select input
- **Checkbox** — Checkbox input with custom styling
- **Radio** — Radio button input with custom styling
- **Switch** — Toggle switch input

#### Infrastructure
- Install generator (`bin/rails generate maquina_components:install`) for easy setup
- Automatic engine CSS import configuration
- Theme variables following shadcn/ui convention (light and dark mode)
- Helper file generation for icon customization
- Generator options: `--skip-theme`, `--skip-helper`

#### Documentation
- Component documentation at https://maquina.app/documentation/components/
- Getting started guide
- Individual component guides with examples and API reference

#### Test/Dummy Application
- Component showcase pages demonstrating all variants
- Dark/light theme toggle implementation
- Theme selector for switching color schemes

### Technical Details
- ERB partials with strict locals for type safety
- Data attributes for styling (no inline Tailwind classes in partials)
- CSS variables for theming compatibility
- Stimulus controllers only where JavaScript interactivity is required
- TailwindCSS 4.0 with `@theme` directive support
- Progressive enhancement (components work without JavaScript where possible)

## [0.1.0] - 2024-12-01

### Added
- Initial project setup
- Rails Engine structure
- Basic TailwindCSS integration

[Unreleased]: https://github.com/maquina-app/maquina_components/compare/v0.3.1...HEAD
[0.3.1]: https://github.com/maquina-app/maquina_components/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/maquina-app/maquina_components/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/maquina-app/maquina_components/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/maquina-app/maquina_components/releases/tag/v0.1.0
