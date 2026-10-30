// New support evolution: floor-matched, rounded, hollow, and fully textured.
// Earlier tested support entry points remain unchanged.
support_shortening = 10;
include <shared/support_geometry.scad>

show_section = false; // Inspection only; never use the section view for printing.
support_floor_extension = 1.5;
support_corner_radius = 2;
support_bridge_raise = 8;
support_min_wall = 6;
support_rib_thickness = 1.2;
surface_pitch = 1.6;
surface_radius = 0.6;
surface_depth = 0.25;
surface_offset = surface_radius-surface_depth;
surface_row_pitch = surface_pitch*sqrt(3)/2;

new_local_floor = compact_stand_bottom_z-support_floor_extension; // 3.5 mm.
new_axis_z = stand_top_axis_height-new_local_floor; // 62.5 mm.
new_stud_z = compact_stand_stud_axis_height-new_local_floor; // 14 mm.
new_bridge_z = stand_upper_body_z+support_bridge_raise-new_local_floor; // 44 mm.
new_top_z = new_axis_z+stand_end_radius; // 74 mm.
shell_allowance = support_min_wall+surface_depth; // 6 mm after recesses.
cavity_x = stand_face_width-2*shell_allowance; // 10.5 mm.
cavity_y = stand_outer_thickness-2*shell_allowance; // 17.5 mm.
cavity_bottom = new_stud_z+bolt_diameter/2+support_min_wall; // 26 mm.
cavity_top = new_bridge_z-shell_allowance; // 37.75 mm.
cavity_height = cavity_top-cavity_bottom;
cavity_bevel = 4.5;

assert(new_stud_z == 14, "Stud axes must match the 14 mm leg radius");
assert(support_corner_radius == 2);
assert(new_bridge_z-new_local_floor > 0);
assert(cavity_x > 2*cavity_bevel && cavity_y > 2*cavity_bevel);
assert(cavity_height > 2*cavity_bevel);
assert(new_axis_z-stand_hole_diameter/2 > new_bridge_z);

module rounded_outer_envelope() {
    linear_extrude(height = new_top_z+epsilon)
        offset(r = support_corner_radius, $fn = 32)
            square([stand_face_width-2*support_corner_radius,
                stand_outer_thickness-2*support_corner_radius], center = true);
}

module rounded_support_blank() {
    difference() {
        union() {
            intersection() {
                union() {
                    // Exact Z=0 floor; raising the bridge does not move the ears.
                    translate([-stand_face_width/2, -stand_outer_thickness/2, 0])
                        cube([stand_face_width, stand_outer_thickness, new_bridge_z]);
                    translate([0, 0, -new_local_floor])
                        stand_upper_fork();
                }
                rounded_outer_envelope();
            }
            translate([0, 0, -new_local_floor])
                stand_upper_index_rings();
        }
        translate([0, 0, -new_local_floor])
            stand_bolt_hole(stand_top_axis_height);
    }
}

module cavity_octahedron(r) {
    polyhedron(points = [[r,0,0],[-r,0,0],[0,r,0],[0,-r,0],[0,0,r],[0,0,-r]],
        faces = [[0,2,4],[2,1,4],[1,3,4],[3,0,4],
            [2,0,5],[1,2,5],[3,1,5],[0,3,5]], convexity = 2);
}

module supported_cavity() {
    // Chamfer all cavity edges at 45 degrees. A single 1.2 mm web divides
    // the remaining short roof spans; no disposable internal support is modeled.
    difference() {
        translate([0, 0, (cavity_bottom+cavity_top)/2])
            minkowski() {
                cube([cavity_x-2*cavity_bevel,
                    cavity_y-2*cavity_bevel,
                    cavity_height-2*cavity_bevel], center = true);
                cavity_octahedron(cavity_bevel);
            }
        translate([-cavity_x/2-epsilon, -support_rib_thickness/2,
            cavity_bottom-epsilon])
            cube([cavity_x+2*epsilon, support_rib_thickness,
                cavity_height+2*epsilon]);
    }
}

// Walk the rounded XY perimeter by arc length, including the corner arcs.
perimeter_lengths = [stand_face_width-2*support_corner_radius,
    PI*support_corner_radius/2, stand_outer_thickness-2*support_corner_radius,
    PI*support_corner_radius/2, stand_face_width-2*support_corner_radius,
    PI*support_corner_radius/2, stand_outer_thickness-2*support_corner_radius,
    PI*support_corner_radius/2];
function perimeter_sum(i) = i <= 0 ? 0 : perimeter_lengths[i-1]+perimeter_sum(i-1);
function perimeter_segment(s, i=0) = s < perimeter_sum(i+1) || i == 7
    ? i : perimeter_segment(s, i+1);
// Return [x,y,nx,ny]; normals point away from the external shell.
function perimeter_sample(s) = let(i = perimeter_segment(s),
    t = s-perimeter_sum(i), r = support_corner_radius,
    hx = stand_face_width/2, hy = stand_outer_thickness/2,
    angle = (90-90*floor(i/2))-t/r*180/PI)
    i == 0 ? [-hx+r+t, hy, 0, 1] :
    i == 2 ? [hx, hy-r-t, 1, 0] :
    i == 4 ? [hx-r-t, -hy, 0, -1] :
    i == 6 ? [-hx, -hy+r+t, -1, 0] :
    let(cx = i == 1 || i == 3 ? hx-r : -hx+r,
        cy = i == 1 || i == 7 ? hy-r : -hy+r)
        [cx+r*cos(angle), cy+r*sin(angle), cos(angle), sin(angle)];

function clear_of_stud_roots(p,z) =
    (abs(p[0]) < stand_face_width/2-support_corner_radius
        || p[1]*p[1]+pow(z-new_stud_z,2) > pow(bolt_diameter/2+0.8,2))
    && (abs(p[1]) < stand_outer_thickness/2-support_corner_radius
        || p[0]*p[0]+pow(z-new_stud_z,2) > pow(bolt_diameter/2+0.8,2));

module all_external_texture(max_z = undef) {
    perimeter = perimeter_sum(8);
    count = round(perimeter/surface_pitch);
    for (row = [0 : floor(new_top_z/surface_row_pitch)])
        for (column = [0 : count-1])
            let(z = 0.9+row*surface_row_pitch,
                p = perimeter_sample((column+(row%2)/2)*perimeter/count))
                if (z < new_top_z && clear_of_stud_roots(p,z)
                    && (is_undef(max_z) || z+surface_radius <= max_z)
                    // No cutter may reach an inward clamping plane, including
                    // the narrow edge where that plane meets the X side wall.
                    && (z < new_bridge_z-surface_radius
                        || abs(p[1]+surface_offset*p[3])
                            > stand_upper_gap/2+surface_radius)
                    // Keep a narrow intact rim at the through-hole, not a
                    // large smooth hex-head/nut seating area on the outer face.
                    && (abs(p[1]) < stand_outer_thickness/2-support_corner_radius
                        || p[0]*p[0]+pow(z-new_axis_z,2)
                            > pow(stand_hole_diameter/2+0.7,2)))
                    translate([p[0]+surface_offset*p[2],
                        p[1]+surface_offset*p[3],z])
                        sphere(r = surface_radius, $fn = 16);

    // Cover the semicircular tops of both ears, but stop before the inward
    // clamping planes. The outside ear faces are textured by the perimeter.
    crown_count = round(PI*stand_end_radius/surface_pitch);
    for (side = [-1,1])
        for (row = [0:3])
            for (column = [0:crown_count])
                let(a = (column+(row%2)/2)*180/crown_count,
                    y = side*(stand_upper_gap/2+0.8+row*surface_pitch))
                    if (a <= 180 && abs(y) < stand_outer_thickness/2-0.6
                        && (is_undef(max_z)
                            || new_axis_z+(stand_end_radius+surface_offset)*sin(a)
                                +surface_radius <= max_z))
                        translate([(stand_end_radius+surface_offset)*cos(a),y,
                            new_axis_z+(stand_end_radius+surface_offset)*sin(a)])
                            sphere(r = surface_radius, $fn = 16);

    // The newly raised horizontal bridge is also a visible external surface.
    for (i = [-6:6])
        for (j = [-5:5])
            let(x = i*surface_pitch+(j%2)*surface_pitch/2,
                y = j*surface_row_pitch)
                if (abs(x) < stand_face_width/2-0.8
                    && abs(y) < stand_upper_gap/2-0.8
                    && (is_undef(max_z)
                        || new_bridge_z+surface_offset+surface_radius <= max_z))
                    translate([x,y,new_bridge_z+surface_offset])
                        sphere(r = surface_radius, $fn = 16);
}

module support_rounded_hollow(textured = true, texture_max_z = undef) {
    color(stand_color)
        union() {
            difference() {
                rounded_support_blank();
                supported_cavity();
                if (textured) all_external_texture(texture_max_z);
            }
            // Add studs after texturing so their complete thread is protected.
            translate([0,0,-new_local_floor])
                for (direction = ["+x","-x","+y","-y"])
                    compact_stand_integrated_stud(direction);
        }
}

if (show_section) {
    difference() {
        support_rounded_hollow();
        translate([0,-30,-1]) cube([40,60,new_top_z+2]);
    }
} else {
    support_rounded_hollow();
}

