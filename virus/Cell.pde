import java.util.Random;

class Cell{
  int x;
  int y;
  CellType type;
  double wall;
  double energy = 0;
  Genome genome;
  double geneTimer = 0;
  boolean tampered = false;
  ParticleContainer pc = new ParticleContainer();

  ArrayList<double[]> laserCoor = new ArrayList<double[]>();
  Particle laserTarget = null;
  int laserT = -9999;
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

  public Cell(int ex, int ey, CellType et, int ed, double ewh, String eg){
    x = ex;
    y = ey;
    type = et;
    dire = ed;
    wall = ewh;
    genome = new Genome(eg,false);

    debugFlag = x == 6 && y == 4; //if we only want to inspect one cell

    Random rnd = new Random(x << 16 + y + 1337); //seed based on coords

    int startpos = rnd.nextInt(genome.codons.size());

    genome.rotateOn = 0;
    genome.rotateOnNext = genome.loopAroundGenome(1);

    //we start at a random position but make sure that we are not in an invalid state!
    for (int i = 0; i < startpos; i++) {
      doAction();
      tickGene();
    }
    laserCoor.clear(); //dont display all the preexecuted actions at once
    laserTarget = null;

    genome.update(); //update drawing postions

    geneTimer = rnd.nextDouble() * settings.gene_tick_time;
    energy = 0.5;
  }

  public String getMemory() {
    if(memory.length() == 0){
      return "[NOTHING]";
    }else{
      return "\"" + memory + "\"";
    }
  }

  public boolean hasGenome() {
    return type == CellType.Normal;
  }

  public boolean isHandInwards() {
    return genome.inwards;
  }

  void drawSelf() {

    double posx = renderer.trueXtoAppX(x);
    double posy = renderer.trueYtoAppY(y);

    if( posx < -renderer.camS || posy < -renderer.camS || posx > renderer.maxRight || posy > ORIG_W_H ) {
      return;
    }
    
    pushMatrix();
    translate((float)posx,(float)posy);
    scale((float)(renderer.camS/BIG_FACTOR));
    noStroke();
    
    if(type == CellType.Locked){

      fill(60,60,60);
      rect(0,0,BIG_FACTOR,BIG_FACTOR);

    }else if(type == CellType.Normal){

      if( tampered && settings.show_tampered ) {
        fill(205, 225, 70);
      }else{
        fill(225, 190, 225);
      }
      
      rect(0,0,BIG_FACTOR,BIG_FACTOR);
      fill(170,100,170);
      float w = (float)(BIG_FACTOR*0.08*wall);
      rect(0,0,BIG_FACTOR,w);
      rect(0,BIG_FACTOR-w,BIG_FACTOR,w);
      rect(0,0,w,BIG_FACTOR);
      rect(BIG_FACTOR-w,0,w,BIG_FACTOR);

      pushMatrix();
      translate(BIG_FACTOR*0.5,BIG_FACTOR*0.5);
      stroke(0);
      strokeWeight(1);

      if(renderer.camS > DETAIL_THRESHOLD) {
        drawInterpreter();
        noStroke();
        genome.drawCodons();
      }

      drawEnergy();
      genome.drawHand();
      popMatrix();
    } else if( type == CellType.Shell ) {

      pushMatrix();
      fill(225,190,225);
      rect(0,0,BIG_FACTOR,BIG_FACTOR);
      fill(170,100,170);
      float w = (float)(BIG_FACTOR*0.08*wall);
      rect(0,0,BIG_FACTOR,w);
      rect(0,BIG_FACTOR-w,BIG_FACTOR,w);
      rect(0,0,w,BIG_FACTOR);
      rect(BIG_FACTOR-w,0,w,BIG_FACTOR);

      pushMatrix();
      translate(BIG_FACTOR*0.5,BIG_FACTOR*0.5);
      stroke(0);
      strokeWeight(1);
      drawEnergy();
      popMatrix();

      popMatrix();
    }
    popMatrix();
    if(type == CellType.Normal){
      drawLaser();
    }
  }
  public void drawInterpreter(){
    int GENOME_LENGTH = genome.codons.size();
    double CODON_ANGLE = (double)(1.0)/GENOME_LENGTH*2*PI;
    double INTERPRETER_SIZE = 23;
    double col = 1;
    double gtf = geneTimer/settings.gene_tick_time;

    if(gtf < 0.5){
      col = Math.min(1,(0.5-gtf)*4);
    }

    pushMatrix();
    rotate((float)(-PI/2+CODON_ANGLE*genome.appRO));
    fill((float)(col*255));
    beginShape();
    strokeWeight(BIG_FACTOR*0.01);
    stroke(80);
    vertex(0,0);
    vertex((float)(INTERPRETER_SIZE*Math.cos(CODON_ANGLE*0.5)),(float)(INTERPRETER_SIZE*Math.sin(CODON_ANGLE*0.5)));
    vertex((float)(INTERPRETER_SIZE*Math.cos(-CODON_ANGLE*0.5)),(float)(INTERPRETER_SIZE*Math.sin(-CODON_ANGLE*0.5)));
    endShape(CLOSE);
    popMatrix();
  }
  public void drawLaser(){
    if(frameCount < laserT+settings.laser_linger_time){
      double alpha = (double)((laserT+settings.laser_linger_time)-frameCount)/settings.laser_linger_time;
      stroke(util.transperize(HAND_COLOR,alpha));
      strokeWeight((float)(0.033333*BIG_FACTOR));
      double[] handCoor = getHandCoor();
      if(laserTarget == null){
        for(double[] singleLaserCoor : laserCoor){
          renderer.scaledLine(handCoor,singleLaserCoor);
        }
      }else{
        if( dist((float)handCoor[0], (float)handCoor[1], (float)laserTarget.coor[0], (float)laserTarget.coor[1]) < 2 ) {
          renderer.scaledLine(handCoor, laserTarget.coor);
        }
      }
    } else {
      laserTarget = null;
      laserCoor.clear();
    }
  }
  public void drawEnergy(){
    noStroke();
    fill(0,0,0);
    ellipse(0,0,17,17);

    if( energy > 0 ) {
      fill(255,255,0);
      ellipseMode(CENTER);
      ellipse(0, 0, 12 * (float) energy + 2, 12 * (float) energy + 2);
    }
  }
  public void drawLightning(){
    pushMatrix();
    scale(1.2);
    noStroke();
    beginShape();
    vertex(-1,-7);
    vertex(2,-7);
    vertex(0,-3);
    vertex(2.5,-3);
    vertex(0.5,1);
    vertex(3,1);
    vertex(-1.5,7);
    vertex(-0.5,3);
    vertex(-3,3);
    vertex(-1,-1);
    vertex(-4,-1);
    endShape(CLOSE);
    popMatrix();
  }
  public void tick(){
    if(type == CellType.Normal){
      if (energy > 0) {
        geneTimer -= PLAY_SPEED;
        do {
          if (geneTimer <= settings.gene_tick_time / 2.0 && didTickGene) {
            doAction();
          }
          if (geneTimer <= 0 && didAction) {
            tickGene();
          }
        } while (geneTimer <= 0);//on high speeds we might needs to do multiple interations per frame
      }
      genome.update();
    }
  }
  boolean didAction = false;
  boolean didTickGene = true;
  public void doAction(){
    didAction = true; //this is added to make sure that the genes really operate in the right order
    if (!didTickGene) return;
    didTickGene = false;
    if (!DEBUG_WORLD) useEnergy(settings.gene_tick_energy * settings.gene_tick_time / 40);
    genome.rotateOn = genome.loopAroundGenome(genome.rotateOn); //in case it got deleted
    Codon thisCodon = genome.codons.get(genome.rotateOn);
    wasSuccess = thisCodon.exec(this);

    if (!DEBUG_WORLD) genome.hurtCodons();
  }
  public void tickGene(){
    didTickGene = true; //this is added to make sure that the genes really operate in the right order
    if (!didAction) {
      geneTimer += settings.gene_tick_time / 2;
      doAction();
      return;
    }
    didAction = false;

    geneTimer += settings.gene_tick_time;

    genome.rotateOn = genome.rotateOnNext;
    genome.rotateOnNext = genome.loopAroundGenome(genome.rotateOnNext + 1);
  }

  //todo amount == (GENE_TICK_ENERGY * settings.gene_tick_time / 40));
  void useEnergy( double amount ){
    energy = Math.max(0, energy - amount);
  }
  void readToMemory(int start, int end, boolean isRelative) {
    memory = "";
    laserTarget = null;
    laserCoor.clear();
    laserT = frameCount;
    for (int pos = start; pos <= end; pos++) {
      int index = genome.loopAroundGenome((isRelative ? genome.performerOn : 0) + pos);
      Codon c = genome.codons.get(index);
      memory = memory + util.infoToString(c);
      if (pos < end) {
        memory = memory + "-";
      }
      laserCoor.add(getCodonCoor(index, genome.CODON_DIST));
    }
  }


  void removeCodons(int start, int end, boolean isRelative) {


    laserTarget = null;
    laserCoor.clear();
    laserT = frameCount;
    for (int pos = start; pos <= end; pos++) {
      int index = genome.loopAroundGenome((isRelative ? genome.performerOn : 0) + start); //usual constant, but we might wrap around after deleting enough items
      if (genome.rotateOnNext > index) {
        genome.rotateOnNext--;
      }
      genome.codons.remove(index);
      laserCoor.add(getCodonCoor(index, genome.CODON_DIST));
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
    double theta = Math.random() * 2 * Math.PI;
    double ugo_vx = Math.cos(theta);
    double ugo_vy = Math.sin(theta);
    double[] startCoor = getHandCoor();
    double[] newUGOcoor = new double[]{startCoor[0], startCoor[1], startCoor[0] + ugo_vx, startCoor[1] + ugo_vy};

    String[] memoryParts = memory.split("-");
    String[] UGOmemoryParts = memoryParts;
    for (int i = 0; i < memoryParts.length * (end - start); i++) {
      useEnergy(settings.gene_tick_energy * settings.gene_tick_time / 40);
    }
    for (int i = 0; i < (end - start); i++) {
      UGOmemoryParts = concat(UGOmemoryParts, memoryParts);
    }
    String UGOmemory = join(UGOmemoryParts, "-");

    UGO ugo = new UGO(newUGOcoor, memory);
    ugo.mutate( settings.mutability );
    world.addParticle(ugo);
    laserTarget = ugo;
  }
  public void writeInwards(int start, int end, boolean isRelative) {
    laserTarget = null;
    String[] memoryParts = memory.split("-");
    for(int pos = start; pos <= end; pos++){
      int index = genome.loopAroundGenome((isRelative ? genome.performerOn : 0) + pos);
      Codon c = genome.codons.get(index);
      if(pos-start < memoryParts.length){
        String memoryPart = memoryParts[pos-start];
        c.setFullInfo(util.stringToInfo(memoryPart));
        laserCoor.add(genome.getCodonCoor(index,genome.CODON_DIST, x, y));
      }
      useEnergy(settings.gene_tick_energy * settings.gene_tick_time / 40);
    }
  }

  public void healWall(){
    wall += (1-wall) * E_RECIPROCAL;
    laserWall();
  }

  public void giveEnergy() {
    energy += (1-energy)*E_RECIPROCAL;
  }

  public void laserWall(){
    laserT = frameCount;
    laserCoor.clear();
    for(int i = 0; i < 4; i++){
      double[] result = {x+(i/2),y+(i%2)};
      laserCoor.add(result);
    }
    laserTarget = null;
  }

  public void eat(Particle food){
    if(food.type == ParticleType.Food){
      Particle newWaste = new Particle(food.coor, util.combineVelocity( food.velo, util.getRandomVelocity() ), ParticleType.Waste,-99999);
      shootLaserAt(newWaste);
      world.addParticle( newWaste );
      food.removeParticle(this);
      energy += (1-energy)*E_RECIPROCAL;
    }else{
      shootLaserAt(food);
    }
  }

  void shootLaserAt(Particle food){
    laserT = frameCount;
    laserTarget = food;
  }

  public double[] getHandCoor(){
    double r = HAND_DIST;
    if( genome.inwards ){
      r -= HAND_LEN;
    }else{
      r += HAND_LEN;
    }
    return genome.getCodonCoor(genome.performerOn,r);
  }
  
  public boolean pushOut(Particle waste){
    int[][] dire = {{0,1},{0,-1},{1,0},{-1,0}};
    int chosen = -1;
    int iter = 0;
    
    while( iter < 64 && chosen == -1 ) {

      int c = (int) random(0, 4);

      if( world.isCellValid( x + dire[c][0], y + dire[c][1] ) && world.cells[ y + dire[c][1] ][ x + dire[c][0] ] == null ) {
        chosen = c;
      }

      iter ++;

    }

    if( chosen == -1 ) return false;
    
    double[] oldCoor = waste.copyCoor();
    for(int dim = 0; dim < 2; dim++){
      if(dire[chosen][dim] == -1){
        waste.coor[dim] = Math.floor(waste.coor[dim])-EPS;
        waste.velo[dim] = -Math.abs(waste.velo[dim]);
      }else if(dire[chosen][dim] == 1){
        waste.coor[dim] = Math.ceil(waste.coor[dim])+EPS;
        waste.velo[dim] = Math.abs(waste.velo[dim]);
      }
      waste.loopCoor(dim);
    }
    Cell p_cell = world.getCellAt(oldCoor[0], oldCoor[1]);
    if( p_cell != null ) p_cell.removeParticle(waste);
    Cell n_cell = world.getCellAt(waste.coor[0], waste.coor[1]);
    if( n_cell != null ) n_cell.addParticle(waste);
    laserT = frameCount;
    laserTarget = waste;
    
    return true;
  }


  public void hurtWall(double multi){
    if(type == CellType.Normal) {
      wall -= settings.wall_damage*multi;
      if(wall <= 0) die();
    }
  }


  public boolean tamper() {
    boolean old = tampered;
    tampered = true;
    return old;
  }


  public void die() {
    for (int i = 0; i < genome.codons.size(); i++) {
      Particle newWaste = new Particle(getCodonCoor(i, genome.CODON_DIST), ParticleType.Waste, -99999);
      world.addParticle( newWaste );
    }

    if (this == editor.selected) {
      editor.close();
    }

    if (type == CellType.Shell) {
      world.shellCount--;
    } else {
      world.aliveCount --;
    }

    world.deadCount ++;
    type = CellType.Empty;
  }


  public void addParticle(Particle food) {
    pc.get(food.type).add(food);
  }

  public void removeParticle(Particle p) {
    pc.get( p.type ).remove( p );
  }


  public Particle selectParticleInCell(ParticleType type) { //type 0=food 1=waste 2=ngo?
    ArrayList<Particle> myList = pc.get(type);
    if (myList.size() == 0) {
      if( type == ParticleType.Waste ) {
        return selectParticleInCell( ParticleType.UGO );
      }return null;
    } else {
      int choiceIndex = (int) (Math.random() * myList.size());
      return myList.get(choiceIndex);
    }
  }

  public String getCellName(){
    if(x == -1){
      return "Custom UGO";
    }else if(type == CellType.Normal){
      return "Cell at ("+x+", "+y+")";
    }else if(type == CellType.Shell) {
      return "Cell Shell";
    }else if(type == CellType.Locked) {
      return "Wall";
    }

    return "Undefined";
  }


  public int getParticleCount(ParticleType t) {
    if (t == null){
      return pc.count();
    } else {
      return pc.get(t).size();
    }
  }

  int getFrameCount() {
    return frameCount;
  }

  public void DEBUG_SET_PLAY_SPEED(float d) {
    PLAY_SPEED = d;
  }

}

enum CellType {
  Empty,
  Locked,
  Normal,
  Shell;

  public boolean isAlive() {
    return this == Normal || this == Shell;
  }

  public boolean isHurtable() {
    return this == Normal;
  }

}
