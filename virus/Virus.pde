
Settings settings;
World world;
Renderer renderer;
Editor editor;
PFont font;

final double EPS = 0.00000001;
final double E_RECIPROCAL = 0.3678794411;
final color WASTE_COLOR = color(100, 65, 0);
final color FOOD_COLOR = color(255, 0, 0);
final color HAND_COLOR = color(0, 128, 0);
final color TELOMERE_COLOR = color(0, 0, 0);
final color ENERGY_COLOR = color(255, 255, 0);
final color WALL_COLOR = color(210, 50, 210);
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
final double[] EDIT_LIST_DIMS = {550, 430, 180, 450};

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
    
    println("Ready!");
    
}

void draw() {
  
    detectMouse();
    world.updateParticleCount();
    world.tick();
    
    renderer.drawBackground();
    renderer.drawCells();
    renderer.drawParticles();
    renderer.drawExtras();
    renderer.drawUI();
    renderer.drawCredits();
  
}
