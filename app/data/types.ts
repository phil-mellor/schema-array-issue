import { type WithLegacy } from '@warp-drive/legacy/model/migration-support';
import type { Type } from '@warp-drive/core/types/symbols';

import { DATA_TYPE_GIZMO, DATA_TYPE_WIDGET } from './constants';

export type Widget = {
  [Type]: typeof DATA_TYPE_WIDGET;
  widgetId: string;
  title: string;
};

export type Gizmo = WithLegacy<{
  [Type]: typeof DATA_TYPE_GIZMO;
  id: string;
  title: string;
  widgets: Widget[];
}>;
