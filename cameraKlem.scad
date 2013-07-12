include <MCAD/nuts_and_bolts.scad>
// Presentation
parts = 1;
top_part = 0;
// Sizes

hole_diameter = 57;
ring_size = 10;
klem_thickness = 21;

wing_thickness = 21;
wing_height = 30;

gap_thickness = 5;

boltType = 5;
boltLength = 20;

// Derived parameters
hole_radius = hole_diameter / 2;
cap_height = METRIC_NUT_THICKNESS[boltType];
capRadius = METRIC_NUT_AC_WIDTHS[boltType] / 2;
wing_extension = 2 * capRadius + 6;
wing_width = (hole_radius + ring_size + wing_extension) * 2;
wingHeight = boltLength + cap_height - 0.5;


module clampBolts(t = 0) {
    $fn = 100;
    for (side = [1, -1]) 
        translate([side * (wing_width/2 - capRadius - 3), 0, wingHeight / 2-cap_height])
        rotate([180,0,0]) union() {
           boltHole(boltType,MM,tolerance = t, boltLength);
           translate([0, 0, boltLength - cap_height]) nutHole(size = boltType, tolerance = t);
        }
    //echo("cap height = ", cap_height);
}

module connectionBolt(tol) {
    $fn = 100;
    boltLeng =  30 + 2;
    echo ("bolt length = ", boltLeng);
    echo ("Tolerance = ", tol);
    translate([0, 0, -(30 + hole_radius)])
    union() {
        boltHole(boltType, MM, tolerance = tol, boltLeng );
        translate([0, 0, boltLeng - 1 - cap_height]) nutHole(size = boltType, tolerance = tol);
    }
}

module klem() {
    echo("Klem:");
    tolerance = 0.5;
	difference() {
		fullPart();
        clampBolts(tolerance);
        connectionBolt(tolerance);
    }
}

module fullPart() {
    echo ("FullPart");
    union() {
        ring();
        footWedge();
    }
}

module bottomPart() {
    cut_height = hole_radius + 30 + 2;
    intersection() {
        translate([0, 20/2, -cut_height/2])
        cube([wing_width + 2, 40 + 2, cut_height], center = true);
        klem();
    }
}

module ring() {
    $fn = 100;
    rotate([90, 0, 0]) difference() {
        union() {
            cylinder(r = hole_radius + ring_size, h = klem_thickness, center = true);
            cube(size = [wing_width,
                          wingHeight, wing_thickness], center = true);
        }
        cylinder(r = hole_radius, h = 1.2 * klem_thickness, center = true);
        cube(size = [wing_width + 2, gap_thickness, klem_thickness + 2], center = true);
    }
}

module footWedge() {
    translate([-25, -21 /2, -(30 + hole_radius)])
    rotate([0, 0, 90])  rotate([90, 0, 0])
    linear_extrude(height = 50, center = false)
        polygon(points = [[0,0], [28.5,0], [28.5, 5], [21,30], [0,30]]);
}

if (parts == 0) {
		klem();
        color("MediumPurple")clampBolts(0);
        color("MediumPurple") connectionBolt(0);
} else {
    //translate([20, 20, 0]) rotate([0, 0, 90])
    if (top_part == 1) {
        translate([0, 0, klem_thickness / 2])
        rotate([90, 0, 0])
            intersection() {
                translate([0, 0, (hole_radius + ring_size) / 2])
                cube([wing_width + 2, klem_thickness + 2,
                        hole_radius + ring_size + 2], center = true);
                klem();
            }
    } else {
        translate([0, 0, klem_thickness / 2])
        rotate([90, 0, 0])
            bottomPart();
    }
}
