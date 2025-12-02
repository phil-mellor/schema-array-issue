import { JSONAPICache } from '@warp-drive/json-api';
import { useLegacyStore } from '@warp-drive/legacy';
import { GizmoSchema, WidgetSchema } from '../data/schemas.ts';

const store = useLegacyStore({
  linksMode: false,
  legacyRequests: true,
  modelFragments: true,
  cache: JSONAPICache,
  schemas: [WidgetSchema, GizmoSchema],
  handlers: [],
  hashFns: [],
});

export default store;
