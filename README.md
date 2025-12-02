# schema-array-issue

This is a demo application to illustrate an issue with schema-arrays.

I'm not sure if this is a bug in the libraries used, or if I am not declaring the schemas
correctly.

# Problem description

The scenario:

A resource schema (gizmo) has a schema-array field (widgets). Each widget has a title attribute.

I want to add widgets to the gizmo and make them editable in the UI. I want the changes to be reflected in the UI
immediately (when clicking the button or when tabbing out of the input field).

For debugging purposes, you can click the "Log state" button to dump the current state of the gizmo
to the page. This is not refreshed automatically when the gizmo is changed, only when you click the button.

## Adding widgets - typescript issues

It's unclear how best to create a new widget object. I can't create it using the store service's createRecord method, because it is an object schema, not a record schema.

If I create it as a POJO, it doesn't have the [Type] symbol, so it's not a Widget. Is it appropriate to cast it to a Widget, or is there a better way to create the object?

## Adding widgets - updating the widgets array

When the user clicks the button to add a widget, it can be added to the widgets array using two different approaches:

- Using array push:
  `this.gizmo!.widgets.push(widget)`
- By assigning a new array:
  `this.gizmo!.widgets = [...this.gizmo!.widgets, widget]`

Both methods work the first widget. When adding a second widget using array reassignment the application crashes with an infinite recursion error. (See the console log for the error.)

What is the correct way to update the widgets array when adding or removing a widget?

## Rendering and updating widgets

There are two approaches to displaying the widgets in the UI:

- Using #each:
  `#each this.gizmo.widgets as |widget|`
- Using #let, get and index:
  `#each this.gizmo.widgets as |_ index|` and `let (get this.gizmo.widgets index) as |widget|`

When editing a widget title via an input field, the change does not update the display section that uses #each enumeration. However, the change is reflected in the display section that uses #let, get, and index enumeration.

When editing a widget title using an input field from the #let/get/index approach, the change does not propagate to the corresponding input field in the #each approach.

If you click the "Log state" button, you will see that the widgets array seems to have been updated correctly, but the DOM does not seem to be updated.

# Development

## Prerequisites

You will need the following things properly installed on your computer.

- [Git](https://git-scm.com/)
- [Node.js](https://nodejs.org/)
- [pnpm](https://pnpm.io/)
- [Google Chrome](https://google.com/chrome/)

## Installation

- `git clone <repository-url>` this repository
- `cd schema-array-issue`
- `pnpm install`

## Running / Development

- `pnpm start`
- Visit your app at [http://localhost:4200](http://localhost:4200).
- Visit your tests at [http://localhost:4200/tests](http://localhost:4200/tests).

### Code Generators

Make use of the many generators for code, try `pnpm ember help generate` for more details

### Running Tests

- `pnpm test`

### Linting

- `pnpm lint`
- `pnpm lint:fix`

### Building

- `pnpm vite build --mode development` (development)
- `pnpm build` (production)

### Deploying

Specify what it takes to deploy your app.

## Further Reading / Useful Links

- [ember.js](https://emberjs.com/)
- [Vite](https://vite.dev)
- Development Browser Extensions
  - [ember inspector for chrome](https://chrome.google.com/webstore/detail/ember-inspector/bmdblncegkenkacieihfhpjfppoconhi)
  - [ember inspector for firefox](https://addons.mozilla.org/en-US/firefox/addon/ember-inspector/)
