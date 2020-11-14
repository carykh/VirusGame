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
    public int totalFoodCount = 0;
    public int totalWasteCount = 0;
    public int totalUGOCount = 0;
    
    public World( Settings settings ) {
     
        int size = settings.world_size;
        cells = new Cell[ size ][ size ];
        CellType[] types = CellType.values();
        
        for( int y = 0; y < size; y++ ) {
            for( int x = 0; x < size; x++ ) {

                CellType type = types[settings.map_data[x][y]];
                    
                if( type == CellType.Empty ) {
                    cells[y][x] = null; 
                    continue;
                }
                    
                Cell cell = new Cell( x, y, type, 0, 1, settings.genome );
                cells[y][x] = cell;
                    
                if( cell.type == CellType.Normal ) initialCount ++;
                if( cell.type == CellType.Shell ) shellCount ++;
                
            }
        }
        
        aliveCount = initialCount;
      
    }
    
    public void tick() {
      
        if( frameCount % settings.graph_update_period == 0 ) {
            graph.append( new GraphFrame( 
                pc.get(ParticleType.Waste).size(),
                pc.get(ParticleType.UGO).size(),
                aliveCount + shellCount) );
        }
      
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
        
        pc.randomTick();
        pc.add( queue );
    }
    
    public void updateParticleCount() {
      
        int count = 0;
        
        while(pc.foods.size() + count < settings.max_food) {
          
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
      
    }
    
    public void addParticle( Particle p ) {
        p.addToCellList();
        queue.add( p );
    }
    
    public void setCellAt( int x, int y, Cell c ) {
        if( cells[y][x] != null ) cells[y][x].die(true);
        cells[y][x] = c;
    }
    
    public boolean isCellValid( int x, int y ) {
        return !(x < 0 || x >= settings.world_size || y < 0 || y >= settings.world_size);
    }
    
    public boolean isCellValid( double x, double y ) {
        return !(x < 0 || x >= settings.world_size || y < 0 || y >= settings.world_size);
    }
    
    public Cell getCellAt( double x, double y ) {
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
