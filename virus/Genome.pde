class Genome{
  ArrayList<Codon> codons;
  int rotateOn = 0;
  int rotateOnNext = 1;
  int performerOn = 0;
  int directionOn = 0;
  double appRO = 0;
  double appPO = 0;
  double appDO = 0;
  double VISUAL_TRANSITION = 0.38;
  float HAND_DIST = 32;
  float HAND_LEN = 7;
  double[][] codonShape = {{-2,0},{-2,2},{-1,3},{0,3},{1,3},{2,2},{2,0},{0,0}};
  double[][] telomereShape = {{-2,2},{-1,3},{0,3},{1,3},{2,2},{2,-2},{1,-3},{0,-3},{-1,-3},{-2,-2}};
  double[][] epigeneticsShape = {{1.5,2},{1.5,4},{1.75,4.2},{2,4},{3,3.33},{2.5,3},{2,2.66},{2,2},{1.75,2}};
  double[][] epigeneticsMiddleShape = {{-0.5, 2.8}, {-0.3, 3.2}, {-0.2, 3.6}, {-0.1, 3.8}, {0, 3.8}, {0.1, 3.8}, {0.2, 3.6}, {0.3, 3.2}, {0.5, 2.8}, {0,3}};
  
  int ZERO_CH = (int)('0');
  double CODON_DIST = 17;
  double CODON_WIDTH = 1.4;
  boolean isUGO;
  
  int scrollOffset = 0;
  
  public Genome(String s, boolean isUGOp){
    codons = new ArrayList<Codon>();
    String[] parts = s.split("-");
    for(int i = 0; i < parts.length; i++){
      int[] info = stringToInfo(parts[i]);
      codons.add(new Codon(fromIntList(info)));
    }
    appRO = 0;
    appPO = 0;
    appDO = 0;
    isUGO = isUGOp;
    if(isUGO){
      CODON_DIST = 10.6;
    }
  }
  public void iterate(){
    appRO += loopIt(rotateOn-appRO, codons.size(),true)*VISUAL_TRANSITION*PLAY_SPEED;
    appPO += loopIt(performerOn-appPO, codons.size(),true)*VISUAL_TRANSITION*PLAY_SPEED;
    appDO += (directionOn-appDO)*VISUAL_TRANSITION*PLAY_SPEED;
    appRO = loopIt(appRO, codons.size(),false);
    appPO = loopIt(appPO, codons.size(),false);
  }
  public void drawHand(){
    double appPOAngle = (float)(appPO*2*PI/codons.size());
    double appDOAngle = (float)(appDO*PI);
    strokeWeight(1);
    noFill();
    stroke(transperize(handColor,0.5));
    ellipse(0,0,HAND_DIST*2,HAND_DIST*2);
    pushMatrix();
    rotate((float)appPOAngle);
    translate(0,-HAND_DIST);
    rotate((float)appDOAngle);
    noStroke();
    fill(handColor);
    beginShape();
    vertex(5,0);
    vertex(-5,0);
    vertex(0,-HAND_LEN);
    endShape(CLOSE);
    popMatrix();
  }
  public int loopAroundGenome(int i) {
     return loopItInt(i, codons.size()); 
  }
  
  public void drawCodons(){
    for(int i = 0; i < codons.size(); i++){
      drawCodon(i);
    }
  }
  public void drawCodon(int i){
    if(camS < ZOOM_THRESHOLD){
      return;
    }
    int VIS_GENOME_LENGTH = max(4,codons.size());
    double CODON_ANGLE = (double)(1.0)/VIS_GENOME_LENGTH*2*PI;
    double PART_ANGLE = CODON_ANGLE/5.0;
    double angleMulti = codons.size() == 2 && i == 1?2:i; //special case 2 codons
    if (codons.size() == 3)angleMulti*=4/3.0; //special case 3 codons
    double baseAngle = -PI/2+angleMulti*CODON_ANGLE;
    pushMatrix();
    rotate((float)(baseAngle));
    
    Codon c = codons.get(i);
    
    //used up codons
    if(c.codonHealth != 1.0){
      beginShape();
      fill(TELOMERE_COLOR);
      for(int v = 0; v < telomereShape.length; v++){
        double[] cv = telomereShape[v];
        double ang = cv[0]*PART_ANGLE;
        double dist = cv[1]*CODON_WIDTH+CODON_DIST;
        vertex((float)(Math.cos(ang)*dist),(float)(Math.sin(ang)*dist));
      }
    }
    endShape(CLOSE);
    
    
    
    
    //epigenetics
    
    boolean flagMiddleEpiSet = false;
    boolean flagStartEpiSet = false;
    for (int mf:c.memorySetFrom) {
      fill(memoryIdColor(mf));
      if (c.memorySetTo.contains(mf)) {
         println(mf + " flagMiddleEpiSet:" + flagMiddleEpiSet);
        if (!flagMiddleEpiSet) {
          flagMiddleEpiSet = true;
          float[] ellipseData = new float[6];
          beginShape();
          for(int v = 0; v < epigeneticsMiddleShape.length; v++){
            double[] cv = epigeneticsMiddleShape[v];
            double ang = cv[0]*PART_ANGLE*c.codonHealth;
            double dist = cv[1]*CODON_WIDTH+CODON_DIST;
            
            float x = (float)(Math.cos(ang)*dist);
            float y = (float)(Math.sin(ang)*dist);
            vertex(x, y);
            if (v >= 3 && v <= 5) {
              int index = (v-3)*2;
              ellipseData[index+0] = x;
              ellipseData[index+1] = y;
            }
          }
          endShape(CLOSE);
          float diameter = sqrt((ellipseData[0]-ellipseData[4])*(ellipseData[0]-ellipseData[4]) + (ellipseData[1]-ellipseData[5])*(ellipseData[1]-ellipseData[5]));
          noStroke();
          ellipseMode(CENTER);
          ellipse(ellipseData[2], ellipseData[3],diameter*3 ,diameter*3);
        }
      } else {
         println(mf + " flagStartEpiSet:" + flagStartEpiSet);
         if (!flagStartEpiSet) {
           
          beginShape();
          flagStartEpiSet = true;
          for(int v = 0; v < epigeneticsShape.length; v++){
            double[] cv = epigeneticsShape[v];
            double ang = cv[0]*PART_ANGLE*c.codonHealth;
            double dist = cv[1]*CODON_WIDTH+CODON_DIST;
            vertex((float)(Math.cos(ang)*dist),(float)(Math.sin(ang)*dist));
          }
          endShape(CLOSE);
        }
      }
      if (flagMiddleEpiSet && flagStartEpiSet)break; //really only care for the first one for each case
    }
    
    for (int mf:c.memorySetTo) {
       if (c.memorySetFrom.contains(mf)) {
        continue;
      }
      fill(memoryIdColor(mf));
      beginShape();
      for(int v = 0; v < epigeneticsShape.length; v++){
        double[] cv = epigeneticsShape[v];
        double ang = -cv[0]*PART_ANGLE*c.codonHealth;
        double dist = cv[1]*CODON_WIDTH+CODON_DIST;
        vertex((float)(Math.cos(ang)*dist),(float)(Math.sin(ang)*dist));
      }
      endShape(CLOSE);
      break; //really only care for the first one
    }
    
    
    //codons
    for(int p = 0; p < 2; p++){
      beginShape();
      fill(c.getColor(p));
      for(int v = 0; v < codonShape.length; v++){
        double[] cv = codonShape[v];
        double ang = cv[0]*PART_ANGLE*c.codonHealth;
        double dist = cv[1]*(2*p-1)*CODON_WIDTH+CODON_DIST;
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
        c.hurt();
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
      str = str+infoToString(c);
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
      str = str+infoToString(c);
      if(i < limit-1){
        str = str+"-";
      }
    }
    return str;
  }
  String getGenomeStringLengthened(){
    if(codons.size() == 20){
      return getGenomeString();
    }else{
      return getGenomeString()+"-00";
    }
  }
}
