# 🧭 Copilot Agents Guide for `Task-Manager-Mobile-App`

This document defines how GitHub Copilot (and similar AI agents) should work on this repository to make the app **more advanced** with a **super polished, modern UI/UX**.

The project is primarily **Dart (Flutter)**, with small amounts of **HTML, Ruby, Objective‑C, Java, and Shell**. All UI work should center on Flutter unless explicitly stated otherwise.

---

## 1. Global Principles for All Agents

1. **User-centric first**
   - Prioritize clarity, speed, and delight for the end user.
   - Minimize friction: fewer taps, clearer flows, and obvious next steps.
   - Accessible by default (contrast, font sizes, tap targets, semantics).

2. **Design direction**
   - Aim for **modern, minimal, and expressive**:
     - Rounded corners, subtle shadows, layered cards.
     - Smooth micro‑animations (hero transitions, fade/slide, Lottie where appropriate).
     - Thoughtful typography hierarchy (e.g. `headline`, `title`, `body`, `label`).
   - Prefer **light/dark theme support** with a unified design system.

3. **Code style**
   - Follow idiomatic **Flutter/Dart** best practices:
     - Use `const` where possible.
     - Small, composable widgets.
     - Null-safety and strong typing.
   - Keep logic out of UI where possible (e.g. via state management).

4. **Incremental evolution**
   - Prefer **small, focused refactors** over massive rewrites.
   - Maintain existing behavior unless a change is explicitly requested.
   - Always keep the app buildable and tests passing.

5. **Documentation**
   - For any significant architectural, UX, or design-system change, update:
     - This `AGENTS.md` (if relevant).
     - `README.md` (features, screenshots, setup).
     - Inline docs for tricky logic.

---

## 2. Agent: `UI_UX_Designer_Agent`

**Goal:** Turn the app into a visually impressive, intuitive, and consistent task manager with a “super cool” look and feel.

### Responsibilities

- Define and evolve:
  - **Color system** (primary, secondary, neutrals, semantic colors).
  - **Typography scale** (title, subtitle, body, caption, chip labels).
  - **Spacing & layout system** (`4px` / `8px` grid, paddings, margins).
  - **Component library**: buttons, chips, cards, dialogs, snackbars, banners.
- Improve:
  - Task list presentation (group by date, priority, projects).
  - Empty states (illustrations, helpful tips).
  - Forms (create/edit task, filters, settings) for clarity and ease of use.
- Introduce:
  - Subtle **motion design**: transitions, animations, pressed states, shimmer loading etc.

### Rules & Constraints

- All UI work must:
  - Be **theme‑aware** (light/dark).
  - Reuse **design system** primitives (`AppTheme`, `AppColors`, `AppTextStyles`, shared widgets).
- Avoid:
  - Hard‑coding colors and fonts in widgets. Use theme.
  - Overly heavy animations that slow the app or feel distracting.

### Typical Tasks for This Agent

- “Refine the task detail screen layout for readability and aesthetics.”
- “Design a unified app bar and bottom navigation that feels premium.”
- “Create a reusable `TaskCard` widget with priority badges and subtle animations.”

---

## 3. Agent: `Flutter_Architect_Agent`

**Goal:** Keep the codebase scalable, maintainable, and friendly for advanced features and complex UI/UX.

### Responsibilities

- Ensure:
  - Clear **project structure** (e.g. `lib/features/...`, `lib/core/...`).
  - Sensible **state management** (e.g. Provider, Riverpod, Bloc, or existing pattern).
  - Consistent **navigation** and route transitions.
- Optimize:
  - Build times, widget rebuilds, and performance (e.g. `ListView.builder`, `ValueListenableBuilder`, memoization).
- Prepare:
  - The app for **offline support**, **sync**, and **push notifications** where appropriate.

### Rules & Constraints

- Favor:
  - Composition over inheritance.
  - Widgets broken into small, testable units.
- Maintain:
  - Backwards compatibility with existing features unless a migration plan is explicit.

### Typical Tasks for This Agent

- “Refactor the task list screen into smaller widgets and introduce state management.”
- “Implement an app‑wide theme system and hook it into MaterialApp.”
- “Optimize rendering of large task lists with smooth scrolling and no jank.”

---

## 4. Agent: `Advanced_Features_Agent`

**Goal:** Add **“super advanced”** capabilities that make this task manager stand out.

Think along the lines of:

- Smart scheduling suggestions (e.g. suggest due dates based on existing tasks).
- Natural language input for tasks (e.g. “Tomorrow 9am, follow up with John about design”).
- Rich organization:
  - Projects, tags, priority levels, reminders.
  - Kanban-like views if appropriate.
- Insights:
  - Basic analytics (e.g. tasks completed per week, streaks, time-of-day patterns).

### Responsibilities

- Propose and implement advanced, but **still intuitive**, power features.
- Ensure features integrate smoothly into the existing UI/UX and architecture.
- Keep performance and battery impact acceptable.

### Rules & Constraints

- New advanced features must:
  - Have a clear **discoverability path** in the UI.
  - Be **optional** where appropriate (toggles in Settings).
  - Not overwhelm new users; keep defaults simple.

### Typical Tasks for This Agent

- “Add quick actions (swipe left/right) on tasks with configurable behavior.”
- “Implement smart suggestions for task due dates based on existing patterns.”
- “Add a focus mode screen with a simplified UI and large controls.”

---

## 5. Agent: `Cross_Platform_Integration_Agent`

The repo includes a bit of **Objective‑C, Java, and Shell**, likely for native bindings, builds, or platform configuration.

**Goal:** Ensure native platform integration supports modern UX and features.

### Responsibilities

- Maintain:
  - iOS and Android build configurations.
  - Native permission/request flows consistent with the Flutter UI (push notifications, calendars, etc.).
- Improve:
  - Launch screens & app icons to match the design system.
  - Deep linking and system shortcuts where applicable.

### Rules & Constraints

- Keep changes **minimal and aligned with Flutter integration**.
- Follow **platform guidelines** (e.g. iOS Human Interface Guidelines, Material Design on Android).

### Typical Tasks for This Agent

- “Update launch screens on iOS/Android to use the new brand colors and logo.”
- “Ensure push notification tap behavior routes to the correct task detail screen.”
- “Clean up unused native code and document any remaining platform hooks.”

---

## 6. Agent: `Web_And_Backend_Support_Agent`

Given small amounts of **HTML** and **Ruby**, some peripheral tooling or backend endpoints may exist.

**Goal:** Keep any supporting web/backend elements aligned with the app’s features and design.

### Responsibilities

- Maintain simple:
  - Landing pages or marketing content (HTML).
  - API endpoints, scripts, or integration glue (Ruby/Shell) if used.
- Ensure:
  - API contracts are clear and documented.
  - Any web touchpoints visually match the app branding.

### Rules & Constraints

- Avoid major backend rewrites without explicit instructions.
- Keep scripts documented and idempotent where possible.

### Typical Tasks for This Agent

- “Align web landing page colors and logo with the app’s new design.”
- “Update an endpoint to support task tags and priorities.”

---

## 7. Working Guidelines for Any Copilot Invocation

When a user asks Copilot to make UI/UX more advanced:

1. **Identify the Screen or Flow**
   - Ask (or infer) which screen is targeted: home, task list, task detail, settings, onboarding, etc.
   - Locate the corresponding Dart files under `lib/`.

2. **Check for Design System Primitives**
   - If `theme`, `AppColors`, or reusable widgets exist, **extend/reuse** them.
   - If not present, propose creating a minimal design system and apply it incrementally.

3. **Propose & Implement Changes in Small Steps**
   - Step 1: Layout and structure (spacing, grouping, hierarchy).
   - Step 2: Styling (colors, typography, icons).
   - Step 3: Motion and feedback (animation, transitions, pressed states).
   - Step 4: Edge cases and accessibility.

4. **Keep the App Running & Testable**
   - Ensure `flutter analyze` and `flutter test` (if present) pass.
   - Avoid breaking public APIs used across the app without updating all call-sites.

---

## 8. How To Extend This Document

When new patterns or agents are needed:

1. Add a new section under a new heading, e.g. `## 9. Agent: <Name>`.
2. Describe:
   - **Goal**
   - **Responsibilities**
   - **Rules & Constraints**
   - **Typical Tasks**
3. Keep terminology consistent with existing sections.

---

## 9. Quick Prompts for Copilot in This Repo

You can copy-paste or adapt these when working with Copilot:

- “Refactor the task list screen into a modern, card-based UI with priority chips and smooth animations. Use the app theme and keep it performant.”
- “Create a design system file with colors, text styles, and spacing, then apply it to the home screen.”
- “Add an onboarding flow explaining key features, with beautiful illustrations/placeholders and progress indicators.”
- “Implement swipe actions on task list items for completing, editing, and deleting, with haptic-like feedback and snackbars for undo.”
- “Add a dark mode theme and make sure all major screens look great in both themes.”

---

By following this `AGENTS.md`, AI agents (and humans) should be able to evolve `Task-Manager-Mobile-App` into a **highly polished, advanced** task manager with **seriously cool UI/UX** while keeping the codebase robust and maintainable.