// Self-contained v0.3 snapshot: no dependency on the development details folder.
use <components/magsafe-ring/ring-indexed-textured.scad>
use <components/vertical-support/support-adjustable-base.scad>
use <components/sculpted-leg/shared/leg_geometry.scad>
use <components/m12-clamp-fasteners/shared/fastener_geometry.scad>

part = "layout"; // layout, assembly, ring, support, leg_x, leg_y, bolt, nut
show_labels = true;
$fn = 96;

module long_leg() { sculpted_leg_extended_root(45.5); }
module short_leg() { sculpted_leg(33.1, rounded_end = true); }
module support() { support_adjustable_base(with_leveling_socket = false); }
module caption(label, p) {
    if (show_labels) color("#555555") translate(p)
        linear_extrude(0.3) text(label,size=4,halign="center");
}
module assembled_holder() {
    support();
    for (a=[0,180]) rotate([0,0,a]) translate([11.5,0,1.5]) long_leg();
    for (a=[90,270]) rotate([0,0,a]) translate([15,0,1.5]) short_leg();
    translate([0,0,62.5]) rotate([0,112.5,0])
        translate([-(sqrt(24*24-8.7*8.7)+16),0,-18.4]) ring_indexed_textured();
    translate([0,22.5,62.5]) rotate([90,0,0]) clamp_bolt_textured();
    translate([0,-15,62.5]) rotate([90,0,0]) clamp_nut_textured();
}
module laid_out_holder() {
    translate([-80,45,0]) ring_indexed_textured();
    translate([15,45,-4]) support();
    translate([60,45,1.5]) long_leg();
    translate([-80,-40,1.5]) short_leg();
    translate([0,-40,0]) clamp_bolt_textured();
    translate([55,-40,0]) clamp_nut_textured();
    caption("MagSafe ring x1",[-70,6,0]);
    caption("Support x1",[15,19,0]);
    caption("Long leg x2",[82,19,0]);
    caption("Short leg x2",[-64,-62,0]);
    caption("M12 bolt x1",[0,-62,0]);
    caption("M12 nut x1",[55,-62,0]);
}
if (part=="layout") laid_out_holder();
else if (part=="assembly") assembled_holder();
else if (part=="ring") ring_indexed_textured();
else if (part=="support") translate([0,0,-4]) support();
else if (part=="leg_x") translate([0,0,1.5]) long_leg();
else if (part=="leg_y") translate([0,0,1.5]) short_leg();
else if (part=="bolt") clamp_bolt_textured();
else if (part=="nut") clamp_nut_textured();
else assert(false,"Unknown v0.3 part selector");

