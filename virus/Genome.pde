class Genome{
  
    boolean isUGO;
    ArrayList<Codon> codons;
    int rotateOn = 0;
    int performerOn = 0;
    boolean inwards = false;
    double appRO = 0;
    double appPO = 0;
    double appDO = 0;
  
    public Genome(String s, boolean isUGOp){
        codons = new ArrayList<Codon>();
        String[] parts = s.split("-");
        for(int i = 0; i < parts.length; i++){
            int[] info = stringToInfo(parts[i]);
            codons.add(new Codon(info));
        }
        appRO = 0;
        appPO = 0;
        appDO = 0;
        isUGO = isUGOp;
    }
  
    public Codon getSelected() {
        if( codons.size() == 0 ) {
            return null;
        }
        return codons.get(rotateOn);
    }
  
    public void next() {
        int s = codons.size();
        rotateOn = ((s == 0) ? 0 : ((rotateOn + 1) % s)); 
    }
  
    public void update(){
      
        int s = codons.size();
        if( s != 0 ) {
            appRO += loopIt( rotateOn-appRO, s, true) * VISUAL_TRANSITION * PLAY_SPEED;
            appPO += loopIt( performerOn-appPO, s, true) * VISUAL_TRANSITION * PLAY_SPEED;
            appDO += ((inwards?1:0) - appDO) * VISUAL_TRANSITION * PLAY_SPEED;
            appRO = loopIt( appRO, s, false);
            appPO = loopIt( appPO, s, false);
        }else{
            appRO = 0;
            appPO = 0;
        }
       
    }
    
    public void drawHand(){
        double appPOAngle = (float)(appPO*2*PI/codons.size());
        double appDOAngle = (float)(appDO*PI);
        strokeWeight(1);
        noFill();
        stroke(transperize(HAND_COLOR,0.5));
        ellipse(0,0,HAND_DIST*2,HAND_DIST*2);
        pushMatrix();
        rotate((float)appPOAngle);
        translate(0,-HAND_DIST);
        rotate((float)appDOAngle);
        noStroke();
        fill(HAND_COLOR);
        beginShape();
        vertex(5,0);
        vertex(-5,0);
        vertex(0,-HAND_LEN);
        endShape(CLOSE);
        popMatrix();
    }
  
    public void drawCodons(){
      
        final int size = codons.size();
        final float codonAngle = 1.0f / max(3, size) * TWO_PI;
        final float partAngle = codonAngle / 5.0f;
        final float codonDist = (float) (isUGO ? CODON_DIST_UGO : CODON_DIST);
        
        for( int i = 0; i < size; i ++ ) {
        
            pushMatrix();
            rotate( -HALF_PI + i * codonAngle );
            
            Codon c = codons.get(i);
            if(c.codonHealth < 0.97){
                beginShape();
                fill(TELOMERE_COLOR);
                for(int v = 0; v < TELOMERE_SHAPE.length; v++){
                    final float[] cv = TELOMERE_SHAPE[v];
                    final float ang = cv[0] * partAngle;
                    final float dist = cv[1] * CODON_WIDTH + codonDist;
                    vertex(cos(ang) * dist, sin(ang) * dist);
                }
                endShape(CLOSE);
            }

            for(int p = 0; p < 2; p++){
                beginShape();
                fill(c.getColor(p));
                for(int v = 0; v < CODON_SHAPE.length; v++){
                    final float[] cv = CODON_SHAPE[v];
                    final float ang = cv[0] * partAngle * c.codonHealth;
                    final float dist = cv[1] * (2 * p - 1) * CODON_WIDTH + codonDist;
                    vertex(cos(ang) * dist, sin(ang) * dist);
                }    
                endShape(CLOSE);
            }
            
            popMatrix();
          
        }

    }

    void hurtCodons( Cell cell ){
        for(int i = 0; i < codons.size(); i++){
            Codon c = codons.get(i);
            if(c.hasSubstance()){
                if( c.hurt() ) {
                    if( cell != null ) {
                        Particle newWaste = new Particle( getCodonCoor(i, CODON_DIST, cell.x, cell.y), ParticleType.Waste, -99999 );
                        world.addParticle( newWaste );
                    }
                  
                    codons.remove(i);
                    return;
                }
            }
        }
    }
    
    public double[] getCodonCoor(int i, double r, int x, int y){
        double theta = (float)(i*2*PI)/(codons.size())-PI/2;
        double r2 = r/BIG_FACTOR;
        double cx = x+0.5+r2*Math.cos(theta);
        double cy = y+0.5+r2*Math.sin(theta);
        double[] result = {cx, cy};
        return result;
    }
  
    int getWeakestCodon(){
        double record = 9999;
        int holder = -1;
        for(int i = 0; i < codons.size(); i++){
            double val = codons.get(i).codonHealth;
            if(val < record){
                record = val;
                holder = i;
            }
        }
        return holder;
    }
  
    String getGenomeString(){
        String str = "";
        for(int i = 0; i < codons.size(); i++){
            Codon c = codons.get(i);
            str = str+infoToString(c.info);
            if(i < codons.size()-1){
                str = str+"-";
            }
        }
        return str;
    }
  
    String getGenomeStringShortened(){
        int limit = max(1,codons.size()-1);
        String str = "";
        for(int i = 0; i < limit; i++){
            Codon c = codons.get(i);
            str = str+infoToString(c.info);
            if(i < limit-1){
                str = str+"-";
            }
        }
        return str;
    }
  
    String getGenomeStringLengthened(){
        if(codons.size() == 9){
            return getGenomeString();
        }else{
            return getGenomeString()+"-00";
        }
    }
    
}
