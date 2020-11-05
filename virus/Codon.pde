class Codon{
  
    public int[] info = new int[4];
    float codonHealth = 1.0;
  
    public Codon(int[] info){
        this.info = info;
    }
  
    public color getColor(int p){
        return CodonInfo.getColor(p, info[p]);
    }
  
    public String getText(int p){
        return CodonInfo.getText(p, info);
    }
    
    public String _getText() {
        return CodonInfo._getText(info); 
    }
  
    public boolean hasSubstance(){
        return info[0] != 0 || info[1] != 0;
    }
  
    public void hurt(){
        if( hasSubstance() ) {
            codonHealth -= Math.random() * settings.codon_degrade_speed;
            if(codonHealth <= 0) {
                codonHealth = 1;
                info[0] = 0;
                info[1] = 0;
            }
        }
    }
  
  public void setInfo(int p, int val){
      info[p] = val;
      codonHealth = 1.0;
  }
  
  public void setFullInfo(int[] info){
      this.info = info;
      codonHealth = 1.0;
  }
  
  public double tick( Cell c ) {
    
      boolean inwards = c.isHandInwards();
      c.genome.hurtCodons();
    
      switch( info[0] ) {
        
          case 0: // NONE //
              return 0;
              
          case 1: // DIGEST //
              if(!inwards) {
                  if(info[1] == 1 || info[1] == 2){
                      Particle foodToEat = c.selectParticleInCell( ParticleType.fromId(info[1] - 1) ); // digest either "food" or "waste".
                      if(foodToEat != null) {
                          c.eat(foodToEat);
                      }
                  }else if(info[1] == 3){
                      c.hurtWall(26);
                      c.laserWall();
                      return (1 - c.energy) * E_RECIPROCAL * -0.2;
                  } 
              }
              break;
              
          case 2: // REMOVE //
              if(!inwards){
                  if(info[1] == 1 || info[1] == 2){
                      Particle wasteToPushOut = c.selectParticleInCell( ParticleType.fromId(info[1] - 1) );
                      if(wasteToPushOut != null){
                          c.pushOut(wasteToPushOut);
                      }
                  }else if(info[1] == 3){
                      c.die();
                  }
              }
              break;
            
          case 3: // REPAIR //
              if(!inwards){
                  if(info[1] == 1 || info[1] == 2){
                      Particle particle = c.selectParticleInCell( ParticleType.fromId(info[1] - 1) );
                      c.shootLaserAt(particle);
                  }else if(info[1] == 3){
                      c.healWall();
                  }
              }
              break;
              
          case 4: // MOVE HAND //
              if(info[1] == 4){
                  c.genome.performerOn = c.genome.getWeakestCodon();
              }else if(info[1] == 5){
                  c.genome.directionOn = 1;
              }else if(info[1] == 6){
                  c.genome.directionOn = 0;
              }else if(info[1] == 7){
                  c.genome.performerOn = loopItInt(c.genome.rotateOn+info[2],c.genome.codons.size());
              }
              break;
              
          case 5: // READ //
              if(info[1] == 7 && inwards){
                  c.readToMemory(info[2],info[3]);
              }
              break;
              
          case 6: // WRITE //
              if(info[1] == 7 || !inwards){
                  c.writeFromMemory(info[2], info[3]);
              }
              break;
              
          default:
              println("Invalid codon opcode!");
              break;
              
      }
    
      return settings.gene_tick_energy;
  }
  
}
