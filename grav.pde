// -*- Mode: java; c-basic-offset: 4; indent-tabs-mode:nil; -*-

// Port of grav by Greg Boewring from the xscreensaver project
// Jeremy English 22-January-2009



final boolean DEF_DECAY = true;   /* Damping for decaying orbits */
final boolean DEF_TRAIL = true;   /* For trails (works good in mono only) */

static boolean decay;
static boolean trail;

final float GRAV    =  -0.02;  /* Gravitational constant */
final float DIST    =  16.0;
final float COLLIDE =   0.0001;
final float ALMOST  =  15.99;
final float HALF    =   0.5;

//final float INTRINSIC_RADIUS    gp->height/5;
//final float STARRADIUS          (unsigned int)(gp->height/(2*DIST));
//final float AVG_RADIUS          (INTRINSIC_RADIUS/DIST);
//final float RADIUS                      (unsigned int)(INTRINSIC_RADIUS/(POS(Z)+DIST));

final float XR = HALF*ALMOST;
final float YR = HALF*ALMOST;
final float ZR = HALF*ALMOST;

final float VR = 0.04;

final int DIMENSIONS = 3;
final int X          = 0;
final int Y          = 1;
final int Z          = 2;

final float DAMP = 0.999999;
final float MaxA = 0.1;    /* Maximum acceleration (w/ damping) */

class Planet{
    float POS[], VEL[], ACC[];
    int    xi, yi, ri;
    color  colors;
    int radius;

    Planet(int x, int y, int width, int height){

        POS = new float[DIMENSIONS];
        VEL = new float[DIMENSIONS];
        ACC = new float[DIMENSIONS];

        colors = color(random(0xff), random(0xff), random(0xff));

        /* Initialize positions */
        POS[X] = x;
        POS[Y] = y;
        POS[Z] = FLOATRAND(-ZR, ZR);

        if (POS[Z] > -ALMOST) {
            xi = (int)
                ((float) width * (HALF + POS[X] / (POS[Z] + DIST)));
            yi = (int)
                ((float) height * (HALF + POS[Y] / (POS[Z] + DIST)));
        } else
            xi = yi = -1;

        /* Initialize velocities */
        VEL[X] = FLOATRAND(-VR, VR);
        VEL[Y] = FLOATRAND(-VR, VR);
        VEL[Z] = FLOATRAND(-VR, VR);

        radius = round(FLOATRAND(10,50));//round(ir / POS[Z] + DIST);

    }

    void draw(Grav gp){
        float      D;          /* A distance variable to work with */
        int cmpt;

        D = POS[X] * POS[X] + POS[Y] * POS[Y] + POS[Z] * POS[Z];
        if (D < COLLIDE)
            D = COLLIDE;
        D = sqrt(D);
        D = D * D * D;
        for (cmpt = X; cmpt < DIMENSIONS; cmpt++) {
            ACC[cmpt] = POS[cmpt] * GRAV / D;
            if (decay) {
                if (ACC[cmpt] > MaxA)
                    ACC[cmpt] = MaxA;
                else if (ACC[cmpt] < -MaxA)
                    ACC[cmpt] = -MaxA;
                VEL[cmpt] = VEL[cmpt] + ACC[cmpt];
                VEL[cmpt] *= DAMP;
            } else {
                /* update velocity */
                VEL[cmpt] = VEL[cmpt] + ACC[cmpt];
            }
            /* update position */
            POS[cmpt] = POS[cmpt] + VEL[cmpt];
        }

        gp.x = xi;
        gp.y = yi;

        if (POS[Z] > -ALMOST) {
            xi = (int)
                ((float) gp.width * (HALF + POS[X] / (POS[Z] + DIST)));
            yi = (int)
                ((float) gp.height * (HALF + POS[Y] / (POS[Z] + DIST)));
        } else
            xi = yi = -1;

        /* Move */
        gp.x = xi;
        gp.y = yi;
        ri = radius;

        /* Redraw */
        stroke(colors);
        fill(colors);
        if (xi >= 0 && yi >= 0 && xi <= gp.width && yi <= gp.height)
            ellipse(xi - ri / 2, yi - ri / 2, ri, ri);
    }

}

class Grav {
    int         width, height;
    int         x, y, sr;
    color starcolor;
    ArrayList planets;
    int STARRADIUS;
    float INTRINSIC_RADIUS;

    Grav(int w, int h){
        width = w;
        height = h;
        INTRINSIC_RADIUS = height/5;
        STARRADIUS = round(height/(2*DIST));
        sr = STARRADIUS;

        planets = new ArrayList();

        starcolor = color(random(0xff), random(0xff), random(0xff));

    }

    void addPlanet(int x, int y){
        x = x - width/2;
        y = y - height/2;
        planets.add(new Planet(x ,y,width,height));
        print("Planet added at " + x + " " + y + " new size is "  + planets.size() + "\n");
    }

    void draw(){
        /* Resize centrepoint */
        switch (round(random(4))) {
        case 0:
            if (sr <  STARRADIUS)
                sr++;
            break;
        case 1:
            if (sr > 2)
                sr--;
        }

        fill(starcolor);
        ellipse(width / 2 - sr / 2, height / 2 - sr / 2, sr, sr);

        for (int ball = 0; ball < planets.size(); ball++){
            Planet p = (Planet)planets.get(ball);
            p.draw(this);
        }
    }
}

Grav grav;

float FLOATRAND(float min, float max){ return random(min, max); }

void mousePressed(){
    grav.addPlanet(mouseX, mouseY);
}

void setup(){
    size(800,600);
    grav = new Grav(800,600);
    print("yes");
}

void draw(){
    background(0);
    grav.draw();
}

