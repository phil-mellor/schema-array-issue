import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { get } from '@ember/object';
import { service } from '@ember/service';
import Component from '@glimmer/component';
import type { Store } from '@warp-drive/core';
import type { Gizmo, Widget } from 'schema-array-issue/data/types';
import { Type } from '@warp-drive/core/types/symbols';
import { DATA_TYPE_WIDGET } from 'schema-array-issue/data/constants';

const setupCode = `const gizmo = store.createRecord('gizmo', { title: 'Example', widgets: [] });`;

const pushCode = `gizmo.widgets.push({ widgetId: 'widget-1', title: 'Widget 1' });`;

const reassignCode = `gizmo.widgets = [
  ...gizmo.widgets,
  { widgetId: 'widget-2', title: 'Widget 2' },
];`;

const renameCode = `widget.title = 'Renamed';`;

const tableCode = `{{#each gizmo.widgets as |widget index|}}
  <input value={{widget.title}} {{on "change" (fn this.updateTitle widget)}} />

  {{!-- Get title from the widget }}
  {{widget.title}}

  {{!-- Look up the widget by index then get the title }}
  {{#let (get gizmo.widgets index) as |current|}}
    {{current.title}}
  {{/let}}
{{/each}}`;

function newWidget(gizmo: Gizmo): Widget {
  const number = gizmo.widgets.length + 1;
  return {
    [Type]: DATA_TYPE_WIDGET,
    widgetId: `widget-${number}`,
    title: `Widget ${number}`,
  };
}

export default class ApplicationComponent extends Component {
  @service declare store: Store;

  bug1Gizmo = this.createGizmo();
  bug2Gizmo = this.createGizmo();

  createGizmo() {
    return this.store.createRecord<Gizmo>('gizmo', {
      title: 'Example',
      widgets: [],
    });
  }

  push = () => {
    this.bug1Gizmo.widgets.push(newWidget(this.bug1Gizmo));
  };

  reassign = () => {
    this.bug1Gizmo.widgets = [
      ...this.bug1Gizmo.widgets,
      newWidget(this.bug1Gizmo),
    ];
  };

  addWidget = () => {
    this.bug2Gizmo.widgets.push(newWidget(this.bug2Gizmo));
  };

  updateTitle = (widget: Widget, event: Event) => {
    widget.title = (event.target as HTMLInputElement).value;
  };

  <template>
    <main>
      <h1>Warp Drive schema-array bugs</h1>
      <p>Each bug below has its own gizmo, set up like this:</p>
      <pre>{{setupCode}}</pre>

      <section>
        <h2>Bug 1: re-assigning the array crashes</h2>
        <ol>
          <li>Open the browser console.</li>
          <li>
            Click
            <strong>Add with push</strong>. This runs:
            <pre>{{pushCode}}</pre>
            "Widget 1" appears in the list below.
          </li>
          <li>
            Click
            <strong>Add by re-assigning</strong>. This runs:
            <pre>{{reassignCode}}</pre>
          </li>
        </ol>

        <div class="buttons">
          <button type="button" {{on "click" this.push}}>Add with push</button>
          <button type="button" {{on "click" this.reassign}}>Add by re-assigning</button>
        </div>

        <ul class="widgets">
          {{#each this.bug1Gizmo.widgets as |widget|}}
            <li>{{widget.title}}</li>
          {{else}}
            <li>No widgets yet</li>
          {{/each}}
        </ul>

        <p><strong>Expected:</strong> "Widget 2" appears below "Widget 1".</p>
        <p><strong>Actual:</strong>
          "Widget 2" doesn't appear, the page stops updating, and the console
          shows
          <code>RangeError: Maximum call stack size exceeded</code>. The spread
          puts Widget 1's ReactiveResource, rather than its data, into the new
          array, and reading it back recurses.</p>
        <p>Reload the page before trying bug 2.</p>
      </section>

      <section>
        <h2>Bug 2: editing a widget doesn't update its row</h2>
        <p>Each row in the table renders the same widget's title in two ways:</p>
        <pre>{{tableCode}}</pre>
        <ol>
          <li>
            Click
            <strong>Add widget</strong>. This pushes "Widget 1", as in bug 1.
          </li>
          <li>
            Change the title to "Renamed" and press Tab. This runs:
            <pre>{{renameCode}}</pre>
          </li>
        </ol>

        <div class="buttons">
          <button type="button" {{on "click" this.addWidget}}>Add widget</button>
        </div>

        <table>
          <thead>
            <tr>
              <th>Title</th>
              <th><code>widget.title</code></th>
              <th><code>current.title</code></th>
            </tr>
          </thead>
          <tbody>
            {{#each this.bug2Gizmo.widgets as |widget index|}}
              <tr>
                <td>
                  <input
                    aria-label="Title"
                    type="text"
                    value={{widget.title}}
                    {{on "change" (fn this.updateTitle widget)}}
                  />
                </td>
                <td>{{widget.title}}</td>
                <td>
                  {{#let (get this.bug2Gizmo.widgets index) as |current|}}
                    {{current.title}}
                  {{/let}}
                </td>
              </tr>
            {{else}}
              <tr>
                <td colspan="3">No widgets yet</td>
              </tr>
            {{/each}}
          </tbody>
        </table>

        <p><strong>Expected:</strong> both columns show "Renamed".</p>
        <p><strong>Actual:</strong>
          only
          <code>current.title</code>
          shows "Renamed".
          <code>widget.title</code>
          still shows "Widget 1", because the edit doesn't notify the widget
          that
          <code>&#123;&#123;#each&#125;&#125;</code>
          already rendered. Reading the widget by index gets the new title.</p>
      </section>
    </main>
  </template>
}
