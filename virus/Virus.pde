
Settings settings;
World world;
Renderer renderer;
Editor editor;
Graph graph;
PFont font;

final double EPS = 0.00000001;
final double E_RECIPROCAL = 0.3678794411;
final color WASTE_COLOR = color(100, 65, 0);
final color FOOD_COLOR = color(255, 0, 0);
final color HAND_COLOR = color(0, 128, 0);
final color TELOMERE_COLOR = color(0, 0, 0);
final color ENERGY_COLOR = color(255, 255, 0);
final color WALL_COLOR = color(210, 50, 210);
final color COPYRIGHT_TEXT_COLOR = color(0, 0, 0, 200);
final color DIVINE_CONTROL_COLOR = color(204, 102, 0);
final color DIVINE_DISABLED_COLOR = color(128, 102, 77);
final float HAND_DIST = 32;
final float HAND_LEN = 7;
final double SPEED_LOW = 0.01;
final double SPEED_HIGH = 0.02;
final float BIG_FACTOR = 100;
final float PLAY_SPEED = 0.6;
final double VISUAL_TRANSITION = 0.38;
final double MARGIN = 4;
final double DETAIL_THRESHOLD = 10;
final double[] GENOME_LIST_DIMS = {70, 430, 360, 450};
final double[] EDIT_LIST_DIMS = {550, 434, 180, 450};
final double CODON_DIST = 17;
final double CODON_DIST_UGO = 10.6;
final float CODON_WIDTH = 1.4;
final float[][] CODON_SHAPE = {{-2,0},{-2,2},{-1,3},{0,3},{1,3},{2,2},{2,0},{0,0}};
final float[][] TELOMERE_SHAPE = {{-2,2},{-1,3},{0,3},{1,3},{2,2},{2,-2},{1,-3},{0,-3},{-1,-3},{-2,-2}};
final String[] DIVINE_CONTROLS = {"Remove", "Revive", "Heal", "Energize", "Make Wall", "Make Shell"};
final color GRAPH_WASTES = color(153, 99, 0);
final color GRAPH_UGOS = color(30, 200, 30);
final color GRAPH_CELLS = color(210, 50, 210);

void setup() {
  
    size(1728, 972);
    noSmooth(); 
  
    surface.setTitle("The Game Of Life, Death And Viruses");
    surface.setResizable(true);
  
    font = loadFont("Jygquip1-96.vlw");
    settings = new Settings();
    world = new World( settings );
    renderer = new Renderer( settings );
    editor = new Editor( settings );
    graph = new Graph( settings.graph_length, width - height - 20, height - 300 );
    graph.setRescan( settings.graph_rescan );
    
    println("Ready!");
    
}

void draw() {
  
    inputCheck();
    world.updateParticleCount();
    world.tick();
    
    renderer.drawBackground();
    renderer.drawCells();
    renderer.drawParticles();
    renderer.drawExtras();
    renderer.drawUI();
    renderer.drawCredits();
  
}
