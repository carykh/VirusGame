class Particle{
  
    protected double[] coor;
    protected double[] velo;
    protected boolean removed = false;
    protected int birthFrame;
    protected ParticleType type;
  
    public Particle(double[] tcoor, ParticleType ttype, int b){
        this(tcoor, getRandomVelocity(), ttype, b);
    }
    
    public Particle(double[] tcoor, double tvelo[], ParticleType ttype, int b){
        coor = tcoor;
        velo = tvelo;
        type = ttype;
        birthFrame = b;
    }
  
    void drawSelf() {
      
        double posx = renderer.trueXtoAppX(coor[0]);
        double posy = renderer.trueYtoAppY(coor[1]);
                
        if( posx > 0 && posy > 0 && posx < renderer.maxRight && posy < height ) {
          
            pushMatrix();
            renderer.dTranslate( posx, posy );
            double ageScale = Math.min(1.0, (frameCount - birthFrame) * settings.age_grow_speed);
            scale( (float) (renderer.camS / BIG_FACTOR * ageScale) );
            noStroke();
          
            if(type == ParticleType.Food){
                fill(FOOD_COLOR);
            }else if(type == ParticleType.Waste){
                fill(WASTE_COLOR);
            }
          
            ellipseMode(CENTER);
            ellipse(0, 0, 0.1 * BIG_FACTOR, 0.1 * BIG_FACTOR);
            popMatrix();
        
        }
    
    }
    
    public void tick() {
        double[] future = {0, 0};
        float visc = world.getCellTypeAt(coor[0], coor[1]) == CellType.Empty ? 1 : 0.5;
        
        future[0] = coor[0] + velo[0] * visc * PLAY_SPEED;
        future[1] = coor[1] + velo[1] * visc * PLAY_SPEED;
        
        boolean cta = checkCellBoundary( coor[0], future[0] );
        boolean ctb = checkCellBoundary( coor[1], future[1] );
            
        if( cta || ctb ) {
            
            CellType ct = world.getCellTypeAt(coor[0], coor[1]);
            CellType ft = world.getCellTypeAt(future[0], future[1]);
            
            if( interact( future, ct, ft ) ) return;
            
            if(ft == CellType.Locked || (type != ParticleType.Food && (ct != CellType.Empty || ft != CellType.Empty))) {
        
                Cell b_cell = world.getCellAt(future[0], future[1]);
                if(b_cell != null && b_cell.type.isHurtable()){
                    b_cell.hurtWall( cta && ctb ? 2 : 1 );
                }
                
                if( cta ) {
                    if(velo[0] >= 0){
                        velo[0] = -velo[0];
                        future[0] = Math.ceil(coor[0]) - EPS;
                    }else{
                        velo[0] = Math.abs(velo[0]);
                        future[0] = Math.floor(coor[0]) + EPS;
                    } 
                }
            
                if( ctb ) {
                    if(velo[1] >= 0){
                        velo[1] = -velo[1];
                        future[1] = Math.ceil(coor[1]) - EPS;
                    }else{
                        velo[1] = Math.abs(velo[1]);
                        future[1] = Math.floor(coor[1]) + EPS;
                    }
                }
                
                Cell t_cell = world.getCellAt(coor[0], coor[1]);
                if(t_cell != null && t_cell.type.isHurtable()){
                    t_cell.hurtWall( cta && ctb ? 2 : 1 );
                }
            
            }else{
              
                if(future[0] >= settings.world_size) { future[0] -= settings.world_size; border(0); } else
                if(future[0] < 0) { future[0] += settings.world_size; border(1); } else
                if(future[1] >= settings.world_size) { future[1] -= settings.world_size; border(2); } else
                if(future[1] < 0) { future[1] += settings.world_size; border(3); }
                
                hurtWalls(coor, future);
            }
            
        }
        
        coor = future;
          
    }
    
    private void border( int wid ) {
        if( type == ParticleType.Waste ) {
            if( world.pc.wastes.size() > settings.max_waste && random(0, 1) < settings.waste_disposal_chance_high ) removeParticle(null);
            if( random(0, 1) < settings.waste_disposal_chance_low ) removeParticle(null);
        }
    }
    
    public double[] copyCoor(){
        double[] result = new double[2];
        result[0] = coor[0];
        result[1] = coor[1];
        return result;
    }
    
    protected void hurtWalls(double[] coor, double[] future) {
      
        Cell p_cell = world.getCellAt(coor[0], coor[1]);
        if( p_cell != null ) {
            if(p_cell.type.isHurtable()){
                p_cell.hurtWall(1);
            }
            p_cell.removeParticle(this);
        }
       
        Cell n_cell = world.getCellAt(future[0], future[1]);
        if( n_cell != null ) {
            if(n_cell.type.isHurtable()){
                n_cell.hurtWall(1);
            }
            n_cell.addParticle(this);
        }
        
    }
    
    public void removeParticle( Cell c ) {
         removed = true;
         if(c != null) c.removeParticle(this);
    }
  
    public void addToCellList(){
        Cell c = world.getCellAt(coor[0], coor[1]);
        if( c != null ) c.addParticle(this);
    }
    
    protected boolean interact( double[] future, CellType cType, CellType fType ) {
        return false;
    }
  
    // REMOVE //
    public void loopCoor(int d){
        while(coor[d] >= settings.world_size){
            coor[d] -= settings.world_size;
        }
    
        while(coor[d] < 0){
            coor[d] += settings.world_size;
        }
    }
}

enum ParticleType {
    Food,
    Waste,
    UGO;
    
    public static ParticleType fromId( int id ) {
        switch(id){
            case 0: return ParticleType.Food;
            case 1: return ParticleType.Waste;
            case 2: return ParticleType.UGO;
        }
        return null;
    }
}
