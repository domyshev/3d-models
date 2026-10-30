// Flat-bottom integral-stud support. The M6 foot is now disabled by default.
// All coordinates retain the assembled tabletop at Z=0.
$fn = 96;
use <support-rounded-hollow.scad>
use <../shared/vendor/dan-kirshner-threads/2.7/threads.scad>

part = "all"; // "all", "support", "stud", "assembly", or "section".
leveling_enabled = false; // Historical M6 foot: opt in only to reproduce it.
leveling_base_z = 4;
leveling_support_top_z = 74;
leveling_cavity_bottom_z = 26;
leveling_thread_diameter = 6;
leveling_thread_pitch = 1;
leveling_diametral_clearance = 0.35; // Initial FDM fit, not print-validated.
leveling_socket_diameter = leveling_thread_diameter+leveling_diametral_clearance;
leveling_socket_depth = 10;
leveling_stud_length = 12;
leveling_projection = 4;
leveling_edge_radius = 0.3;
leveling_blade_thickness = 1.4;
leveling_slot_clearance_per_side = 0.1;
leveling_slot_width = leveling_blade_thickness+2*leveling_slot_clearance_per_side;
leveling_slot_depth = 2.4;
leveling_texture_floor_margin = 0.8;
leveling_epsilon = 0.05;

assert(leveling_base_z+leveling_socket_depth < leveling_cavity_bottom_z);
assert(leveling_stud_length-leveling_projection == 8);
assert(leveling_socket_depth > leveling_stud_length-leveling_projection);
assert(leveling_edge_radius > 0 && 2*leveling_edge_radius < leveling_stud_length);
assert(leveling_slot_depth < leveling_projection);

module leveling_upper_mask(z) {
    translate([-50,-50,z]) cube([100,100,leveling_support_top_z-z+1]);
}

module leveling_socket_cutter() {
    translate([0,0,leveling_base_z-leveling_epsilon])
        if ($preview)
            cylinder(d = leveling_socket_diameter,
                h = leveling_socket_depth+leveling_epsilon);
        else
            metric_thread(diameter = leveling_socket_diameter,
                pitch = leveling_thread_pitch,
                length = leveling_socket_depth+leveling_epsilon,
                internal = true, leadin = 3);
}

module support_adjustable_base(with_leveling_socket = leveling_enabled) {
    // Match the successful limited-texture support's default tessellation.
    // Keep this local: the separate M6 stud retains its 96-segment envelope.
    let($fn = 0, $fa = 12, $fs = 2)
    color("#F3E5C8")
        difference() {
            intersection() {
                support_rounded_hollow(textured = false);
                leveling_upper_mask(leveling_base_z);
            }
            if (with_leveling_socket) leveling_socket_cutter();
            // Keep the new flat sole and its edge free of decorative cuts.
            intersection() {
                all_external_texture(50);
                leveling_upper_mask(leveling_base_z+leveling_texture_floor_margin);
            }
        }
}

module leveling_stud_rounded_envelope() {
    r = leveling_thread_diameter/2;
    f = leveling_edge_radius;
    steps = 12;
    profile = concat([[0,0]], [
        for (i = [0:steps])
            let(a = -90+i*90/steps)
                [r-f+f*cos(a),f+f*sin(a)]
    ], [
        for (i = [0:steps])
            let(a = i*90/steps)
                [r-f+f*cos(a),leveling_stud_length-f+f*sin(a)]
    ], [[0,leveling_stud_length]]);
    rotate_extrude(convexity = 4) polygon(profile);
}

module m6_leveling_stud() {
    // Slotted end is Z=0: it faces down toward the table when installed.
    color("#D88932")
        difference() {
            intersection() {
                metric_thread(diameter = leveling_thread_diameter,
                    pitch = leveling_thread_pitch,
                    length = leveling_stud_length,
                    internal = false, leadin = 0, test = $preview);
                leveling_stud_rounded_envelope();
            }
            translate([-leveling_thread_diameter,
                -leveling_slot_width/2,-leveling_epsilon])
                cube([2*leveling_thread_diameter,leveling_slot_width,
                    leveling_slot_depth+leveling_epsilon]);
        }
}

module positioned_leveling_stud() {
    translate([0,0,leveling_base_z-leveling_projection]) m6_leveling_stud();
}

if (part == "support") {
    support_adjustable_base();
} else if (part == "stud") {
    m6_leveling_stud();
} else if (part == "assembly") {
    support_adjustable_base();
    if (leveling_enabled) positioned_leveling_stud();
} else if (part == "section") {
    difference() {
        support_adjustable_base();
        translate([0,-30,-1]) cube([40,60,leveling_support_top_z+2]);
    }
    if (leveling_enabled) positioned_leveling_stud();
} else if (part == "all") {
    support_adjustable_base();
    // Flip only the presentation copy so the screwdriver slot is visible.
    if (leveling_enabled)
        translate([34,0,leveling_base_z+leveling_stud_length])
            rotate([180,0,0]) m6_leveling_stud();
} else {
    assert(false,"Unknown part selector");
}
