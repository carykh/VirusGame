package virus;


import static virus.Method.*;

public final class Const {
  public static boolean DEBUG_WORLD = false; //todo settings
  public static boolean AdvGenome = false;

  //###SCREEN
  public final static int ORIG_W_W = 1728;
  public final static int ORIG_W_H = 972;
  public final static int UI_THICKNESS = ORIG_W_W - ORIG_W_H;
  public final static int MAX_WINDOW = javax.swing.JFrame.MAXIMIZED_BOTH;
  public final double screenRatio = ORIG_W_W / (double) ORIG_W_H;


  //###COLOURS
  public final static int WASTE_COLOR = color(100, 65, 0);
  public final static int FOOD_COLOR = color(255, 0, 0);
  public final static int HAND_COLOR = color(0, 128, 0);
  public final static int TELOMERE_COLOR = color(0, 0, 0);
  public final static int ENERGY_COLOR = color(255, 255, 0);
  public final static int WALL_COLOR = color(210, 50, 210);
  public final static int COPYRIGHT_TEXT_COLOR = color(0, 0, 0, 200);
  public final static int DIVINE_CONTROL_COLOR = color(204, 102, 0);
  public final static int DIVINE_DISABLED_COLOR = color(128, 102, 77);
  public final static int GRAPH_WASTES = color(153, 99, 0);
  public final static int GRAPH_UGOS = color(30, 200, 30);
  public final static int GRAPH_CELLS = color(210, 50, 210);

  //###CONST
  public final static double EPS = 0.00000001;
  public final static double E_RECIPROCAL = 0.3678794411;
  public final static float HAND_DIST = 32;
  public final static float HAND_LEN = 7;
  public final static double SPEED_LOW = 0.01;
  public final static double SPEED_HIGH = 0.02;
  public final static float BIG_FACTOR = 100;
  public final static double VISUAL_TRANSITION = 0.38;
  public final static double MARGIN = 4;
  public final static double DETAIL_THRESHOLD = 10;
  public final static Dim GENOME_LIST_DIMS = new Dim(70, 430, 360, 450);
  public final static Dim EDIT_LIST_DIMS = new Dim(550, 434, 180, 450);
  public final static double CODON_DIST = 17;
  public final static double CODON_DIST_UGO = 10.6;
  public final static float CODON_WIDTH = 1.4f;
  public final static float[][] CODON_SHAPE = {{-2, 0}, {-2, 2}, {-1, 3}, {0, 3}, {1, 3}, {2, 2}, {2, 0}, {0, 0}};
  public final static float[][] TELOMERE_SHAPE = {{-2, 2}, {-1, 3}, {0, 3}, {1, 3}, {2, 2}, {2, -2}, {1, -3}, {0, -3}, {-1, -3}, {-2, -2}};
  public final static float[][] epigeneticsShape = {{1.5f, 2}, {1.5f, 4}, {1.75f, 4.2f}, {2, 4}, {3, 3.33f}, {2.5f, 3}, {2, 2.66f}, {2, 2}, {1.75f, 2}};
  public final static float[][] epigeneticsMiddleShape = {{-0.5f, 2.8f}, {-0.3f, 3.2f}, {-0.2f, 3.6f}, {-0.1f, 3.8f}, {0, 3.8f}, {0.1f, 3.8f}, {0.2f, 3.6f}, {0.3f, 3.2f}, {0.5f, 2.8f}, {0, 3}};
  public final static String[] DIVINE_CONTROLS = {"Remove", "Revive", "Heal", "Energize", "Make Wall", "Make Shell"};
  public final static int VIEW_FIELD_DIS_CNT = 16;


  //replace double with float regex
  //float.*?(\d+\.\d+)(?!(f|\d))
  //$0f

  //add public regex
  //^(\W+)((\w+ )*)(final|static)
  //$1public $2$4

  //make classes nonstatic and public
  //^([ \t]*)(public )?((static )?|(final )?){2}(class)
  //$1public $5$6

  //make vars public
  //^( *)(public|private|)( \w+ \w+(;| *\=))
  //$1public$3

}
