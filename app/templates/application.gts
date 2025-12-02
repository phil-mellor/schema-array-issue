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
  globalWidgetCounter++;

  const widget = {
    widgetId: `widget-${globalWidgetCounter}`,
    title: `Original title for widget ${globalWidgetCounter}`,
  };

  return widget;
}

export default class ApplicationComponent extends Component {
  @service declare store: Store;

  @tracked gizmo: Gizmo | null = null;
  @tracked debuggingInformation: string =
    'Click the button to refresh the state...';

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

  refreshDebuggingInformation = () => {
    this.debuggingInformation = JSON.stringify(
      {
        title: this.gizmo!.title,
        widgets: this.gizmo!.widgets.map((widget) => ({
          widgetId: widget.widgetId,
          title: widget.title,
        })),
      },
      null,
      2
    );
  };

  <template>
    {{outlet}}
    <form>
      {{#if this.gizmo}}
        <div class="container">
          <h1>Gizmo: "{{this.gizmo.title}}"</h1>
          <p>This is the gizmo title. It is displayed in the heading above. You
            can edit it in the input field below.</p>
          <div>
            <label for="title">Gizmo title:</label>
            <input
              type="text"
              id="title"
              value={{this.gizmo.title}}
              {{on "change" this.updateTitle}}
            />
          </div>

          <div class="good">
            When tabbing out of the input field, the title will be updated
            above. This is the expected behavior.
          </div>

          <p>A gizmo can have multiple widgets. By default there are no widgets.</p>

          <p>Widgets can be added using two different approaches:</p>
          <ul>
            <li>Using array push:
              <code>this.gizmo!.widgets.push(widget)</code></li>
            <li>By assigning a new array:
              <code>this.gizmo!.widgets = [...this.gizmo!.widgets, widget]</code></li>
          </ul>

          <div class="buttons">
            <button
              type="button"
              {{on "click" this.addWidgetUsingArrayPush}}
            >Add widget using array push</button>
            <button
              type="button"
              {{on "click" this.addWidgetByAssigningArray}}
            >Add widget by re-assigning array</button>
          </div>

          <div class="alert">
            Issue: when adding a second widget using array reassignment, the
            application crashes with an infinite recursion error.
          </div>
        </div>

        {{#if this.gizmo.widgets.length}}
          <div class="container">
            <h2>Widget display</h2>
            <p>The widgets are displayed below. Here we enumerate the widgets
              using two different approaches:</p>
          </div>

          <div class="cols">
            <div class="col type1">
              <h3>Widgets enumerated using #each:</h3>
              <p>A simple each loop:
                <code>#each this.gizmo.widgets as |widget|</code></p>
              <ol>
                {{#each this.gizmo.widgets as |widget|}}
                  <li>
                    {{widget.title}}
                  </li>
                {{/each}}
              </ol>
            </div>
            <div class="col type2">
              <h3>Widgets enumerated using #let, get and index:</h3>
              <p>An #each loop that gets each element by its index:
                <code>#each this.gizmo.widgets as |_ index|</code>
                and
                <code>let (get this.gizmo.widgets index) as |widget|</code></p>
              <ol>
                {{#each this.gizmo.widgets as |_ index|}}
                  {{#let (get this.gizmo.widgets index) as |widget|}}
                    <li>
                      {{widget.title}}
                    </li>
                  {{/let}}
                {{/each}}
              </ol>
            </div>
          </div>

          <div class="container">
            <hr />
            <h2>Widget editing</h2>
            <p>We allow editing of the widget titles. Again, we use two
              different approaches to enumerate the widgets:</p>
          </div>

          <div class="cols">
            <div class="col type1">
              <h3>Input fields enumerated using #each:</h3>
              <p>A simple each loop:
                <code>#each this.gizmo.widgets as |widget|</code></p>
              <ol>
                {{#each this.gizmo.widgets as |widget|}}
                  <li>
                    <input
                      aria-label="Widget title"
                      type="text"
                      value={{widget.title}}
                      {{on "change" (fn this.updateWidget widget)}}
                    />
                  </li>
                {{/each}}
              </ol>
            </div>
            <div class="col type2">
              <h3>Input fields enumerated using #let, get and index:</h3>
              <p>An #each loop that gets each element by its index:
                <code>#each this.gizmo.widgets as |_ index|</code>
                and
                <code>let (get this.gizmo.widgets index) as |widget|</code></p>
              <ol>
                {{#each this.gizmo.widgets as |_ index|}}
                  {{#let (get this.gizmo.widgets index) as |widget|}}
                    <li>
                      <input
                        aria-label="Widget title"
                        type="text"
                        value={{widget.title}}
                        {{on "change" (fn this.updateWidget widget)}}
                      />
                    </li>
                  {{/let}}
                {{/each}}
              </ol>
            </div>
          </div>

          <div class="container">
            <div class="alert">
              Issue: when editing a widget title using an input field from
              either approach, the change does not update the display section
              that uses the #each approach.
            </div>

            <div class="alert">
              Issue: when editing a widget title using an input field from the
              #let/get/index approach, the change does not propagate to the
              corresponding input field in the #each approach.
            </div>
          </div>
        {{else}}
          <div class="container">
            <p>No widgets found - please add some.</p>
          </div>
        {{/if}}

        <hr />

        <div class="container">
          <h2>Debugging information</h2>
          <p>You can display the current state of the gizmo by clicking the
            button below.</p>
          <p>This is
            <strong>not</strong>
            refreshed automatically when the gizmo is changed, only when you
            click the button.</p>

          <div class="buttons">
            <button
              type="button"
              {{on "click" this.refreshDebuggingInformation}}
            >Log state</button>
          </div>

          <div class="output">
            <pre>{{this.debuggingInformation}}</pre>
          </div>
        </div>
      {{else}}
        <div class="buttons">
          <button type="button" {{on "click" this.createGizmo}}>Create Gizmo</button>
        </div>
      {{/if}}
    </form>
  </template>
}
