// Split clamp holder for a 56 mm Apple MagSafe puck.

$fn = 96;

use <vendor/dan-kirshner-threads/2.7/threads.scad>

// Display/export selector: "all", "assembly", "holder", "stand_bolt", "nut",
// "stand", "stand_flat", "stand_long_side", "platform",
// "base_socket_x", "base_socket_y", "base_end_block",
// "base_connector", or "platform_preview".
part = "assembly";
show_magsafe_reference = false;
show_labels = true;

// Measured MagSafe dimensions.
magsafe_diameter = 56;
magsafe_edge_thickness = 5.5;
magsafe_protrusion = 0.8;

// Holder ring and lower retaining flange.
ring_wall = 4;
pocket_depth = magsafe_edge_thickness - magsafe_protrusion; // 4.7 mm.
flange_radial_width = 4;
flange_thickness = 2;
ring_outer_diameter = magsafe_diameter + 2 * ring_wall; // 64 mm.
flange_opening_diameter = magsafe_diameter - 2 * flange_radial_width; // 48 mm.
ring_total_depth = pocket_depth + flange_thickness; // 6.7 mm.
ring_inner_radius = magsafe_diameter / 2;
flange_relief_base_width = 4;
flange_relief_angles = [-90, 90, 180];

// Clamp blocks. Scale the original 20 x 22 mm face proportionally so an
// M12 hex head and nut have wrench clearance from the holder ring.
block_face_scale = 1.6;
block_radial_width = 20 * block_face_scale; // 32 mm along X.
block_height_z = 22 * block_face_scale; // 35.2 mm along Z.
block_thickness = 6;
block_gap = 5;
block_corner_radius = 16;
removed_ring_width = 2 * block_thickness + block_gap; // 17 mm.
block_join_overlap = 0.2;
flange_opening_radius = flange_opening_diameter / 2;
block_outer_y = removed_ring_width / 2 + block_join_overlap;
block_inner_x = sqrt(
    flange_opening_radius * flange_opening_radius
        - block_outer_y * block_outer_y
);
block_front_z = magsafe_protrusion;
block_hole_center_x = block_inner_x + block_radial_width / 2;
block_hole_center_z = block_front_z + block_height_z / 2;

// M12 clamp fastener.
block_hole_diameter = 13;
clamp_alignment_collar_depth = 3;
clamp_alignment_collar_radial_wall = 3;
clamp_alignment_collar_outer_diameter = block_hole_diameter
    + 2 * clamp_alignment_collar_radial_wall; // 19 mm.
bolt_diameter = 12;
bolt_pitch = 1.75;
bolt_head_across_flats = 19;
bolt_head_height = 7.5;
nut_across_flats = 19;
nut_height = bolt_head_height; // 7.5 mm, matching the bolt head.
nut_thread_diameter = 12.7;
stand_bolt_under_head_length = 37.5;
stand_bolt_thread_length = 16;
stand_bolt_smooth_length = stand_bolt_under_head_length
    - stand_bolt_thread_length; // 21.5 mm.
minimum_hex_ring_clearance = 1;
hex_corner_radius = hex_vertex_diameter(bolt_head_across_flats) / 2;
hex_ring_clearance = sqrt(
    (block_hole_center_x - ring_outer_diameter / 2)
        * (block_hole_center_x - ring_outer_diameter / 2)
    + (block_hole_center_z - magsafe_edge_thickness - flange_thickness)
        * (block_hole_center_z - magsafe_edge_thickness - flange_thickness)
) - hex_corner_radius;

// Vertical support stand. Z=0 is the tabletop; the stand begins on the
// 6 mm base plate and holds the upper bolt axis 76 mm above the table.
stand_top_axis_height = 76;
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
stand_index_inner_diameter = 14;
stand_index_outer_diameter = 21;
stand_index_station_count = 2 * stand_index_tooth_count;
stand_index_step_angle = 360 / stand_index_station_count;
stand_upper_inner_face_mid_y = stand_upper_gap / 2; // 9 mm.
stand_upper_inner_face_angle = 0;

// Compact modular base. Four end blocks and socket bodies form an exact
// 110 x 78 mm footprint around the central indexed ear.
base_target_length_x = 110;
base_target_width_y = 78;
base_stud_axis_height = 10;
base_stud_length = 8;
base_attachment_outer_diameter = 18;
base_attachment_clearance = 1;
base_socket_depth = 8.35;
base_connector_length = 16;
base_connector_hex_key_size = 5;
base_connector_hex_clearance_per_side = 0.05;
base_connector_hex_socket_size = base_connector_hex_key_size
    + 2 * base_connector_hex_clearance_per_side; // 5.1 mm across flats.
base_connector_hex_socket_depth = 4;
base_connector_solid_core = base_connector_length
    - 2 * base_connector_hex_socket_depth; // 8 mm.
base_end_block_cross_section = 20;
base_end_block_axis_length = 10;
base_end_block_chamfer = 1.2;

// The lower stand fork has an 18 mm nominal gap. Complementary serrations
// need 0.8 mm per interface (0.7 mm tooth plus 0.1 mm valley), followed by
// 0.3 mm assembly clearance on each side.
platform_lug_interface_clearance = 0.3;
platform_lug_serration_stack = stand_index_tooth_height
    + stand_index_valley_height; // 0.8 mm per side.
platform_lug_thickness = stand_lower_gap
    - 2 * (
        platform_lug_serration_stack
            + platform_lug_interface_clearance
    ); // 15.8 mm core.
platform_lug_depth = stand_face_width; // 23 mm along X.
platform_lug_height = stand_face_width; // 23 mm tall D-shaped ear.
platform_lug_radius = stand_end_radius; // 11.5 mm.
platform_lug_hole_diameter = stand_hole_diameter;
platform_lug_bottom_z = base_stud_axis_height
    + base_attachment_outer_diameter / 2
    + base_attachment_clearance; // 20 mm.
platform_lug_axis_height = platform_lug_bottom_z
    + platform_lug_height / 2; // 31.5 mm.
platform_lug_top_z = platform_lug_bottom_z + platform_lug_height; // 43 mm.
base_socket_x_length = (
    base_target_length_x
        - platform_lug_depth
        - 2 * base_end_block_axis_length
) / 2; // 33.5 mm.
base_socket_y_length = (
    base_target_width_y
        - platform_lug_thickness
        - 2 * base_end_block_axis_length
) / 2; // 21.1 mm.
base_socket_x_solid_core = base_socket_x_length - 2 * base_socket_depth;
base_socket_y_solid_core = base_socket_y_length - 2 * base_socket_depth;

epsilon = 0.05;

holder_color = "#4F86C6";
bolt_color = "#E07A3F";
nut_color = "#7E57C2";
stand_color = "#F3E5C8";
platform_color = "#B7A58A";
base_socket_color = "#8B5A2B";
base_end_block_color = "#DDE8B0";
base_connector_color = "#7E57C2";
magsafe_color = [0.85, 0.85, 0.85, 0.35];
label_color = "#333333";
label_size = 3.6;
label_height = 0.35;

assert(
    abs(pocket_depth - 4.7) < 0.001,
    "MagSafe pocket depth must be 4.7 mm"
);
assert(removed_ring_width == 17, "Clamp opening must be 17 mm wide");
assert(
    nut_height == bolt_head_height,
    "Nut height must match the bolt-head height"
);
assert(
    hex_ring_clearance >= minimum_hex_ring_clearance,
    "M12 hex head and nut need at least 1 mm clearance from the ring"
);
assert(
    block_gap - clamp_alignment_collar_depth == 2,
    "The alignment collar must leave 2 mm between the clamp arms"
);
assert(
    stand_bolt_smooth_length + stand_bolt_thread_length
        == stand_bolt_under_head_length,
    "Stand bolt shank lengths must equal 37.5 mm"
);
assert(
    stand_upper_gap == 18
        && stand_upper_arm_thickness == 6,
    "Upper stand arms must be uniformly 6 mm thick"
);
assert(
    stand_lower_arm_thickness == 6,
    "Lower stand arms must be 6 mm thick"
);
assert(
    stand_body_height > 0,
    "Upper and lower stand forks need a solid central bridge"
);
assert(
    abs(stand_body_height - 19.5) < 0.001,
    "Stand central body must be 19.5 mm high"
);
assert(
    stand_index_outer_diameter <= stand_face_width - 2,
    "Stand serrations need at least 1 mm to the outer ear edge"
);
assert(
    abs(platform_lug_thickness - 15.8) < 0.001,
    "Indexed platform lug core must be 15.8 mm thick"
);
assert(
    abs(platform_lug_bottom_z - 20) < 0.001
        && abs(platform_lug_axis_height - 31.5) < 0.001
        && abs(platform_lug_top_z - 43) < 0.001,
    "Compact base ear heights must preserve 1 mm attachment clearance"
);
assert(
    abs(base_socket_x_length - 33.5) < 0.001
        && abs(base_socket_y_length - 21.1) < 0.001,
    "Socket bodies must produce an exact 110 x 78 mm assembly"
);
assert(
    abs(base_socket_x_solid_core - 16.8) < 0.001
        && abs(base_socket_y_solid_core - 4.4) < 0.001,
    "Opposing 8.35 mm sockets must leave the calculated solid centers"
);
assert(
    base_stud_length < base_socket_depth,
    "M12 base studs need axial seating clearance in their sockets"
);
assert(
    base_connector_length / 2 < base_socket_depth,
    "The 16 mm connector needs seating clearance at both ends"
);
assert(
    base_connector_solid_core == 8,
    "Opposing 4 mm hex sockets must leave an 8 mm solid core"
);

function hex_vertex_diameter(across_flats) = across_flats / cos(30);

function stand_index_polar3(radius, angle, normal_position) = [
    radius * cos(angle),
    radius * sin(angle),
    normal_position
];

function stand_index_height(station_index) =
    station_index % 2 == 0
        ? stand_index_tooth_height
        : stand_index_valley_height;

function stand_index_sector_midpoint(
    radius,
    station_index,
    normal_position
) = stand_index_polar3(
    radius,
    (station_index + 0.5) * stand_index_step_angle,
    normal_position
);

module stand_index_serration_ring() {
    inner_radius = stand_index_inner_diameter / 2;
    outer_radius = stand_index_outer_diameter / 2;
    points = [
        for (
            station_index = [0 : stand_index_station_count - 1]
        )
            let(
                next_index = (
                    station_index + 1
                ) % stand_index_station_count,
                top_mid_normal = (
                    stand_index_height(station_index)
                        + stand_index_height(next_index)
                ) / 2,
                side_mid_normal = (
                    -stand_index_embed + top_mid_normal
                ) / 2
            )
                each [
                    stand_index_polar3(
                        inner_radius,
                        station_index * stand_index_step_angle,
                        -stand_index_embed
                    ),
                    stand_index_polar3(
                        outer_radius,
                        station_index * stand_index_step_angle,
                        -stand_index_embed
                    ),
                    stand_index_polar3(
                        inner_radius,
                        station_index * stand_index_step_angle,
                        stand_index_height(station_index)
                    ),
                    stand_index_polar3(
                        outer_radius,
                        station_index * stand_index_step_angle,
                        stand_index_height(station_index)
                    ),
                    stand_index_sector_midpoint(
                        (inner_radius + outer_radius) / 2,
                        station_index,
                        top_mid_normal
                    ),
                    stand_index_sector_midpoint(
                        (inner_radius + outer_radius) / 2,
                        station_index,
                        -stand_index_embed
                    ),
                    stand_index_sector_midpoint(
                        outer_radius,
                        station_index,
                        side_mid_normal
                    ),
                    stand_index_sector_midpoint(
                        inner_radius,
                        station_index,
                        side_mid_normal
                    )
                ]
    ];
    faces = [
        for (
            station_index = [0 : stand_index_station_count - 1]
        )
            let(
                next_index = (
                    station_index + 1
                ) % stand_index_station_count,
                bottom_inner = 8 * station_index,
                bottom_outer = bottom_inner + 1,
                top_inner = bottom_inner + 2,
                top_outer = bottom_inner + 3,
                top_midpoint = bottom_inner + 4,
                bottom_midpoint = bottom_inner + 5,
                outer_midpoint = bottom_inner + 6,
                inner_midpoint = bottom_inner + 7,
                next_bottom_inner = 8 * next_index,
                next_bottom_outer = next_bottom_inner + 1,
                next_top_inner = next_bottom_inner + 2,
                next_top_outer = next_bottom_inner + 3
            )
                each [
                    [top_inner, top_outer, top_midpoint],
                    [top_outer, next_top_outer, top_midpoint],
                    [next_top_outer, next_top_inner, top_midpoint],
                    [next_top_inner, top_inner, top_midpoint],
                    [bottom_inner, next_bottom_inner, bottom_midpoint],
                    [next_bottom_inner, next_bottom_outer, bottom_midpoint],
                    [next_bottom_outer, bottom_outer, bottom_midpoint],
                    [bottom_outer, bottom_inner, bottom_midpoint],
                    [bottom_outer, next_bottom_outer, outer_midpoint],
                    [next_bottom_outer, next_top_outer, outer_midpoint],
                    [next_top_outer, top_outer, outer_midpoint],
                    [top_outer, bottom_outer, outer_midpoint],
                    [bottom_inner, top_inner, inner_midpoint],
                    [top_inner, next_top_inner, inner_midpoint],
                    [next_top_inner, next_bottom_inner, inner_midpoint],
                    [next_bottom_inner, bottom_inner, inner_midpoint]
                ]
    ];

    polyhedron(points = points, faces = faces, convexity = 4);
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

module closed_ring_with_flange() {
    union() {
        // The puck projects 0.8 mm above the front edge of this wall.
        translate([0, 0, magsafe_protrusion])
            annulus(
                ring_outer_diameter,
                magsafe_diameter,
                pocket_depth
            );

        // Bottom support: 2 mm thick and projecting 4 mm inward.
        translate([0, 0, magsafe_edge_thickness])
            annulus(
                ring_outer_diameter,
                flange_opening_diameter,
                flange_thickness
            );
    }
}

module flange_relief_cut() {
    translate([0, 0, magsafe_edge_thickness - epsilon])
        linear_extrude(height = flange_thickness + 2 * epsilon)
            polygon([
                [ring_inner_radius, 0],
                [flange_opening_radius, -flange_relief_base_width / 2],
                [flange_opening_radius, flange_relief_base_width / 2]
            ]);
}

module flange_relief_cuts() {
    for (relief_angle = flange_relief_angles)
        rotate([0, 0, relief_angle])
            flange_relief_cut();
}

module split_ring_with_flange() {
    difference() {
        closed_ring_with_flange();

        // Remove a straight 17 mm section on the +X side of the ring.
        translate([
            0,
            -removed_ring_width / 2,
            -epsilon
        ])
            cube([
                ring_outer_diameter / 2 + epsilon,
                removed_ring_width,
                magsafe_edge_thickness
                    + flange_thickness
                    + 2 * epsilon
            ]);

        // Three triangular flex cuts in the lower retaining flange.
        flange_relief_cuts();
    }
}

module clamp_block_profile_2d() {
    radius = block_corner_radius;
    width = block_radial_width;
    height = block_height_z;

    union() {
        // Full middle strips shared by all four corners.
        translate([0, radius])
            square([width, height - 2 * radius]);
        translate([radius, 0])
            square([width - 2 * radius, height]);

        // Keep the inner/front corner square where the block meets the ring.
        square([radius, radius]);

        // Round the other three free corners.
        translate([width - radius, radius])
            circle(r = radius);
        translate([radius, height - radius])
            circle(r = radius);
        translate([width - radius, height - radius])
            circle(r = radius);
    }
}

module upper_clamp_block() {
    overlap_thickness = block_thickness + block_join_overlap;

    translate([
        block_inner_x,
        block_gap / 2 + overlap_thickness,
        block_front_z
    ])
        rotate([90, 0, 0])
            linear_extrude(height = overlap_thickness)
                clamp_block_profile_2d();
}

module clamp_blocks() {
    // The two blocks occupy 6 mm each inside the removed 17 mm section.
    upper_clamp_block();
    mirror([0, 1, 0])
        upper_clamp_block();
}

module holder_inner_envelope_cuts() {
    // Keep the front portion flush with the Ø56 MagSafe circumference.
    translate([0, 0, -epsilon])
        cylinder(
            d = magsafe_diameter,
            h = magsafe_edge_thickness + 2 * epsilon
        );

    // Continue the blocks exactly to the cylindrical Ø48 boundary of the
    // retaining flange throughout their rearward extension.
    translate([0, 0, magsafe_edge_thickness - epsilon])
        cylinder(
            d = flange_opening_diameter,
            h = block_front_z
                + block_height_z
                - magsafe_edge_thickness
                + 2 * epsilon
        );
}

module clamp_bolt_hole() {
    translate([
        block_hole_center_x,
        -removed_ring_width / 2 - block_join_overlap - epsilon,
        block_hole_center_z
    ])
        rotate([-90, 0, 0])
            cylinder(
                d = block_hole_diameter,
                h = removed_ring_width
                    + 2 * block_join_overlap
                    + 2 * epsilon
            );
}

module clamp_alignment_collar() {
    // A single annular guide projects from the +Y clamp arm into the gap.
    // The common bolt-hole subtraction supplies its 13 mm inner diameter.
    translate([
        block_hole_center_x,
        block_gap / 2 + epsilon,
        block_hole_center_z
    ])
        rotate([90, 0, 0])
            cylinder(
                d = clamp_alignment_collar_outer_diameter,
                h = clamp_alignment_collar_depth + epsilon
            );
}

module circle_holder() {
    color(holder_color)
        difference() {
            union() {
                split_ring_with_flange();
                clamp_blocks();
                clamp_alignment_collar();
            }

            clamp_bolt_hole();
            holder_inner_envelope_cuts();
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

module stand_lower_positive_arm() {
    intersection() {
        translate([
            -stand_face_width / 2,
            stand_lower_gap / 2,
            stand_lower_tip_z
        ])
            cube([
                stand_face_width,
                stand_lower_arm_thickness,
                stand_lower_body_z - stand_lower_tip_z + epsilon
            ]);

        stand_face_envelope("lower");
    }
}

module stand_lower_fork() {
    stand_lower_positive_arm();
    mirror([0, 1, 0])
        stand_lower_positive_arm();
}

module stand_central_body() {
    translate([
        -stand_face_width / 2,
        -stand_outer_thickness / 2,
        stand_lower_body_z - epsilon
    ])
        cube([
            stand_face_width,
            stand_outer_thickness,
            stand_body_height + 2 * epsilon
        ]);
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

module stand_lower_positive_index_ring() {
    translate([
        0,
        stand_lower_gap / 2,
        stand_lower_axis_height
    ])
        rotate([90, 0, 0])
            stand_index_serration_ring();
}

module stand_lower_index_rings() {
    stand_lower_positive_index_ring();
    mirror([0, 1, 0])
        stand_lower_positive_index_ring();
}

module stand_index_rings() {
    stand_upper_index_rings();
    stand_lower_index_rings();
}

module vertical_support_stand() {
    color(stand_color)
        difference() {
            union() {
                stand_lower_fork();
                stand_central_body();
                stand_upper_fork();
                stand_index_rings();
            }

            stand_bolt_hole(stand_lower_axis_height);
            stand_bolt_hole(stand_top_axis_height);
        }
}

module vertical_support_stand_for_print() {
    // The design uses the real tabletop as Z=0 and starts the stand on the
    // future 6 mm base. Move only the standalone export down onto the bed.
    translate([0, 0, -stand_base_thickness])
        vertical_support_stand();
}

module vertical_support_stand_flat_for_print() {
    // Lay a broad outer ear face on the print bed. After the X rotation,
    // the original 30 mm Y envelope becomes the Z print height.
    translate([0, 0, stand_outer_thickness / 2])
        rotate([90, 0, 0])
            vertical_support_stand_for_print();
}

module vertical_support_stand_long_side_for_print() {
    // Put the 81.5 mm length along the bed while keeping the broad ear
    // planes vertical. Both X edges now have the same 6 mm thickness.
    translate([0, 0, stand_face_width / 2])
        rotate([0, 90, 0])
            vertical_support_stand_for_print();
}

module platform_lug_profile_2d() {
    union() {
        square([
            platform_lug_depth,
            platform_lug_height / 2
        ], center = false);

        translate([
            platform_lug_depth / 2,
            platform_lug_height / 2
        ])
            circle(r = platform_lug_radius);
    }
}

module platform_lug_core() {
    translate([
        -platform_lug_depth / 2,
        platform_lug_thickness / 2,
        platform_lug_bottom_z
    ])
        rotate([90, 0, 0])
            linear_extrude(height = platform_lug_thickness)
                platform_lug_profile_2d();
}

module platform_lug_positive_index_ring() {
    translate([
        0,
        platform_lug_thickness / 2,
        platform_lug_axis_height
    ])
        rotate([-90, 0, 0])
            rotate([0, 0, stand_index_step_angle])
                stand_index_serration_ring();
}

module platform_lug_index_rings() {
    platform_lug_positive_index_ring();
    mirror([0, 1, 0])
        platform_lug_positive_index_ring();
}

module platform_lug_hole() {
    translate([
        0,
        -platform_lug_thickness / 2
            - stand_index_tooth_height
            - epsilon,
        platform_lug_axis_height
    ])
        rotate([-90, 0, 0])
            cylinder(
                d = platform_lug_hole_diameter,
                h = platform_lug_thickness
                    + 2 * stand_index_tooth_height
                    + 2 * epsilon
            );
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

module base_internal_thread_cutter(length) {
    if ($preview) {
        cylinder(d = nut_thread_diameter, h = length, $fn = 48);
    } else {
        metric_thread(
            diameter = nut_thread_diameter,
            pitch = bolt_pitch,
            length = length,
            internal = true,
            leadin = 3
        );
    }
}

module compact_base_stud(direction) {
    half_x = platform_lug_depth / 2;
    half_y = platform_lug_thickness / 2;

    if (direction == "+x")
        translate([half_x - epsilon, 0, base_stud_axis_height])
            rotate([0, 90, 0])
                base_external_thread(base_stud_length + epsilon);
    else if (direction == "-x")
        translate([-half_x + epsilon, 0, base_stud_axis_height])
            rotate([0, -90, 0])
                base_external_thread(base_stud_length + epsilon);
    else if (direction == "+y")
        translate([0, half_y - epsilon, base_stud_axis_height])
            rotate([-90, 0, 0])
                base_external_thread(base_stud_length + epsilon);
    else
        translate([0, -half_y + epsilon, base_stud_axis_height])
            rotate([90, 0, 0])
                base_external_thread(base_stud_length + epsilon);
}

module compact_threaded_base() {
    color(platform_color)
        difference() {
            union() {
                translate([
                    -platform_lug_depth / 2,
                    -platform_lug_thickness / 2,
                    0
                ])
                    cube([
                        platform_lug_depth,
                        platform_lug_thickness,
                        platform_lug_bottom_z + epsilon
                    ]);
                platform_lug_core();
                platform_lug_index_rings();
                for (direction = ["+x", "-x", "+y", "-y"])
                    compact_base_stud(direction);
            }

            platform_lug_hole();
        }
}

module base_double_socket(length, part_color = base_socket_color) {
    color(part_color)
        difference() {
            cylinder(
                d = base_attachment_outer_diameter,
                h = length,
                $fn = 96
            );

            translate([0, 0, -epsilon])
                base_internal_thread_cutter(base_socket_depth + epsilon);

            translate([0, 0, length + epsilon])
                rotate([180, 0, 0])
                    base_internal_thread_cutter(
                        base_socket_depth + epsilon
                    );
        }
}

module base_chamfer_octahedron(radius) {
    polyhedron(
        points = [
            [ radius, 0, 0], [-radius, 0, 0],
            [0, radius, 0], [0, -radius, 0],
            [0, 0, radius], [0, 0, -radius]
        ],
        faces = [
            [0, 2, 4], [2, 1, 4], [1, 3, 4], [3, 0, 4],
            [2, 0, 5], [1, 2, 5], [3, 1, 5], [0, 3, 5]
        ],
        convexity = 2
    );
}

module base_chamfered_end_block_body() {
    chamfer = base_end_block_chamfer;

    translate([0, 0, base_end_block_axis_length / 2])
        minkowski() {
            cube([
                base_end_block_cross_section - 2 * chamfer,
                base_end_block_cross_section - 2 * chamfer,
                base_end_block_axis_length - 2 * chamfer
            ], center = true);
            base_chamfer_octahedron(chamfer);
        }
}

module base_end_block() {
    color(base_end_block_color)
        difference() {
            base_chamfered_end_block_body();

            // The only opening is centered on one 20 x 20 mm face.
            translate([
                0,
                0,
                base_end_block_axis_length + epsilon
            ])
                rotate([180, 0, 0])
                    base_internal_thread_cutter(
                        base_socket_depth + epsilon
                    );
        }
}

module base_threaded_connector() {
    color(base_connector_color)
        difference() {
            base_external_thread(base_connector_length);

            translate([0, 0, -epsilon])
                cylinder(
                    h = base_connector_hex_socket_depth + epsilon,
                    r = base_connector_hex_socket_size / sqrt(3),
                    $fn = 6
                );

            translate([
                0,
                0,
                base_connector_length
                    - base_connector_hex_socket_depth
            ])
                cylinder(
                    h = base_connector_hex_socket_depth + epsilon,
                    r = base_connector_hex_socket_size / sqrt(3),
                    $fn = 6
                );
        }
}

module base_assembled_end_block(axis, sign) {
    if (axis == "x") {
        socket_length = base_socket_x_length;
        socket_start = platform_lug_depth / 2;
        block_center = base_target_length_x / 2
            - base_end_block_axis_length / 2;

        if (sign > 0) {
            translate([socket_start, 0, base_stud_axis_height])
                rotate([0, 90, 0])
                    base_double_socket(socket_length);
            translate([
                block_center + base_end_block_axis_length / 2,
                0,
                base_stud_axis_height
            ])
                rotate([0, -90, 0])
                    base_end_block();
        } else {
            translate([-socket_start, 0, base_stud_axis_height])
                rotate([0, -90, 0])
                    base_double_socket(socket_length);
            translate([
                -block_center - base_end_block_axis_length / 2,
                0,
                base_stud_axis_height
            ])
                rotate([0, 90, 0])
                    base_end_block();
        }
    } else {
        socket_length = base_socket_y_length;
        socket_start = platform_lug_thickness / 2;
        block_center = base_target_width_y / 2
            - base_end_block_axis_length / 2;

        if (sign > 0) {
            translate([0, socket_start, base_stud_axis_height])
                rotate([-90, 0, 0])
                    base_double_socket(socket_length);
            translate([
                0,
                block_center + base_end_block_axis_length / 2,
                base_stud_axis_height
            ])
                rotate([90, 0, 0])
                    base_end_block();
        } else {
            translate([0, -socket_start, base_stud_axis_height])
                rotate([90, 0, 0])
                    base_double_socket(socket_length);
            translate([
                0,
                -block_center - base_end_block_axis_length / 2,
                base_stud_axis_height
            ])
                rotate([-90, 0, 0])
                    base_end_block();
        }
    }
}

module platform_fit_preview() {
    compact_threaded_base();

    for (sign = [-1, 1]) {
        base_assembled_end_block("x", sign);
        base_assembled_end_block("y", sign);
    }
}

module base_assembled_connector(axis, sign) {
    if (axis == "x") {
        interface_x = sign * (
            platform_lug_depth / 2 + base_socket_x_length
        );

        if (sign > 0)
            translate([
                interface_x - base_connector_length / 2,
                0,
                base_stud_axis_height
            ])
                rotate([0, 90, 0])
                    base_threaded_connector();
        else
            translate([
                interface_x + base_connector_length / 2,
                0,
                base_stud_axis_height
            ])
                rotate([0, -90, 0])
                    base_threaded_connector();
    } else {
        interface_y = sign * (
            platform_lug_thickness / 2 + base_socket_y_length
        );

        if (sign > 0)
            translate([
                0,
                interface_y - base_connector_length / 2,
                base_stud_axis_height
            ])
                rotate([-90, 0, 0])
                    base_threaded_connector();
        else
            translate([
                0,
                interface_y + base_connector_length / 2,
                base_stud_axis_height
            ])
                rotate([90, 0, 0])
                    base_threaded_connector();
    }
}

module assembled_modular_base() {
    platform_fit_preview();

    // Each 16 mm connector bridges the sleeve/end-block interface with
    // 8 mm of engagement on either side.
    for (sign = [-1, 1]) {
        base_assembled_connector("x", sign);
        base_assembled_connector("y", sign);
    }
}

module external_bolt_thread(length) {
    metric_thread(
        diameter = bolt_diameter,
        pitch = bolt_pitch,
        length = length,
        internal = false,
        leadin = 2,
        test = $preview
    );
}

module internal_nut_thread(length) {
    metric_thread(
        diameter = nut_thread_diameter,
        pitch = bolt_pitch,
        length = length,
        internal = true,
        leadin = 2,
        test = $preview
    );
}

module m12_bolt_with_shank(smooth_length, thread_length) {
    color(bolt_color)
        union() {
            cylinder(
                d = hex_vertex_diameter(bolt_head_across_flats),
                h = bolt_head_height,
                $fn = 6
            );

            translate([0, 0, bolt_head_height - epsilon])
                cylinder(
                    d = bolt_diameter,
                    h = smooth_length + 2 * epsilon
                );

            translate([
                0,
                0,
                bolt_head_height + smooth_length - epsilon
            ])
                external_bolt_thread(thread_length + epsilon);
        }
}

module m12_stand_bolt() {
    m12_bolt_with_shank(
        stand_bolt_smooth_length,
        stand_bolt_thread_length
    );
}

module m12_nut() {
    color(nut_color)
        difference() {
            cylinder(
                d = hex_vertex_diameter(nut_across_flats),
                h = nut_height,
                $fn = 6
            );

            translate([0, 0, -epsilon])
                internal_nut_thread(nut_height + 2 * epsilon);
        }
}

module magsafe_reference() {
    color(magsafe_color)
        cylinder(
            d = magsafe_diameter,
            h = magsafe_edge_thickness
        );
}

module positioned_holder_at_joint(axis_height, tilt = 90) {
    // Move the clamp-hole axis to the origin before applying the phone tilt,
    // then place that axis concentrically inside the upper stand fork.
    translate([0, 0, axis_height])
        rotate([0, tilt, 0])
            translate([
                -block_hole_center_x,
                0,
                -block_hole_center_z
            ])
                circle_holder();
}

module positioned_magsafe_at_joint(axis_height, tilt = 90) {
    translate([0, 0, axis_height])
        rotate([0, tilt, 0])
            translate([
                -block_hole_center_x,
                0,
                -block_hole_center_z
            ])
                magsafe_reference();
}

module assembled_joint_fastener(axis_height) {
    // The 37.5 mm under-head length spans the complete 30 mm fork and the
    // 7.5 mm nut without protruding beyond it.
    translate([
        0,
        stand_outer_thickness / 2 + bolt_head_height,
        axis_height
    ])
        rotate([90, 0, 0])
            m12_stand_bolt();

    translate([
        0,
        -stand_outer_thickness / 2,
        axis_height
    ])
        rotate([90, 0, 0])
            m12_nut();
}

module complete_assembly() {
    stand_assembly_z = platform_lug_axis_height
        - stand_lower_axis_height;
    upper_joint_axis_height = stand_assembly_z
        + stand_top_axis_height;

    assembled_modular_base();

    translate([0, 0, stand_assembly_z])
        vertical_support_stand();

    // Start from the vertical 90-degree position and lean the top of the
    // holder 20 degrees toward the support stand.
    positioned_holder_at_joint(upper_joint_axis_height, 110);

    if (show_magsafe_reference)
        positioned_magsafe_at_joint(upper_joint_axis_height, 110);

    assembled_joint_fastener(platform_lug_axis_height);
    assembled_joint_fastener(upper_joint_axis_height);
}

module layout_label(label_text, position, size = label_size) {
    color(label_color)
        translate([position[0], position[1], epsilon])
            linear_extrude(height = label_height)
                text(
                    label_text,
                    size = size,
                    halign = "center",
                    valign = "center"
                );
}

module current_parts_labels() {
    layout_label("MagSafe clamp ring", [-91, 12]);
    layout_label("Vertical support", [0, 28]);
    layout_label("Threaded base", [91, 28]);

    layout_label("M12 long bolt", [-91, -69]);
    layout_label("M12 nut", [-54.6, -69]);
    layout_label("Hex connector", [-20.8, -69]);
    layout_label("Long sleeve", [19.5, -69]);
    layout_label("Short sleeve", [55.9, -69]);
    layout_label("End block", [91, -69]);
}

module current_parts_layout() {
    // The two row centerlines sit equally far from the X axis. The outer
    // structural parts align with the outer fasteners, and the stand is
    // centered between them.
    translate([-91, 52.5, 0])
        rotate([0, 0, 180])
            circle_holder();

    translate([0, 52.5, 0])
        vertical_support_stand();

    translate([91, 52.5, 0])
        compact_threaded_base();

    // Fasteners and one representative of every modular base component.
    // Their former X spacing is increased by 30 percent around X=0.
    translate([-91, -52.5, 0])
        m12_stand_bolt();

    translate([-54.6, -52.5, 0])
        m12_nut();

    translate([-20.8, -52.5, 0])
        base_threaded_connector();

    translate([19.5, -52.5, 0])
        base_double_socket(base_socket_x_length);

    translate([55.9, -52.5, 0])
        base_double_socket(base_socket_y_length);

    translate([91, -52.5, 0])
        base_end_block();

    if (show_labels)
        current_parts_labels();
}

assert(
    part == "all"
        || part == "assembly"
        || part == "holder"
        || part == "stand_bolt"
        || part == "nut"
        || part == "stand"
        || part == "stand_flat"
        || part == "stand_long_side"
        || part == "platform"
        || part == "base_socket_x"
        || part == "base_socket_y"
        || part == "base_end_block"
        || part == "base_connector"
        || part == "platform_preview",
    str("Unknown part: ", part)
);

if (part == "all") {
    current_parts_layout();

    if (show_magsafe_reference)
        translate([-91, 52.5, 0])
            magsafe_reference();
} else if (part == "assembly") {
    complete_assembly();
} else if (part == "holder") {
    circle_holder();
} else if (part == "stand_bolt") {
    m12_stand_bolt();
} else if (part == "nut") {
    m12_nut();
} else if (part == "stand") {
    vertical_support_stand_for_print();
} else if (part == "stand_flat") {
    vertical_support_stand_flat_for_print();
} else if (part == "stand_long_side") {
    vertical_support_stand_long_side_for_print();
} else if (part == "platform") {
    compact_threaded_base();
} else if (part == "base_socket_x") {
    base_double_socket(base_socket_x_length);
} else if (part == "base_socket_y") {
    base_double_socket(base_socket_y_length);
} else if (part == "base_end_block") {
    base_end_block();
} else if (part == "base_connector") {
    base_threaded_connector();
} else if (part == "platform_preview") {
    platform_fit_preview();
}
