class Codon{
  public int[] codonInfo = new int[4];
  boolean[] altered = new boolean[4];
  double codonHealth;
  public Codon(int[] info, double health, boolean isUGOp){
    codonInfo = info;
    codonHealth = health;
    for(int i = 0; i < 4; i++){
      altered[i] = isUGOp;
    }
  }
  public color getColor(int p){
    return intToColor(CodonInfo.getColor(p,codonInfo[p]));
  }
  public color getTextColor(int p){
    return intToColor(CodonInfo.getTextColor(p,codonInfo[p]));
  }
  public String getText(int p){
    return CodonInfo.getText(p,codonInfo);
  }
  public boolean hasSubstance(){
    return (codonInfo[0] != 0 || codonInfo[1] != 0);
  }
  public void hurt(){
    if(hasSubstance()){
      codonHealth -= Math.random()*CODON_DEGRADE_SPEED;
      if(codonHealth <= 0){
        codonHealth = 1;
        codonInfo[0] = 0;
        codonInfo[1] = 0;
      }
    }
  }
  public void setInfo(int p, int val){
    codonInfo[p] = val;
    altered[p] = true;
    codonHealth = 1.0;
  }
  public void setFullInfo(int[] info){
    codonInfo = info;
    codonHealth = 1.0;
  }
}
