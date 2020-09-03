boolean DEBUG_WORLD = false;
boolean AdvGenome = false;

int WORLD_SIZE = 12;
final int ORIG_W_W = 1728;
final int ORIG_W_H = 972;
int W_W = ORIG_W_W;
int W_H = ORIG_W_H;
final double screenRatio = ORIG_W_W/(double)ORIG_W_H;
Cell[][] cells = new Cell[WORLD_SIZE][WORLD_SIZE];
ArrayList<ArrayList<Particle>> particles = new ArrayList<ArrayList<Particle>>(0);
int foodLimit = 180;
float BIG_FACTOR = 100;
float PLAY_SPEED = DEBUG_WORLD?0.1:0.6;
double GENE_TICK_TIME = DEBUG_WORLD?20:40;
double margin = 4;
int START_LIVING_COUNT = 0;
int[] cellCounts = {0,0,0};

double REMOVE_WASTE_SPEED_MULTI = 0.001f;
double removeWasteTimer = 1.0f;

double GENE_TICK_ENERGY = 0.014f;
double WALL_DAMAGE = 0.01f;
static double CODON_DEGRADE_SPEED = 0.008f;
static double EPS = 0.00000001f;

String starterGenome = DEBUG_WORLD?(AdvGenome?"0-0-0".replace("0", "0a0-0aA-46-11-22-33-11-22-33-11-22-33-28-9a1-7a2-0a1-28-97A0-ga0-h93-7aA-0a2-45-d93-993-4b-4a0-890-490-4a0-891-491-4a0-892-4b-893-0a2-590-a91-9a1-a92-9a4-491-2700-891-eaA-0a4-490-2700-890-eaA-0a1-a92-9a5-492-2700-892-eaA-0a5-490-4710-890-491-4710-891-492-4710-892-eaA-00-00"):"33"):"46-11-22-33-11-22-33-45-44-5700-6700";
//"0a0-0aA-46-33-33-33-28-9a1-7a2-0a1-28-97A0-ga0-h93-7aA-0a2-45-d93-993-4b-4a0-890-490-4a0-891-491-4a0-892-4b-893-0a2-590-a91-9a1-a92-9a4-491-2700-891-ea2-0a4-490-2700-890-ea2-0a1-a92-9a5-492-2700-892-ea2-0a5-490-4710-890-491-4710-891-492-4710-892-eaA-00-00-0a0-0aA-46-33-33-33-28-9a1-7a2-0a1-28-97A0-ga0-h93-7aA-0a2-45-d93-993-4b-4a0-890-490-4a0-891-491-4a0-892-4b-893-0a2-590-a91-9a1-a92-9a4-491-2700-891-ea2-0a4-490-2700-890-ea2-0a1-a92-9a5-492-2700-892-ea2-0a5-490-4710-890-491-4710-891-492-4710-892-eaA-00-00-0a0-0aA-46-33-33-33-28-9a1-7a2-0a1-28-97A0-ga0-h93-7aA-0a2-45-d93-993-4b-4a0-890-490-4a0-891-491-4a0-892-4b-893-0a2-590-a91-9a1-a92-9a4-491-2700-891-ea2-0a4-490-2700-890-ea2-0a1-a92-9a5-492-2700-892-ea2-0a5-490-4710-890-491-4710-891-492-4710-892-eaA-00-00"
boolean canDragWorld = false;
double clickWorldX = -1;
double clickWorldY = -1;
boolean DQclick = false;
int[] codonToEdit = {-1,-1,0,0};
Dim genomeListDims = new Dim(70,430,360,450);
Dim editListDims = new Dim(550,430,180,450);
double[] arrowToDraw = null;
Particle selectedUGO = null;
Cell selectedCell = null;
Cell UGOcell;
int lastEditTimeStamp = 0;
int handColor = color(0,128,0);
int TELOMERE_COLOR = color(0,0,0);
int WASTE_COLOR = color(100,65,0);
int MAX_CODON_COUNT = 300; // If a cell were to have more codons in its DNA than this number if it were to absorb a cirus particle, it won't absorb it.

double SPEED_LOW = 0.01f;
double SPEED_HIGH = 0.02f;
double MIN_ARROW_LENGTH_TO_PRODUCE = 0.4f;

double ZOOM_THRESHOLD = 0;//80;
PFont font;
int flashCursorRed = 0;
int activeCursorRed = 0;
boolean activeCursorHighLow = false;
boolean scrollLocked = true;

int dragAndDropCodonId = -1;
double dragAndDropRX;
double dragAndDropRY;

static double globalUIScale = 1;
static class Dim{
  private final double x;
  private final double y;
  private final double w;
  private final double h;
  
  public Dim(double x, double y, double w, double h) {
     this.x = x; 
     this.y = y;
     this.w = w;
     this.h = h;
  }
  
  public double getX() {
    return x;  
  }
  
  public double getY() {
    return y;  
  }
  
  public double getW() {
    return w;  
  }
  
  public double getH() {
    return h;  
  }
  
}


static char[] encording = "0123456789abcdefghijklmnopqrstuvwxyz!£$%^&*()[]{}_,.<>;:'@#~|\\/=+`¬¦ZYXWVUTSRQPONMLKJIHGFEDCBA".toCharArray(); //do not use '-' it is the seperator char
static int enMax = encording.length/2 + encording.length%2;
static int enMin = -encording.length/2;
static HashMap<Character, Integer> decoding = new HashMap();
static {
  for(int i=enMin;i<enMax;i++) {
    decoding.put(codonValToChar(i), i);
  }
}

static int codonCharToVal(char c){
  return decoding.get(c);
}
static char codonValToChar(int i){
  if (i < enMin) i = 0;
  if (i >= enMax) i = 0;
  if (i < 0) i = encording.length + i;
  return encording[i];
}

void setup(){
  font = loadFont("Jygquip1-96.vlw");
  for(int j = 0; j < 3; j++){
    ArrayList<Particle> newList = new ArrayList<Particle>(0);
    particles.add(newList);
  }
  for(int y = 0; y < WORLD_SIZE; y++){
    for(int x = 0; x < WORLD_SIZE; x++){
      int t = getTypeFromXY(x,y);
      cells[y][x] = new Cell(x,y,t,0,1,starterGenome);
      if(t == 2){
        START_LIVING_COUNT++;
        cellCounts[0]++;
      }
    }
  }
  size(1728,972);
  noSmooth();
  UGOcell = new Cell(-1,-1,2,0,1,"00-00-00-00-00");
  
  surface.setResizable(true);
  surface.setSize((int)(W_W * globalUIScale), (int)(W_H * globalUIScale));
  surface.setResizable(false);
  //W_W = (int)(ORIG_W_W*globalUIScale);
  //W_H = (int)(ORIG_W_H*globalUIScale);
  //camS *=globalUIScale;
}
int getTypeFromXY(int preX, int preY){
  int[] weirdo = {0,1,1,2};
  int x = (preX/4)*3;
  x += weirdo[preX%4];
  int y = (preY/4)*3;
  y += weirdo[preY%4];
  int result = 0;
  for(int i = 1; i < WORLD_SIZE; i *= 3){
    if((x/i)%3 == 1 && (y/i)%3 == 1){
      result = 1;
      int xPart = x%i;
      int yPart = y%i;
      boolean left = (xPart == 0);
      boolean right = (xPart == i-1);
      boolean top = (yPart == 0);
      boolean bottom = (yPart == i-1);
      if(left || right || top || bottom){
        result = 2;
      }
    }
  }
  return result;
}

boolean wasMouseDown = false;
double camX = 0;
double camY = 0;
double MIN_CAM_S = ((float)W_H)/WORLD_SIZE;
double camS = MIN_CAM_S;
void draw(){
  scale((float)globalUIScale);
  doParticleCountControl();
  iterate();
  detectMouse();
  drawBackground();
  drawCells();
  drawParticles();
  drawExtras();
  drawUI();
  drawSpeedControl();
}
void drawSpeedControl(){
  fill(80);
  noStroke();
  for(int i=0;i<3;i++)
  {
    rect(10+i*75,10,65,40);
  }
  setTextFont(font,48);
  fill(255);
  textAlign(CENTER, CENTER);
  text("<<", 43, 30);
  text(">>", (10+75*2+33), 30);
  setTextFont(font,38);
  text("x"+String.format("%.1f", PLAY_SPEED), (10+75+33), 30);
}
void drawExtras(){
  if(arrowToDraw != null){
    if(euclidLength(arrowToDraw) > MIN_ARROW_LENGTH_TO_PRODUCE){
      stroke(0);
    }else{
      stroke(0,0,0,80);
    }
    drawArrow(arrowToDraw[0],arrowToDraw[1],arrowToDraw[2],arrowToDraw[3]);
  }
}
void doParticleCountControl(){
  ArrayList<Particle> foods = particles.get(0);
  while(foods.size() < foodLimit){
    int choiceX = -1;
    int choiceY = -1;
    while(choiceX == -1 || cells[choiceY][choiceX].type >= 1){
      choiceX = (int)random(0,WORLD_SIZE);
      choiceY = (int)random(0,WORLD_SIZE);
    }
    double extraX = random(0.3,0.7);
    double extraY = random(0.3,0.7);
    double x = choiceX+extraX;
    double y = choiceY+extraY;
    double[] coor = {x,y};
    Particle newFood = new Particle(coor,0,frameCount);
    foods.add(newFood);
    newFood.addToCellList();
  }
  
  ArrayList<Particle> wastes = particles.get(1);
  if(wastes.size() > foodLimit){
    removeWasteTimer -= (wastes.size()-foodLimit)*REMOVE_WASTE_SPEED_MULTI*PLAY_SPEED;
    while(removeWasteTimer < 0){
      int choiceIndex = -1;
      int iter = 0;
      while(iter < 50 && (choiceIndex == -1 || getCellAt(wastes.get(choiceIndex).coor,true).type == 2)){
        choiceIndex = (int)(Math.random()*wastes.size());
      } // If possible, choose a particle that is NOT in a cell at the moment.
      wastes.get(choiceIndex).removeParticle();
      removeWasteTimer++;
    }
  }
}
double[] getRandomVelo(){
  double sp = Math.random()*(SPEED_HIGH-SPEED_LOW)+SPEED_LOW;
  double ang = random(0,2*PI);
  double vx = sp*Math.cos(ang);
  double vy = sp*Math.sin(ang);
  double[] result = {vx, vy};
  return result;
}
void iterate(){
  for(int z = 0; z < 3; z++){
    ArrayList<Particle> sparticles = particles.get(z);
    for(int i = 0; i < sparticles.size(); i++){
      Particle p = sparticles.get(i);
      p.iterate();
    }
  }
  for(int y = 0; y < WORLD_SIZE; y++){
    for(int x = 0; x < WORLD_SIZE; x++){
      cells[y][x].iterate();
    }
  }
}
void drawParticles(){
  for(int z = 0; z < 3; z++){//z=0 all food, z=1 all waste, z=2 all UGOs
    ArrayList<Particle> sparticles = particles.get(z);
    for(int i = 0; i < sparticles.size(); i++){
      Particle p = sparticles.get(i);
      p.drawParticle(trueXtoAppX(p.coor[0]),trueYtoAppY(p.coor[1]),trueStoAppS(1));
    }
  }
}
void checkUGOclick(){
  clickWorldX = appXtoTrueX(mouseX);
  clickWorldY = appYtoTrueY(mouseY);
  for(Particle UGO: particles.get(2)){
    double dis= euclidLength(new double[]{UGO.coor[0],UGO.coor[1], clickWorldX, clickWorldY});
    if(dis<=0.15){
      if(UGO != selectedUGO)
      {
        selectedCell=null;
        selectedUGO=UGO;
        break;
      }
    }
  }
}

void checkGLdrag() {
  double gx = genomeListDims.getX();
  double gy = genomeListDims.getY();
  double gw = genomeListDims.getW();
  double gh = genomeListDims.getH();
  double rMouseX = ((mouseX-W_H)-gx)/gw;
  double rMouseY = (mouseY-gy)/gh;
  
  Genome g = selectedCell.genome;
  int GENOME_LENGTH = g.codons.size();
  if (GENOME_LENGTH > VIEW_FIELD_DIS_CNT) {
    GENOME_LENGTH = VIEW_FIELD_DIS_CNT;
  }
  double appCodonHeight = gh/GENOME_LENGTH;
  
  if(rMouseX >= 0 && rMouseX < 1 && rMouseY >= 0 && rMouseY < 1){
    if(rMouseY < 1){
  
      dragAndDropCodonId = (int)(rMouseY*min(g.codons.size(), VIEW_FIELD_DIS_CNT)) + g.scrollOffset;
      dragAndDropRX = rMouseX * gw;
      dragAndDropRY = rMouseY * gh - appCodonHeight * (dragAndDropCodonId - g.scrollOffset);
      codonToEdit[0] = codonToEdit[1] = -1;
    }
  }
}


void releaseGLdrag() {
  double gx = genomeListDims.getX();
  double gy = genomeListDims.getY();
  double gw = genomeListDims.getW();
  double gh = genomeListDims.getH();
  
  double minX =-0.25*gw;
  double maxX =+1.25*gw;
  
  
  Genome g = selectedCell.genome;
  int GENOME_LENGTH = g.codons.size();
  if (GENOME_LENGTH > VIEW_FIELD_DIS_CNT) {
    GENOME_LENGTH = VIEW_FIELD_DIS_CNT;
  }
  double appCodonHeight = gh/GENOME_LENGTH;
  
  double arrowUIX =  mouseX - gx - W_H;
  double arrowUIY = mouseY - gy + appCodonHeight/2;
  int arrowRowY = (int)(arrowUIY/appCodonHeight);
  if (arrowRowY >= 0 && arrowRowY <= GENOME_LENGTH && arrowUIX > minX && arrowUIX <= maxX) {
    Codon dragged =g.codons.get(dragAndDropCodonId);
    int newId = arrowRowY + g.scrollOffset;
    if (newId != dragAndDropCodonId) {
      if (newId > dragAndDropCodonId)newId--;
      g.codons.remove(dragAndDropCodonId);
      g.codons.add(newId, dragged);
    }
  }
  dragAndDropCodonId = -1;
  
}

void checkGLclick(){
  if (dragAndDropCodonId > 0)return;
  double gx = genomeListDims.getX();
  double gy = genomeListDims.getY();
  double gw = genomeListDims.getW();
  double gh = genomeListDims.getH();
  double rMouseX = ((mouseX-W_H)-gx)/gw;
  double rMouseY = (mouseY-gy)/gh;
  
   //add arrow
  Genome g = selectedCell.genome;
  int GENOME_LENGTH = g.codons.size();
  int offset = Math.max(0, Math.min(g.scrollOffset, GENOME_LENGTH-VIEW_FIELD_DIS_CNT));
  
  if (GENOME_LENGTH > VIEW_FIELD_DIS_CNT) {
    GENOME_LENGTH = VIEW_FIELD_DIS_CNT;
  }
  
 
  double appCodonHeight = gh/GENOME_LENGTH;
    
  double arrowUIX =  mouseX - gx - W_H;
  double arrowUIY = mouseY - gy + appCodonHeight/2;
  int arrowRowY = (int)(arrowUIY/appCodonHeight);
  double arrowH = min(80, (float)appCodonHeight);
  
  double crossUIX =  mouseX - gx - W_H - gw;
  double crossUIY = mouseY - gy;
  int rowCY = (int)(crossUIY/appCodonHeight);

  
  
  if(rMouseX >= 0 && rMouseX < 1 && rMouseY >= 0){
    if(rMouseY < 1){
      codonToEdit[0] = (int)(rMouseX*2);
      codonToEdit[1] = (int)(rMouseY*min(selectedCell.genome.codons.size(), VIEW_FIELD_DIS_CNT)) + selectedCell.genome.scrollOffset;
    }else if(selectedCell == UGOcell){
      if(rMouseX < 0.5){
        String genomeString = UGOcell.genome.getGenomeStringShortened();
        selectedCell = UGOcell = new Cell(-1,-1,2,0,1,genomeString);
      }else{
        String genomeString = UGOcell.genome.getGenomeStringLengthened();
        selectedCell = UGOcell = new Cell(-1,-1,2,0,1,genomeString);
      }
    }
  } else if (arrowRowY >= 0 && arrowRowY <= GENOME_LENGTH && arrowUIX >= -50 && arrowUIX <= 5) {
      g.codons.add(arrowRowY + offset, new Codon());
  } else if (rowCY >= 0 && rowCY < GENOME_LENGTH && crossUIX >= -5 && crossUIX <= 50) {
      g.codons.remove(rowCY + offset);
      if (g.codons.size() == 0) {
        g.codons.add(new Codon());
      }
  }
}
void checkETclick(){
  double ex = editListDims.getX();
  double ey = editListDims.getY();
  double ew = editListDims.getW();
  double eh = editListDims.getH();
  
  //codon rows
  double rMouseX = ((mouseX-W_H)-ex)/ew;
  double rMouseY = (mouseY-ey)/eh;
  
 
  
  
  
  if(rMouseX >= 0 && rMouseX < 1 && rMouseY >= 0 && rMouseY < 1){
    Button[] currentButtons = codonToEdit[0]==0?codonTypeButtons:codonAttributeButtons;
    
    
    int optionCount = currentButtons.length;
    int choice = (int)(rMouseY*optionCount);
    boolean changeMade = currentButtons[choice].onClick(rMouseX, rMouseY);
    if(changeMade && selectedCell != UGOcell){
            changeMade = true;
            lastEditTimeStamp = frameCount;
            selectedCell.tamper();
     }
     
    

    
    if(codonToEdit[0] == 1 && choice >= optionCount-2){ 
      int diff = 1;
      if(rMouseX < 0.5){
        diff = -1;
      }
      if(choice == optionCount-2){
        codonToEdit[2] = loopCodonInfo(codonToEdit[2]+diff);
      }else{
        codonToEdit[3] = loopCodonInfo(codonToEdit[3]+diff);
      }
    }
  } else{
    codonToEdit[0] = codonToEdit[1] = -1;
    scrollLocked = true;
  }
}
int loopCodonInfo(int val){
  while(val < -30){
    val += 61;
  }
  while(val > 30){
    val -= 61;
  }
  return val;
}


double dragStartX;
double dragStartY;

void detectMouse(){
  if (mousePressed){
    arrowToDraw = null;
    if(!wasMouseDown) {
      dragStartX = mouseX;
      dragStartY = mouseY;
      
      if(mouseX < W_H){
        boolean buttonPressed = true;
        if(mouseX>=10 && mouseX <=75 && mouseY>=10 && mouseY <=50)//speed down
        {
          if(PLAY_SPEED>0.1)
          {
            PLAY_SPEED-=0.1;
          }
        }
        else if(mouseX>=10+2*75 && mouseX <=75+2*75 && mouseY>=10 && mouseY <=50)//speed up
        {
          if(PLAY_SPEED<99.9)
          {
            PLAY_SPEED+=0.1;
          }
        }
        else
        {
          buttonPressed = false;
          codonToEdit[0] = codonToEdit[1] = -1;
          clickWorldX = appXtoTrueX(mouseX);
          clickWorldY = appYtoTrueY(mouseY);
          canDragWorld = true;
        }
        if (buttonPressed) {
          canDragWorld = false;
          wasMouseDown = true;
          return; //fix bug that moven screen when pressing button
        }
      }else{
        if(selectedCell != null){
          if(codonToEdit[0] >= 0){
            checkETclick();
          }
          checkGLclick();
        }
        if(selectedCell == UGOcell){
          if((mouseX >= W_H+530 && codonToEdit[0] == -1) || mouseY < 160){
            selectedCell = null;
            selectedUGO=null;
          }
        }else if(mouseX > W_W-160 && mouseY < 160){
          selectedCell = UGOcell;
          selectedUGO=null;
        }
        canDragWorld = false;
      }
      DQclick = false;
    }else {
      double dragDistSQ = (dragStartX-mouseX)*(dragStartX-mouseX)+(dragStartY-mouseY)*(dragStartY-mouseY); //this is squared, always compare with sqaured number
      if(canDragWorld){
        double newCX = appXtoTrueX(mouseX);
        double newCY = appYtoTrueY(mouseY);
        if(newCX != clickWorldX || newCY != clickWorldY){
          DQclick = true;
        }
        if(selectedCell == UGOcell){
          stroke(0,0,0);
          arrowToDraw = new double[]{clickWorldX,clickWorldY,newCX,newCY};
        }else{
          camX -= (newCX-clickWorldX);
          camY -= (newCY-clickWorldY);
        }
      } else if (selectedCell != null && dragDistSQ > 10 && dragAndDropCodonId < 0) {
        checkGLdrag();
      }
    }
  }
  if(!mousePressed){
    if(wasMouseDown){
      if (dragAndDropCodonId >= 0) {
        releaseGLdrag();
      } else if(selectedCell == UGOcell && arrowToDraw != null){
        if(euclidLength(arrowToDraw) > MIN_ARROW_LENGTH_TO_PRODUCE){
          produceUGO(arrowToDraw);
        }
      }
      
      
      if(!DQclick && canDragWorld){
        double[] mCoor = {clickWorldX,clickWorldY};
        Cell clickedCell = getCellAt(mCoor,false);
        if(selectedCell != UGOcell){
          selectedCell = null;
        }
        if(clickedCell != null && clickedCell.type == 2){
          selectedUGO=null;
          selectedCell = clickedCell;
        }
        
        checkUGOclick();
      }
    }
    clickWorldX = -1;
    clickWorldY = -1;
    arrowToDraw = null;
  }
  wasMouseDown = mousePressed;
}
public void mouseWheel(processing.event.MouseEvent event) {
  float e = event.getCount();
   if (mouseX > W_H) {
    double UIX =  mouseX - W_H;
    double UIY = mouseY;
    if (selectedCell != null & dimWithinBox(genomeListDims, UIX, UIY)) {
      Genome g = selectedCell.genome;
      int GENOME_LENGTH = g.codons.size();
      int scrollValue = max(1,(int)abs(e)/3)*(int)Math.signum(e);
     
      g.scrollOffset = Math.max(0, Math.min(g.scrollOffset + scrollValue , GENOME_LENGTH-VIEW_FIELD_DIS_CNT));
      
      if (codonToEdit[1] >= 0) {
        if (scrollLocked && codonToEdit[1] < g.scrollOffset) {
          g.scrollOffset = codonToEdit[1];
          flashCursorRed++;
        } else if (scrollLocked && codonToEdit[1] >= g.scrollOffset+VIEW_FIELD_DIS_CNT) {
          g.scrollOffset = Math.max(codonToEdit[1]-VIEW_FIELD_DIS_CNT+1, 0);
          flashCursorRed++;
        }
        if (flashCursorRed==1) {
           activeCursorRed = millis();
        }
        if (flashCursorRed>5&(millis()-activeCursorRed)>200) {
           scrollLocked = false;
           activeCursorRed = 0;
           flashCursorRed = 0;
           
        }
      } else {
           scrollLocked = true;
      }
    }
      
    return;
  }
  
  
  double ZOOM_F = 1.05f;
  double thisZoomF = 1;
  if(e == 1){
    thisZoomF = 1/ZOOM_F;
  }else{
    thisZoomF = ZOOM_F;
  }
  double worldX = mouseX/camS+camX;
  double worldY = mouseY/camS+camY;
  camX = (camX-worldX)/thisZoomF+worldX;
  camY = (camY-worldY)/thisZoomF+worldY;
  camS *= thisZoomF;
}
double euclidLength(double[] coor){
  return Math.sqrt(Math.pow(coor[0]-coor[2],2)+Math.pow(coor[1]-coor[3],2));
}
void produceUGO(double[] coor){
  if(getCellAt(coor,false) != null && getCellAt(coor,false).type == 0){
    String genomeString = UGOcell.genome.getGenomeString();
    Particle newUGO = new Particle(coor,2,genomeString,frameCount);
    particles.get(2).add(newUGO);
    newUGO.addToCellList();
    lastEditTimeStamp = frameCount;
  }
}

public boolean dimWithinBox(Dim dims, double x, double y) {
  double dx = dims.getX();
  double dy = dims.getY();
  double w = dims.getW() + dx;
  double h = dims.getH() + dy;
  return dx < x && x <= w && dy < y && y <= h;
}
public void drawBackground(){
  background(255);
}
void drawArrow(double dx1, double dx2, double dy1, double dy2){
  float x1 = (float)trueXtoAppX(dx1);
  float y1 = (float)trueYtoAppY(dx2);
  float x2 = (float)trueXtoAppX(dy1);
  float y2 = (float)trueYtoAppY(dy2);
  strokeWeight((float)(0.03*camS));
  line(x1,y1,x2,y2);
  float angle = atan2(y2-y1,x2-x1);
  float head_size = (float)(0.2*camS);
  float x3 = x2+head_size*cos(angle+PI*0.8);
  float y3 = y2+head_size*sin(angle+PI*0.8);
  line(x2,y2,x3,y3);
  float x4 = x2+head_size*cos(angle-PI*0.8);
  float y4 = y2+head_size*sin(angle-PI*0.8);
  line(x2,y2,x4,y4);
}
String framesToTime(double f){
  double ticks = f/GENE_TICK_TIME*PLAY_SPEED;
  String timeStr = nf((float)ticks,0,1);
  if(ticks >= 1000){
    timeStr = (int)(Math.round(ticks))+"";
  }
  return timeStr+"t since";
}
String count(int count, String s){
  if(count == 1){
    return count+" "+s;
  }else{
    return count+" "+s+"s";
  }
}
void drawUI(){
  pushMatrix();
  translate(W_H,0);
  fill(0);
  noStroke();
  rect(0,0,W_W-W_H,W_H);
  fill(255);
  setTextFont(font,48);
  textAlign(LEFT);
  text(framesToTime(frameCount)+" start",25,60);
  text(framesToTime(frameCount-lastEditTimeStamp)+" edit",25,108);
  setTextFont(font,36);
  text("Healthy: "+cellCounts[0]+" / "+START_LIVING_COUNT,360,50);
  text("Tampered: "+cellCounts[1]+" / "+START_LIVING_COUNT,360,90);
  text("Dead: "+cellCounts[2]+" / "+START_LIVING_COUNT,360,130);
  if(selectedCell != null){
    drawCellStats();
  }
  else if(selectedUGO != null)
  {
    fill(80);
    noStroke();
    rect(10,160,530,W_H-170);
    fill(255);
    setTextFont(font,96);
    textAlign(LEFT);
    text("Selected UGO",25,255);
    drawGenomeAsList(selectedUGO.UGO_genome,genomeListDims);
  }
  popMatrix();
  drawUGObutton((selectedCell != UGOcell));
}
void drawUGObutton(boolean drawUGO){
  fill(80);
  noStroke();
  rect(W_W-130,10,120,140);
  fill(255);
  textAlign(CENTER);
  if(drawUGO){
    setTextFont(font,48);
    text("MAKE",W_W-70,70);
    text("UGO",W_W-70,120);
  }else{
    setTextFont(font,36);
    text("CANCEL",W_W-70,95);
  }
}
void drawCellStats(){
  boolean isUGO = (selectedCell.x == -1);
  fill(80);
  noStroke();
  rect(10,160,530,W_H-170);
  if(!isUGO){
    rect(540,160,200,270);
  }
  fill(255);
  setTextFont(font,96);
  textAlign(LEFT);
  text(selectedCell.getCellName(),25,255);
  if(!isUGO){
    setTextFont(font,32);
    text("Inside this cell,",555,200);
    text("there are:",555,232);
    text(count(selectedCell.getParticleCount(-1),"particle"),555,296);
    text("("+count(selectedCell.getParticleCount(0),"food")+")",555,328);
    text("("+count(selectedCell.getParticleCount(1),"waste")+")",555,360);
    text("("+count(selectedCell.getParticleCount(2),"UGO")+")",555,392);
    drawBar(color(255,255,0),selectedCell.energy,"Energy",290);
    drawBar(color(210,50,210),selectedCell.wallHealth,"Wall health",360);
  }
  drawGenomeAsList(selectedCell.genome,genomeListDims);
  drawButtonTable(editListDims, codonToEdit[0]==0?codonTypeButtons:codonAttributeButtons);
  //drawEditTable(editListDims);
  if(!isUGO){
    fill(255);
    setTextFont(font,32);
    textAlign(LEFT);
    text("Memory: "+getMemory(selectedCell),25,940);
    textAlign(RIGHT);
    int offset = 0;
    
    {
      List<Codon> codons = selectedCell.genome.codons;
      SortedSet<Integer> foundIds = new TreeSet(); //i know this is very wasteful of objects but we cannot do better than this, luckily just once per frame
      HashMap<Integer, Integer> from = new HashMap(); 
      HashMap<Integer, Integer> to = new HashMap(); 
      for(int i = 0; i < codons.size();i++) {
        Codon c = codons.get(i);
        foundIds.addAll(c.memorySetFrom);
        for(int j:c.memorySetFrom) {
          from.put(j, i);
        }
        for(int j:c.memorySetTo) {
          to.put(j, i);
        }
      }
      for (int i:foundIds) {
        text(i + ":" + from.get(i) + ", " + to.get(i),545,440+(offset++)*32);
      }
    }
    
    
    
  }
}
String getMemory(Cell c){
  if(c.memory.length() == 0){
    return "[NOTHING]";
  }else{
    return "\""+c.memory+"\"";
  }
}

void setTextFont(PFont font, float size) {
  textFont(font,size);
}

final int VIEW_FIELD_DIS_CNT = 16;
public void drawGenomeAsList(Genome g, Dim dims){
  double x = dims.getX();
  double y = dims.getY();
  double w = dims.getW();
  double h = dims.getH();
  int GENOME_LENGTH = g.codons.size();
  int offset = Math.max(0, Math.min(g.scrollOffset, GENOME_LENGTH-VIEW_FIELD_DIS_CNT));
  boolean scrolling = false;
  
  if (GENOME_LENGTH > VIEW_FIELD_DIS_CNT) {
    GENOME_LENGTH = VIEW_FIELD_DIS_CNT;
    scrolling = true;
  }
  
  
  double appCodonHeight = h/GENOME_LENGTH;
  double appW = w*0.5-margin;
  setTextFont(font,30);
  textAlign(CENTER);
  pushMatrix();
  dTranslate(x,y);
  
  if (g.rotateOn >= offset && g.rotateOn < offset+VIEW_FIELD_DIS_CNT) {
    pushMatrix();
    dTranslate(0,appCodonHeight*(g.appRO-offset+0.5f));
    if(selectedCell != UGOcell){
      if(selectedUGO == null){
        drawGenomeArrows(w,appCodonHeight);
      }
    }
    popMatrix();
  }
  
  double redflashFac = 0;
  for(int i = 0; i < GENOME_LENGTH; i++){
    if (i+offset == dragAndDropCodonId) continue;
    double appY = appCodonHeight*i;
    Codon codon = g.codons.get(i+offset);
    
    drawCodon(codon, 0, appY, w, appW, appCodonHeight);
    
    for(int p = 0; p < 2; p++){
      double extraX = (w*0.5-margin)*p;
      if(p == codonToEdit[0] && i + offset == codonToEdit[1]){
        double highlightFac = 0.5f+0.5f*sin(frameCount*0.25f);
        fill(255,255,255,(float)(highlightFac*140));
        dRect(extraX+margin,appY+margin,appW,appCodonHeight-margin*2);
        if (flashCursorRed > 0) {
          
          redflashFac = sin(frameCount*0.25*4/3); //quick = attention
          redflashFac *= redflashFac;
          
          
          if (!activeCursorHighLow & redflashFac > 0.99f) {
            activeCursorHighLow = true;
          } else if (activeCursorHighLow & redflashFac < 0.01f) {
            activeCursorHighLow = false;
            flashCursorRed--;
            if (millis()-activeCursorRed>400) {
              flashCursorRed = 0;
              activeCursorRed = 0;
            }
          }
        
          fill(255,0,0,(float)(redflashFac*255));
          dRect(extraX+margin,appY+margin,appW,appCodonHeight-margin*2);
        }
      }
    }
  }
  
  if(scrolling) {
    double unit = h/g.codons.size();
    double scrbar_h = unit*20;
    double scrbar_y = unit*offset;
    
    fill(255);
    dRect(x+w+40-5,scrbar_y,5,scrbar_h);
    fill(255,0,0,(float)(redflashFac*255));
    dRect(x+w+40-5,scrbar_y,5,scrbar_h);
  }
  
  if(selectedCell == UGOcell){
    fill(255);
    setTextFont(font,60);
    double avgY = (h+height-y)/2;
    dText("( - )",w*0.25,avgY+11);
    dText("( + )",w*0.75-margin,avgY+11);
  }
  
   
  double arrowUIX =  mouseX - x - W_H;
  double arrrowUIY = mouseY - y + appCodonHeight/2;
  int rowAY = (int)(arrrowUIY/appCodonHeight);
  
  //drag and drop
  if (dragAndDropCodonId >= 0 && dragAndDropCodonId<g.codons.size()) {
    
    
    double minX =-0.25*w;
    double maxX =+1.25*w;
  
    if (rowAY >= 0 && rowAY <= GENOME_LENGTH && arrowUIX > minX && arrowUIX <= maxX) {
      
      fill(255);
      drawAddArrows(0, rowAY*appCodonHeight, min(80, (float)appCodonHeight), false);
      
      drawAddArrows(w, rowAY*appCodonHeight, min(80, (float)appCodonHeight), true);
    }
    
    setTextFont(font,30);
    textAlign(CENTER);
    drawCodon(g.codons.get(dragAndDropCodonId), mouseX-x-W_H-dragAndDropRX, mouseY-y-dragAndDropRY, w, appW, appCodonHeight);
    
  } else {
    //add button
    
    if (rowAY >= 0 && rowAY <= GENOME_LENGTH && arrowUIX >= -70 && arrowUIX <= 25) {
      
      fill(color(100,255,0));
      drawAddArrows(0, rowAY*appCodonHeight, min(80, (float)appCodonHeight), false);
    }
    
    //remove button
    double crossUIX =  mouseX - x - W_H - w;
    double crossUIY = mouseY - y;
    int rowCY = (int)(crossUIY/appCodonHeight);
    if (rowCY >= 0 && rowCY < GENOME_LENGTH && crossUIX >= -25 && crossUIX <= 70) {
      drawRemoveCross(w+30, (rowCY+0.5)*appCodonHeight, min(60, (float)(appCodonHeight-2*margin)), 60, 15);
    }
  }
  
  popMatrix();
}

void drawCodon(Codon codon, double x, double y, double w, double appW, double appCodonHeight) {
    for(int p = 0; p < 2; p++){
    double extraX = (w*0.5-margin)*p;
      color fillColor = codon.getColor(p);
      color textColor = codon.getTextColor(p);
      fill(0);
      dRect(x+extraX+margin,y+margin,appW,appCodonHeight-margin*2);
      if(codon.hasSubstance()){
        fill(fillColor);
        double trueW = appW*codon.codonHealth;
        double trueX = x+extraX+margin;
        if(p == 0){
          trueX += appW*(1-codon.codonHealth);
        }
        dRect(trueX,y+margin,trueW,appCodonHeight-margin*2);
      }
      fill(textColor);
      dText(codon.getText(p),x+extraX+w*0.25,y+appCodonHeight/2+11);
    }
}

class Button {
  private String text;
  color foreColor;
  color backColor;
  
  public Button(String text, color foreColor, color backColor) {
    this.text = text;
    this.foreColor = foreColor;
    this.backColor = backColor;
  }
  
  public String getText() {
     return text; 
  }
  
  public boolean onClick(double rMouseX, double rMouseY) {
    return false;//noOp
  }
  
  protected void drawButton(double x, double y, double w, double h, color back, color fore, String text) {
    fill(back);
    dRect(x,y,w,h);
    fill(fore);
    dText(text,x+w*0.5,y+h/2+11);
  }
  
  public void drawButton(double x, double y, double w, double h) {
    drawButton(x,y,w,h,backColor,foreColor, getText());
  }
}

class ButtonChangeRGL extends Button{
  boolean start;
  public ButtonChangeRGL(String text, boolean start) {
    super(text, color(255,255,255), color(90,90,90));
    this.start = start;
  }
  
  public boolean onClick(double rMouseX, double rMouseY) {
    int diff = 1;
    if(rMouseX < 0.5){
      diff = -1;
    }
    
    if (start) {
      editRGL.loc += diff;
    } else {
      
      editRGL.end += diff;
    }
    return false;
  }
}

class ButtonChangeMemoryLocation extends Button{
  public ButtonChangeMemoryLocation(String text) {
    super(text, color(255,255,255), color(90,90,90));
  }
  
  public boolean onClick(double rMouseX, double rMouseY) {
    int diff = 1;
    if(rMouseX < 0.5){
      diff = -1;
    }
    
    
     editMemoryLoc.memoryId += diff;
    return false;
  }
}

class ButtonChangeMark extends Button{
  public ButtonChangeMark(String text) {
    super(text, color(255,255,255), color(90,90,90));
  }
  
  public boolean onClick(double rMouseX, double rMouseY) {
    int diff = 1;
    if(rMouseX < 0.5){
      diff = -1;
    }
    
    
     editMark.markId += diff;
    return false;
  }
}


class ButtonChangeDegree extends Button{
  public ButtonChangeDegree(String text) {
    super(text, color(255,255,255), color(90,90,90));
  }
  
  public boolean onClick(double rMouseX, double rMouseY) {
    int id = (int)(rMouseX*5);    
    switch (id) {
      case 0:
        editDegree.setDegree(editDegree.getDegree()-45);
      break;
      case 1:
        editDegree.setDegree(editDegree.getDegree()-1);
      break;
      case 2:
        editDegree.setDegree(0);
      break;
      case 3:
        editDegree.setDegree(editDegree.getDegree()+1);
      break;
      case 4:
        editDegree.setDegree(editDegree.getDegree()+45);
      break;
    }
    return false;
  }
  
  private String[] buttons = {"--", "-", "0", "+", "++"};
  public void drawButton(double x, double y, double w, double h) {
    double offset = w/5;
    for(int i=0;i<5;i++) {
        drawButton(x+offset*i,y,w/5,h,backColor,foreColor, buttons[i]);
    }
  }
}



class ButtonCommon extends Button {
  CommonBase common;
  
  public ButtonCommon(CommonBase common) {
    super(common.getTextSimple(), intToColor((common.getTextColor())), intToColor(common.getColor()));
    this.common = common;
  }
  
  
  public String getText() {
     return common.getTextSimple(); 
  }

}



class ButtonEditAttribute extends ButtonCommon {
  CodonAttribute attribute;
  
  public ButtonEditAttribute(CodonAttribute attribute) {
    super(attribute);
    this.attribute = attribute;
  }
  
  public boolean onClick(double rMouseX, double rMouseY) {
      Codon thisCodon = selectedCell.genome.codons.get(codonToEdit[1]);
      
      AttributeRGL oldRGL = thisCodon.getAttribute() instanceof AttributeRGL?(AttributeRGL)thisCodon.getAttribute():null;
      if (oldRGL == null || oldRGL.getStartLocation() != codonToEdit[2] || oldRGL.getEndLocation() != codonToEdit[3]) {
        thisCodon.setAttribute(new AttributeRGL(codonToEdit[2], codonToEdit[3]));
      } else {
        return false;
      }
      thisCodon.setAttribute(attribute);
      return true;
  }
}

Button[] codonAttributeButtons = new Button[CodonAttributes.values().length];
AttributeRGL editRGL = new AttributeRGL(0,0);
AttributeMemoryLocation editMemoryLoc = new AttributeMemoryLocation(0);
AttributeMark editMark = new AttributeMark(0);
AttributeDegree editDegree = new AttributeDegree(0);
{
  ArrayList<Button> buttons = new ArrayList();
  
  for(int i = 0; i < CodonAttributes.values().length; i++){
    CodonAttribute att = CodonAttributes.values()[i].v;
    if (att instanceof AttributeRGL)att=editRGL;  //todo OOP this
    if (att instanceof AttributeMemoryLocation)att=editMemoryLoc;
    if (att instanceof AttributeMark)att=editMark;
    if (att instanceof AttributeDegree)att=editDegree;
    buttons.add(new ButtonEditAttribute(att));
  }
  
  int rglPos = CodonAttributes.RGL00.ordinal() + 1;
  buttons.add(rglPos, new ButtonChangeRGL("- RGL end +", false));
  buttons.add(rglPos, new ButtonChangeRGL("- RGL start +", true));
  int memLocPos = CodonAttributes.MemoryLocation.ordinal() + 3;
  buttons.add(memLocPos, new ButtonChangeMemoryLocation("- MemLoc Id +"));
  int markPos = CodonAttributes.Mark.ordinal() + 4;
  buttons.add(markPos, new ButtonChangeMark("- Mark Id +"));
  int degPos = CodonAttributes.Degree.ordinal() + 5;
  buttons.add(degPos, new ButtonChangeDegree("-- -  0  + ++"));
  
  codonAttributeButtons = buttons.toArray(new Button[buttons.size()]);
}

class ButtonEditCodonType extends ButtonCommon {
  CodonType type;
  
  public ButtonEditCodonType(CodonType type) {
    super(type);
    this.type = type;
  }
  
  public boolean onClick(double rMouseX, double rMouseY) {
      Codon thisCodon = selectedCell.genome.codons.get(codonToEdit[1]);
      thisCodon.setType(type);
      return true;
  }

}

Button[] codonTypeButtons = new Button[CodonTypes.values().length];
{
  for(int i = 0; i < CodonTypes.values().length; i++){
    codonTypeButtons[i] = new ButtonEditCodonType(CodonTypes.values()[i].v);
  }
}


void drawButtonTable(Dim dims, Button[] buttons){
  double x = dims.getX();
  double y = dims.getY();
  double w = dims.getW();
  double h = dims.getH();
  
  double appW = w-margin*2;
  setTextFont(font,30);
  textAlign(CENTER);
  
  int p = codonToEdit[0];
  int s = codonToEdit[2];
  int e = codonToEdit[3];
  if(p >= 0){
    pushMatrix();
    dTranslate(x,y);
    double appChoiceHeight = h/buttons.length;
    for(int i = 0; i < buttons.length; i++){
      double appY = appChoiceHeight*i;
      buttons[i].drawButton(margin,appY+margin,appW,appChoiceHeight-margin*2);
    }
    popMatrix();
  }
}

public void keyPressed() {
  
  if(selectedCell != null){
    if (keyCode == 67 && (int)key == 3) { //ctrl c
    String memory = "";
    for(int pos = 0; pos < selectedCell.genome.codons.size(); pos++){
      if(pos > 0){
        memory = memory+"-";
      }
      Codon c = selectedCell.genome.codons.get(pos);
      memory = memory+infoToString(c);
    }
    copyStringToClipboard(memory);
    } else if (keyCode == 86 && (int)key == 22) { //ctrl v
      String memory = getStringFromClipboard();
      try {
        selectedCell.genome = new Genome(memory,false);
      } catch (Exception e){}
    }
  }
  
}

public int colorInterp(int a, int b, double x){
  float newR = (float)(red(a)+(red(b)-red(a))*x);
  float newG = (float)(green(a)+(green(b)-green(a))*x);
  float newB = (float)(blue(a)+(blue(b)-blue(a))*x);
  return color(newR, newG, newB);
}
void drawAddArrows(double x, double y, float arrowH, boolean left){
  dTranslate(x, y);
  beginShape();
  vertex(left?5:-5,0);
  vertex(left?45:-45, -arrowH/2);
  vertex(left?45:-45,  arrowH/2);
  endShape(CLOSE);
  dTranslate(-x, -y);
}

void drawRemoveCross(double x, double y, float cSize, float baseScale, float cWidth){ 
  cWidth *= cSize/baseScale;
  
  dTranslate(x, y);
  fill(color(160,30,30));
  beginShape();
  float min = -cSize/2;
  float max = cSize/2;
  float pythagorasC = sqrt(1/(float)2)*cWidth;
  
  
  vertex(min+pythagorasC, min);
  vertex(min, min+pythagorasC);
  vertex(max-pythagorasC, max);
  
  vertex(max-pythagorasC, max);
  vertex(max, max-pythagorasC);
  vertex(min+pythagorasC, min);
  
  
  
  
  vertex(min, max-pythagorasC);
  vertex(min+pythagorasC, max);
  vertex(max, min+pythagorasC);
  
  vertex(max, min+pythagorasC);
  vertex(max-pythagorasC, min);
  vertex(min, max-pythagorasC);
  
 
  endShape(CLOSE);
  dTranslate(-x, -y);
}

void drawGenomeArrows(double dw, double dh){
  float w = (float)dw;
  float h = (float)dh;
  fill(255);
  beginShape();
  vertex(-5,0);
  vertex(-45,-40);
  vertex(-45,40);
  endShape(CLOSE);
  beginShape();
  vertex(w+5,0);
  vertex(w+45,-40);
  vertex(w+45,40);
  endShape(CLOSE);
  noStroke();
  rect(0,-h/2,w,h);
}
void dRect(double x, double y, double w, double h){
  noStroke();
  rect((float)x, (float)y, (float)w, (float)h);
}
void dText(String s, double x, double y){
  text(s, (float)x, (float)y);
}
void dTranslate(double x, double y){
  translate((float)x, (float)y);
}
void daLine(double[] a, double[] b){
  float x1 = (float)trueXtoAppX(a[0]);
  float y1 = (float)trueYtoAppY(a[1]);
  float x2 = (float)trueXtoAppX(b[0]);
  float y2 = (float)trueYtoAppY(b[1]);
  strokeWeight((float)(0.03*camS));
  line(x1,y1,x2,y2);
}
void drawBar(color col, double stat, String s, double y){
  fill(150);
  rect(25,(float)y,500,60);
  fill(col);
  rect(25,(float)y,(float)(stat*500),60);
  fill(0);
  setTextFont(font,48);
  textAlign(LEFT);
  text(s+": "+nf((float)(stat*100),0,1)+"%",35,(float)y+47);
}
void drawCells(){
  for(int y = 0; y < WORLD_SIZE; y++){
    for(int x = 0; x < WORLD_SIZE; x++){
      cells[y][x].drawCell(trueXtoAppX(x),trueYtoAppY(y),trueStoAppS(1));
    }
  }
}
double trueXtoAppX(double x){
  return (x-camX)*camS;
}
double trueYtoAppY(double y){
  return (y-camY)*camS;
}
double appXtoTrueX(double x){
  return x/camS+camX;
}
double appYtoTrueY(double y){
  return y/camS+camY;
}
double trueStoAppS(double s){
  return s*camS;
}
int getCellTypeAt(double x, double y, boolean allowLoop){
  int ix = (int)x;
  int iy = (int)y;
  if(allowLoop){
    ix = (ix+WORLD_SIZE)%WORLD_SIZE;
    iy = (iy+WORLD_SIZE)%WORLD_SIZE;
  }else{
    if(ix < 0 || ix >= WORLD_SIZE || iy < 0 || iy >= WORLD_SIZE){
      return 0;
    }
  }
  return cells[iy][ix].type;
}
int getCellTypeAt(double[] coor, boolean allowLoop){
  return getCellTypeAt(coor[0],coor[1],allowLoop);
}
Cell getCellAt(double x, double y, boolean allowLoop){
  int ix = (int)x;
  int iy = (int)y;
  if(allowLoop){
    ix = (ix+WORLD_SIZE)%WORLD_SIZE;
    iy = (iy+WORLD_SIZE)%WORLD_SIZE;
  }else{
    if(ix < 0 || ix >= WORLD_SIZE || iy < 0 || iy >= WORLD_SIZE){
      return null;
    }
  }
  return cells[iy][ix];
}
Cell getCellAt(double[] coor, boolean allowLoop){
  return getCellAt(coor[0],coor[1],allowLoop);
}
boolean cellTransfer(double x1, double y1, double x2, double y2){
  int ix1 = (int)Math.floor(x1);
  int iy1 = (int)Math.floor(y1);
  int ix2 = (int)Math.floor(x2);
  int iy2 = (int)Math.floor(y2);
  return (ix1 != ix2 || iy1 != iy2);
}
boolean cellTransfer(double[] coor1, double[] coor2){
  return cellTransfer(coor1[0], coor1[1], coor2[0], coor2[1]);
}
double loopIt(double x, double len, boolean evenSplit){
  if(evenSplit){
    while(x >= len*0.5){
      x -= len;
    }
    while(x < -len*0.5){
      x += len;
    }
  }else{
    while(x > len-0.5){
      x -= len;
    }
    while(x < -0.5){
      x += len;
    }
  }
  return x;
}
static int loopItInt(int x, int len){
  if (len == 0)return 0;
  return (x+len*10)%len;
}
color intToColor(int[] c){
  return color(c[0],c[1],c[2]);
}
color transperize(color col, double trans){
  float alpha = (float)(trans*255);
  return color(red(col),green(col),blue(col),alpha);
}
String infoToString(CodonPair codon){
  String result = codonValToChar(codon.getType().id)+""+codonValToChar(codon.getAttribute().id) + codon.getType().saveExtra() + codon.getAttribute().saveExtra();
  return result;
}
int[] stringToInfo(String str){
  int[] info = new int[str.length()];
  for(int i = 0; i < str.length(); i++){
      char c = str.charAt(i);
    info[i] = codonCharToVal(c);
  }
  return info;
}
