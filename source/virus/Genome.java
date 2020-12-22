package virus;

import java.util.ArrayList;

import static virus.Codon.fromIntList;
import static processing.core.PApplet.*;
import static virus.Codon.memoryIdColor;
import static virus.Const.*;
import static virus.Var.*;
import static virus.Method.*;
import static virus.Util.*;
import static java.lang.Math.PI;

public class Genome {

  int ZERO_CH = (int)('0');

 public boolean isUGO;
  ArrayList<Codon> codons;
 public int rotateOn = 0;
 public int rotateOnNext = 1;
 public int performerOn = 0;
 public boolean inwards = false;
 public double appRO = 0;
 public double appPO = 0;
 public double appDO = 0;
 public int scrollOffset = 0;

  public Genome(String s, boolean isUGOp){
    codons = new ArrayList<Codon>();
    String[] parts = s.split("-");
    for (int i = 0; i < parts.length; i++) {
      int[] info =stringToInfo(parts[i]);
      codons.add(new Codon(fromIntList(info)));
    }
    appRO = 0;
    appPO = 0;
    appDO = 0;
    isUGO = isUGOp;
  }

  public Codon getSelected() {
    if( codons.size() == 0 ) {
      return Codon.EMPTY;
    }
    rotateOn = loopAroundGenome(rotateOn); //in case it got deleted
    return codons.get(rotateOn);
  }

  /*public void next() {
      rotateOn = rotateOnNext % codons.size();
  }*/

  public void mutate( double m ) {

    while( m > random(0, 1) ) {

      if( random(0, 1) < 0.3 && codons.size() > 1 ) { // delete
        codons.remove( (int) random( 0, codons.size() ) );
        return;
      }

      if( random(0, 1) < 0.4 ) { // replace
        codons.set( (int) random( 0, codons.size() ), Codon.createRandom() );
        return;
      }

      if( random(0, 1) < 0.5 ) { // add
        codons.add( Codon.createRandom());
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
      appRO +=loopIt(rotateOn - appRO, s, true) * VISUAL_TRANSITION * PLAY_SPEED;
      appPO +=loopIt(performerOn - appPO, s, true) * VISUAL_TRANSITION * PLAY_SPEED;
      appDO += ((inwards?1:0) - appDO) * VISUAL_TRANSITION * PLAY_SPEED;
      appRO =loopIt(appRO, s, false);
      appPO =loopIt(appPO, s, false);
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
    stroke(transperize(HAND_COLOR, 0.5));
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
    return loopItInt(i, codons.size());
  }

  public void drawCodons() {

    final int size = codons.size();
    final float codonAngle = 1.0f / max(2, size) * TWO_PI;
    final float partAngle = codonAngle / 5.0f;
    final float codonDist = (float) (isUGO ? CODON_DIST_UGO : CODON_DIST);

    for (int i = 0; i < codons.size(); i++) {
      pushMatrix();
      rotate(-HALF_PI + i * codonAngle);

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
              float[] cv = epigeneticsMiddleShape[v];
              float ang = cv[0] * partAngle * (float)c.codonHealth;
              float dist = cv[1] * CODON_WIDTH + codonDist;

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
              float[] cv = epigeneticsShape[v];
              float ang = cv[0] * partAngle * (float)c.codonHealth;
              float dist = cv[1] * CODON_WIDTH + codonDist;
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
          float[] cv = epigeneticsShape[v];
          float ang = -cv[0] * partAngle * (float)c.codonHealth;
          float dist = cv[1] * CODON_WIDTH + codonDist;
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
          final float ang = cv[0] * partAngle * (float)c.codonHealth;
          final float dist = cv[1] * (2 * p - 1) * CODON_WIDTH + codonDist;
          vertex(cos(ang) * dist, sin(ang) * dist);
        }
        endShape(CLOSE);
      }

      popMatrix();
    }

  }

  void hurtCodons(Cell cell) {
    for (int i = 0; i < codons.size(); i++) {
      Codon c = codons.get(i);
      if (c.hasSubstance()) {
        if(c.hurt()) {
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
      str = str +infoToString(c);
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
      str = str +infoToString(c);
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
