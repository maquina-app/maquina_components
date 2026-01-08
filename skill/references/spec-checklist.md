# UI Spec Checklist

Checklist for UI implementation when working from feature specs. Use this to verify completeness before marking a spec implementation as done.

---

## Pre-Implementation Checklist

Before writing code, verify you have:

- [ ] **Read the feature spec** completely
- [ ] **Identified all views** needed (index, show, new, edit, partials)
- [ ] **Listed components** required from maquina_components
- [ ] **Decided composition approach** (direct partials, app wrappers, or custom)
- [ ] **Mapped user flows** to Turbo patterns (Drive, Frames, Streams)
- [ ] **Identified I18n keys** needed
- [ ] **Noted accessibility requirements** (ARIA labels, keyboard nav)
- [ ] **Checked mobile requirements** (responsive breakpoints)

---

## Component Usage Checklist

### Layout & Structure

- [ ] Page uses correct layout (sidebar/inset vs public)
- [ ] Breadcrumbs present for navigation context
- [ ] Page header has title and actions
- [ ] Content sections use appropriate spacing (`space-y-6`)
- [ ] Grid responsive at correct breakpoints
- [ ] Cards used for content grouping

### Content Display

- [ ] **Tables** have proper header/body structure
- [ ] **Tables** have action column with dropdown
- [ ] **Cards** use header/content/footer appropriately
- [ ] **Badges** used for status indicators
- [ ] **Alerts** used for important messages
- [ ] Money displayed using `format_money()` helper
- [ ] Dates/times displayed using I18n `l()` helper
- [ ] Times use monospace font (`font-mono`)

### Forms

- [ ] Form has `data-component="form"` attribute
- [ ] Form has `group` class (enables `group-aria-busy:` loading states)
- [ ] All fields wrapped in `data-form-part="group"`
- [ ] Labels have `data-component="label"`
- [ ] Required fields marked with `data-required="true"` on label
- [ ] Required fields have `required: true` HTML attribute
- [ ] **Inputs have appropriate `type`** (email, tel, url, number, date)
- [ ] **Inputs have sensible `maxlength`** (254 for email, 100 for names, etc.)
- [ ] **Inputs have `minlength` where appropriate** (passwords, names)
- [ ] **Inputs have `pattern` for custom validation** (phone, postal code)
- [ ] **Inputs have `autocomplete` hints** (email, tel, name)
- [ ] Inputs have `data-component="input|select|textarea"`
- [ ] **Errors displayed inline per field** (not in an alert list)
- [ ] Error messages use `data-form-part="error"`
- [ ] Error fields have `aria-invalid` and `aria-describedby`
- [ ] Help text uses `data-form-part="description"`
- [ ] Actions in `data-form-part="actions"`
- [ ] Submit button has loading state (`group-aria-busy:` or `data-turbo-submits-with`)
- [ ] Flash message shown for validation failure summary
- [ ] Form validates on client (HTML5 attributes)
- [ ] Form validates on server (model validations)

### Navigation & Actions

- [ ] **Buttons** use correct variants (primary for main CTA)
- [ ] **Buttons** have appropriate size for context
- [ ] **Destructive actions** use destructive variant
- [ ] **Destructive actions** have confirmation dialog
- [ ] **Dropdown menus** for row actions
- [ ] **Pagination** present for lists > 10 items
- [ ] Links have appropriate Turbo behavior

### States

- [ ] **Empty state** displayed when no data
- [ ] **Loading state** for async content (skeleton)
- [ ] **Error state** for failed operations
- [ ] **Success state** for completed actions (flash/alert)
- [ ] **Disabled state** for unavailable actions
- [ ] **Selected state** for current items

---

## Accessibility Checklist

### Keyboard Navigation

- [ ] All interactive elements focusable via Tab
- [ ] Focus visible (ring styles applied)
- [ ] Focus order logical (top-to-bottom, left-to-right)
- [ ] Dropdown menus navigable with arrow keys
- [ ] Modals trap focus while open
- [ ] Escape closes modals/dropdowns

### Screen Readers

- [ ] Images have `alt` text
- [ ] Icon-only buttons have `aria-label`
- [ ] Form fields have associated labels
- [ ] Error messages linked with `aria-describedby`
- [ ] Dynamic content uses `aria-live` regions
- [ ] Tables have proper `<th>` headers
- [ ] Links have descriptive text (not "click here")

### Visual

- [ ] Color contrast meets WCAG AA (4.5:1 for text)
- [ ] Information not conveyed by color alone
- [ ] Text resizable to 200% without breaking
- [ ] Touch targets minimum 44x44px on mobile

---

## Responsive Checklist

### Mobile (< 768px)

- [ ] Single column layout
- [ ] Tables convert to card list or horizontal scroll
- [ ] Navigation collapses to hamburger/sidebar
- [ ] Touch-friendly button sizes
- [ ] Form inputs 16px+ to prevent zoom
- [ ] Modal full-width with padding

### Tablet (768px - 1024px)

- [ ] 2-column layouts where appropriate
- [ ] Sidebar visible but collapsible
- [ ] Tables fit or scroll horizontally

### Desktop (> 1024px)

- [ ] Multi-column layouts
- [ ] Sidebar expanded by default
- [ ] Full table view

---

## I18n Checklist

- [ ] All user-facing text in locale files
- [ ] No hardcoded strings in views
- [ ] Enum values translated (`t("enums.model.field.value")`)
- [ ] Flash messages translated
- [ ] Form labels and placeholders translated
- [ ] Button text translated
- [ ] Empty state messages translated
- [ ] Error messages translated (use ActiveRecord I18n)
- [ ] Date/time formats use I18n (`l(date, format: :short)`)
- [ ] Pluralization handled (`t(".items", count: @count)`)
- [ ] Both ES and EN locales complete

---

## Turbo Checklist

### Forms

- [ ] Form submission uses Turbo (default)
- [ ] Validation errors return 422 status
- [ ] Success redirects or streams update
- [ ] Loading state shows during submission

### Navigation

- [ ] Frame-based updates where appropriate
- [ ] Full page navigation for major transitions
- [ ] Broadcast subscriptions for real-time updates

### Updates

- [ ] New items prepend/append correctly
- [ ] Updated items replace in place
- [ ] Deleted items removed from DOM
- [ ] Empty state appears when last item deleted
- [ ] Counters/stats update after changes

---

## Performance Checklist

- [ ] N+1 queries prevented (`includes()`)
- [ ] Pagination for large collections
- [ ] Lazy loading for below-fold content
- [ ] Images optimized and lazy loaded
- [ ] No unnecessary JavaScript
- [ ] Fragment caching for expensive partials

---

## Code Quality Checklist

### Views

- [ ] Partials extracted for reusable content
- [ ] Partials use locals, not instance variables
- [ ] Logic extracted to helpers or models
- [ ] No raw HTML where components exist
- [ ] Consistent indentation (2 spaces)

### CSS

- [ ] Using Tailwind utilities
- [ ] No inline styles
- [ ] Using design system colors (CSS variables)
- [ ] Responsive classes mobile-first

### Testing

- [ ] System tests for critical paths
- [ ] Controller tests for all actions
- [ ] Tests cover both ES and EN locales
- [ ] Tests verify empty states render

---

## Quick Reference: Spec → UI Mapping

| Spec Requirement | UI Component | Notes |
|------------------|--------------|-------|
| List of items | Table + Card | Card wrapper, table inside |
| Create/Edit form | Form in Card | Form components via data attrs |
| Detail view | Card sections | Multiple cards for sections |
| Status indicator | Badge | Map status to variant |
| Action buttons | Button variants | Primary for main, outline for secondary |
| Delete action | Destructive button | With confirmation |
| Row actions | Dropdown menu | Edit, delete, etc |
| Search/filter | Form + auto-submit | Turbo frame for results |
| No data | Empty state | Icon, title, description, action |
| Success message | Alert (success) | Auto-dismiss after delay |
| Error message | Alert (destructive) | Persist until dismissed |
| Modal form | Frame + dialog | Lazy load content |
| Inline edit | Frame | Replace on edit, revert on cancel |

---

## Sign-off Template

Copy this template into your spec progress.yml when UI is complete:

```yaml
ui_implementation:
  completed_at: YYYY-MM-DD
  components_used:
    - Card (main container)
    - Table (data display)
    - Badge (status)
    - Button (actions)
    - Form (create/edit)
    - Empty (no data state)
    - Dropdown Menu (row actions)
  
  checklist_verified:
    - accessibility: true
    - responsive: true
    - i18n: true
    - turbo: true
    - empty_states: true
    - loading_states: true
    - error_states: true
  
  notes: |
    Any implementation notes or deviations from spec
```

---

## Common Issues & Fixes

| Issue | Fix |
|-------|-----|
| Form not submitting via Turbo | Check `data-turbo="false"` not set |
| Validation errors not showing | Return `status: :unprocessable_entity` |
| **Errors in alert list, not inline** | Move errors to each field's group, use flash for summary |
| **Input missing maxlength** | Add `maxlength` attribute (254 email, 100 names, etc.) |
| **Input wrong type** | Use `email_field`, `phone_field`, `number_field`, etc. |
| **Missing required indicator** | Add `required: true` to input AND `data-required` to label |
| Empty state not appearing | Check ID matches stream target |
| Dropdown not closing | Verify Stimulus controller connected |
| Badge wrong color | Check variant mapping |
| Table overflow on mobile | Add `container: true` or use cards |
| Flash not showing | Check flash partial ID matches |
| Icons not rendering | Use `icon_for` helper |
| Form errors not accessible | Add `aria-describedby` to input |
| Button too small on mobile | Ensure min 44px touch target |
