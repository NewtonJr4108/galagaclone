ArrayList<Starfield> stars = new ArrayList<Starfield>();

PFont font;

//Sprite images (credit goes to 25scratch, Goemar, xdonthave1xx on spriters-resource.com)
PImage logo;
PImage player;


PImage projectile;
PImage en1;
PImage en2;
PImage en3;
PImage en4;

//scaled down image of spaceship to resprent levels of ship durability like in the game
PImage dur;
//keeps from spamming rapidfire
boolean cooldown = false;


//enemy arraylist which is gradually reduced from when it detects firing
ArrayList<Enemy> enemies = new ArrayList<Enemy>();

Player ship = new Player();

//contains vars that dictate what screens runs when as well as keeping track of score and when to prevent running processes when the game ends
NondiegeticScreens gamestate = new NondiegeticScreens();
void setup() {
  size(864, 672);


  //sprites loaded in data file

  en1 = loadImage("enemy1.png");

  en2 = loadImage("enemy2.png");
  en2.resize(64, 64);

  en3 = loadImage("enemy3.png");
  en3.resize(64, 64);

  en4 = loadImage("enemy4.png");
  en4.resize(64, 64);



  font = createFont("font.ttf", 50);
  logo = loadImage("logo.png");
  logo.resize(300, 250);

  player = loadImage("player.png");
  player.resize(128, 128);

  dur = loadImage("player.png");
  dur.resize(32, 32);



  projectile = loadImage("projectile.png");
  projectile.resize(48, 50);

  //total of 10 enemies to defeat, 500 points a piece
  for (int i = 0; i < 10; i++) {
    enemies.add(new Enemy());
  }


  for (int i = 0; i < 200; i++) {

    stars.add(new Starfield());
  }
}

void draw() {
  textFont(font);

  background(0);

  //title page before actual game runs

  gamestate.start();

  //galaga stars only move down screen, so modifying Pvector VY is the only necesarry parameter, x stays the same

  for (Starfield s : stars) {
    //map size of stars to acceleration to create parallax effect
    float vy = map(s.d, 0, 4, 1, 2);
    float vx = 0;

    s.velocity = new PVector(vx, vy);

    s.display();
    s.move();
  }
  //if title screen done (ie button pressed) begin game
  if (gamestate.start == false) {

    ship.move();
    ship.display();
    gamestate.score();
    gamestate.instructions();
    gamestate.durability();

    //if enemy detects it is within 64 pixels of the player, the player's durability will begin to be reduced
    for (int i = 0; i < enemies.size(); i++) {

      Enemy e = enemies.get(i);
      e.move();
      e.display();
      if (dist(e.location.x, e.location.y, ship.location.x, ship.location.y) < 64) {
        gamestate.durability-=1;
      }
    }
  }

  //projectile arraylist iterates through itself as well as the enemies arraylist to detect if they are within 30 pixels
  //if yes, both projectile and enemy at their respective indexes are removed and points are counted
  for (int i = 0; i < ship.rockets.size(); i++) {
    //to ensure you can't fire after death
    if (gamestate.lose == true) {
      return;
    }

    Projectile r = ship.rockets.get(i);
    r.display();
    r.move();



    for (int a = 0; a < enemies.size(); a++) {
      Enemy e = enemies.get(a);


      if (dist(r.p_location.x, r.p_location.y, e.location.x, e.location.y) <= 30) {



        enemies.remove(a);
        ship.rockets.remove(r);



        gamestate.score += 500;
      }
      if (r.p_location.y < -10) {

        ship.rockets.remove(r);
      }
    }
  }
  //winning condition
  if (gamestate.score == 5000) {

    gamestate.win();
  }
}

//functionality for firing cooldown:
//you must release to fire instead of press so there is a bit of delay rather than firing unstoppably
void keyReleased() {
  if (key == 'x') {

    cooldown = true;
    ship.fire();
  }
}



//title, game over screen, win screen, score, durability
class NondiegeticScreens {
  boolean start, lose, win;

  float logoy = height+1000;

  int score;

  float time;

  int durability;



  NondiegeticScreens() {

    start = true;
    lose = false;
    win = false;

    score = 0;

    durability = 60;
  }

  void start() {

    if (start == true) {

      stroke(255);
      //line(width/2, logoy, mouseX, mouseY);

      imageMode(CENTER);

      image(logo, width/2, logoy);

      for (float i = 0; i < 500; i++) {


        if (logoy > height/2) {
          logoy-=0.01;
        } else if (logoy <= height/2) {

          textAlign(CENTER);
          fill(255);
          textSize(40);

          text("Press Any Key to Start", width/2-10, 500);
          if (keyPressed == true) {

            start = false;
          }


          return;
        } else return;
      }
    } else return;
  }

  void score() {
    textAlign(CENTER);
    fill(255);
    textSize(40);

    fill(255, 0, 0);

    text("Score", width*2/3+100, 70);

    fill(255);

    text(score, width*2/3+100, 120);
  }
  void instructions() {
    textSize(9);

    text("Instructions:\nUse X to Fire\nUse Left and Right Arrows to Move\nDefeat the Enemies and get to 5000 points to win\nDon't let the enimies detroy your ship!", width*2/3+100, 600);
  }

  void durability() {
    textSize(10);
    fill(255, 0, 0);
    //There's a difference of about 20 frames from when contact is made with the aliens, so damage is taken from multiples of 40

    text("Ship Durability:", width*2/3+100, 530);


    if (durability == 60) {

      image(dur, width*2/3+60, 560);
    }

    if (durability >= 40) {

      image(dur, width*2/3+100, 560);
    }

    if (durability >= 1) {

      image(dur, width*2/3+140, 560);
    } else {

      lose();

      lose = true;
    }
  }
  void lose() {
    textSize(100);

    fill(255, 0, 0);


    text("Game Over!", width/2, 300);
  }

  void win() {
    textSize(100);

    fill(0, 255, 0);

    text("You Win!", width/2, 300);
  }
}

class Starfield {

  PVector location, velocity, acceleration;
  float d;
  color c;


  Starfield() {
    location = new PVector(random(0, width), random(0, height));
    acceleration= new PVector(0, 0);
    velocity = new PVector(d, 0);
    c = color(random(255), random(255), (0));


    d = random(1, 5);
  }

  void display() {
    //remember to implememnt twinkle effect


    fill(c);


    noStroke();
    circle(location.x, location.y, d);
  }

  void move() {

    velocity.add(acceleration);
    location.add(velocity);

    //wrap
    if (location.y > height) location.y = -1;
  }
}


//acceleration is controlled by arrows, added to velocity and reversed with a bounce on screen edges
class Player {
  PVector location, velocity, acceleration;

  //projectiles stored in player class
  ArrayList<Projectile> rockets = new ArrayList<Projectile>();


  Player() {
    location = new PVector(432, 600);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
  }

  void display() {

    if (gamestate.lose == true) {
      //if lost, don't display

      return;
    }
    imageMode(CENTER);
    image(player, location.x, location.y);
  }

  void move() {


    if (keyCode == RIGHT && keyPressed) {

      acceleration = new PVector(0.1, 0);
    }

    if (keyCode == LEFT && keyPressed) {

      acceleration = new PVector(-0.1, 0);
    }



    if (location.x <= 40) {

      velocity = (new PVector(-velocity.x, 0));
      acceleration = (new PVector(-acceleration.x, 0));
    }

    if (location.x >= width-40) {

      velocity = (new PVector(-velocity.x, 0));
      acceleration = (new PVector(-acceleration.x, 0));
    }
    velocity.limit(5);


    velocity.add(acceleration);
    location.add(velocity);
  }


  void fire() {
    if (cooldown == true) {

      rockets.add(new Projectile());
      //cooldown, can only be fired after pressing
      cooldown = false;
    }
  }
}

class Projectile {
  PVector p_location, p_velocity;

  Projectile() {
    //copies attributes of ship location so ship location itself isn't modified
    p_location = ship.location.copy();
    p_velocity = new PVector(0, -6);
  }

  void move() {
    p_location.add(p_velocity);
  }

  void display() {

    image(projectile, p_location.x, p_location.y);
  }
}

class Enemy {
  boolean initial;
  PVector location, velocity, motion;
  float vx, vy;

  int rnd;


  PImage sprite;



  Enemy() {

    location = new PVector(-100, 1/3*height);

    vx = random(1, 3);

    vy = random(1, 4);

    rnd = round(random(1, 4));
  }



  void display() {

    if (rnd == 1) {

      sprite = en1;
    }
    if (rnd == 2) {

      sprite = en2;
    }
    if (rnd ==3) {

      sprite = en3;
    }

    if (rnd == 4) {

      sprite = en4;
    }

    fill(0, 255, 0);
    image(sprite, location.x, location.y);

    stroke(255);
  }


  void move() {



    if (location.x > ship.location.x) {

      location.add(-vx, 0);
    }

    if (location.x < ship.location.x) {

      location.add(vx, 0);
    }

    location.add(0, vy);


    if (location.y >= height) {

      location.y = -10;
    }
  }
}
