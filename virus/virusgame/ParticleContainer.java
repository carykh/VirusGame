package virusgame;

import java.util.ArrayList;
import java.util.Iterator;


import static virusgame.Var.*;
import static virusgame.Const.*;
import static virusgame.Method.*;
import static virusgame.Util.*;

public class ParticleContainer {
    
    public final ArrayList<Particle> foods = new ArrayList<Particle>();
    public final ArrayList<Particle> wastes = new ArrayList<Particle>();
    public final ArrayList<Particle> ugos = new ArrayList<Particle>();
    
    public ArrayList<Particle> get( ParticleType type ) {

        switch( type ){
            case Food: return foods;
            case Waste: return wastes;
            case UGO: return ugos;
        }
        
        return null;
      
    }
    
    public void add( ArrayList<Particle> queue ) {
     
        for( Particle p : queue ) {
            get( p.type ).add( p );
        }
        
        queue.clear();
      
    }
    
    public void tick( ParticleType type ) {
        
        for (Iterator<Particle> it = get(type).iterator(); it.hasNext();) { 
            Particle p = it.next();
            p.tick();
            if( p.removed ) it.remove();
        }
      
    }
    
    public int count() {
        return foods.size() + wastes.size() + ugos.size();
    }
    
    public void randomTick() {
        if( getFrameCount() % 10 == 0 ) {
            int c = count() / settings.particles_per_rand_update;
        
            for( ; c > 0; c -- ) {
                ArrayList<Particle> array = get( ParticleType.fromId(randomInt(0, 2) ) );
                int index =randomInt(0, array.size() - 1);
                if( index != -1 ) array.get( index ).randomTick();
            }
        }
    }
  
}
