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
        return codons.get(rotateOn);
    }
  
    public void next() {
        rotateOn = (rotateOn + 1) % codons.size(); 
    }
  
    public void update(){
      appRO += loopIt(rotateOn-appRO, codons.size(),true)*VISUAL_TRANSITION*PLAY_SPEED;
      appPO += loopIt(performerOn-appPO, codons.size(),true)*VISUAL_TRANSITION*PLAY_SPEED;
      appDO += ((inwards?1:0)-appDO)*VISUAL_TRANSITION*PLAY_SPEED;
      appRO = loopIt(appRO, codons.size(),false);
      appPO = loopIt(appPO, codons.size(),false);
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
        for(int i = 0; i < codons.size(); i++){
            drawCodon(i);
        }
    }
  
    public void drawCodon(int i){
        int VIS_GENOME_LENGTH = max(3,codons.size());
        double CODON_ANGLE = (double)(1.0)/VIS_GENOME_LENGTH * TWO_PI;
        double PART_ANGLE = CODON_ANGLE/5.0;
        double baseAngle = -HALF_PI + i * CODON_ANGLE;
        pushMatrix();
        rotate((float)(baseAngle));
    
        Codon c = codons.get(i);
        if(c.codonHealth < 0.97){
            beginShape();
            fill(TELOMERE_COLOR);
            for(int v = 0; v < TELOMERE_SHAPE.length; v++){
                double[] cv = TELOMERE_SHAPE[v];
                double ang = cv[0]*PART_ANGLE;
                double dist = cv[1] * CODON_WIDTH + (isUGO ? CODON_DIST_UGO : CODON_DIST);
                vertex((float)(Math.cos(ang)*dist),(float)(Math.sin(ang)*dist));
            }
            endShape(CLOSE);
        }

        for(int p = 0; p < 2; p++){
            beginShape();
            fill(c.getColor(p));
            for(int v = 0; v < CODON_SHAPE.length; v++){
                double[] cv = CODON_SHAPE[v];
                double ang = cv[0]*PART_ANGLE*c.codonHealth;
                double dist = cv[1]*(2*p-1) * CODON_WIDTH + (isUGO ? CODON_DIST_UGO : CODON_DIST);
                vertex((float)(Math.cos(ang)*dist),(float)(Math.sin(ang)*dist));
            }
            endShape(CLOSE);
        }
        popMatrix();
    }
  
    void hurtCodons(){
        for(int i = 0; i < codons.size(); i++){
            Codon c = codons.get(i);
            if(c.hasSubstance()){
                if( c.hurt() ) {
                    codons.remove(i);
                    return;
                }
            }
        }
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
