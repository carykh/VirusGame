class Codon extends CodonPair{ //this includes health
  //id 0 = kind of colon
  
  
  
  double codonHealth = 1;
  
  
  public Codon(CodonPair codon) {
    super(codon);
  }
  
  public Codon(CodonType type, CodonAttribute attribute){
    super(type, attribute);
  }
  
  
  public color getColor(int p){
    return intToColor( p == 0? type.getColor():attribute.getColor()); //for leg support
    //return intToColor(CodonInfo.getColor(p,codonInfo[p]));
  }
  public color getTextColor(int p){
    return intToColor(p == 0? type.getTextColor():attribute.getTextColor()); //for leg support
  }
  public String getText(int p){
    return p == 0? type.getName():attribute.getName(); //for leg support
  }
  public boolean hasSubstance(){
    return ((!(type instanceof CodonNone)) || (!(attribute instanceof AttributeNone))); //probably whether this codon can get hurt?
  }
  public void hurt(){
    if(hasSubstance()){
      codonHealth -= Math.random()*CODON_DEGRADE_SPEED;
      if(codonHealth <= 0){
        codonHealth = 1;
        
        type = CodonTypes.None.v;
        attribute = CodonAttributes.None.v;
      }
    }
  }
  public void setFullInfo(int[] info){
    CodonPair data = fromIntList(info); 
    this.type = data.type;
    this.attribute = data.attribute;
    codonHealth = 1.0;
  }
  
  public void setType(CodonType type) {
     this.type= type; 
  }
  
  public void setAttribute(CodonAttribute attribute) {
     this.attribute= attribute; 
  }
  
  public void exec(Cell cell) {
    type.exec(cell, attribute);
  }
}

static CodonPair fromIntList(int[] ints) {
  CodonType type = CodonTypes.values()[ints[0]].v;
  CodonAttribute att = CodonAttributes.values()[ints[1]].v;
  if (att == CodonAttributes.RGL00.v && ints[2] != 0 && ints[3]!=0) {
     att = new AttributeRGL(ints[2], ints[3]);
  }
  println(type + " " + att);
  return new CodonPair(type, att);
}

static class CodonPair{//just information 
  protected CodonType type;
  protected CodonAttribute attribute;
  
  public CodonPair(CodonPair codon) {
    this(codon.type, codon.attribute);
  }
  
  public CodonPair(CodonType type, CodonAttribute attribute){
    this.type = type;
    this.attribute = attribute;
  }
  

  public CodonType getType() {
    return type;
  }
  
  public CodonAttribute getAttribute() {
    return attribute;
  }
  
}

enum CodonTypes{
  None(new CodonNone()),
  Digest(new CodonDigest()),
  Remove(new CodonRemove()),
  Repair(new CodonRepair()),
  MoveHand(new CodonMoveHand()),
  Read(new CodonRead()),
  Write(new CodonWrite());

  
  public final CodonType v;
  private CodonTypes(CodonType value) {
    this.v = value; 
  }
}


  //  static String[][] names = {{"none","digest","remove","repair","move hand","read","write"},  {"none","food","waste","wall","weak loc","inward","outward","RGL","- RGL start +","- RGL end +"}};
enum CodonAttributes{
  None(new AttributeNone()),
  Food(new AttributeFood()),
  Waste(new AttributeWaste()),
  Wall(new AttributeWall()),
  WeakLoc(new AttributeWeakLoc()),
  Inward(new AttributeInward()),
  Outward(new AttributeOutward()),
  RGL00(new AttributeRGL(0, 0));

  
  public final CodonAttribute v;
  private CodonAttributes(CodonAttribute value) {
    this.v = value; 
  }
}


static class CommonBase {
     int id;
  int[]  backColor;
  int[]  textColor;
  String name;
  CodonAttribute attribute;
  
  public CommonBase(int id, int[] backColor, int[] textColor, String name){
    this.id= id;
    this.backColor = backColor;
    this.textColor = textColor;
    this.name = name;
  } 
  
    public int[]  getColor(){
    return backColor;
  }
  public int[]  getTextColor(){
    return textColor;
  }
  public String getName(){
    return name;
  }
  
  
  public String toString() {
    return getName();
  }
}

static int[] c(int v1, int v2, int v3) {
    if (v1 > 255) v1 = 255; else if (v1 < 0) v1 = 0;
    if (v2 > 255) v2 = 255; else if (v2 < 0) v2 = 0;
    if (v3 > 255) v3 = 255; else if (v3 < 0) v3 = 0;

    return new int[]{v1,v2,v3};
}

static class CodonType extends CommonBase {
  
  public CodonType(int id, int[] backColor, int[] textColor, String name){
    super(id, backColor, textColor, name); 
  }
  
  
  public void exec(Cell cell, CodonAttribute attribute) {
    //noOP
  }
}
static class CodonAttribute extends CommonBase {
  
  public CodonAttribute(int id, int[] backColor, int[] textColor, String name){
    super(id, backColor, textColor, name); 
  }
  
}

  //public void doAction(){
  //  useEnergy();
  //  Codon thisCodon = genome.codons.get(genome.rotateOn);
  //  int[] info = thisCodon.codonInfo;
  //  if(info[0] == 1 && genome.directionOn == 0){
  //    if(info[1] == 1 || info[1] == 2){
  //      Particle foodToEat = selectParticleInCell(info[1]-1); // digest either "food" or "waste".
  //      if(foodToEat != null){
  //        eat(foodToEat);
  //      }
  //    }else if(info[1] == 3){ // digest "wall"
  //      energy += (1-energy)*E_RECIPROCAL*0.2;
  //      hurtWall(26);
  //      laserWall();
  //    }
  //  }else if(info[0] == 2 && genome.directionOn == 0){
  //    if(info[1] == 1 || info[1] == 2){
  //      Particle wasteToPushOut = selectParticleInCell(info[1]-1);
  //      if(wasteToPushOut != null){
  //        pushOut(wasteToPushOut);
  //      }
  //    }else if(info[1] == 3){
  //      die();
  //    }
  //  }else if(info[0] == 3 && genome.directionOn == 0){
  //    if(info[1] == 1 || info[1] == 2){
  //      Particle particle = selectParticleInCell(info[1]-1);
  //      shootLaserAt(particle);
  //    }else if(info[1] == 3){
  //      healWall();
  //    }
  //  }else if(info[0] == 4){
  //    if(info[1] == 4){
  //      genome.performerOn = genome.getWeakestCodon();
  //    }else if(info[1] == 5){
  //      genome.directionOn = 1;
  //    }else if(info[1] == 6){
  //      genome.directionOn = 0;
  //    }else if(info[1] == 7){
  //      genome.performerOn = loopItInt(genome.rotateOn+info[2],genome.codons.size());
  //    }
  //  }else if(info[0] == 5 && genome.directionOn == 1){
  //    if(info[1] == 7){
  //      readToMemory(info[2],info[3]);
  //    }
  //  }else if(info[0] == 6){
  //    if(info[1] == 7 || genome.directionOn == 0){
  //      writeFromMemory(info[2],info[3]);
  //    }
  //  }
  //  genome.hurtCodons();
  //}
  
  //  static String[][] names = {{"none","digest","remove","repair","move hand","read","write"},  {"none","food","waste","wall","weak loc","inward","outward","RGL","- RGL start +","- RGL end +"}};
  
  //{{color(0, 0, 0),color(100, 0, 200),color(180, 160, 10),
  //color(0, 150, 0),color(200, 0, 100),color(70, 70, 255),
  //color(0, 0, 220)},
  //{color(0, 0, 0),color(200, 50, 50),color(100, 65, 0),color(160, 80, 160),
  //color(80, 180, 80),color(0, 100, 100),
  //color(0, 200, 200),color(140, 140, 140),color(90, 90, 90),color(90, 90, 90)}};
  
static class AttributeNone extends CodonAttribute {
  public AttributeNone() {
    super(0, c(0,0,0), c(255,255,255), "none"); 
  }
}   
static class AttributeParticle extends CodonAttribute {
  ParticleType particle;
  
  public AttributeParticle(int id, int[] backColor, int[] textColor, ParticleType particle) {
    super(id, backColor, textColor, particle.toString()); 
    this.particle = particle;
  }
  
  public ParticleType getParticle() {
   return particle; 
  }
} 
static class AttributeFood extends AttributeParticle {
  public AttributeFood() {
    super(1, c(200, 50, 50), c(255,255,255), ParticleType.Food); 
  }
} 
static class AttributeWaste extends AttributeParticle {
  public AttributeWaste() {
    super(2, c(100, 65, 0), c(255,255,255), ParticleType.Waste); 
  }
} 
static class AttributeWall extends CodonAttribute {
  public AttributeWall() {
    super(3, c(160, 80, 160), c(255,255,255), "wall"); 
  }
} 
static class AttributeGenomeCursor extends CodonAttribute {
  public AttributeGenomeCursor(int id, int[] backColor, int[] textColor, String name) {
    super(id, backColor, textColor, name); 
  }
  
  public void setCursor(Genome genome) {//noOP
}
} 
static class AttributeGenomeCursorDirection extends AttributeGenomeCursor {
  boolean inwards;
  
  public AttributeGenomeCursorDirection(int id, int[] backColor, int[] textColor, String name, boolean inwards) {
    super(id, backColor, textColor, name); 
    this.inwards = inwards;
  }
  
  public boolean isInwards() {
     return inwards; 
  }
    
    
  public void setCursor(Genome genome) {
    genome.directionOn = isInwards()?1:0;
  }
} 

static class AttributeGenomeLoc extends AttributeGenomeCursor {
  int loc;
  
  public AttributeGenomeLoc(int id, int[] backColor, int[] textColor, String name, int loc) {
    super(id,backColor, textColor, name); 
    this.loc = loc;
  }
  
  
  public int getLocation() {return getLocation(null);}
  public int getLocation(Genome genome) {
     return loc; 
  }
    
    
  public void setCursor(Genome genome) {
    genome.performerOn = loopItInt(genome.rotateOn+getLocation(genome),genome.codons.size());
  }
  
  public String toString() {
    return name + "(loc=" + loc + ")";
  }
} 

static class AttributeGenomeRange extends AttributeGenomeLoc {
  int end;
  
  public AttributeGenomeRange(int id, int[] backColor, int[] textColor, String name, int start, int end) {
    super(id, backColor, textColor, name, start); 
    this.end = end;
  }
  
  
  public int getStartLocation() {return getStartLocation(null);}
  
  public int getStartLocation(Genome genome) {
     return getLocation(genome); 
  }
  
  
  public int getEndLocation() {return getEndLocation(null);}
  public int getEndLocation(Genome genome) {
     return end; 
  }
  
  
  public String toString() {
    return name + "(start=" + loc + " ,end=" + end + ")";
  }
} 
static class AttributeWeakLoc extends AttributeGenomeLoc {
  public AttributeWeakLoc() {
    super(4, c(80, 180, 80), c(255,255,255), "weak loc", -1); //-1 is a placehoder
  }
  
  public int getLocation(Genome genome) {
     return genome==null?-1:genome.getWeakestCodon(); 
  }
} 
static class AttributeInward extends AttributeGenomeCursorDirection {
  public AttributeInward() {
    super(5, c(0, 100, 100), c(255,255,255), "inward", true); 
  }
} 
static class AttributeOutward extends AttributeGenomeCursorDirection {
  public AttributeOutward() {
    super(6, c(0, 200, 200), c(255,255,255), "outward", false); 
  }
} 
static class AttributeRGL extends AttributeGenomeRange {
  public AttributeRGL(int start, int end) {
    super(7, c(140, 140, 140), c(255,255,255), "RGL", start, end); 
  }
  
} 
static class Attribute extends CodonAttribute {
  public Attribute() {
    super(0, c(255,255,255), c(255,255,255), ""); 
  }
} 
  
  
  
  
  
  
    //public void doAction(){
  //  useEnergy();
  //  Codon thisCodon = genome.codons.get(genome.rotateOn);
  //  int[] info = thisCodon.codonInfo;
  //  if(info[0] == 1 && genome.directionOn == 0){
  //    if(info[1] == 1 || info[1] == 2){
  //      Particle foodToEat = selectParticleInCell(info[1]-1); // digest either "food" or "waste".
  //      if(foodToEat != null){
  //        eat(foodToEat);
  //      }
  //    }else if(info[1] == 3){ // digest "wall"
  //      energy += (1-energy)*E_RECIPROCAL*0.2;
  //      hurtWall(26);
  //      laserWall();
  //    }
  //  }else if(info[0] == 2 && genome.directionOn == 0){
  //    if(info[1] == 1 || info[1] == 2){
  //      Particle wasteToPushOut = selectParticleInCell(info[1]-1);
  //      if(wasteToPushOut != null){
  //        pushOut(wasteToPushOut);
  //      }
  //    }else if(info[1] == 3){
  //      die();
  //    }
  //  }else if(info[0] == 3 && genome.directionOn == 0){
  //    if(info[1] == 1 || info[1] == 2){
  //      Particle particle = selectParticleInCell(info[1]-1);
  //      shootLaserAt(particle);
  //    }else if(info[1] == 3){
  //      healWall();
  //    }
  //  }else if(info[0] == 4){
  //    if(info[1] == 4){
  //      genome.performerOn = genome.getWeakestCodon();
  //    }else if(info[1] == 5){
  //      genome.directionOn = 1;
  //    }else if(info[1] == 6){
  //      genome.directionOn = 0;
  //    }else if(info[1] == 7){
  //      genome.performerOn = loopItInt(genome.rotateOn+info[2],genome.codons.size());
  //    }
  //  }else if(info[0] == 5 && genome.directionOn == 1){
  //    if(info[1] == 7){
  //      readToMemory(info[2],info[3]);
  //    }
  //  }else if(info[0] == 6){
  //    if(info[1] == 7 || genome.directionOn == 0){
  //      writeFromMemory(info[2],info[3]);
  //    }
  //  }
  //  genome.hurtCodons();
  //}
  
//Define all Types
static class CodonNone extends CodonType {
  public CodonNone() {
    super(0, c(0,0,0), c(255,255,255), "none"); 
  }
  
  public void exec(Cell cell, CodonAttribute attribute) {
    //noOP
  }
}
static class CodonDigest extends CodonType {
  public CodonDigest() {
    super(1, c(180,160,10), c(255,255,255), "digest"); 
  }
  
  public void exec(Cell cell, CodonAttribute attribute) {
    if (cell.genome.directionOn == 0) {
      if (attribute instanceof AttributeParticle) {
        Particle foodToEat = cell.selectParticleInCell(((AttributeParticle)attribute).getParticle().ordinal()); // digest either "food" or "waste". (now even NGO is possible!! no attribute for that yet tho)
        if(foodToEat != null){
          cell.eat(foodToEat);
        }
      } else if (attribute instanceof AttributeWall) {
        cell.energy += (1-cell.energy)*E_RECIPROCAL*0.2;
        cell.hurtWall(26);
        cell.laserWall();
      }
    }
  }
}
static class CodonRemove extends CodonType {
  public CodonRemove() {
    super(2, c(180, 160, 10), c(255,255,255), "remove"); 
  }
  
  public void exec(Cell cell, CodonAttribute attribute) {
    if (cell.genome.directionOn == 0) {
      if (attribute instanceof AttributeParticle) {
        Particle wasteToPushOut = cell.selectParticleInCell(((AttributeParticle)attribute).getParticle().ordinal()); // pushes out either "food" or "waste". (now even NGO is possible!! no attribute for that yet tho)
        if(wasteToPushOut != null){
          cell.pushOut(wasteToPushOut);
        }
      } else if (attribute instanceof AttributeWall) {
        cell.die();
      }      
    }
  }
}
static class CodonRepair extends CodonType {
  public CodonRepair() {
    super(3, c(0, 150, 0), c(255,255,255), "repair"); 
  }
  
  public void exec(Cell cell, CodonAttribute attribute) {
    if (cell.genome.directionOn == 0) {
      if (attribute instanceof AttributeParticle) {
        Particle particle = cell.selectParticleInCell(((AttributeParticle)attribute).getParticle().ordinal());
        if(particle != null){
          cell.shootLaserAt(particle);
        }
      } else if (attribute instanceof AttributeWall) {
        cell.healWall();
      }      
    }
  }
}
static class CodonMoveHand extends CodonType {
  public CodonMoveHand() {
    super(4, c(200, 0, 100), c(255,255,255), "move hand"); 
  }
  
  public void exec(Cell cell, CodonAttribute attribute) {
    Genome genome = cell.genome;
    if(attribute instanceof AttributeGenomeCursor){
      ((AttributeGenomeCursor)attribute).setCursor(genome);
    }
  }
}
static class CodonRead extends CodonType {
  public CodonRead() {
    super(5, c(70, 70, 255), c(255,255,255), "read"); 
  }
  
  public void exec(Cell cell, CodonAttribute attribute) {
    Genome genome = cell.genome;
    if (attribute instanceof AttributeGenomeRange) {
      AttributeGenomeRange range = (AttributeGenomeRange)attribute;
      cell.readToMemory(range.getStartLocation(genome), range.getEndLocation(genome));
    }
  }
}
static class CodonWrite extends CodonType {
  public CodonWrite() {
    super(6, c(0, 0, 220), c(255,255,255), "write"); 
  }
  
  public void exec(Cell cell, CodonAttribute attribute) {
    Genome genome = cell.genome;
    if (attribute instanceof AttributeGenomeRange) {
      AttributeGenomeRange range = (AttributeGenomeRange)attribute;
      cell.writeFromMemory(range.getStartLocation(genome), range.getEndLocation(genome));
    } else {
      cell.writeFromMemory(0, 0); 
    }
  }
}
