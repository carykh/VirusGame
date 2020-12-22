package virus;

import virus.Codon.*;

public class CodonPair {//just information
  protected CodonType type;
  protected CodonAttribute attribute;

  public CodonPair(CodonPair codon) {
    this(codon.type, codon.attribute);
  }

  public CodonPair(CodonType type, CodonAttribute attribute) {
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
