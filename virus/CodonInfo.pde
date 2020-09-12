static class CodonInfo{
  public static int[][][] cols = {{{0,0,0},{100,0,200},{180,160,10},
  {0,150,0},{200,0,100},{70,70,255},
  {0,0,220},{220,70,70}},
  {{0,0,0},{200,50,50},{100,65,0},{160,80,160},
  {80,180,80},{0,100,100},
  {0,200,200},{50, 255, 50},{140,140,140},{90,90,90},{90,90,90}}};
  static String[][] names = {{"none","digest","remove","repair","move hand","read","write","delete"},
  {"none","food","waste","wall","weak loc","inward","outward","ugo","RGL","- RGL start +","- RGL end +"}};
  public static int[] getColor(int p, int t){
    return CodonInfo.cols[p][t];
  }
  public static int[] getTextColor(int p, int t){
    /*int[] c = cols[p][t];
    float sum = c[0]+c[1]*2+c[2];
    if(sum < 128*3){
      int[] result = {255,255,255};
      return result;
    }else{
      int[] result = {0,0,0};
      return result;
    }*/
    int[] result = {255,255,255};
    return result;
  }
  public static String getText(int p, int[] codonInfo){
    String result = CodonInfo.names[p][codonInfo[p]].toUpperCase();
    if(p == 1 && codonInfo[1] == 8){
      result += " ("+codonInfo[2]+" to "+codonInfo[3]+")";
    }
    return result;
  }
  public static String getTextSimple(int p, int t, int start, int end){
    String result = CodonInfo.names[p][t].toUpperCase();
    if(p == 1 && t == 8){
      result += " ("+start+" to "+end+")";
    }
    return result;
  }
  public static int getOptionSize(int p){
    return names[p].length;
  }
}
