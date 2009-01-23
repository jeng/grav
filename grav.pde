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

    Planet(int width, int height, float ir){

        POS = new float[DIMENSIONS];
        VEL = new float[DIMENSIONS];
        ACC = new float[DIMENSIONS];

        colors = color(random(0xff), random(0xff), random(0xff));

        /* Initialize positions */
        POS[X] = FLOATRAND(-XR, XR);
        POS[Y] = FLOATRAND(-YR, YR);
        POS[Z] = FLOATRAND(-ZR, ZR);

        if (POS[Z] > -ALMOST) {
            xi = (int)
                ((float) width * (HALF + POS[X] / (POS[Z] + DIST)));
            yi = (int)
                ((float) height * (HALF + POS[Y] / (POS[Z] + DIST)));
        } else
            xi = yi = -1;
        ri = round(ir / POS[Z] + DIST);

        /* Initialize velocities */
        VEL[X] = FLOATRAND(-VR, VR);
        VEL[Y] = FLOATRAND(-VR, VR);
        VEL[Z] = FLOATRAND(-VR, VR);

        /* Draw planets */
        this.draw();

    }

    void draw(){
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

        grav.x = xi;
        grav.y = yi;

        if (POS[Z] > -ALMOST) {
            xi = (int)
                ((float) grav.width * (HALF + POS[X] / (POS[Z] + DIST)));
            yi = (int)
                ((float) grav.height * (HALF + POS[Y] / (POS[Z] + DIST)));
        } else
            xi = yi = -1;

        /* Move */
        grav.x = xi;
        grav.y = yi;
        ri = round(grav.INTRINSIC_RADIUS / POS[Z] + DIST);

        /* Redraw */
        fill(colors);
        if (xi >= 0 && yi >= 0 && xi <= grav.width && yi <= grav.height)
            ellipse(xi,yi,xi + (2 * ri), yi + (2 * ri));
    }

}

class Grav {
    int         width, height;
    int         x, y, sr, nplanets;
    color starcolor;
    Planet planets[];
    int STARRADIUS;
    float INTRINSIC_RADIUS;

    Grav(int w, int h, int np){
        width = w;
        height = h;
        INTRINSIC_RADIUS = height/5;
        STARRADIUS = round(height/(2*DIST));
        sr = STARRADIUS;

        nplanets = np;

        planets = new Planet[nplanets];

        starcolor = color(random(0xff), random(0xff), random(0xff));

        for(int ball = 0; ball < nplanets; ball++)
            planets[ball] = new Planet(width, height, INTRINSIC_RADIUS );
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

        for (int ball = 0; ball < nplanets; ball++)
            planets[ball].draw();
    }
}

Grav grav;

float FLOATRAND(float min, float max){ return random(min, max); }

void setup(){
    size(800,600);
    grav = new Grav(800,600,10);
    print("yes");
}

void draw(){
    background(0);
    //grav.draw();
}

