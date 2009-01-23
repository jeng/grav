// -*- mode:java; c-basic-offset: 4; indent-tabs-mode: nil -*-

// Copyright (c) 2009 Jeremy English <jhe@jeremyenglish.org>

// Permission to use, copy, modify, distribute, and sell this software
// and its documentation for any purpose is hereby granted without
// fee, provided that the above copyright notice appear in all copies
// and that both that copyright notice and this permission notice
// appear in supporting documentation.  No representations are made
// about the suitability of this software for any purpose.  It is
// provided "as is" without express or implied warranty.

// Created: 23-January-2009

class Pos{
    private int x,y;
    Pos(int x, int y){
        this.x = x;
        this.y = y;
    }
    int getX(){
        return x;
    }
    int getY(){
        return y;
    }
}

class GuiFont{
    private PFont pf;
    private color c;
    private int sz;

    GuiFont(PFont pf, color c, int sz){
        this.pf = pf;
        this.c = c;
        this.sz = sz;
    }

    void makeActive(){
        textFont(pf,sz);
    }

    color getColor(){
        return c;
    }

    int getSize(){
        return sz;
    }

    PFont getFont(){
        return pf;
    }
}


interface ClickEvent {
    void onClick(Object tag);
}

interface Drawable{
    void draw();
}

interface MouseMove{
    void onMove();
}

interface MouseDrag{
    void onDrag();
}

interface GuiElement extends Drawable, ClickEvent, MouseMove, MouseDrag{
}

class Button implements GuiElement{
    private String caption;
    private Pos p;
    private ClickEvent ce;
    private int fs;
    private color c;
    private float w, h;
    private int leftPad;
    private int topPad;
    private GuiFont gf;
    private int clickTime;
    private boolean lastOnButton;
    private int onButtonTime;
    private Object tag;

    Button(String caption, Pos p, ClickEvent ce, GuiFont gf, color c){
        this.caption = caption;
        this.p = p;
        this.ce = ce;
        this.fs = gf.getSize();
        this.c = c;
        gf.makeActive();
        this.w = textWidth(caption);
        this.leftPad = round(w/10);
        this.w = this.w + (2 * leftPad);
        this.h = fs;
        this.topPad = round(fs/10);
        this.h = this.h + (2 * topPad);
        this.gf = gf;
        this.clickTime = 0;
        this.lastOnButton = false;
        this.onButtonTime = 0;
    }

    void draw(){
        textAlign(LEFT);
        gf.makeActive();
        pushMatrix();
        translate(p.getX(), p.getY());
        int dct = millis() - clickTime;
        int dob = millis() - onButtonTime;
        int sOffset = round(h/10);
        smooth();
        strokeWeight(2);
        strokeJoin(ROUND);

        if (dob < 125){ //The mouse has just came over the button.
            //Scale everthing up by the padding amount
            //Draw the shadow
            float nw = w + (2 * sOffset);
            float nh = h + (2 * sOffset);
            int nOffset = round(nh/10);
            noStroke();
            fill(0,0,0,50);
            rect(nOffset-sOffset, nOffset-sOffset, nw, nh);
            //Draw a rectangle
            stroke(0);
            fill(c);
            rect(-sOffset,-sOffset, nw, nh);
            //Draw the highlight
            PImage img = createImage(round(nw), round(nh), ARGB);
            for(int i=0; i < img.pixels.length; i++) {
                img.pixels[i] = color(0xff, 0xff, 0xff,  100 - max(0,i % img.width));
            }
            image(img, -sOffset,-sOffset);
            //Draw the text on top
            fill(gf.getColor());
            text(caption, leftPad, topPad + (fs - topPad));
        }
        else if (dct < 250){ //Has not been 1/4 of a second since the click. Draw the pushed down button
            //Draw a rectangle
            fill(c);
            rect(sOffset,sOffset, w, h);
            //Draw the highlight
            PImage img = createImage(round(w), round(h), ARGB);
            for(int i=0; i < img.pixels.length; i++) {
                img.pixels[i] = color(0xff, 0xff, 0xff,  100 - max(0,i % img.width));
            }
            image(img, sOffset, sOffset);
            //Draw the text on top
            fill(gf.getColor());
            text(caption, leftPad + sOffset, topPad + (fs - topPad) + sOffset);
        }
        else { //Draw the default button
            //Draw the shadow
            noStroke();
            fill(0,0,0,50);
            rect(sOffset, sOffset, w, h);
            //Draw a rectangle
            stroke(0);
            fill(c);
            rect(0,0, w, h);
            //Draw the highlight
            PImage img = createImage(round(w), round(h), ARGB);
            for(int i=0; i < img.pixels.length; i++) {
                img.pixels[i] = color(0xff, 0xff, 0xff,  100 - max(0,i % img.width));
            }
            image(img, 0,0);
            //Draw the text on top
            fill(gf.getColor());
            text(caption, leftPad, topPad + (fs - topPad));
        }
        popMatrix();
    }

    private boolean mouseOnButton(){
        int mx = mouseX;
        int my = mouseY;
        return (p.getX() < mx && mx < (p.getX() + w) && p.getY() < my && my < (p.getY() + h));
    }

    void onClick(Object tag){
        if (mouseOnButton()){
            clickTime = millis();
            ce.onClick(tag);
        }
    }

    void onMove(){
        boolean ob = mouseOnButton();
        if (ob && !lastOnButton){
            onButtonTime = millis();
        }
        lastOnButton = ob;
    }

    void onDrag(){}

}

class Slider implements GuiElement{
    private int x;
    private int y;
    private int w;
    private int h;
    private int value;
    private int sx; //slider x
    private int sy; //slider y
    private int sw; //slider width
    private int sh; //slider height;
    private color c;
    private boolean grabbed;
    private float stepper;

    //Value should be in the range of 0 to 100. 0 being all the way to the left.
    Slider(int x, int y, int width, int height, int value, color c){
        this.x = x;
        this.y = y;
        this.w = width;
        this.h = height;
        this.value = value;
        this.sw = round(width / 10);
        this.sh = height;
        this.sy = y;
        this.c = c;
        grabbed = false;
        stepper = (this.w - sw) / 100.0;
    }

    private void set_sx(){
        sx = round((value * stepper) + x);
    }

    void draw(){
        fill(0);
        //Paint the end peices
        rect(x,y,1,sh);
        rect(w + x,y,1,sh);

        //paint the slot for the slider
        rect(x,y + (h/2),w,1);

        //paint the slider
        fill(c);
        set_sx();
        rect(sx,sy,sw,sh);
    }

    void onClick(Object tag){
        int mx = mouseX;
        int my = mouseY;
        grabbed = false;
        if (mousePressed && mouseButton == LEFT){
            if (sx < mx && mx < (sx + sw) && my > sy && my < (sy + sh)){
                grabbed = true;
            }
        }
    }

    void onMove(){}

    void onDrag(){
        int mx = mouseX;
        if (grabbed){
            if(x <= mx && mx <= ((w - sw) + x)){
                int x1 = mx - x;
                println(x1);
                value = round(x1/stepper);
            }
        }
    }

    int getValue(){
        return value;
    }

}


