# schema-array-issue

A minimal Ember app that reproduces two Warp Drive bugs with schema-arrays:

- writing existing items back to a schema-array stores proxies in
  the cache.
- editing a field of an item in a schema-array doesn't update the
  rendered row.

It uses `@warp-drive/*` 5.8.0 in legacy mode. Use the `main` branch to see the bugs. The `patch`
branch applies local patches that work around them.

## Setup

```sh
pnpm install
pnpm start
```

Open http://localhost:4200 and follow the steps for each bug.

Each bug has a gizmo record: a new, unsaved record with a `widgets` schema-array. Widgets are schema-objects
with `widgetId` and `title` attributes. The schemas are in [`app/data/schemas.ts`](app/data/schemas.ts),
and the page is [`app/templates/application.gts`](app/templates/application.gts).

## Bug 1: re-assigning the array crashes

Add a widget with `push`, then add another by re-assigning the array:

```ts
gizmo.widgets.push(widget);
gizmo.widgets = [...gizmo.widgets, widget];
```

**Expected:** the gizmo has two widgets.

**Actual:** rendering throws `Maximum call stack size exceeded`, and the page stops responding.

## Bug 2: edits don't update `{{#each}}` rows

Add a widget and change its title. The page renders each title twice:

- `{{#each gizmo.widgets as |widget|}}` with `{{widget.title}}`
- `{{get gizmo.widgets index}}` with `.title`

**Expected:** both show the new title.

**Actual:** only the second updates.

## Development

- `pnpm lint` and `pnpm lint:fix`
- `pnpm build`
