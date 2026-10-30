// Suspended-center evolution of the integral-stud, limited-texture support.
// Preserve all joint coordinates; replace only the bottom 4 mm envelope.
$fn = 96;
use <support-rounded-hollow.scad>

bottom_center_clearance = 1;
bottom_measured_safe_height = 4; // Author's measurement on the printed assembly.
bottom_cap_height = bottom_measured_safe_height-bottom_center_clearance; // 3 mm.
bottom_shoulder_z = bottom_center_clearance+bottom_cap_height; // Z=4 mm.
bottom_profile_rings = 40;
bottom_profile_columns = 96;
bottom_top_z = 74;
bottom_color = "#F3E5C8";
show_section = false;

assert(bottom_center_clearance > 0);
assert(bottom_center_clearance < bottom_shoulder_z);
assert(bottom_shoulder_z < 14-17/2,
    "The rounded underside must stay below the 17 mm leg seating envelope");

function bottom_vertex_index(ring, column) = 1
    + (ring-1)*bottom_profile_columns+(column%bottom_profile_columns);
function bottom_perimeter_point(column) =
    perimeter_sample(column*perimeter_sum(8)/bottom_profile_columns);

module rounded_bottom_envelope() {
    // Rounded-rectangular analogue of a shallow ellipsoidal lower cap.
    // At the center its bottom is Z=1; at the side walls it joins at Z=4
    // with a vertical tangent. There is no flat sole or spherical shoulder.
    apex = [0,0,bottom_center_clearance];
    points = concat([apex], [
        for (ring = [1:bottom_profile_rings])
            for (column = [0:bottom_profile_columns-1])
                let(a = ring*90/bottom_profile_rings,
                    p = bottom_perimeter_point(column))
                    [p[0]*sin(a),p[1]*sin(a),
                        bottom_shoulder_z-bottom_cap_height*cos(a)]
    ], [[0,0,bottom_shoulder_z]]);
    top_center = len(points)-1;
    faces = concat([
        for (column = [0:bottom_profile_columns-1])
            [0,bottom_vertex_index(1,column+1),bottom_vertex_index(1,column)]
    ], [
        for (ring = [1:bottom_profile_rings-1])
            for (column = [0:bottom_profile_columns-1])
                each [
                    [bottom_vertex_index(ring,column),
                        bottom_vertex_index(ring,column+1),
                        bottom_vertex_index(ring+1,column+1)],
                    [bottom_vertex_index(ring,column),
                        bottom_vertex_index(ring+1,column+1),
                        bottom_vertex_index(ring+1,column)]
                ]
    ], [
        for (column = [0:bottom_profile_columns-1])
            [top_center,bottom_vertex_index(bottom_profile_rings,column),
                bottom_vertex_index(bottom_profile_rings,column+1)]
    ]);
    union() {
        polyhedron(points = points,faces = faces,convexity = 4);
        // This unrestricted upper mask preserves every protruding stud.
        translate([-50,-50,bottom_shoulder_z-0.001])
            cube([100,100,bottom_top_z-bottom_shoulder_z+1]);
    }
}

module support_rounded_bottom() {
    color(bottom_color)
        intersection() {
            support_rounded_hollow(textured = true,texture_max_z = 50);
            rounded_bottom_envelope();
        }
}

if (show_section) {
    difference() {
        support_rounded_bottom();
        translate([0,-30,-1]) cube([40,60,bottom_top_z+2]);
    }
} else {
    support_rounded_bottom();
}
