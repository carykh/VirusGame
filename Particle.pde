class Particle{
  double[] coor;
  double[] velo;
  int type;
  double laserX = 0;
  double laserY = 0;
  int laserT = -9999;
  int birthFrame;
  double AGE_GROW_SPEED = 0.08;
  Genome UGO_genome;
  
  public Particle(double[] tcoor, int ttype, int b){
    coor = tcoor;
    velo = getRandomVelo();
    type = ttype;
    UGO_genome = null;
    birthFrame = b;
  }
  public Particle(double[] tcoor, int ttype, String genomeString, int b){
    coor = tcoor;
    double dx = tcoor[2]-tcoor[0];
    double dy = tcoor[3]-tcoor[1];
    double dist = Math.sqrt(dx*dx+dy*dy);
    double sp = Math.random()*(SPEED_HIGH-SPEED_LOW)+SPEED_LOW;
    velo = new double[]{dx/dist*sp,dy/dist*sp};
    type = ttype;
    UGO_genome = new Genome(genomeString,true);
    birthFrame = b;
  }
  public double[] copyCoor(){
    double[] result = new double[2];
    for(int dim = 0; dim < 2; dim++){
      result[dim] = coor[dim];
    }
    return result;
  }
  public void moveDim(int d){
    float visc = (getCellTypeAt(coor,true) == 0) ? 1 : 0.5;
    double[] future = copyCoor();
    future[d] = coor[d]+velo[d]*visc*PLAY_SPEED;
    if(cellTransfer(coor, future)){
      int currentType = getCellTypeAt(coor,true);
      int futureType = getCellTypeAt(future,true);
      if(type == 2 && currentType == 0 && futureType == 2 &&
      UGO_genome.codons.size()+getCellAt(future,true).genome.codons.size() <= MAX_CODON_COUNT){ // there are few enough codons that we can fit in the new material!
        injectGeneticMaterial(future);  // UGO is going to inject material into a cell!
      }else if(futureType == 1 ||
      (type >= 1 && (currentType != 0 || futureType != 0))){ // bounce
        Cell b_cell = getCellAt(future,true);
        if(b_cell.type >= 2){
          b_cell.hurtWall(1);
        }
        if(velo[d] >= 0){
          velo[d] = -Math.abs(velo[d]);
          future[d] = Math.ceil(coor[d])-EPS;
        }else{
          velo[d] = Math.abs(velo[d]);
          future[d] = Math.floor(coor[d])+EPS;
        }
        Cell t_cell = getCellAt(coor,true);
        if(t_cell.type >= 2){
          t_cell.hurtWall(1);
        }
      }else{
        while(future[d] >= WORLD_SIZE){
          future[d] -= WORLD_SIZE;
        }
        while(future[d] < 0){
          future[d] += WORLD_SIZE;
        }
        hurtWalls(coor, future);
      }
    }
    coor = future;
  }
  public void injectGeneticMaterial(double[] futureCoor){
    Cell c = getCellAt(futureCoor,true);
    int injectionLocation = c.genome.rotateOn;
    ArrayList<Codon> toInject = UGO_genome.codons;
    int INJECT_SIZE = UGO_genome.codons.size();
    
    for(int i = 0; i < toInject.size(); i++){
      int[] info = toInject.get(i).codonInfo;
      c.genome.codons.add(injectionLocation+i,new Codon(info,1.0));
    }
    if(c.genome.performerOn >= c.genome.rotateOn){
      c.genome.performerOn += INJECT_SIZE;
    }
    c.genome.rotateOn += INJECT_SIZE;
    c.tamper();
    removeParticle();
    Particle newWaste = new Particle(coor,1,-99999);
    newWaste.addToCellList();
    particles.get(1).add(newWaste);
  }
  public void hurtWalls(double[] coor, double[] future){
    Cell p_cell = getCellAt(coor,true);
    if(p_cell.type >= 2){
      p_cell.hurtWall(1);
    }
    p_cell.removeParticleFromCell(this);
    Cell n_cell = getCellAt(future,true);
    if(n_cell.type >= 2){
      n_cell.hurtWall(1);
    }
    n_cell.addParticleToCell(this);
  }
  public void iterate(){
    for(int dim = 0; dim < 2; dim++){
      moveDim(dim);
    }
  }
  public void drawParticle(double x, double y, double s){
    pushMatrix();
    translate((float)x,(float)y);
    
    double ageScale = Math.min(1.0,(frameCount-birthFrame)*AGE_GROW_SPEED);
    scale((float)(s/BIG_FACTOR*ageScale));
    noStroke();
    if(type == 0){
      fill(255,0,0);
    }else if(type == 1){
      fill(WASTE_COLOR);
    }else if(type == 2){
      fill(0);
    }
    ellipseMode(CENTER);
    ellipse(0,0,0.1*BIG_FACTOR,0.1*BIG_FACTOR);
    if(UGO_genome != null){
      UGO_genome.drawCodons();
    }
    popMatrix();
  }

  public void removeParticle(){
    particles.get(type).remove(this);
    getCellAt(coor,true).particlesInCell.get(type).remove(this);
  }
  public void addToCellList(){
    Cell cellIn = getCellAt(coor,true);
    cellIn.addParticleToCell(this);
  }
  public void loopCoor(int d){
    while(coor[d] >= WORLD_SIZE){
      coor[d] -= WORLD_SIZE;
    }
    while(coor[d] < 0){
      coor[d] += WORLD_SIZE;
    }
  }
}