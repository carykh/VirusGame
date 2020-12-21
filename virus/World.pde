class World {
  
    private Cell[][] cells;
    public ParticleContainer pc = new ParticleContainer();
    
    private ArrayList<Particle> queue = new ArrayList<Particle>();
    private int initialCount = 0;
    private int aliveCount = 0;
    private int deadCount = 0;
    private int shellCount = 0;
    private int infectedCount = 0;
    private int lastEditFrame = 0;
    
    public World( Settings settings ) {
     
        int size = settings.world_size;
        cells = new Cell[ size ][ size ];
        CellType[] types = CellType.values();
        
        for( int y = 0; y < size; y++ ) {
            for( int x = 0; x < size; x++ ) {

                if( x == 0 || y == 0 || x == size - 1 || y == size - 1 ) {
                    cells[y][x] = null;
                }else{
                    int type = settings.map_data[x-1][y-1];
                    
                    if( type == 0 ) {
                        cells[y][x] = null; 
                        continue;
                    }
                    
                    Cell cell = new Cell( x, y, types[type], 0, 1, settings.genome );
                    cells[y][x] = cell;
                    
                    if( cell.type == CellType.Normal ) initialCount ++;
                    if( cell.type == CellType.Shell ) shellCount ++;
                    
                }
                
            }
        }
        
        aliveCount = initialCount;
      
    }
    
    public void tick() {
        pc.tick( ParticleType.Food );
        pc.tick( ParticleType.Waste );
        pc.tick( ParticleType.UGO );
  
        for( int y = 0; y < settings.world_size; y++ ) {
            for( int x = 0; x < settings.world_size; x++ ) {
                Cell c = cells[y][x];
                if( c != null ) {
                    c.tick();
                    if( c.type == CellType.Empty ) cells[y][x] = null;
                }
            }
        }
        
        pc.add( queue );
    }


  double REMOVE_WASTE_SPEED_MULTI = 0.001f; //todo move to settings, remove waste limit from settings
  double removeWasteTimer = 1.0f;
    public void updateParticleCount() {
      
        int count = 0;
        
        while(pc.foods.size() + count < settings.max_food) { //i assume this counts food twice! size() updates and count too!
          
            int choiceX = -1;
            int choiceY = -1;
            int iter = 0;
            
            while( iter < 16 && (choiceX == -1 || cells[choiceY][choiceX] != null)){
                choiceX = (int) random(0,settings.world_size);
                choiceY = (int) random(0,settings.world_size);
                iter ++;
            }

            double[] coor = {
                choiceX + random(0.3, 0.7),
                choiceY + random(0.3, 0.7)
            };

            Particle food = new Particle(coor, ParticleType.Food, frameCount);
            world.addParticle( food );
            count ++;
    }

        //todo needs to copy waste removal over! this is improper and thiis could should already be somewhere
    if (pc.wastes.size() > settings.max_waste) {
      removeWasteTimer -= (pc.wastes.size()-settings.max_waste)*REMOVE_WASTE_SPEED_MULTI*PLAY_SPEED;
      while (removeWasteTimer < 0) {
        int choiceIndex = -1;
        int iter = 0;
        //if we have different particle containers for world and each cell this should be easier
        while ((choiceIndex == -1 || world.getCellTypeAt(pc.wastes.get(choiceIndex).coor[0], pc.wastes.get(choiceIndex).coor[1]) == CellType.Empty) && iter++ < 50) {
          choiceIndex = (int)(Math.random()*pc.wastes.size());
        } // If possible, choose a particle that is NOT in a cell at the moment.
          pc.wastes.remove(choiceIndex);
        removeWasteTimer++;
      }
    }
  }
    
    public void addParticle( Particle p ) {
        p.addToCellList();
        queue.add( p );
    }
    
    public Cell getCellAt( double x, double y) {
        int ix = ((int) x + settings.world_size) % settings.world_size;
        int iy = ((int) y + settings.world_size) % settings.world_size;
        
        if(ix < 0 || ix >= settings.world_size || iy < 0 || iy >= settings.world_size) {
            return null;
        }
        
        return cells[iy][ix];
    }
  
    public CellType getCellTypeAt( double x, double y ) {
        Cell c = getCellAt( x, y );
        if( c != null ) {
            return c.type; 
        }
        
        return CellType.Empty;
    }
    
    public Cell getCellAtUnscaled( double x, double y ) {
       int ix = (int) x;
       int iy = (int) y;
       
       if(ix < 0 || ix >= settings.world_size || iy < 0 || iy >= settings.world_size) {
           return null;
       }
        
      return cells[iy][ix];
    }
  
}
