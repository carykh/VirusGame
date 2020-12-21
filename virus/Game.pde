//class c{
  boolean DEBUG_WORLD = false; //todo settings
  boolean AdvGenome = false;

  //###SCREEN
  final static int ORIG_W_W = 1728;
  final static int ORIG_W_H = 972;
  final static int UI_THICKNESS = ORIG_W_W-ORIG_W_H;
  final static int MAX_WINDOW = javax.swing.JFrame.MAXIMIZED_BOTH;
  int W_W = ORIG_W_W;
  int W_H = ORIG_W_H;
  final double screenRatio = ORIG_W_W/(double)ORIG_W_H;


  //###COLOURS
  final color WASTE_COLOR = color(100, 65, 0);
  final color FOOD_COLOR = color(255, 0, 0);
  final color HAND_COLOR = color(0, 128, 0);
  final color TELOMERE_COLOR = color(0, 0, 0);
  final color ENERGY_COLOR = color(255, 255, 0);
  final color WALL_COLOR = color(210, 50, 210);
  final color COPYRIGHT_TEXT_COLOR = color(0, 0, 0, 200);

  //###CONST
  final static double EPS = 0.00000001;
  final static double E_RECIPROCAL = 0.3678794411;
  final static float HAND_DIST = 32;
  final static float HAND_LEN = 7;
  final static double SPEED_LOW = 0.01;
  final static double SPEED_HIGH = 0.02;
  final static float BIG_FACTOR = 100;
  final static double VISUAL_TRANSITION = 0.38;
  final static double MARGIN = 4;
  final static double DETAIL_THRESHOLD = 10;
  final static Dim GENOME_LIST_DIMS = new Dim(70, 430, 360, 450);
  final static Dim EDIT_LIST_DIMS = new Dim(550, 430, 180, 450);
  final static int VIEW_FIELD_DIS_CNT = 16;
  
  //###VAR
  float PLAY_SPEED = DEBUG_WORLD?40:0.6;
  float scalefactor = 1;

  Settings settings;
  World world;
  Renderer renderer;
  Editor editor;
  PFont font;

  static Util util; {util = new Util();}
  VirusGame game = new VirusGame();
  Input input = new Input();

  void settings() {
    size(ORIG_W_W, ORIG_W_H);  //size(ORIG_W_W, ORIG_W_H); //apprrently used a static const is not allowed lol
    noSmooth();
    //size & noSmooth are a bit special, cannot call is from anywhere but eva
  }
  
  void setup() {
    game.setup();
  }

  void draw() {
    game.draw();
  }


  void keyPressed() {
    input.keyPressed();
  }

  void mouseWheel(processing.event.MouseEvent event) {
    input.mouseWheel(event);
  }
//}
