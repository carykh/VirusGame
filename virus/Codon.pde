class Codon extends CodonPair{ //this includes health
  //id 0 = kind of colon
  
  
  
  double codonHealth = 1;
  
  
  public Codon() {
    super(CodonTypes.None.v, CodonAttributes.None.v);
  }
  
  
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
    return p == 0? type.getTextSimple():attribute.getTextSimple(); //for leg support
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
     this.type= type.clone(); 
  }
  
  public void setAttribute(CodonAttribute attribute) {
     this.attribute= attribute.clone(); 
  }
  
  public boolean exec(Cell cell) {
    return type.exec(cell, attribute);
  }
}

static CodonPair fromIntList(int[] ints) {
  CodonType type = CodonTypes.values()[ints[0]].v;
  CodonAttribute att = CodonAttributes.values()[ints[1]].v;
  
  
  CodonPair result = new CodonPair(type, att);
  
  //important to only edit the cloned ones from the result!
  int offset = result.type.processExtra(ints, 2);
  result.attribute.processExtra(ints, 2);
  return result;
}

static class CodonPair{//just information 
  protected CodonType type;
  protected CodonAttribute attribute;
  
  public CodonPair(CodonPair codon) {
    this(codon.type, codon.attribute);
  }
  
  public CodonPair(CodonType type, CodonAttribute attribute){
    this.type = type.clone();
    this.attribute = attribute.clone();
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
  Write(new CodonWrite()),
  Goto(new CodonGoto()),
  MemTo(new CodonMemorizeTo()),
  CondGoto(new CodonCondGoto()),
  Compare(new CodonCompare()),
  FindMarker(new CodonFindMarker()),
  CondMark(new CodonCondMark()),
  Exists(new CodonExists());
  
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
  RGL00(new AttributeRGL(0, 0)),
  UGO(new AttributeUGO()),
  MemoryLocation( new AttributeMemoryLocation(0)),
  Mark(new AttributeMark(0)),
  Cursor(new AttributeCursor());

  
  public final CodonAttribute v;
  private CodonAttributes(CodonAttribute value) {
    this.v = value; 
  }
}


static class CommonBase implements Cloneable {
  int id;
  int[]  backColor;
  int[]  textColor;
  String name;
  
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
  
    public  String getTextSimple(){ 
    String result = getName().toUpperCase();
    return result;
  }
  
  public CommonBase clone() {
    try {
      return (CommonBase)super.clone(); 
    } catch(CloneNotSupportedException e) {return null;}
  }
  
  public boolean equals(Object o) {
    return o instanceof CommonBase && ((CommonBase)o).id == id;
  }
  
  public String saveExtra() {return "";}
  
  public int processExtra(int[] data, int offset) {
    return offset; 
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
  
  public CodonType clone() {
    return (CodonType)super.clone(); 
  }
 
  public boolean exec(Cell cell, CodonAttribute attribute) {
    return false;
    //noOP
  }
}
static class CodonAttribute extends CommonBase {
  
  public CodonAttribute(int id, int[] backColor, int[] textColor, String name){
    super(id, backColor, textColor, name); 
  }
  
  public CodonAttribute clone() {
    return (CodonAttribute)super.clone(); 
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
static class AttributeUGO extends AttributeParticle {
  public AttributeUGO() {
    super(8, c(158, 28, 128), c(255,255,255), ParticleType.UGO); 
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
  
  public void setCursor(Cell cell) {//noOP
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
    
    
  public void setCursor(Cell cell) {
    cell.genome.directionOn = isInwards()?1:0;
  }
} 

static class AttributeGenomeLoc extends AttributeGenomeCursor {
  int loc;
  boolean isRelative;
  
  public AttributeGenomeLoc(int id, int[] backColor, int[] textColor, String name, int loc, boolean isRelative) {
    super(id,backColor, textColor, name); 
    this.loc = loc;
    this.isRelative = isRelative;
  }
  
  
  public int getLocation() {return getLocation(null);}
  public int getLocation(Cell cell) {
     return loc; 
  }
    
    
  public void setCursor(Cell cell) {
    cell.genome.performerOn = getAbsoluteLoc(cell, false);
    cell.lastRange = new AbsoluteRange(cell.genome.performerOn, 0); 
  }
  
  public int getAbsoluteLoc(Cell cell, boolean cursor) {
    return  getAbsoluteLoc(cell, cursor, 0);
  }
  public int getAbsoluteLoc(Cell cell, boolean cursor, int extraRelative) {
    int result = isRelative?(cursor?cell.genome.rotateOn:cell.genome.performerOn)+getLocation(cell):getLocation(cell);
    result += extraRelative;
    return cell.genome.loopAroundGenome(result);
  }
  
  public String toString() {
    return name + "(loc=" + loc + ")";
  }
} 

static class AttributeGenomeRange extends AttributeGenomeLoc {
  int end;
  
  public AttributeGenomeRange(int id, int[] backColor, int[] textColor, String name, int start, int end, boolean isRelative) {
    super(id, backColor, textColor, name, start, isRelative); 
    this.end = end;
  }
  
  
  public int getStartLocation() {return getStartLocation(null);}
  
  public int getStartLocation(Cell cell) {
     return getLocation(cell); 
  }
  
  
  public int getEndLocation() {return getEndLocation(null);}
  public int getEndLocation(Cell cell) {
     return end; 
  }
    
  public String toString() {
    return name + "(start=" + loc + " ,end=" + end + ")";
  }
} 
static class AttributeWeakLoc extends AttributeGenomeLoc {
  public AttributeWeakLoc() {
    super(4, c(80, 180, 80), c(255,255,255), "weak loc", -1, false); //-1 is a placehoder
  }
  
  public int getLocation(Cell cell) {
     return cell==null?-1:cell.genome.getWeakestCodon(); 
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
    super(7, c(140, 140, 140), c(255,255,255), "RGL", start, end, true); 
  }
  
  public  String getTextSimple(){ 
    return super.getTextSimple()+ " ("+loc+" to "+end+")";
  }
  
  
  
  public boolean equals(Object o) {
    AttributeRGL rgl;
    return o instanceof AttributeRGL &&  super.equals(o) && (rgl=((AttributeRGL)o)).loc == loc && rgl.end == end;
  }
  
  public String saveExtra() {
    return "" +  codonValToChar(loc) + codonValToChar(end);
  }
  
  public int processExtra(int[] data, int offset) {
    loc = data[offset++];
    end = data[offset++];
    return offset; 
  }
  
} 
static class AbsoluteRange{
   int start;
   int length;
   public AbsoluteRange(int start, int length) {
      this.start = start;
      this.length = length;
   }
   
   public int getEnd() {
     return start+length; 
   }
   
   public int getEndResolved(Genome genome) {
     return genome.loopAroundGenome(getEnd()); 
   }
   
   public String toString() {
     return start + ", " + length;
   }
}
static class AttributeMemoryLocation extends AttributeGenomeRange {
  int memoryId;
  public AttributeMemoryLocation(int memoryId) {
    super(9, c(255,0,255), c(255,255,255), "MemLoc", -1, -1, false); //-1 is a placehoder
    this.memoryId = memoryId;
  }
  
  public int getLocation(Cell cell) {
    if (cell == null) return 0;
     AbsoluteRange r =  cell.rangeMemory.get(memoryId);
     return r==null?0:r.start; 
  }
  
  
  public int getEndLocation(Cell cell) {
    if (cell == null) return 0;
     AbsoluteRange r =  cell.rangeMemory.get(memoryId);
     return r==null?0:r.getEnd(); 
  }
  
  
  public  String getTextSimple(){ 
    return super.getTextSimple()+ " ("+memoryId+")";
  }
  
    
  public boolean equals(Object o) {
    return o instanceof AttributeMemoryLocation &&  super.equals(o) && ((AttributeMemoryLocation)o).memoryId == memoryId;
  }
  
  public String saveExtra() {
    return "" + codonValToChar(memoryId);
  }
  
  public int processExtra(int[] data, int offset) {
    memoryId = data[offset++];
    return offset; 
  }
  
  public boolean exists(Cell cell) {
    return cell.rangeMemory.containsKey(memoryId);
  }
  
} 

static class AttributeMark extends CodonAttribute {
  int markId;
  public AttributeMark(int markId) {
    super(10, c(0,200,200), c(255,255,255), "Mark"); //-1 is a placehoder
    this.markId = markId;
  }
  
  
  public  String getTextSimple(){ 
    return super.getTextSimple()+ " ("+markId+")";
  }
  
    
  public boolean equals(Object o) {
    return o instanceof AttributeMark &&  super.equals(o) && ((AttributeMark)o).markId == markId;
  }
  
  public String saveExtra() {
    return "" + codonValToChar(markId);
  }
  
  public int processExtra(int[] data, int offset) {
    markId = data[offset++];
    return offset; 
  }
  
} 


static class AttributeCursor extends AttributeGenomeLoc {
  public AttributeCursor() {
    super(11, c(140, 140, 140), c(255,255,255), "Cursor", -1, false); 
  }
  
  
    public int getLocation(Cell cell) {
     return cell==null?-1:cell.genome.rotateOn; 
  }
}


static class Attribute extends CodonAttribute {
  public Attribute() {
    super(-1, c(255,255,255), c(255,255,255), ""); 
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
  
  public boolean exec(Cell cell, CodonAttribute attribute) {
    return false;//noOP
  }
}
static class CodonDigest extends CodonType {
  public CodonDigest() {
    super(1, c(180,160,10), c(255,255,255), "digest"); 
  }
  
  public boolean exec(Cell cell, CodonAttribute attribute) {
    if (cell.genome.directionOn == 0) {
      if (attribute instanceof AttributeParticle) {
        Particle foodToEat = cell.selectParticleInCell(((AttributeParticle)attribute).getParticle().ordinal()); // digest either "food" or "waste". (now even UGO is possible!! no attribute for that yet tho)
        if(foodToEat != null){
          cell.eat(foodToEat);
          return true;
        }
      } else if (attribute instanceof AttributeWall) {
        cell.energy += (1-cell.energy)*E_RECIPROCAL*0.2;
        cell.hurtWall(26);
        cell.laserWall();
        return true;
      }
    }
    return false;
  }
}
static class CodonRemove extends CodonType {
  public CodonRemove() {
    super(2, c(180, 160, 10), c(255,255,255), "remove"); 
  }
  
  public boolean exec(Cell cell, CodonAttribute attribute) {
    Genome genome = cell.genome;
    if (genome.directionOn == 0) {
      if (attribute instanceof AttributeParticle) {
        Particle wasteToPushOut = cell.selectParticleInCell(((AttributeParticle)attribute).getParticle().ordinal()); // pushes out either "food" or "waste". (now even UGO is possible!! no attribute for that yet tho)
        if(wasteToPushOut != null){
          cell.pushOut(wasteToPushOut);
          return true;
        }
      } else if (attribute instanceof AttributeWall) {
        cell.die();
        return true;
      }
    } else {
      if (attribute instanceof AttributeGenomeLoc) {
        AttributeGenomeLoc loc = (AttributeGenomeLoc)attribute;
        int start = loc.getLocation(cell);
        int end = start;
        if (attribute instanceof AttributeGenomeRange) {
          AttributeGenomeRange range = (AttributeGenomeRange)attribute;
          end = range.getEndLocation(cell);
        }
        
        cell.removeCodons(start, end, loc.isRelative);
        
        return true;
      }
    }

    return false;
  }
}
static class CodonRepair extends CodonType {
  public CodonRepair() {
    super(3, c(0, 150, 0), c(255,255,255), "repair"); 
  }
  
  public boolean exec(Cell cell, CodonAttribute attribute) {
    if (cell.genome.directionOn == 0) {
      if (attribute instanceof AttributeParticle) {
        Particle particle = cell.selectParticleInCell(((AttributeParticle)attribute).getParticle().ordinal());
        if(particle != null){
          cell.shootLaserAt(particle);
          return true;
        }
      } else if (attribute instanceof AttributeWall) {
        cell.healWall();
        return true;
      }      
    }
    return false;
  }
}
static class CodonMoveHand extends CodonType {
  public CodonMoveHand() {
    super(4, c(200, 0, 100), c(255,255,255), "move hand"); 
  }
  
  public boolean exec(Cell cell, CodonAttribute attribute) {
    Genome genome = cell.genome;
    if(attribute instanceof AttributeGenomeCursor){
      ((AttributeGenomeCursor)attribute).setCursor(cell);
      return true;
    }
    return false;
  }
}
static class CodonRead extends CodonType {
  public CodonRead() {
    super(5, c(70, 70, 255), c(255,255,255), "read"); 
  }
  
  public boolean exec(Cell cell, CodonAttribute attribute) {
    Genome genome = cell.genome;
    if (attribute instanceof AttributeGenomeRange) {
      AttributeGenomeRange range = (AttributeGenomeRange)attribute;
      int start = range.getStartLocation(cell);
      int end = range.getEndLocation(cell);
      
      cell.readToMemory(start, end, range.isRelative);
      
      cell.lastRange = new AbsoluteRange(genome.performerOn+start, end-start);
      return true;
    }
    return false;
  }
}
static class CodonWrite extends CodonType {
  public CodonWrite() {
    super(6, c(0, 0, 220), c(255,255,255), "write"); 
  }
  
  public boolean exec(Cell cell, CodonAttribute attribute) {
    Genome genome = cell.genome;
    if (attribute instanceof AttributeGenomeRange) {
      AttributeGenomeRange range = (AttributeGenomeRange)attribute;
      
      int start = range.getStartLocation(cell);
      int end = range.getEndLocation(cell);
      
      cell.writeFromMemory(start, end, range.isRelative);
      
      cell.lastRange = new AbsoluteRange(genome.performerOn+start, end-start);
      return true;
    } else {
      cell.writeFromMemory(0, 0, true); 
      return true;
    }
  }
}
static class CodonGoto extends CodonType {
  public CodonGoto() {
    super(7, c(200, 200, 0), c(255,255,255), "goto"); 
  }
  
  public boolean exec(Cell cell, CodonAttribute attribute) {
    Genome genome = cell.genome;
    if(attribute instanceof AttributeGenomeLoc){
      genome.rotateOnNext = ((AttributeGenomeLoc)attribute).getAbsoluteLoc(cell, true);
      cell.lastRange = new AbsoluteRange(genome.rotateOnNext, 0);
      return true;
    }
    return false;
  }
}

static class CodonMemorizeTo extends CodonType {
  public CodonMemorizeTo() {
    super(8, c(100, 100, 0), c(255,255,255), "Mem To"); 
  }
  
  public boolean exec(Cell cell, CodonAttribute attribute) {
    if(attribute instanceof AttributeMemoryLocation){
      int memoryId = ((AttributeMemoryLocation)attribute).memoryId;
      cell.rangeMemory.put(memoryId, cell.lastRange);
      return true;
    }
    return false;
  }
}

static class CodonCondGoto extends CodonType {
  public CodonCondGoto() {
    super(9, c(200, 200, 0), c(255,255,255), "cond goto"); 
  }
  
  public boolean exec(Cell cell, CodonAttribute attribute) {
    Genome genome = cell.genome;
    if (!cell.wasSuccess) return true;
    if(attribute instanceof AttributeGenomeLoc){
      genome.rotateOnNext = ((AttributeGenomeLoc)attribute).getAbsoluteLoc(cell, true);
      cell.lastRange = new AbsoluteRange(genome.rotateOnNext, 0);
      return true;
    }
    return false;
  }
}

static class CodonCompare extends CodonType {
  public CodonCompare() {
    super(10, c(200, 100, 0), c(255,255,255), "compare"); 
  }
  
  public boolean exec(Cell cell, CodonAttribute attribute) {
    Genome genome = cell.genome;
    if (attribute instanceof AttributeGenomeLoc) {
      AttributeGenomeLoc loc = (AttributeGenomeLoc)attribute;
      String oldmemory = cell.memory;
      int start = loc.getLocation(cell);
      int end = start;
      if (attribute instanceof AttributeGenomeRange) {
        AttributeGenomeRange range = (AttributeGenomeRange)attribute;
        end = range.getEndLocation(cell);
      }
      
      cell.readToMemory(start, end, loc.isRelative);
      
      cell.lastRange = new AbsoluteRange(genome.performerOn+start, end-start);
      String newmemory = cell.memory;
      cell.memory = oldmemory;
      
      return oldmemory.startsWith(newmemory) || newmemory.startsWith(oldmemory);
    }
    return false;
  }
}

static class CodonFindMarker extends CodonType {
  public CodonFindMarker() {
    super(11, c(0, 200, 200), c(255,255,255), "find marker"); 
  }
  
  public boolean exec(Cell cell, CodonAttribute attribute) {
    Genome genome = cell.genome;
    for(int pos = 1; pos < genome.codons.size(); pos++){
      int index = genome.loopAroundGenome(genome.performerOn+pos);
      //we dont want to find ourselves!
      if (index == genome.rotateOn)continue;
      
      Codon c = genome.codons.get(index);
      if (c.getAttribute().equals(attribute)) {
         cell.lastRange = new AbsoluteRange(index, 0);
         return true;
      }
    }
    return false;
  }
}



static class CodonCondMark extends CodonType {
  public CodonCondMark() {
    super(12, c(0, 200, 200), c(255,255,255), "cond mark"); 
  }
  
  public boolean exec(Cell cell, CodonAttribute attribute) {
    Genome genome = cell.genome;
    
    
    if (!cell.wasSuccess) return false;
    
    int loc = genome.loopAroundGenome(cell.lastRange.start);
    
    
    Codon c = genome.codons.get(loc);
    c.setAttribute(attribute);
    
    return true;
  }
}

static class CodonExists extends CodonType {
  public CodonExists() {
    super(13, c(200, 100, 50), c(255,255,255), "exists"); 
  }
  
  public boolean exec(Cell cell, CodonAttribute attribute) {
    Genome genome = cell.genome;
    if (attribute instanceof AttributeParticle) {
      Particle particle = cell.selectParticleInCell(((AttributeParticle)attribute).getParticle().ordinal());
      return particle != null;
    } else if (attribute instanceof AttributeMemoryLocation) {
      return ((AttributeMemoryLocation)attribute).exists(cell);
    }     
    return false;
  }
}
