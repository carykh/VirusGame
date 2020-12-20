
import java.util.Random;

  public final static double E_RECIPROCAL = 0.3678794411;
class Cell{
  int x;
  int y;
  int type;
  double wallHealth;
  Genome genome;
  double geneTimer = 0;
  double energy = 0;
  boolean tampered = false;
  ArrayList<ArrayList<Particle>> particlesInCell = new ArrayList<ArrayList<Particle>>(0);

  ArrayList<double[]> laserCoor = new ArrayList<double[]>();
  Particle laserTarget = null;
  int laserT = -9999;
  int LASER_LINGER_TIME = 30;
  String memory = "";
  AbsoluteRange lastRange = new AbsoluteRange(0, -1);
  boolean wasSuccess;
  /*
   0: empty
   1: empty, inaccessible
   2: normal cell
   3: waste management cell
   4: gene-removing cell
  */
  int dire;

  boolean debugFlag = false;

  public Cell(int ex, int ey, int et, int ed, double ewh, String eg) {
    for (int j = 0; j < 3; j++) {
      ArrayList<Particle> newList = new ArrayList<Particle>(0);
      particlesInCell.add(newList);
    }
    x = ex;
    y = ey;
    type = et;
    dire = ed;
    wallHealth = ewh;
    genome = new Genome(eg, false);
    
    debugFlag = x == 6 && y == 4; //if we only want to inspect one cell
    
    Random rnd = new Random(x << 16 + y + 1337); //seed based on coords
    
    int startpos = rnd.nextInt(genome.codons.size());
    
    genome.rotateOn = 0;
    genome.rotateOnNext = genome.loopAroundGenome(1);
    
    //we start at a random position but make sure that we are not in an invalid state!
    for(int i=0;i<startpos;i++) {
       doAction();
       tickGene();
    }
    laserCoor.clear(); //dont display all the preexecuted actions at once
    laserTarget = null;
    
    genome.iterate(); //update drawing postions
    
    geneTimer = rnd.nextDouble()*GENE_TICK_TIME;
    energy = 0.5;
  }
  void drawCell(double x, double y, double s) {
    pushMatrix();
    translate((float)x, (float)y);
    scale((float)(s/BIG_FACTOR));
    noStroke();
    if (type == 1) {
      fill(60, 60, 60);
      rect(0, 0, BIG_FACTOR, BIG_FACTOR);
    } else if (type == 2) {
      if (this == selectedCell) {
        fill(0, 255, 255);
      } else if (tampered) {
        fill(205, 225, 70);
      } else {
        fill(225, 190, 225);
      }
      rect(0, 0, BIG_FACTOR, BIG_FACTOR);
      fill(170, 100, 170);
      float w = (float)(BIG_FACTOR*0.08*wallHealth);
      rect(0, 0, BIG_FACTOR, w);
      rect(0, BIG_FACTOR-w, BIG_FACTOR, w);
      rect(0, 0, w, BIG_FACTOR);
      rect(BIG_FACTOR-w, 0, w, BIG_FACTOR);

      pushMatrix();
      translate(BIG_FACTOR*0.5, BIG_FACTOR*0.5);
      stroke(0);
      strokeWeight(1);
      drawInterpreter();
      drawEnergy();
      genome.drawCodons();
      genome.drawHand();
      popMatrix();
    }
    popMatrix();
    if (type == 2) {
      drawLaser();
    }
  }
  public void drawInterpreter() {
    int GENOME_LENGTH = genome.codons.size();
    double CODON_ANGLE = (double)(1.0)/GENOME_LENGTH*2*PI;
    double INTERPRETER_SIZE = 23;
    double col = 1;
    double gtf = geneTimer/GENE_TICK_TIME;
    if (gtf < 0.5) {
      col = Math.min(1, (0.5-gtf)*4);
    }
    pushMatrix();
    rotate((float)(-PI/2+CODON_ANGLE*genome.appRO));
    fill((float)(col*255));
    beginShape();
    strokeWeight(BIG_FACTOR*0.01);
    stroke(80);
    vertex(0, 0);
    vertex((float)(INTERPRETER_SIZE*Math.cos(CODON_ANGLE*0.5)), (float)(INTERPRETER_SIZE*Math.sin(CODON_ANGLE*0.5)));
    vertex((float)(INTERPRETER_SIZE*Math.cos(-CODON_ANGLE*0.5)), (float)(INTERPRETER_SIZE*Math.sin(-CODON_ANGLE*0.5)));
    endShape(CLOSE);
    popMatrix();
  }
  public void drawLaser() {
    if (frameCount < laserT+(LASER_LINGER_TIME/PLAY_SPEED)) {
      double alpha = (double)((laserT+LASER_LINGER_TIME)-frameCount)/LASER_LINGER_TIME/PLAY_SPEED;
      stroke(transperize(handColor, alpha));
      strokeWeight((float)(0.033333*BIG_FACTOR));
      double[] handCoor = getHandCoor();
      if (laserTarget == null) {
        for (double[] singleLaserCoor : laserCoor) {
          daLine(handCoor, singleLaserCoor);
        }
      } else {
        double[] targetCoor = laserTarget.coor;
        daLine(handCoor, targetCoor);
      }
    } else {
      laserTarget = null;
      laserCoor.clear();
    }
  }
  public void drawEnergy() {
    noStroke();
    fill(0, 0, 0);
    ellipse(0, 0, 17, 17);
    fill(255, 255, 0);
    pushMatrix();
    scale((float)Math.sqrt(energy));
    drawLightning();
    popMatrix();
  }
  public void drawLightning() {
    pushMatrix();
    scale(1.2);
    noStroke();
    beginShape();
    vertex(-1, -7);
    vertex(2, -7);
    vertex(0, -3);
    vertex(2.5, -3);
    vertex(0.5, 1);
    vertex(3, 1);
    vertex(-1.5, 7);
    vertex(-0.5, 3);
    vertex(-3, 3);
    vertex(-1, -1);
    vertex(-4, -1);
    endShape(CLOSE);
    popMatrix();
  }
  public void iterate(){
    if(type == 2){
      if(energy > 0){
        geneTimer -= PLAY_SPEED;
        do{
          if (geneTimer <= GENE_TICK_TIME/2.0 && didTickGene) {
            doAction();
          }
          if (geneTimer <= 0 && didAction) {
            tickGene();
          }
        } while (geneTimer <= 0);//on high speeds we might needs to do multiple interations per frame
      }
      genome.iterate();
    }
  }
  public void doAction(){
    didAction = true; //this is added to make sure that the genes really operate in the right order
    if (!didTickGene)return;
    didTickGene = false;
    if(!DEBUG_WORLD)useEnergy();
    Codon thisCodon = genome.codons.get(genome.rotateOn);
    wasSuccess = thisCodon.exec(this);
    
    if(!DEBUG_WORLD)genome.hurtCodons();
  }
  
  void useEnergy() {
    energy = Math.max(0, energy-(GENE_TICK_ENERGY*GENE_TICK_TIME/40));
  }
  void readToMemory(int start, int end, boolean isRelative) {
    memory = "";
    laserTarget = null;
    laserCoor.clear();
    laserT = frameCount;
    for (int pos = start; pos <= end; pos++) {
      int index = genome.loopAroundGenome((isRelative?genome.performerOn:0)+pos);
      Codon c = genome.codons.get(index);
      memory = memory+infoToString(c);
      if (pos < end) {
        memory = memory+"-";
      }
      laserCoor.add(getCodonCoor(index, genome.CODON_DIST));
    }
  }
  
  
  void removeCodons(int start, int end, boolean isRelative){
    
    
    laserTarget = null;
    laserCoor.clear();
    laserT = frameCount;
    for(int pos = start; pos <= end; pos++){
      int index = genome.loopAroundGenome((isRelative?genome.performerOn:0)+start); //usual constant, but we might wrap around after deleting enough items
      if (genome.rotateOnNext > index) {
        genome.rotateOnNext--;
      }
      genome.codons.remove(index);
      laserCoor.add(getCodonCoor(index,genome.CODON_DIST));
    }
  }
  
  
  void writeFromMemory(int start, int end, boolean isRelative) {
    if (memory.length() == 0) {
      return;
    }
    laserTarget = null;
    laserCoor.clear();
    laserT = frameCount;
    if (genome.directionOn == 0) {
      writeOutwards(start, end);
    } else {
      writeInwards(start, end, isRelative);
    }
  }
  public void writeOutwards(int start, int end) {
    double theta = Math.random()*2*Math.PI;
    double ugo_vx = Math.cos(theta);
    double ugo_vy = Math.sin(theta);
    double[] startCoor = getHandCoor();
    double[] newUGOcoor = new double[]{startCoor[0], startCoor[1], startCoor[0]+ugo_vx, startCoor[1]+ugo_vy};

    String[] memoryParts = memory.split("-");
    String[] UGOmemoryParts = memoryParts;
    for (int i = 0; i < memoryParts.length*(end - start); i++) {
      useEnergy();
    }
    for (int i = 0; i < (end - start); i++) {
      UGOmemoryParts = concat(UGOmemoryParts, memoryParts);
    }
    String UGOmemory = join(UGOmemoryParts, "-");

    Particle newUGO = new Particle(newUGOcoor, 2, UGOmemory, frameCount);
    particles.get(2).add(newUGO);
    newUGO.addToCellList();
    laserTarget = newUGO;
    
    String[] memoryParts = memory.split("-");
    for(int i = 0; i < memoryParts.length; i++){
      useEnergy();
    }
  }
  public void writeInwards(int start, int end, boolean isRelative) {
    laserTarget = null;
    String[] memoryParts = memory.split("-");
    for (int pos = start; pos <= end; pos++) {
      int index = genome.loopAroundGenome((isRelative?genome.performerOn:0)+pos);
      Codon c = genome.codons.get(index);
      if(pos-start < memoryParts.length){
        String memoryPart = memoryParts[pos-start];
        c.setFullInfo(stringToInfo(memoryPart));
        laserCoor.add(getCodonCoor(index,genome.CODON_DIST));
      }
      useEnergy();
    }
  }
  public void healWall() {
    wallHealth += (1-wallHealth)*E_RECIPROCAL;
    laserWall();
  }
  public void laserWall() {
    laserT = frameCount;
    laserCoor.clear();
    for (int i = 0; i < 4; i++) {
      double[] result = {x+(i/2), y+(i%2)};
      laserCoor.add(result);
    }
    laserTarget = null;
  }
  public void eat(Particle food) {
    if (food.type == 0) {
      Particle newWaste = new Particle(food.coor, 1, -99999);
      shootLaserAt(newWaste);
      newWaste.addToCellList();
      particles.get(1).add(newWaste);
      food.removeParticle();
      energy += (1-energy)*E_RECIPROCAL;
    } else {
      shootLaserAt(food);
    }
  }
  void shootLaserAt(Particle food) {
    laserT = frameCount;
    laserTarget = food;
  }
  public double[] getHandCoor() {
    double r = genome.HAND_DIST;
    if (genome.directionOn == 0) {
      r += genome.HAND_LEN;
    } else {
      r -= genome.HAND_LEN;
    }
    return getCodonCoor(genome.performerOn, r);
  }
  public double[] getCodonCoor(int i, double r) {
    double theta = (float)(i*2*PI)/(genome.codons.size())-PI/2;
    double r2 = r/BIG_FACTOR;
    double handX = x+0.5+r2*Math.cos(theta);
    double handY = y+0.5+r2*Math.sin(theta);
    double[] result = {handX, handY};
    return result;
  }
  public void pushOut(Particle waste) {
    int[][] dire = {{0, 1}, {0, -1}, {1, 0}, {-1, 0}};
    boolean canPushOut = false;
    for (int i = 0; i < 4; i++) {
      if (!(y+dire[i][1] > WORLD_SIZE - 1 || y+dire[i][1] < 0 || x+dire[i][0] > WORLD_SIZE - 1 || x+dire[i][0] < 0 || cells[y+dire[i][1]][x+dire[i][0]].type != 0)) {
        canPushOut = true;
      }
    }
    if (canPushOut) {
      int chosen = -1;
      while (chosen == -1 || y+dire[chosen][1] > WORLD_SIZE - 1 || y+dire[chosen][1] < 0 || x+dire[chosen][0] > WORLD_SIZE - 1 || x+dire[chosen][0] < 0 || cells[y+dire[chosen][1]][x+dire[chosen][0]].type != 0) {
        chosen = (int)random(0, 4);
      }
      double[] oldCoor = waste.copyCoor();
      for (int dim = 0; dim < 2; dim++) {
        if (dire[chosen][dim] == -1) {
          waste.coor[dim] = Math.floor(waste.coor[dim])-EPS;
          waste.velo[dim] = -Math.abs(waste.velo[dim]);
        } else if (dire[chosen][dim] == 1) {
          waste.coor[dim] = Math.ceil(waste.coor[dim])+EPS;
          waste.velo[dim] = Math.abs(waste.velo[dim]);
        }
        waste.loopCoor(dim);
      }
      Cell p_cell = getCellAt(oldCoor, true);
      p_cell.removeParticleFromCell(waste);
      Cell n_cell = getCellAt(waste.coor, true);
      n_cell.addParticleToCell(waste);
      laserT = frameCount;
      laserTarget = waste;
    }
  }
  
  boolean didAction = false;
  boolean didTickGene = true;
  public void tickGene() {
    didTickGene = true; //this is added to make sure that the genes really operate in the right order
    if (!didAction) {
      geneTimer += GENE_TICK_TIME/2;
      doAction();
      return;
    }
    didAction = false;
    
    geneTimer += GENE_TICK_TIME;
    
    genome.rotateOn = genome.rotateOnNext;
    genome.rotateOnNext = genome.loopAroundGenome(genome.rotateOnNext+1);
  }
  public void hurtWall(double multi) {
    if (type >= 2) {
      wallHealth -= WALL_DAMAGE*multi*(DEBUG_WORLD?0.4:1);
      if (wallHealth <= 0) {
        die();
      }
    }
  }
  public void tamper() {
    if (!tampered) {
      tampered = true;
      cellCounts[0]--;
      cellCounts[1]++;
    }
  }
  public void die() {
    for (int i = 0; i < genome.codons.size(); i++) {
      Particle newWaste = new Particle(getCodonCoor(i, genome.CODON_DIST), 1, -99999);
      newWaste.addToCellList();
      particles.get(1).add(newWaste);
    }
    type = 0;
    if (this == selectedCell) {
      selectedCell = null;
    }
    if (tampered) {
      cellCounts[1]--;
    } else {
      cellCounts[0]--;
    }
    cellCounts[2]++;
  }
  public void addParticleToCell(Particle food) {
    particlesInCell.get(food.type).add(food);
  }
  public void removeParticleFromCell(Particle food) {
    ArrayList<Particle> myList = particlesInCell.get(food.type);
    for (int i = 0; i < myList.size(); i++) {
      if (myList.get(i) == food) {
        myList.remove(i);
      }
    }
  }
  public Particle selectParticleInCell(int type) { //type 0=food 1=waste 2=ngo?
    ArrayList<Particle> myList = particlesInCell.get(type);
    if (myList.size() == 0) {
      return null;
    } else {
      int choiceIndex = (int)(Math.random()*myList.size());
      return myList.get(choiceIndex);
    }
  }
  public String getCellName() {
    if (x == -1) {
      return "Custom UGO";
    } else if (type == 2) {
      return "Cell at ("+x+", "+y+")";
    } else {
      return "";
    }
  }
  public int getParticleCount(int t) {
    if (t == -1) {
      int sum = 0;
      for (int i = 0; i < 3; i++) {
        sum += particlesInCell.get(i).size();
      }
      return sum;
    } else {
      return particlesInCell.get(t).size();
    }
  }

  int getFrameCount() {
    return frameCount;
  }

  public void DEBUG_SET_PLAY_SPEED(float d) {
    PLAY_SPEED = d;
  }
}
