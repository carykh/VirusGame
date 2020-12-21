
double VISUAL_TRANSITION = 0.38;
        float HAND_DIST = 32;
        float HAND_LEN = 7;
        double[][] codonShape = {{-2,0},{-2,2},{-1,3},{0,3},{1,3},{2,2},{2,0},{0,0}};
        double[][] telomereShape = {{-2,2},{-1,3},{0,3},{1,3},{2,2},{2,-2},{1,-3},{0,-3},{-1,-3},{-2,-2}};
        double[][] epigeneticsShape = {{1.5, 2}, {1.5, 4}, {1.75, 4.2}, {2, 4}, {3, 3.33}, {2.5, 3}, {2, 2.66}, {2, 2}, {1.75, 2}};
        double[][] epigeneticsMiddleShape = {{-0.5, 2.8}, {-0.3, 3.2}, {-0.2, 3.6}, {-0.1, 3.8}, {0, 3.8}, {0.1, 3.8}, {0.2, 3.6}, {0.3, 3.2}, {0.5, 2.8}, {0, 3}};


class Genome {

  int ZERO_CH = (int)('0');
  
  boolean isUGO;
  ArrayList<Codon> codons;
  int rotateOn = 0;
  int rotateOnNext = 1;
  int performerOn = 0;
  boolean inwards = false;
  double appRO = 0;
  double appPO = 0;
  double appDO = 0;
  int scrollOffset = 0;

  public Genome(String s, boolean isUGOp){
    codons = new ArrayList<Codon>();
    String[] parts = s.split("-");
    for (int i = 0; i < parts.length; i++) {
      int[] info = util.stringToInfo(parts[i]);
      codons.add(new Codon(fromIntList(info)));
    }
    appRO = 0;
    appPO = 0;
    appDO = 0;
    isUGO = isUGOp;
    if (isUGO) {
      CODON_DIST = 10.6;
    }
  }

public Codon getSelected() {
    if( codons.size() == 0 ) {
      return Codon.Empty;
    }
      return codons.get(rotateOn);
  }

  /*public void next() {
      rotateOn = rotateOnNext % codons.size();
  }*/

  public void mutate( double m ) {

    if( m > random(0, 1) ) {

      if( random(0, 1) < 0.3 && codons.size() > 1 ) { // delete
        codons.remove( (int) random( 0, codons.size() ) );
        return;
      }

      if( random(0, 1) < 0.4 ) { // replace
        codons.set( (int) random( 0, codons.size() ), new Codon() );
        return;
      }

      if( random(0, 1) < 0.5 ) { // add
        codons.add( new Codon() );
        return;
      }

      if( random(0, 1) < 0.6 ) { // swap

        int a = (int) random( 0, codons.size() );
        int b = (int) random( 0, codons.size() );

        if( a != b ) {

          Codon ca = codons.get(a);
          Codon cb = codons.get(b);

          codons.set(a, cb);
          codons.set(b, ca);
          return;

        }

      }

    }

  }

  public void update() {

    int s = codons.size();
    if( s != 0 ) {
      appRO += util.loopIt(rotateOn - appRO, s, true) * VISUAL_TRANSITION * PLAY_SPEED;
      appPO += util.loopIt(performerOn - appPO, s, true) * VISUAL_TRANSITION * PLAY_SPEED;
      appDO += ((inwards?1:0) - appDO) * VISUAL_TRANSITION * PLAY_SPEED;
      appRO = util.loopIt(appRO, s, false);
      appPO = util.loopIt(appPO, s, false);
    } else {
      appRO = 0;
      appPO = 0;
    }
  }

  public void drawHand() {
    double appPOAngle = (float) (appPO * 2 * PI / codons.size());
    double appDOAngle = (float) (appDO * PI);
    strokeWeight(1);
    noFill();
    stroke(util.transperize(HAND_COLOR, 0.5));
    ellipse(0, 0, HAND_DIST * 2, HAND_DIST * 2);
    pushMatrix();
    rotate((float) appPOAngle);
    translate(0, -HAND_DIST);
    rotate((float) appDOAngle);
    noStroke();
    fill(HAND_COLOR);
    beginShape();
    vertex(5, 0);
    vertex(-5, 0);
    vertex(0, -HAND_LEN);
    endShape(CLOSE);
    popMatrix();
  }

  public int loopAroundGenome(int i) {
    return util.loopItInt(i, codons.size());
  }

  public void drawCodons() {

    final int size = codons.size();
    final float codonAngle = 1.0f / max(3, size) * TWO_PI;
    final float partAngle = codonAngle / 5.0f;
    final float codonDist = (float) (isUGO ? CODON_DIST_UGO : CODON_DIST);

    for (int i = 0; i < codons.size(); i++) {
      float angleMulti = codons.size() == 2 && i == 1 ? 2 : i; //special case 2 codons
      if (codons.size() == 3) angleMulti *= 4 / 3.0; //special case 3 codons
      pushMatrix();
      rotate( -HALF_PI + angleMulti * CODON_ANGLE);

      Codon c = codons.get(i);

      //used up codons
      if (c.codonHealth < 0.97) {
        beginShape();
        fill(TELOMERE_COLOR);
        for (int v = 0; v < TELOMERE_SHAPE.length; v++) {
          final float[] cv = TELOMERE_SHAPE[v];
          final float ang = cv[0] * partAngle;
          final float dist = cv[1] * CODON_WIDTH + codonDist;
          vertex(cos(ang) * dist, sin(ang) * dist);
        }
        endShape(CLOSE);
      }


      //epigenetics

      boolean flagMiddleEpiSet = false;
      boolean flagStartEpiSet = false;
      for (int mf : c.memorySetFrom) {
        fill(memoryIdColor(mf));
        if (c.memorySetTo.contains(mf)) {
          if (!flagMiddleEpiSet) {
            flagMiddleEpiSet = true;
            float[] ellipseData = new float[6];
            beginShape();
            for (int v = 0; v < epigeneticsMiddleShape.length; v++) {
              double[] cv = epigeneticsMiddleShape[v];
              double ang = cv[0] * partAngle * c.codonHealth;
              double dist = cv[1] * CODON_WIDTH + codonDist;

              float x = (float) (Math.cos(ang) * dist);
              float y = (float) (Math.sin(ang) * dist);
              vertex(x, y);
              if (v >= 3 && v <= 5) {
                int index = (v - 3) * 2;
                ellipseData[index + 0] = x;
                ellipseData[index + 1] = y;
              }
            }
            endShape(CLOSE);
            float diameter = sqrt((ellipseData[0] - ellipseData[4]) * (ellipseData[0] - ellipseData[4]) + (ellipseData[1] - ellipseData[5]) * (ellipseData[1] - ellipseData[5]));
            noStroke();
            ellipseMode(CENTER);
            ellipse(ellipseData[2], ellipseData[3], diameter * 3, diameter * 3);
          }
        } else {
          if (!flagStartEpiSet) {

            beginShape();
            flagStartEpiSet = true;
            for (int v = 0; v < epigeneticsShape.length; v++) {
              double[] cv = epigeneticsShape[v];
              double ang = cv[0] * partAngle * c.codonHealth;
              double dist = cv[1] * CODON_WIDTH + codonDist;
              vertex((float) (Math.cos(ang) * dist), (float) (Math.sin(ang) * dist));
            }
            endShape(CLOSE);
          }
        }
        if (flagMiddleEpiSet && flagStartEpiSet) break; //really only care for the first one for each case
      }

      for (int mf : c.memorySetTo) {
        if (c.memorySetFrom.contains(mf)) {
          continue;
        }
        fill(memoryIdColor(mf));
        beginShape();
        for (int v = 0; v < epigeneticsShape.length; v++) {
          double[] cv = epigeneticsShape[v];
          double ang = -cv[0] * partAngle * c.codonHealth;
          double dist = cv[1] * CODON_WIDTH + codonDist;
          vertex((float) (Math.cos(ang) * dist), (float) (Math.sin(ang) * dist));
        }
        endShape(CLOSE);
        break; //really only care for the first one
      }


      //codons
      for (int p = 0; p < 2; p++) {
        beginShape();
        fill(c.getColor(p));
        for (int v = 0; v < CODON_SHAPE.length; v++) {
          final float[] cv = CODON_SHAPE[v];
          final float ang = cv[0] * partAngle * c.codonHealth;
          final float dist = cv[1] * (2 * p - 1) * CODON_WIDTH + codonDist;
          vertex(cos(ang) * dist, sin(ang) * dist);
        }
        endShape(CLOSE);
      }
    }

    popMatrix();
  }

        }

    }

    void hurtCodons( Cell cell) {
    for (int i = 0; i < codons.size(); i++) {
      Codon c = codons.get(i);
      if (c.hasSubstance()) {
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

  int getWeakestCodon() {
    double record = 9999;
    int holder = -1;
    for (int i = 0; i < codons.size(); i++) {
      double val = codons.get(i).codonHealth;
      if (val < record) {
        record = val;
        holder = i;
      }
    }
    return holder;
  }

  String getGenomeString() {
    String str = "";
    for (int i = 0; i < codons.size(); i++) {
      Codon c = codons.get(i);
      str = str + util.infoToString(c);
      if (i < codons.size() - 1) {
        str = str + "-";
      }
    }
    return str;
  }

  String getGenomeStringShortened() {
    int limit = max(1, codons.size() - 1);
    String str = "";
    for (int i = 0; i < limit; i++) {
      Codon c = codons.get(i);
      str = str + util.infoToString(c);
      if (i < limit - 1) {
        str = str + "-";
      }
    }
    return str;
  }

  String getGenomeStringLengthened() {
    if (codons.size() == 20) {
      return getGenomeString();
    } else {
      return getGenomeString() + "-00";
    }
  }
}
