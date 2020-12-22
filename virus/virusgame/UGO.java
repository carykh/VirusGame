package virusgame;

import java.util.ArrayList;


import static processing.core.PConstants.*;
import static virusgame.Const.*;
import static virusgame.Var.*;
import static virusgame.Method.*;
import static virusgame.Util.*;
import static java.lang.Math.*;

public class UGO extends Particle {
  
   public Genome genome;
   public boolean divine = false;

    public UGO( double[] coor, String data ) {
        super( coor, ParticleType.UGO, getFrameCount() );
        genome = new Genome( data, true );
        
        double dx = coor[2] - coor[0];
        double dy = coor[3] - coor[1];
        double dist = Math.sqrt(dx * dx + dy * dy);
        double sp = dist * ( SPEED_HIGH - SPEED_LOW ) + SPEED_LOW;
        velo = new double[]{ dx / dist * sp, dy / dist * sp};
        world.totalUGOCount ++;
    }

    public void markDivine() {
         divine = true;
    }

    public void mutate( double mutability ) {
         genome.mutate( mutability );
    }

    public void tick() {
        super.tick();

        if( getFrameCount() % settings.gene_tick_time == 0 ) {
            genome.hurtCodons(null);
            if( genome.codons.size() == 0 ) {
                removeParticle( world.getCellAt(coor[0], coor[1]) );
               Particle p = new Particle( coor, velo, ParticleType.Waste, -99999 );
                world.addParticle( p );
            }
        }
    }
    
    void drawSelf() {
      
       double posx = renderer.trueXtoAppX(coor[0]);
       double posy = renderer.trueYtoAppY(coor[1]);
                
        if( posx > 0 && posy > 0 && posx < ORIG_W_W && posy < ORIG_W_W ) {
          
            pushMatrix();
            renderer.dTranslate( posx, posy );
            double ageScale = Math.min(1.0, (getFrameCount() - birthFrame) * settings.age_grow_speed);
            scale( (float) (renderer.camS / BIG_FACTOR * ageScale) );
            noStroke();
            fill(0);
            ellipseMode(CENTER);
            ellipse(0, 0, 0.1f * BIG_FACTOR, 0.1f * BIG_FACTOR);
            if( renderer.camS > DETAIL_THRESHOLD && genome != null ) genome.drawCodons();
            popMatrix();
        
        }
    
    }
    
    protected boolean interact( double[] future, CellType ct, CellType ft ) {
       
       Cell fc = world.getCellAt(future[0], future[1]);
        if( fc != null ) {

            if( divine || fc.wall * settings.cell_wall_protection < random(0,1) || CellType.Shell.isType(fc) ) {

                if(type == ParticleType.UGO && ct == CellType.Empty && ft == CellType.Normal && genome.codons.size()+fc.genome.codons.size() <= settings.max_codon_count){
                    // there are few enough codons that we can fit in the new material!
                    return injectGeneticMaterial(fc);
                }else if(type == ParticleType.UGO && ft == CellType.Shell && ct == CellType.Empty ){
                    return injectGeneticMaterial(fc);
                }//todo check do we bounce correctly?

            }
          
        }
        
       return false;
      
    }
    
    public boolean injectGeneticMaterial( Cell c ){
        if (this == editor.ugoSelected) {
            editor.close();
        }

        if( CellType.Shell.isType(c) ) {

            c.type = CellType.Normal;
            c.genome.codons = genome.codons;
            c.genome.rotateOn = 0;
            c.genome.rotateOnNext = 1;
            c.genome.performerOn = 0;
            c.init();
            world.shellCount --;
            world.aliveCount ++;
                
        }else{
              
           int injectionLocation = c.genome.rotateOn;
            ArrayList<Codon> toInject = genome.codons;
           int size = genome.codons.size();
    
            for(int i = 0; i < toInject.size(); i++){
                c.genome.codons.add(injectionLocation+i, new Codon(toInject.get(i)));
            }
                
            if(c.genome.performerOn >= c.genome.rotateOn){
                c.genome.performerOn += size;
            }
                
            c.genome.rotateOn += size;
            c.genome.rotateOnNext += size;
        }
            
        if( !c.tamper() ) world.infectedCount ++;
        removeParticle( world.getCellAt(coor[0], coor[1]) );
       Particle p = new Particle(coor,combineVelocity( this.velo,getRandomVelocity() ), ParticleType.Waste, -99999);
        world.addParticle( p );
            
       return true;
        
    }

}
