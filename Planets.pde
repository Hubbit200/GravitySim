//VARIABLES & CLASSES --------------------------------------------------
double gVar = 6.674e-11;
Body[] celestialBodies = new Body[0];

float viewX, viewY;

boolean dragging, running = true, createOpen, spawnStationary = false;
float speed = 1, updateFrequency = 20, qualityLevel = 1, spawnRadius = 20, spawnXSpeed, spawnYSpeed, spawnMassMult = 1;
double spawnMass = 9e23;
float ogX, ogY, lastMillis = -speed, zoom = 1, draggingY;
ArrayList<PVector> collisions = new ArrayList<PVector>();
PVector[] stars = new PVector[150];

PImage pause, play, menubg, x1, x5, x05, recentre, create, planetsTex;
PImage[] planetTex = new PImage[10];
color[] trailColours = {#5F5F5F, #A5A5A5, #A5A5A5, #E5B66F, #6F76E5, #D38253, #E5C89B, #868BE0, #C586E0, #FADB28};
int hovered, draggingValue, centeredId = -1;

//CELESTIAL BODY CLASS
class Body {
  private float posX, posY, trailX, trailY, radius;
  private double accX, accY, mass;
  private double velX, velY;
  private int planetTexIndex, id;
  private boolean stationary;
  private PVector[] trail = new PVector[16];

  Body(final int x, final int y, final float rad, final double m, final int i, final float sx, final float sy, final boolean stat) {
    posX = x;
    posY = y;
    radius = rad;
    mass = m;
    id = i;
    velX = sx;
    velY = sy;
    if (radius < 20)planetTexIndex = 0;
    else if (radius >= 20 && radius < 45)planetTexIndex = round(random(0.51, 3.49));
    else if (radius < 100)planetTexIndex = round(random(3.51, 8.49));
    else planetTexIndex = 9;
    stationary = stat;
    trail[0] = new PVector(posX, posY);
    for (int o = 1; o < trail.length; o++) {
      trail[o] = new PVector(-1, 0);
    }
  }

  //Draw body
  void drawBody() {
    //fill(r, g, b);
    if (!stationary)for (int o = 0; o < trail.length; o++) {
      fill(trailColours[planetTexIndex], 255/(o/8+2));
      if (trail[o].x!=-1)circle((trail[o].x-viewX)*zoom, zoom*(trail[o].y-viewY), radius/(o+2)*zoom);
    }
    //circle((posX-viewX)*zoom, (posY-viewY)*zoom, radius*zoom);
    image(planetTex[planetTexIndex], (posX-viewX-radius/2)*zoom, (posY-viewY-radius/2)*zoom, radius*zoom, radius*zoom);
  }

  void updatePos() {
    if (!stationary) {
      updateVel();
      if (abs(trail[0].x-posX)>radius*2 || abs(trail[0].y-posY)>radius*2)trail = (PVector[])subset(splice(trail, new PVector(trailX, trailY), 0), 0, trail.length);
      else if (abs(trail[0].x-posX)>radius || abs(trail[0].y-posY)>radius) {
        trailX = posX;
        trailY = posY;
      }
      posX += velX * speed / frameRate;
      posY += velY * speed / frameRate;

      checkCollisions();
    }
    if (abs(posX)>999999 || abs(posY) > 999999)destroyBody(id);
  }

  void checkCollisions() {
    for (Body p : celestialBodies) {
      if (p.id != id && dist(posX, posY, p.posX, p.posY) < radius/2 + p.radius/2 && !collisions.contains(new PVector(p.id, id, 0)) && !collisions.contains(new PVector(id, p.id, 0))) {
        collisions.add(new PVector(id, p.id));
        println(collisions);
        if (radius < p.radius) {
          collisions.remove(collisions.indexOf(new PVector(id, p.id, 0)));
          p.velX = p.velX/2;
          p.velY = p.velY/2;
          destroyBody(id);
        } else {
          collisions.remove(collisions.indexOf(new PVector(id, p.id, 0)));
          velX = velX/2;
          velY = velY/2;
          destroyBody(p.id);
        }
      }
    }
  }

  void updateVel() {
    velX += accX * speed / frameRate;
    velY += accY * speed / frameRate;
  }

  void calcAccl() {
    accX = 0;
    accY = 0;
    for (Body p : celestialBodies) {
      if (p.id != id) {
        double r = 1000 * Math.sqrt((p.posX-posX)*(p.posX-posX) + (p.posY-posY)*(p.posY-posY));
        double acc = gVar * p.mass / (r*r);
        accX += (p.posX-posX) / r * acc;
        accY +=  (p.posY-posY) / r * acc;
      }
    }
  }
}

//METHODS -----------------------------------------------
//Create new body
void newPlanet(final int x, final int y, final float r, final double m, final float sx, final float sy, final boolean stat) {
  celestialBodies = (Body[]) expand(celestialBodies, celestialBodies.length+1);
  celestialBodies[celestialBodies.length-1] = new Body(x, y, r, m, celestialBodies.length-1, sx, sy, stat);
}

void destroyBody(int id) {
  celestialBodies[id] = celestialBodies[celestialBodies.length-1];
  celestialBodies[id].id = id;
  celestialBodies = (Body[]) shorten(celestialBodies);
  if (centeredId == id) {
    if (centeredId < celestialBodies.length-1)centeredId++;
    else centeredId = 0;
  }
}

void recenter() {
  viewY = 0;
  viewX = 0;
}

void drawUI() {

  if (mouseY<80 && mouseX > width/5*2) {
    if (mouseX<width/2 && mouseX>width/2-65)hovered=1;
    else if (mouseX>width/2 && mouseX<width/2+65)hovered=2;
    else if (mouseX>width/2+width/19 && mouseX<width/2+width/19+65)hovered=3;
    else if (mouseX>width/2-width/19-60 && mouseX<width/2-width/19+65)hovered=4;
  } else if (createOpen && mouseY < 205 && mouseX > width/4 && mouseX < width/4+width/5) {
    if (mouseX<width/3.55)hovered = 5;
    else if (mouseX<width/3.1)hovered = 6;
    else if (mouseX<width/2.85)hovered = 7;
    else if (mouseX<width/2.5)hovered = 8;
    else hovered = 9;
  } else hovered = 0;


  if (createOpen) {
    fill(160);
    if (hovered == 0)circle(mouseX, mouseY, spawnRadius*zoom);
    fill(100);
    rect(width/4, 5, width/5, 200, 20);
    fill(0);
    text("RADIUS", width/3.71, 183);
    rect(width/3.71-2, 20, 4, 145);
    if (hovered != 5)rect(width/3.71-10, map(spawnRadius, 5, 200, 165, 20), 20, 5);
    else rect(width/3.71-12, map(spawnRadius, 5, 200, 165, 20), 24, 6);
    text("VEL X", width/3.3, 183);
    rect(width/3.3-2, 20, 4, 145);
    if (hovered != 6)rect(width/3.3-10, map(spawnXSpeed, -100, 100, 165, 20), 20, 5);
    else rect(width/3.3-12, map(spawnXSpeed, -100, 100, 165, 20), 24, 6);
    text("VEL Y", width/2.96, 183);
    rect(width/2.96-2, 20, 4, 145);
    if (hovered != 7)rect(width/2.96-10, map(spawnYSpeed, 100, -100, 165, 20), 20, 5);
    else rect(width/2.96-12, map(spawnYSpeed, 100, -100, 165, 20), 24, 6);
    text("MASS", width/2.69, 183);
    rect(width/2.69-2, 20, 4, 145);
    if (hovered != 8)rect(width/2.69-10, map(spawnMassMult, -2, 2, 165, 20), 20, 5);
    else rect(width/2.69-12, map(spawnMassMult, -2, 2, 165, 20), 24, 6);
    text("STATIONARY", width/2.4, 183);
    if (hovered != 9)fill(120);
    else fill(140);
    rect(width/2.4-40, 120, 80, 40, 10);
    fill(0);
    if (spawnStationary)text("YES", width/2.4-40, 120, 80, 36);
    else text("NO", width/2.4-40, 120, 80, 36);
  }

  image(menubg, width/5*2, 0, width/5, 80);

  if (running) {
    if (hovered != 1) {
      tint(255, 50);
      image(pause, width/2-67, 10, 60, 60);
      tint(255, 255);
      image(pause, width/2-65, 8, 60, 60);
    } else image(pause, width/2-67, 10, 60, 60);
  } else {
    if (hovered != 1) {
      tint(255, 50);
      image(play, width/2-67, 10, 60, 60);
      tint(255, 255);
      image(play, width/2-65, 8, 60, 60);
    } else image(play, width/2-67, 10, 60, 60);
  }

  if (speed == 1) {
    if (hovered != 2) {
      tint(255, 50);
      image(x1, width/2+5, 11, 60, 60);
      tint(255, 255);
      image(x1, width/2+7, 9, 60, 60);
    } else image(x1, width/2+5, 11, 60, 60);
  } else if (speed == 5) {
    if (hovered != 2) {
      tint(255, 50);
      image(x5, width/2+5, 11, 60, 60);
      tint(255, 255);
      image(x5, width/2+7, 9, 60, 60);
    } else image(x5, width/2+5, 10, 60, 60);
  } else if (speed == 0.5) {
    if (hovered != 2) {
      tint(255, 50);
      image(x05, width/2+5, 11, 60, 60);
      tint(255, 255);
      image(x05, width/2+7, 9, 60, 60);
    } else image(x05, width/2+5, 10, 60, 60);
  }

  if (hovered != 3) {
    tint(255, 50);
    image(recentre, width/2+width/19, 11, 60, 60);
    tint(255, 255);
    image(recentre, width/2+width/19+2, 9, 60, 60);
  } else image(recentre, width/2+width/19, 11, 60, 60);
  if (hovered!=4) {
    tint(255, 50);
    image(create, width/2-width/19-60, 11, 60, 60);
    tint(255, 255);
    image(create, width/2-width/19-58, 9, 60, 60);
  } else image(create, width/2-width/19-60, 11, 60, 60);
  
  fill(255);
  if(centeredId != -1)text("Planeta "+celestialBodies[centeredId].id, width/2, 110);
}

//START ----------------------------------------------------------------
//Setup
void setup() {
  //size(1400, 1200);
  frameRate(60);
  fullScreen();
  smooth();
  fill(255);
  background(0);
  noStroke();
  textSize(20);
  textAlign(CENTER, CENTER);

  //Load images
  pause = loadImage("pause.png");
  play = loadImage("play.png");
  menubg = loadImage("menubg.png");
  x1 = loadImage("1x.png");
  x5 = loadImage("5x.png");
  x05 = loadImage("0.5x.png");
  recentre = loadImage("centre.png");
  create = loadImage("create.png");
  planetsTex = loadImage("planets.png");
  for (int i = 0; i < 10; i++) {
    planetTex[i] = planetsTex.get(i%5*200, floor(i/5)*200, 200, 200);
  }

  for (int i = 0; i < 150; i++) {
    stars[i] = new PVector(random(-5000, 5000), random(-2000, 2000), random(1, 4));
  }

  //Create init planets
  newPlanet(550, 400, 30, 5.9e20, 5, -130, false);
  newPlanet(400, 400, 60, 5.9e24, 5, -80, false);
  newPlanet(1500, 600, 160, 9e25, 0, 0, true);
}

void draw() {
  if (centeredId != -1) {
    viewX = celestialBodies[centeredId].posX-width/(2*zoom);
    viewY = celestialBodies[centeredId].posY-height/(2*zoom);
  } else if (dragging) {
    viewX = viewX + (ogX-mouseX);
    viewY = viewY + (ogY-mouseY);
    ogY = mouseY;
    ogX = mouseX;
  }
  if (draggingValue!=0) {
    switch(draggingValue) {
    case 1:
      spawnRadius = constrain(map(mouseY, 20, 165, 200, 5), 5, 200);
      break;
    case 2:
      spawnXSpeed = constrain(map(mouseY, 20, 165, 100, -100), -100, 100);
      break;
    case 3:
      spawnYSpeed = constrain(map(mouseY, 20, 165, -100, 100), -100, 100);
      break;
    case 4:
      spawnMassMult = constrain(map(mouseY, 20, 165, 2, -2), -2, 2);
      break;
    }
  }

  background(0);
  fill(255);
  for (int i = 0; i < 150; i++) {
    if (stars[i].x-(viewX/4*zoom) > 0 && stars[i].y-(viewY/4*zoom) > 0 && stars[i].x-(viewX/4*zoom)<width && stars[i].y-(viewY/4*zoom) < height)circle(stars[i].x-(viewX/4*zoom), stars[i].y-(viewY/4*zoom), stars[i].z);
  }

  for (Body p : celestialBodies) {
    if (millis()-lastMillis > updateFrequency/speed/qualityLevel && running) {
      p.calcAccl();
    }
    if (running)p.updatePos();
    p.drawBody();
  }
  if (millis()-lastMillis > updateFrequency/speed/qualityLevel)lastMillis = millis();

  drawUI();
}

void mousePressed() {
  if (hovered == 0) {
    if (createOpen) {
      newPlanet((int)((mouseX/zoom+viewX)), (int)((mouseY/zoom+viewY)), spawnRadius, spawnMass*pow(10, spawnMassMult), spawnXSpeed, spawnYSpeed, spawnStationary);
      createOpen = false;
    } else {
      dragging = true;
      ogX = mouseX;
      ogY = mouseY;
    }
  } else {
    switch(hovered) {
    case 1:
      running = !running;
      break;
    case 2:
      if (speed == 1)speed = 5;
      else if (speed == 5)speed = 0.5;
      else speed = 1;
      break;
    case 3:
      viewX = 0;
      viewY = 0;
      zoom = 1;
      break;
    case 4:
      createOpen = !createOpen;
      break;
    case 5:
      draggingValue = 1;
      draggingY = mouseY;
      break;
    case 6:
      draggingValue = 2;
      draggingY = mouseY;
      break;
    case 7:
      draggingValue = 3;
      draggingY = mouseY;
      break;
    case 8:
      draggingValue = 4;
      draggingY = mouseY;
      break;
    case 9:
      spawnStationary = !spawnStationary;
      break;
    }
  }
}
void mouseReleased() {
  dragging = false;
  draggingValue = 0;
}

void mouseWheel(MouseEvent event) {
  if (event.getCount()>0 && zoom-0.05 > 0.3) {
    zoom-=0.05;
    viewX += (width/2*zoom-width/2*(zoom+0.05));
    viewY += (height/2*zoom-height/2*(zoom+0.05));
  } else if (event.getCount()<0 && zoom+0.05 < 2) {
    zoom+=0.05;
    viewX += (mouseX*zoom-mouseX*(zoom-0.05))/2;
    viewY += (mouseY*zoom-mouseY*(zoom-0.05))/2;
  }
}

void keyPressed() {
  if (key == 'p') {
    if (centeredId < celestialBodies.length-1)centeredId++;
    else centeredId = -1;
  }
}
