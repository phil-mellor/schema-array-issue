import type { ObjectSchema } from '@warp-drive/core/types/schema/fields';
import { DATA_TYPE_GIZMO, DATA_TYPE_WIDGET } from './constants';
import { withDefaults } from '@warp-drive/legacy/model/migration-support';

export const WidgetSchema: ObjectSchema = {
  type: DATA_TYPE_WIDGET,
  identity: null,
  fields: [
    {
      kind: 'attribute',
      name: 'widgetId',
      type: 'string',
    },
    {
      kind: 'attribute',
      name: 'title',
      type: 'string',
    },
  ],
};

export const GizmoSchema = withDefaults({
  type: DATA_TYPE_GIZMO,
  legacy: true,
  identity: {
    kind: '@id',
    name: 'id',
  },
  fields: [
    {
      kind: 'attribute',
      name: 'title',
      type: 'string',
    },
    {
      kind: 'schema-array',
      name: 'widgets',
      type: DATA_TYPE_WIDGET,
      options: {
        defaultValue: true,
      },
    },
  ],
});
