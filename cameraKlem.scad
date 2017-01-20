include <MCAD/nuts_and_bolts.scad>
// Presentation
full = 1;
top = 2;
bottom = 3;
toHold = 4;
calibrate = 5;

display = bottom;

parts = 1;
top_part = 0;
// Sizes

hole_diameter = 57;
ring_size = 10;
klem_thickness = 21;

wing_thickness = 21;
wing_height = 30;

// Leg/foot dimensions
legHeight = 30; // from inner radius till bottom
footWidth = 28.6;    // width of the zwaluwstaart

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

///////////////////////////////////////////////////
// Camera and lens as dummy 
///////////////////////////////////////////////////
coreRadius = hole_diameter / 2;
coreLength = 25;

cameraRadius = 60;
cameraWidth = 40;

adapterRadius = 64.5 /2;
adapterDepth = 23;

lensRadius = 70 / 2;
lensLength = 130;

module cameraLens() {
    union() {
        cylinder(r = coreRadius, h = coreLength + 5, center = false);
        translate([0, 0, -(cameraWidth - 1)])
            color("red") cylinder(r = cameraRadius, h = cameraWidth, center = false);
        translate([0, 0, coreLength])
            color("silver") cylinder(r = adapterRadius, h = adapterDepth, center = false);
        translate([0, 0, coreLength + adapterDepth])
            color("black") cylinder(r = lensRadius, h = lensLength, center = false);
    }
}

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
    boltType = 6; // M6
    echo ("bolt length = ", boltLeng);
    echo ("Tolerance = ", tol);
    translate([0, 0, -(30 + hole_radius)])
    union() {
        boltHole(boltType, MM, tolerance = tol, boltLeng );
        translate([0, 0, boltLeng - 1 - cap_height]) nutHole(size = boltType, tolerance = tol);
    }
}

////////////////////////////////////////////////////////////////
// The total setup
////////////////////////////////////////////////////////////////]
module klem() {
    echo("Klem:");
    tolerance = 0.5;
	difference() {
		fullPart();
        //clampBolts(tolerance);
        connectionBolt(tolerance);
    }
}

// All parts combined
module fullPart() {
    echo ("FullPart");
    union() {
        ring();
        //leg();
    }
}


// The ring, including the 'wings' that bind the two halves
module ring() {
    $fn = 100;
    rotate([90, 0, 0]) difference() {
        union() {
            cylinder(r = hole_radius + ring_size, h = klem_thickness, center = true);
            wing();
            leg();
        }
        cylinder(r = hole_radius, h = 1.2 * klem_thickness, center = true);
        cube(size = [wing_width + 2, gap_thickness, klem_thickness + 2], center = true);
    }
}

module topWedge() {
    // Setup variables
    
    // Angle of line from center to edge of the wing
    theta = atan2(wingHeight/2, wing_width/2);
    echo("theta = ", theta);
    
    // Distance from center to edge of the wing
    d = wingHeight / 2 / sin(theta);
    echo("d = ", d);
    echo("r = ", hole_radius + ring_size);
    
    // Angle between line to wing edge and tangent point
    phi = acos((hole_radius + ring_size) / d);
    echo("phi = ", phi);
    
    // Angle between horizontal and radius to tangent
    alpha = theta + phi;
    
    // Coordinates of the tangent point
    xt = (hole_radius + ring_size) * cos(alpha);
    yt = (hole_radius + ring_size) * sin(alpha);
    
    echo("xt = ", xt);
    echo("yt = ", yt);
    
    difference() {
        linear_extrude(height = klem_thickness, center = true)
            polygon(points = [
                [wing_width/2, wingHeight / 2],
                [-wing_width/2, wingHeight / 2],
                [-xt, yt],
                [xt, yt]
            ]);
        for (side = [1, -1]) rotate([-90, 0, 0])  
            translate([side * (wing_width/2 - capRadius - 3), 0, wingHeight / 2])
                cylinder(r = capRadius + 2, h = 10, center = false);
    }
        
}
// The wings of the ring
module wing() {
    tolerance = 0.5;
    difference() {
        union() {
            cube(size = [wing_width, wingHeight, wing_thickness], center = true);
            topWedge();
        }
        rotate([-90, 0, 0]) clampBolts(tolerance);
    }
}

/////////////////////////////////////////////////////////////////////////
// The bottom part
/////////////////////////////////////////////////////////////////////////

// The leg towards the rail
module leg() {
    footLength = 56;
    footHeight = 22;
    
    rotate([180, 0, 0]) 
    union() {
        translate([0,
                   legHeight / 2 // top to center
                   + hole_diameter / 2,  // top to inner radius
                   0]) 
        union() {
            cube([footWidth, legHeight, klem_thickness], center = true); // leg
            translate([0, -(footHeight -legHeight) / 2, (footLength - klem_thickness)/ 2]) 
                cube([footWidth, footHeight, footLength], center = true);
       }
       bottomWedge();
   }     
}

module bottomWedge() {
    bottomLeg = hole_radius + legHeight;
    boltCenter = wing_width/2 - capRadius - 3; 
    difference() {
        linear_extrude(height = klem_thickness, center = true)
            polygon(points = [
                [footWidth/2, bottomLeg - 5],
                [boltCenter, wingHeight / 2],
                [-boltCenter, wingHeight / 2],
                [-footWidth/2, bottomLeg - 5]
            ]);
        for (side = [1, -1]) rotate([-90, 0, 0])  
            translate([side * (wing_width/2 - capRadius - 3), 0, wingHeight / 2])
                cylinder(r = capRadius + 1, h = 1000, center = false);
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

/////////////////////////////////////////////////////////////////////
// Small cube to check the calibration of the printer
// The horizontal dimension after the printing should be the defined
// foot width
/////////////////////////////////////////////////////////////////////
module calibrate() {
    cube([footWidth, footWidth, 5], center = true);
}

if (display == full) {
		klem();
        color("MediumPurple")clampBolts(0);
        color("MediumPurple") connectionBolt(0);
        rotate([-90,00,0]) translate([ 0, 0, -klem_thickness/2-2.5]) cameraLens();
} else if (display == top) {
        translate([0, 0, klem_thickness / 2])
        rotate([90, 0, 0])
            intersection() {
                translate([0, 0, (hole_radius + ring_size) / 2])
                cube([wing_width + 2, klem_thickness + 2,
                        hole_radius + ring_size + 2], center = true);
                klem();
            }
} else if (display == bottom) {
        translate([0, 0, klem_thickness / 2])
        rotate([90, 0, 0])
            bottomPart();
} else if (display == toHold) {
    cylinder(r = hole_radius, h = 20, $fn = 100);
} else if (display == calibrate) {
    calibrate();
} else leg();
