/// The UI libraries in one import: Flutter's Material library
/// (`material_ui`) and the Material 3 Expressive components
/// (`material_3_expressive`, the `M3E…` widgets). Both export a
/// `RoundedPolygon` and a `CornerRounding`; the Expressive ones win here.
library;

export 'package:material_3_expressive/material_3_expressive.dart';
export 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;
