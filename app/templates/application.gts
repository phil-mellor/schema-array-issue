import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { get } from '@ember/object';
import { service } from '@ember/service';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import type { Store } from '@warp-drive/core';
import type { Gizmo, Widget } from 'schema-array-issue/data/types';

let globalWidgetCounter = 0;

function createNewWidget() {
  // Widget is a schema object, not a record, so we can't
  // create it using the store service.
  const widget = {
    widgetId: `widget-${globalWidgetCounter}`,
    title: `New widget ${globalWidgetCounter}`,
  };
  globalWidgetCounter++;

  return widget;
}

export default class ApplicationComponent extends Component {
  @service declare store: Store;

  @tracked gizmo: Gizmo | null = null;

  createGizmo = () => {
    // Gizmo is a record, so we can create it directly.
    this.gizmo = this.store.createRecord('gizmo', {
      title: 'Example',
      widgets: [],
    });
  };

  updateTitle = (event: Event) => {
    this.gizmo!.title = (event.target as HTMLInputElement).value;
  };

  addWidgetUsingArrayPush = () => {
    // Issue 4 - is it appropriate to cast to Widget here?
    // The object doesn't have the [Type] symbol, so it's not a Widget.
    const widget = createNewWidget() as Widget;
    this.gizmo!.widgets.push(widget);
  };

  addWidgetByAssigningArray = () => {
    // Issue 4 - is it appropriate to cast to Widget here?
    // The object doesn't have the [Type] symbol, so it's not a Widget.
    const widget = createNewWidget() as Widget;
    const newArray = [...this.gizmo!.widgets, widget];
    this.gizmo!.widgets = newArray;
  };

  updateWidget = (widget: Widget, event: Event) => {
    widget.title = (event.target as HTMLInputElement).value;
  };

  <template>
    {{outlet}}
    <form>
      {{#if this.gizmo}}
        <h1>Gizmo: "{{this.gizmo.title}}"</h1>
        <p>This is the gizmo title. It is displayed in the heading above. You can edit it in the input field below.</p>
        <div>
          <label for="title">Gizmo title:</label>
          <input type="text" id="title" value={{this.gizmo.title}} {{on "change" this.updateTitle}} />
        </div>

        <div class="good">
          When tabbing out of the input field, the title will be updated above. This is the expected behavior.
        </div>

        <h2>Widgets</h2>
        <p>A gizmo can have multiple widgets. By default there are no widgets.</p>

        <p>Widgets can be added using two different approaches:</p>
        <ul>
          <li>Using array push: <code>this.gizmo!.widgets.push(widget)</code></li>
          <li>By assigning a new array: <code>this.gizmo!.widgets = [...this.gizmo!.widgets, widget]</code></li>
        </ul>

        <button type="button" {{on "click" this.addWidgetUsingArrayPush}}>Add widget using array push</button>
        <button type="button" {{on "click" this.addWidgetByAssigningArray}}>Add widget by re-assigning array</button>

        <div class="alert">
          Issue 1: if you add a second widget using the array re-assignment approach, the page will crash due to infinite recursion.
          It doesn't matter how you added the first widget(s).
        </div>

        {{#if this.gizmo.widgets.length}}
          <h3>Widget display</h3>
          <p>The widgets are displayed below. Here we enumerate the widgets using two different approaches:</p>
          <ul>
            <li>A simple each loop: <code>#each this.gizmo.widgets as |widget|</code></li>
            <li>An each loop getting each element by its index: <code>#each this.gizmo.widgets as |_ index|</code> and <code>let (get this.gizmo.widgets index) as |widget|</code></li>
          </ul>

          <div class="cols">
            <div class="col">
              <h3>Widgets enumerated using #each:</h3>
              <ul>
                {{#each this.gizmo.widgets as |widget|}}
                  <ol>
                    {{widget.title}}
                  </ol>
                {{/each}}
              </ul>
            </div>
            <div class="col">
              <h3>Widgets enumerated using #let, get and index:</h3>
              <ul>
                {{#each this.gizmo.widgets as |_ index|}}
                  {{#let (get this.gizmo.widgets index) as |widget|}}
                    <ol>
                      {{widget.title}}
                    </ol>
                  {{/let}}
                {{/each}}
              </ul>
            </div>
          </div>

          <h3>Widget editing</h3>
          <p>We allow editing of the widget titles. Again, we use two different approaches to enumerate the widgets:</p>
          <ul>
            <li>A simple each loop: <code>#each this.gizmo.widgets as |widget|</code></li>
            <li>An each loop getting each element by its index: <code>#each this.gizmo.widgets as |_ index|</code> and <code>let (get this.gizmo.widgets index) as |widget|</code></li>
          </ul>

          <div class="cols">
            <div class="col">
              <h3>Input fields enumerated using #each:</h3>
              {{#each this.gizmo.widgets as |widget|}}
                <div>
                  <input aria-label="Widget title" type="text" value={{widget.title}} {{on "change" (fn this.updateWidget widget)}} />
                </div>
              {{/each}}
            </div>
            <div class="col">
              <h3>Input fields enumerated using #let, get and index:</h3>
              {{#each this.gizmo.widgets as |_ index|}}
                {{#let (get this.gizmo.widgets index) as |widget|}}
                  <div>
                    <input aria-label="Widget title" type="text" value={{widget.title}} {{on "change" (fn this.updateWidget widget)}} />
                  </div>
                {{/let}}
              {{/each}}
            </div>
          </div>

          <div class="alert">
            Issue 2: if you edit a widget title using either of the input fields, the change will not be reflected in
            the display when it is enumerated using #each. The change is reflected in the display when it is enumerated using #let, get and index.
          </div>

          <div class="alert">
            Issue 3: if you edit a widget title using the second input field, the change will not be reflected in
            the first input field.  The change is reflected in the list when it is enumerated using #let, get and index.
          </div>
        {{else}}
          <p>No widgets found - please add some.</p>
        {{/if}}
      {{else}}
        <button type="button" {{on "click" this.createGizmo}}>Create Gizmo</button>
      {{/if}}
    </form>
  </template>
}
