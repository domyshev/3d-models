// Diagnostic texture limit: 2 mm below the lowest edge of either index ring.
// Z=62.5 mm axis - 21/2 mm index radius - 2 mm clearance = Z=50 mm.
// Whole spherical cutters stay below the limit; no partial boundary dimples.
use <support-rounded-hollow.scad>
support_rounded_hollow(textured = true, texture_max_z = 62.5-21/2-2);
