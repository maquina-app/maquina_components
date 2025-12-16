# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/maquina-app/maquina_components/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/maquina-app/maquina_components/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/maquina-app/maquina_components/releases/tag/v0.1.0
