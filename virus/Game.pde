//class c{
  static boolean DEBUG_WORLD = false; //todo settings
  static boolean AdvGenome = false;

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
  final color DIVINE_CONTROL_COLOR = color(204, 102, 0);
  final color DIVINE_DISABLED_COLOR = color(128, 102, 77);
  final color GRAPH_WASTES = color(153, 99, 0);
  final color GRAPH_UGOS = color(30, 200, 30);
  final color GRAPH_CELLS = color(210, 50, 210);

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
  final static Dim EDIT_LIST_DIMS = new Dim(550, 434, 180, 450);
  final static double CODON_DIST = 17;
  final static double CODON_DIST_UGO = 10.6;
  final static float CODON_WIDTH = 1.4;
  final static float[][] CODON_SHAPE = {{-2,0},{-2,2},{-1,3},{0,3},{1,3},{2,2},{2,0},{0,0}};
  final static float[][] TELOMERE_SHAPE = {{-2,2},{-1,3},{0,3},{1,3},{2,2},{2,-2},{1,-3},{0,-3},{-1,-3},{-2,-2}};
  final static float[][] epigeneticsShape = {{1.5, 2}, {1.5, 4}, {1.75, 4.2}, {2, 4}, {3, 3.33}, {2.5, 3}, {2, 2.66}, {2, 2}, {1.75, 2}};
  final static float[][] epigeneticsMiddleShape = {{-0.5, 2.8}, {-0.3, 3.2}, {-0.2, 3.6}, {-0.1, 3.8}, {0, 3.8}, {0.1, 3.8}, {0.2, 3.6}, {0.3, 3.2}, {0.5, 2.8}, {0, 3}};
  final static String[] DIVINE_CONTROLS = {"Remove", "Revive", "Heal", "Energize", "Make Wall", "Make Shell"};
  final static int VIEW_FIELD_DIS_CNT = 16;



        //###VAR
  static float PLAY_SPEED = DEBUG_WORLD?40:0.6;
  float scalefactor = 1;

  static Settings settings;
  static World world;
  static Renderer renderer;
  static Editor editor;
  static Graph graph;
  static PFont font;

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
