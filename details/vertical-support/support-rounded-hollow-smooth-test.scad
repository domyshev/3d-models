// Diagnostic control: remove only decorative texture, not the functional teeth.
// Reuse all dimensions and cavity geometry from the textured support.
use <support-rounded-hollow.scad>
support_rounded_hollow(textured = false);
