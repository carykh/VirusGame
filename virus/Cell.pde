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
    int dire;
  
    public Cell(int ex, int ey, CellType et, int ed, double ewh, String eg){
        x = ex;
        y = ey;
        type = et;
        dire = ed;
        wall = ewh;
        genome = new Genome(eg,false);
        genome.rotateOn = (int)(Math.random()*genome.codons.size());
        geneTimer = Math.random()*settings.gene_tick_time;
        energy = 0.5;
    }
  
    public String getMemory() {
        if(memory.length() == 0){
            return "[NOTHING]";
        }else{
            return "\"" + memory + "\"";
        }
    }
    
    public boolean isHandInwards() {
        return genome.directionOn == 1;
    }
  
    void drawSelf() {
      
        double posx = renderer.trueXtoAppX(x);
        double posy = renderer.trueYtoAppY(y);
      
        if( posx < -renderer.camS || posy < -renderer.camS || posx > renderer.maxRight || posy > height ) {
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
        
            if(this == editor.selected){
                fill(0,255,255);
            }else if(tampered){
                fill(205,225,70);
            }else{
                fill(225,190,225);
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
          
        }else if( type == CellType.Shell ) {
        
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
            stroke(transperize(HAND_COLOR,alpha));
            strokeWeight((float)(0.033333*BIG_FACTOR));
            double[] handCoor = getHandCoor();
            if(laserTarget == null){
                for(double[] singleLaserCoor : laserCoor){
                    renderer.scaledLine(handCoor,singleLaserCoor);
                }
            }else{
                double[] targetCoor = laserTarget.coor;
                renderer.scaledLine(handCoor,targetCoor);
            }
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
  
    public void tick(){
        if(type == CellType.Normal){
            if(energy > 0){
                double oldGT = geneTimer;
                geneTimer -= PLAY_SPEED;
                
                if(geneTimer <= settings.gene_tick_time/2.0 && oldGT > settings.gene_tick_time/2.0){
                    useEnergy( genome.getSelected().tick(this) );
                }
                
                if(geneTimer <= 0){
                    geneTimer += settings.gene_tick_time;
                    genome.next();
                }
            }
            
            genome.update();
        }
    }
  
    void useEnergy( double amount ){
        energy = Math.max(0, energy - amount);
    }
  
    void readToMemory(int start, int end){
      
        memory = "";
        laserTarget = null;
        laserCoor.clear();
        laserT = frameCount;
        
        for(int pos = start; pos <= end; pos++){
            int index = loopItInt(genome.performerOn+pos,genome.codons.size());
            Codon c = genome.codons.get(index);
            memory = memory+infoToString(c.info);
            if(pos < end){
                memory = memory+"-";
            }
            laserCoor.add(getCodonCoor(index,genome.CODON_DIST));
        }
    }
    
    public void writeFromMemory(int start, int end){
        if(memory.length() == 0) return;
        laserTarget = null;
        laserCoor.clear();
        laserT = frameCount;
        if(genome.directionOn == 0){
            writeOutwards();
        }else{
            writeInwards(start,end);
        }
    }
    
    private void writeOutwards() {
        double theta = Math.random()*2*Math.PI;
        double ugo_vx = Math.cos(theta);
        double ugo_vy = Math.sin(theta);
        double[] startCoor = getHandCoor();
        double[] newUGOcoor = new double[]{startCoor[0],startCoor[1],startCoor[0]+ugo_vx,startCoor[1]+ugo_vy};
        Particle newUGO = new UGO(newUGOcoor, memory);
        world.addParticle(newUGO);
        laserTarget = newUGO;
    
        String[] memoryParts = memory.split("-");
        for(int i = 0; i < memoryParts.length; i++){
            useEnergy( settings.gene_tick_energy );
        }
    }
    
    private void writeInwards(int start, int end){
        laserTarget = null;
        String[] memoryParts = memory.split("-");
        for(int pos = start; pos <= end; pos++){
            int index = loopItInt(genome.performerOn+pos,genome.codons.size());
            Codon c = genome.codons.get(index);
            if(pos-start < memoryParts.length){
                String memoryPart = memoryParts[pos-start];
                c.setFullInfo(stringToInfo(memoryPart));
                laserCoor.add(getCodonCoor(index,genome.CODON_DIST));
            }
            useEnergy( settings.gene_tick_energy );
        }
    }
    
    public void healWall(){
        wall += (1-wall) * E_RECIPROCAL;
        laserWall();
    }
    
    public void laserWall(){
        laserT = frameCount;
        laserCoor.clear();
        for(int i = 0; i < 4; i++){
            double[] result = {x+(i/2), y+(i%2)};
            laserCoor.add(result);
        }
        laserTarget = null;
    }
  
    public void eat(Particle food){
        if(food.type == ParticleType.Food){
            Particle newWaste = new Particle(food.coor, combineVelocity( food.velo, getRandomVelocity() ), ParticleType.Waste,-99999);
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
        if(genome.directionOn == 0){
            r += HAND_LEN;
        }else{
            r -= HAND_LEN;
        }
        return getCodonCoor(genome.performerOn,r);
    }
  
    public double[] getCodonCoor(int i, double r){
        double theta = (float)(i*2*PI)/(genome.codons.size())-PI/2;
        double r2 = r/BIG_FACTOR;
        double handX = x+0.5+r2*Math.cos(theta);
        double handY = y+0.5+r2*Math.sin(theta);
        double[] result = {handX, handY};
        return result;
    }
    
    public void pushOut(Particle waste){
        int[][] dire = {{0,1},{0,-1},{1,0},{-1,0}};
        int chosen = -1;
        int iter = 0;
        while(chosen == -1 || (world.cells[y+dire[chosen][1]][x+dire[chosen][0]] != null && world.cells[y+dire[chosen][1]][x+dire[chosen][0]].type != CellType.Empty) ){
            chosen = (int)random(0,4);
            iter ++;
            if( iter > 64 ) return;
        }
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
  
    public void die(){
        for(int i = 0; i < genome.codons.size(); i++){
            Particle newWaste = new Particle( getCodonCoor(i, genome.CODON_DIST), ParticleType.Waste, -99999 );
            world.addParticle( newWaste );
        }
        
        if(this == editor.selected){
            editor.close();
        }
        
        if( type == CellType.Shell ){
            world.shellCount --;
        }else{
            world.aliveCount --;
        }
        
        world.deadCount ++;
        type = CellType.Empty;
    }
  
    public void addParticle(Particle food){
        pc.get(food.type).add(food);
    }
  
    public void removeParticle(Particle p){
        pc.get( p.type ).remove( p );
    }
  
    public Particle selectParticleInCell(ParticleType type){
        ArrayList<Particle> myList = pc.get(type);
        if(myList.size() == 0){
      
            return null;
        }else{
            int choiceIndex = (int)(Math.random()*myList.size());
            return myList.get(choiceIndex);
        }
    }
  
    public String getCellName(){
        if(x == -1){
            return "Custom UGO";
        }else if(type == CellType.Normal){
            return "Cell at ("+x+", "+y+")";
        }
        
        return "";
    }
  
    public int getParticleCount(ParticleType t){
        if(t == null){
            return pc.count();
        }else{
            return pc.get(t).size();
        }
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
