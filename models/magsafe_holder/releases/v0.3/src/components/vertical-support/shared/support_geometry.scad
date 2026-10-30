// Shared direct-base support geometry, isolated from the complete model.
// support_shortening removes material only from the straight central column.
$fn = 96;
use <../../shared/vendor/dan-kirshner-threads/2.7/threads.scad>

stand_top_axis_height = 76 - support_shortening;
stand_base_thickness = 6;
stand_hole_diameter = 13;
stand_hole_edge = 5;
stand_fork_tail = 20;
stand_upper_fork_length = stand_hole_edge
    + stand_hole_diameter
    + stand_fork_tail; // 38 mm.
stand_face_width = 2 * stand_hole_edge
    + stand_hole_diameter; // 23 mm in X.
stand_end_radius = stand_face_width / 2; // 11.5 mm.
stand_lower_fork_length = 24; // 23 mm wide with 1 mm rotational allowance.
stand_outer_thickness = 30;
stand_upper_gap = 18;
stand_upper_arm_thickness = (
    stand_outer_thickness - stand_upper_gap
) / 2; // 6 mm.
stand_lower_gap = 18;
stand_lower_arm_thickness = (
    stand_outer_thickness - stand_lower_gap
) / 2; // 6 mm.
stand_lower_axis_height = stand_base_thickness
    + stand_hole_edge
    + stand_hole_diameter / 2; // 17.5 mm.
stand_upper_tip_z = stand_top_axis_height
    + stand_hole_edge
    + stand_hole_diameter / 2;
stand_upper_body_z = stand_top_axis_height
    - stand_hole_diameter / 2
    - stand_fork_tail;
stand_lower_tip_z = stand_base_thickness;
stand_lower_body_z = stand_lower_tip_z + stand_lower_fork_length;
stand_body_height = stand_upper_body_z - stand_lower_body_z;

// Fine radial locking serrations on the four inward-facing fork surfaces.
stand_index_tooth_count = 48;
stand_index_tooth_height = 0.7;
stand_index_valley_height = 0.1;
stand_index_embed = 0.2;
stand_index_tooth_root_overlap = 0.05;
stand_index_inner_diameter = 14;
stand_index_outer_diameter = 21;
stand_index_station_count = 2 * stand_index_tooth_count;
stand_index_step_angle = 360 / stand_index_station_count;
stand_upper_inner_face_mid_y = stand_upper_gap / 2; // 9 mm.
stand_upper_inner_face_angle = 0;

epsilon = 0.05;
stand_color = "#F3E5C8";
bolt_diameter = 12;
bolt_pitch = 1.75;
base_stud_length = 8;
compact_stand_bottom_z = 5;
compact_stand_stud_axis_height = 17.5;
compact_stand_stud_inward_extension = 0.3;

function stand_index_polar3(radius, angle, normal_position) = [
    radius * cos(angle),
    radius * sin(angle),
    normal_position
];

module stand_index_tooth(tooth_index) {
    inner_radius = stand_index_inner_diameter / 2;
    outer_radius = stand_index_outer_diameter / 2;
    center_angle = 2 * tooth_index * stand_index_step_angle;
    left_angle = center_angle - stand_index_step_angle;
    right_angle = center_angle + stand_index_step_angle;
    root_height = stand_index_valley_height
        - stand_index_tooth_root_overlap;

    points = [
        // A planar six-point root embedded into the continuous annular bed.
        stand_index_polar3(inner_radius, left_angle, root_height),
        stand_index_polar3(outer_radius, left_angle, root_height),
        stand_index_polar3(outer_radius, center_angle, root_height),
        stand_index_polar3(outer_radius, right_angle, root_height),
        stand_index_polar3(inner_radius, right_angle, root_height),
        stand_index_polar3(inner_radius, center_angle, root_height),

        // The exposed roof rises from a valley on both sides to one ridge.
        stand_index_polar3(
            inner_radius,
            left_angle,
            stand_index_valley_height
        ),
        stand_index_polar3(
            outer_radius,
            left_angle,
            stand_index_valley_height
        ),
        stand_index_polar3(
            outer_radius,
            center_angle,
            stand_index_tooth_height
        ),
        stand_index_polar3(
            outer_radius,
            right_angle,
            stand_index_valley_height
        ),
        stand_index_polar3(
            inner_radius,
            right_angle,
            stand_index_valley_height
        ),
        stand_index_polar3(
            inner_radius,
            center_angle,
            stand_index_tooth_height
        )
    ];
    faces = [
        // Sloped exposed roof.
        [6, 7, 8], [6, 8, 11],
        [11, 8, 9], [11, 9, 10],
        // Planar root, wound in the opposite direction.
        [0, 2, 1], [0, 5, 2],
        [5, 3, 2], [5, 4, 3],
        // Six closed perimeter walls.
        [0, 1, 7], [0, 7, 6],
        [1, 2, 8], [1, 8, 7],
        [2, 3, 9], [2, 9, 8],
        [3, 4, 10], [3, 10, 9],
        [4, 5, 11], [4, 11, 10],
        [5, 0, 6], [5, 6, 11]
    ];

    polyhedron(points = points, faces = faces, convexity = 2);
}

module stand_index_serration_ring() {
    // Keep one continuous annular bed inside the parent part. Each ridge is a
    // separate closed solid whose root overlaps that bed by 0.05 mm. This
    // avoids coincident sector faces and non-manifold internal shells in STL.
    render(convexity = 4)
        union() {
            translate([0, 0, -stand_index_embed])
                annulus(
                    stand_index_outer_diameter,
                    stand_index_inner_diameter,
                    stand_index_embed + stand_index_valley_height
                );

            for (tooth_index = [0 : stand_index_tooth_count - 1])
                stand_index_tooth(tooth_index);
        }
}

module annulus(outer_diameter, inner_diameter, height) {
    difference() {
        cylinder(d = outer_diameter, h = height);
        translate([0, 0, -epsilon])
            cylinder(
                d = inner_diameter,
                h = height + 2 * epsilon
            );
    }
}

module stand_face_envelope(profile = "upper") {
    translate([0, stand_outer_thickness / 2 + epsilon, 0])
        rotate([90, 0, 0])
            linear_extrude(height = stand_outer_thickness + 2 * epsilon)
                if (profile == "upper") {
                    // Full-width root plus a concentric semicircular free end.
                    union() {
                        translate([
                            -stand_face_width / 2,
                            stand_upper_body_z
                        ])
                            square([
                                stand_face_width,
                                stand_top_axis_height - stand_upper_body_z
                            ]);
                        translate([0, stand_top_axis_height])
                            circle(r = stand_end_radius);
                    }
                } else {
                    // 23 x 24 mm lower ear with a rounded free end and a
                    // full-width attachment to the central body.
                    union() {
                        translate([
                            -stand_face_width / 2,
                            stand_lower_axis_height
                        ])
                            square([
                                stand_face_width,
                                stand_lower_body_z - stand_lower_axis_height
                            ]);
                        translate([0, stand_lower_axis_height])
                            circle(r = stand_end_radius);
                    }
                }
}

module stand_upper_positive_arm() {
    intersection() {
        // Match the lower fork: a constant 18 mm gap and two uniform
        // 6 mm arms across the complete 23 mm face width.
        translate([
            -stand_face_width / 2,
            stand_upper_gap / 2,
            stand_upper_body_z - epsilon
        ])
            cube([
                stand_face_width,
                stand_upper_arm_thickness,
                stand_upper_tip_z - stand_upper_body_z + 2 * epsilon
            ]);

        stand_face_envelope("upper");
    }
}

module stand_upper_fork() {
    stand_upper_positive_arm();
    mirror([0, 1, 0])
        stand_upper_positive_arm();
}

module stand_central_body(bottom_z = stand_lower_body_z) {
    translate([
        -stand_face_width / 2,
        -stand_outer_thickness / 2,
        bottom_z - epsilon
    ])
        cube([
            stand_face_width,
            stand_outer_thickness,
            stand_upper_body_z - bottom_z + 2 * epsilon
        ]);
}

module compact_stand_integrated_stud(direction) {
    half_x = stand_face_width / 2;
    half_y = stand_outer_thickness / 2;
    inward = compact_stand_stud_inward_extension;
    length = base_stud_length + epsilon + inward;

    if (direction == "+x")
        translate([
            half_x - epsilon - inward,
            0,
            compact_stand_stud_axis_height
        ])
            rotate([0, 90, 0])
                base_external_thread(length);
    else if (direction == "-x")
        translate([
            -half_x + epsilon + inward,
            0,
            compact_stand_stud_axis_height
        ])
            rotate([0, -90, 0])
                base_external_thread(length);
    else if (direction == "+y")
        translate([
            0,
            half_y - epsilon - inward,
            compact_stand_stud_axis_height
        ])
            rotate([-90, 0, 0])
                base_external_thread(length);
    else
        translate([
            0,
            -half_y + epsilon + inward,
            compact_stand_stud_axis_height
        ])
            rotate([90, 0, 0])
                base_external_thread(length);
}

module stand_bolt_hole(axis_height) {
    translate([
        0,
        -stand_outer_thickness / 2 - epsilon,
        axis_height
    ])
        rotate([-90, 0, 0])
            cylinder(
                d = stand_hole_diameter,
                h = stand_outer_thickness + 2 * epsilon
            );
}

module stand_upper_positive_index_ring() {
    translate([
        0,
        stand_upper_inner_face_mid_y,
        stand_top_axis_height
    ])
        rotate([0, 0, stand_upper_inner_face_angle])
            rotate([90, 0, 0])
                stand_index_serration_ring();
}

module stand_upper_index_rings() {
    stand_upper_positive_index_ring();
    mirror([0, 1, 0])
        stand_upper_positive_index_ring();
}

module base_external_thread(length) {
    metric_thread(
        diameter = bolt_diameter,
        pitch = bolt_pitch,
        length = length,
        internal = false,
        leadin = 2,
        test = $preview
    );
}

module detail_support() {
    // Normalize the existing local Z=5 floor to tabletop Z=0.
    translate([0, 0, -compact_stand_bottom_z])
        color(stand_color)
            difference() {
                union() {
                    stand_central_body(compact_stand_bottom_z);
                    for (direction = ["+x", "-x", "+y", "-y"])
                        compact_stand_integrated_stud(direction);
                    stand_upper_fork();
                    stand_upper_index_rings();
                }
                stand_bolt_hole(stand_top_axis_height);
            }
}
assert(support_shortening >= 0);
assert(stand_upper_body_z > compact_stand_stud_axis_height + bolt_diameter / 2);

