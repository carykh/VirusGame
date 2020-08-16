int WORLD_SIZE = 12;
int W_W = 1728;
int W_H = 972;
Cell[][] cells = new Cell[WORLD_SIZE][WORLD_SIZE];
ArrayList<ArrayList<Particle>> particles = new ArrayList<ArrayList<Particle>>(0);
int foodLimit = 180;
float BIG_FACTOR = 100;
float PLAY_SPEED = 0.6;
double GENE_TICK_TIME = 40.0;
double margin = 4;
int START_LIVING_COUNT = 0;
int[] cellCounts = {0,0,0};

double REMOVE_WASTE_SPEED_MULTI = 0.001;
double removeWasteTimer = 1.0;

double GENE_TICK_ENERGY = 0.014;
double WALL_DAMAGE = 0.01;
double CODON_DEGRADE_SPEED = 0.008;
double EPS = 0.00000001;

String starterGenome = "46-11-22-33-11-22-33-45-44-57__-67__";
boolean canDrag = false;
double clickWorldX = -1;
double clickWorldY = -1;
boolean DQclick = false;
int[] codonToEdit = {-1,-1,0,0};
double[] genomeListDims = {70,430,360,450};
double[] editListDims = {550,430,180,450};
double[] arrowToDraw = null;
Cell selectedCell = null;
Cell UGOcell;
int lastEditTimeStamp = 0;
color handColor = color(0,128,0);
color TELOMERE_COLOR = color(0,0,0);
color WASTE_COLOR = color(255,255,255);
int MAX_CODON_COUNT = 20; // If a cell were to have more codons in its DNA than this number if it were to absorb a cirus particle, it won't absorb it.

double SPEED_LOW = 0.01;
double SPEED_HIGH = 0.02;
double MIN_ARROW_LENGTH_TO_PRODUCE = 0.4;

double ZOOM_THRESHOLD = 0;//80;
PFont font;
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
  doParticleCountControl();
  iterate();
  detectMouse();
  drawBackground();
  drawCells();
  drawParticles();
  drawExtras();
  drawUI();
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
    removeWasteTimer -= (wastes.size()-foodLimit)*REMOVE_WASTE_SPEED_MULTI;
    if(removeWasteTimer < 0){
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
  for(int z = 0; z < 3; z++){
    ArrayList<Particle> sparticles = particles.get(z);
    for(int i = 0; i < sparticles.size(); i++){
      Particle p = sparticles.get(i);
      p.drawParticle(trueXtoAppX(p.coor[0]),trueYtoAppY(p.coor[1]),trueStoAppS(1));
    }
  }
}
void checkGLclick(){
  double gx = genomeListDims[0];
  double gy = genomeListDims[1];
  double gw = genomeListDims[2];
  double gh = genomeListDims[3];
  double rMouseX = ((mouseX-W_H)-gx)/gw;
  double rMouseY = (mouseY-gy)/gh;
  if(rMouseX >= 0 && rMouseX < 1 && rMouseY >= 0){
    if(rMouseY < 1){
      codonToEdit[0] = (int)(rMouseX*2);
      codonToEdit[1] = (int)(rMouseY*selectedCell.genome.codons.size());
    }else if(selectedCell == UGOcell){
      if(rMouseX < 0.5){
        String genomeString = UGOcell.genome.getGenomeStringShortened();
        selectedCell = UGOcell = new Cell(-1,-1,2,0,1,genomeString);
      }else{
        String genomeString = UGOcell.genome.getGenomeStringLengthened();
        selectedCell = UGOcell = new Cell(-1,-1,2,0,1,genomeString);
      }
    }
  }
}
void checkETclick(){
  double ex = editListDims[0];
  double ey = editListDims[1];
  double ew = editListDims[2];
  double eh = editListDims[3];
  double rMouseX = ((mouseX-W_H)-ex)/ew;
  double rMouseY = (mouseY-ey)/eh;
  if(rMouseX >= 0 && rMouseX < 1 && rMouseY >= 0 && rMouseY < 1){
    int optionCount = CodonInfo.getOptionSize(codonToEdit[0]);
    int choice = (int)(rMouseY*optionCount);
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
    }else{
      Codon thisCodon = selectedCell.genome.codons.get(codonToEdit[1]);
      if(codonToEdit[0] == 1 && choice == 7){
        if(thisCodon.codonInfo[1] != 7 ||
        thisCodon.codonInfo[2] != codonToEdit[2] || thisCodon.codonInfo[3] != codonToEdit[3]){
          thisCodon.setInfo(1,choice);
          thisCodon.setInfo(2,codonToEdit[2]);
          thisCodon.setInfo(3,codonToEdit[3]);
          if(selectedCell != UGOcell){
            lastEditTimeStamp = frameCount;
            selectedCell.tamper();
          }
        }
      }else{
        if(thisCodon.codonInfo[codonToEdit[0]] != choice){
          thisCodon.setInfo(codonToEdit[0],choice);
          if(selectedCell != UGOcell){
            lastEditTimeStamp = frameCount;
            selectedCell.tamper();
          }
        }
      }
    }
  }else{
    codonToEdit[0] = codonToEdit[1] = -1;
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
int codonCharToVal(char c){
  int val = (int)(c) - (int)('A');
  return val-30;
}
String codonValToChar(int i){
  int val = (i+30) + (int)('A');
  return (char)val+"";
}
void detectMouse(){
  if (mousePressed){
    arrowToDraw = null;
    if(!wasMouseDown) {
      if(mouseX < W_H){
        codonToEdit[0] = codonToEdit[1] = -1;
        clickWorldX = appXtoTrueX(mouseX);
        clickWorldY = appYtoTrueY(mouseY);
        canDrag = true;
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
          }
        }else if(mouseX > W_W-160 && mouseY < 160){
          selectedCell = UGOcell;
        }
        canDrag = false;
      }
      DQclick = false;
    }else if(canDrag){
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
    }
  }
  if(!mousePressed){
    if(wasMouseDown){
      if(selectedCell == UGOcell && arrowToDraw != null){
        if(euclidLength(arrowToDraw) > MIN_ARROW_LENGTH_TO_PRODUCE){
          produceUGO(arrowToDraw);
        }
      }
      if(!DQclick && canDrag){
        double[] mCoor = {clickWorldX,clickWorldY};
        Cell clickedCell = getCellAt(mCoor,false);
        if(selectedCell != UGOcell){
          selectedCell = null;
        }
        if(clickedCell != null && clickedCell.type == 2){
          selectedCell = clickedCell;
        }
      }
    }
    clickWorldX = -1;
    clickWorldY = -1;
    arrowToDraw = null;
  }
  wasMouseDown = mousePressed;
}
void mouseWheel(MouseEvent event) {
  double ZOOM_F = 1.05;
  double thisZoomF = 1;
  float e = event.getCount();
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
void drawBackground(){
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
  double ticks = f/GENE_TICK_TIME;
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
  textFont(font,48);
  textAlign(LEFT);
  text(framesToTime(frameCount)+" start",25,60);
  text(framesToTime(frameCount-lastEditTimeStamp)+" edit",25,108);
  textFont(font,36);
  text("Healthy: "+cellCounts[0]+" / "+START_LIVING_COUNT,360,50);
  text("Tampered: "+cellCounts[1]+" / "+START_LIVING_COUNT,360,90);
  text("Dead: "+cellCounts[2]+" / "+START_LIVING_COUNT,360,130);
  if(selectedCell != null){
    drawCellStats();
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
    textFont(font,48);
    text("MAKE",W_W-70,70);
    text("UGO",W_W-70,120);
  }else{
    textFont(font,36);
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
  textFont(font,96);
  textAlign(LEFT);
  text(selectedCell.getCellName(),25,255);
  if(!isUGO){
    textFont(font,32);
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
  drawEditTable(editListDims);
  if(!isUGO){
    textFont(font,32);
    textAlign(LEFT);
    text("Memory: "+getMemory(selectedCell),25,940);
  }
}
String getMemory(Cell c){
  if(c.memory.length() == 0){
    return "[NOTHING]";
  }else{
    return "\""+c.memory+"\"";
  }
}
void drawGenomeAsList(Genome g, double[] dims){
  double x = dims[0];
  double y = dims[1];
  double w = dims[2];
  double h = dims[3];
  int GENOME_LENGTH = g.codons.size();
  double appCodonHeight = h/GENOME_LENGTH;
  double appW = w*0.5-margin;
  textFont(font,30);
  textAlign(CENTER);
  pushMatrix();
  dTranslate(x,y);
  pushMatrix();
  dTranslate(0,appCodonHeight*(g.appRO+0.5));
  if(selectedCell != UGOcell){
    drawGenomeArrows(w,appCodonHeight);
  }
  popMatrix();
  for(int i = 0; i < GENOME_LENGTH; i++){
    double appY = appCodonHeight*i;
    Codon codon = g.codons.get(i);
    for(int p = 0; p < 2; p++){
      double extraX = (w*0.5-margin)*p;
      color fillColor = codon.getColor(p);
      color textColor = codon.getTextColor(p);
      fill(0);
      dRect(extraX+margin,appY+margin,appW,appCodonHeight-margin*2);
      if(codon.hasSubstance()){
        fill(fillColor);
        double trueW = appW*codon.codonHealth;
        double trueX = extraX+margin;
        if(p == 0){
          trueX += appW*(1-codon.codonHealth);
        }
        dRect(trueX,appY+margin,trueW,appCodonHeight-margin*2);
      }
      fill(textColor);
      dText(codon.getText(p),extraX+w*0.25,appY+appCodonHeight/2+11);
      
      if(p == codonToEdit[0] && i == codonToEdit[1]){
        double highlightFac = 0.5+0.5*sin(frameCount*0.25);
        fill(255,255,255,(float)(highlightFac*140));
        dRect(extraX+margin,appY+margin,appW,appCodonHeight-margin*2);
      }
    }
  }
  if(selectedCell == UGOcell){
    fill(255);
    textFont(font,60);
    double avgY = (h+height-y)/2;
    dText("( - )",w*0.25,avgY+11);
    dText("( + )",w*0.75-margin,avgY+11);
  }
  popMatrix();
}
void drawEditTable(double[] dims){
  double x = dims[0];
  double y = dims[1];
  double w = dims[2];
  double h = dims[3];
  
  double appW = w-margin*2;
  textFont(font,30);
  textAlign(CENTER);
  
  int p = codonToEdit[0];
  int s = codonToEdit[2];
  int e = codonToEdit[3];
  if(p >= 0){
    pushMatrix();
    dTranslate(x,y);
    int choiceCount = CodonInfo.getOptionSize(codonToEdit[0]);
    double appChoiceHeight = h/choiceCount;
    for(int i = 0; i < choiceCount; i++){
      double appY = appChoiceHeight*i;
      color fillColor = intToColor(CodonInfo.getColor(p,i));
      color textColor = intToColor(CodonInfo.getTextColor(p,i));
      fill(fillColor);
      dRect(margin,appY+margin,appW,appChoiceHeight-margin*2);
      fill(textColor);
      dText(CodonInfo.getTextSimple(p, i, s, e),w*0.5,appY+appChoiceHeight/2+11);
    }
    popMatrix();
  }
}
color colorInterp(color a, color b, double x){
  float newR = (float)(red(a)+(red(b)-red(a))*x);
  float newG = (float)(green(a)+(green(b)-green(a))*x);
  float newB = (float)(blue(a)+(blue(b)-blue(a))*x);
  return color(newR, newG, newB);
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
  textFont(font,48);
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
int loopItInt(int x, int len){
  return (x+len*10)%len;
}
color intToColor(int[] c){
  return color(c[0],c[1],c[2]);
}
color transperize(color col, double trans){
  float alpha = (float)(trans*255);
  return color(red(col),green(col),blue(col),alpha);
}
String infoToString(int[] info){
  String result = info[0]+""+info[1];
  if(info[1] == 7){
    result += codonValToChar(info[2])+""+codonValToChar(info[3]);
  }
  return result;
}
int[] stringToInfo(String str){
  int[] info = new int[4];
  for(int i = 0; i < 2; i++){
    info[i] = Integer.parseInt(str.substring(i,i+1));
  }
  if(info[1] == 7){
    for(int i = 2; i < 4; i++){
      char c = str.charAt(i);
      info[i] = codonCharToVal(c);
    }
  }
  return info;
}
