// Experimental open-bottom support with four replaceable-stud M12 sockets.
// Previous integral-stud and texture-control variants remain unchanged.
$fn = 96;
use <support-rounded-hollow.scad>
use <../shared/vendor/dan-kirshner-threads/2.7/threads.scad>

view = "part"; // "part" or "section". Export only the complete part for printing.
socket_body_x = 23;
socket_body_y = 30;
socket_axis_height = 14;
socket_body_height = 74;
socket_thread_diameter = 12.7;
socket_thread_pitch = 1.75;
socket_stud_diameter = 12;
socket_stud_engagement = 8;
socket_nominal_wall = 3;
socket_boss_diameter = socket_thread_diameter+2*socket_nominal_wall; // 18.7 mm.
socket_channel_length = 10.35;
socket_shell = 6.25; // 6 mm after the 0.25 mm decorative dimples.
socket_void_x = socket_body_x-2*socket_shell; // 10.5 mm.
socket_void_y = socket_body_y-2*socket_shell; // 17.5 mm.
socket_void_top = 37.75;
socket_void_roof_bevel = 4.5;
socket_texture_limit = 50;
socket_epsilon = 0.05;
socket_color = "#F3E5C8";

assert(socket_boss_diameter < socket_body_x);
assert(socket_channel_length < socket_body_x/2);
assert(socket_stud_engagement < socket_channel_length);
// This checks actual 12 mm stud envelopes, not the larger 12.7 mm cutters.
assert(socket_body_y/2-socket_stud_engagement-socket_stud_diameter/2 >= 1);
assert(socket_body_x-2*socket_stud_engagement == 7);
assert(socket_body_y-2*socket_stud_engagement == 14);

module socket_direction(direction) {
    rotate([0,0,direction*90]) children();
}

function socket_face(direction) = direction%2 == 0
    ? socket_body_x/2 : socket_body_y/2;

module open_bottom_cavity() {
    shoulder = socket_void_top-socket_void_roof_bevel;
    union() {
        translate([-socket_void_x/2,-socket_void_y/2,-socket_epsilon])
            cube([socket_void_x,socket_void_y,shoulder+2*socket_epsilon]);
        hull() {
            translate([-socket_void_x/2,-socket_void_y/2,shoulder])
                cube([socket_void_x,socket_void_y,socket_epsilon]);
            translate([-(socket_void_x-2*socket_void_roof_bevel)/2,
                -(socket_void_y-2*socket_void_roof_bevel)/2,
                socket_void_top-socket_epsilon])
                cube([socket_void_x-2*socket_void_roof_bevel,
                    socket_void_y-2*socket_void_roof_bevel,socket_epsilon]);
        }
    }
}

module socket_boss(direction) {
    r = socket_boss_diameter/2;
    // The 45-degree lower haunch merges with the shell, replacing separate ribs.
    // The four overlapping bosses form one load-carrying internal node.
    socket_direction(direction)
        translate([socket_face(direction)-socket_channel_length,0,socket_axis_height])
            rotate([0,90,0])
                linear_extrude(height = socket_channel_length+socket_epsilon)
                    union() {
                        circle(r = r);
                        polygon([[r/sqrt(2),-r/sqrt(2)],
                            [r/sqrt(2),r/sqrt(2)],[r*sqrt(2),0]]);
                    }
}

module socket_thread_cut(direction) {
    // Channels deliberately open through the bosses into the central void.
    // Adjacent channels communicate: do not retain fragile blind-end membranes.
    socket_direction(direction)
        translate([socket_face(direction)+socket_epsilon,0,socket_axis_height])
            rotate([0,-90,0])
                if ($preview)
                    cylinder(d = socket_thread_diameter,
                        h = socket_channel_length+2*socket_epsilon);
                else
                    metric_thread(diameter = socket_thread_diameter,
                        pitch = socket_thread_pitch,
                        length = socket_channel_length+2*socket_epsilon,
                        internal = true, leadin = 3);
}

module socket_contact_masks() {
    // Preserve smooth 17 mm leg-seating faces around all four socket mouths.
    for (direction = [0:3])
        socket_direction(direction)
            translate([socket_face(direction)-1,0,socket_axis_height])
                rotate([0,90,0]) cylinder(d = 17.6,h = 2);
}

module support_threaded_sockets() {
    color(socket_color)
        difference() {
            union() {
                difference() {
                    rounded_support_blank();
                    open_bottom_cavity();
                }
                // Clip reinforcements to the original outer shell and ears.
                intersection() {
                    rounded_support_blank();
                    union() {
                        for (direction = [0:3]) socket_boss(direction);
                    }
                }
            }
            for (direction = [0:3]) socket_thread_cut(direction);
            difference() {
                all_external_texture(socket_texture_limit);
                socket_contact_masks();
            }
        }
}

if (view == "part") {
    support_threaded_sockets();
} else if (view == "section") {
    difference() {
        support_threaded_sockets();
        translate([0,-25,-1]) cube([40,50,socket_body_height+2]);
    }
} else {
    assert(false, "Unknown view: use part or section");
}
