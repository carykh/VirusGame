package virus;

import java.util.ArrayList;


import static virus.Var.*;
import static virus.Util.*;
import static virus.Method.*;

public class World {
  
    private Cell[][] cells; //this should be private because world wrapping!
    public ParticleContainer pc = new ParticleContainer();
    
    private ArrayList<Particle> queue = new ArrayList<Particle>();
    public int initialCount = 0;
    public int aliveCount = 0;
    public int deadCount = 0;
    public int shellCount = 0;
    public int infectedCount = 0;
    public int lastEditFrame = 0;
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
                    
                if( CellType.Normal.isType(cell) ) initialCount ++;
                if( CellType.Shell.isType(cell) ) shellCount ++;
                
            }
        }
        
        aliveCount = initialCount;
      
    }

    public void init() {
      int size = settings.world_size;

      for( int y = 0; y < size; y++ ) {
        for( int x = 0; x < size; x++ ) {
          Cell c =cells[x][y];
          if (c != null)c.init();

        }
      }
    }

    int lastGraphFrame = 0;
    public void tick() {

        if( getFrameCount()-lastGraphFrame > (settings.graph_update_period/PLAY_SPEED)) {
          lastGraphFrame = getFrameCount();
            graph.append( new Graph.GraphFrame(
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
                    if( CellType.Empty.isType(c) ) cells[y][x] = null;
                }
            }
        }
        
        pc.randomTick();
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
                choiceX = (int) randomInt(0,settings.world_size);
                choiceY = (int) randomInt(0,settings.world_size);
                iter ++;
            }

            double[] coor = {
                choiceX + random(0.3, 0.7),
                choiceY + random(0.3, 0.7)
            };

            Particle food = new Particle(coor, ParticleType.Food, getFrameCount());
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
    
    public void setCellAt( int x, int y, Cell c ) {
        if( cells[y][x] != null ) cells[y][x].die();
        cells[y][x] = c;
    }

    public boolean isCellValid( int x, int y ) {
        return !(x < 0 || x >= settings.world_size || y < 0 || y >= settings.world_size);
    }

    public boolean isCellValid( double x, double y ) {
        return !(x < 0 || x >= settings.world_size || y < 0 || y >= settings.world_size);
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
