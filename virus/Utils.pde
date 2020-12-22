

class Util {
  public double[] getRandomVelocity() {
      double sp = Math.random() * (SPEED_HIGH - SPEED_LOW) + SPEED_LOW;
      double ang = Math.random() * 2 * PI;
      double[] result = {sp * Math.cos(ang), sp * Math.sin(ang)};
      return result;
  }

  public double[] combineVelocity(double[] a, double[] b) {
      double ac = a[0] + b[0] + SPEED_LOW;
      double bc = a[1] + b[1] + SPEED_LOW;
      double[] result = {ac > SPEED_HIGH ? SPEED_HIGH : ac, bc > SPEED_HIGH ? SPEED_HIGH : bc};
      return result;
  }

  public color transperize(color col, double trans){
      return color(red(col), green(col), blue(col), (float) trans * 255);
  }

  public boolean checkCellBoundary(double a, double b) {
      int ia = (int) Math.floor(a);
      int ib = (int) Math.floor(b);
      return (ia != ib);
  }

  int randomInt(int min, int max) {
    return (int) Math.floor(Math.random() * (max - min) ) + min;
  }
  double random(double min, double max) {
    return Math.random() * (max - min) + min;
  }
  float random(float min, float max) {
    return ((float)Math.random()) * (max - min) + min;
  }

boolean randomBool() {
    return random(0, 1) > 0.5;
}


  // BEGIN JUNK //


  public int loopCodonInfo(int val){
      while(val < -30) val += 61;
      while(val > 30) val -= 61;
      return val;
  }

  char[] encording = "0123456789abcdefghijklmnopqrstuvwxyz!£$%^&*()[]{}_,.<>;:'@#~|\\/=+`¬¦ZYXWVUTSRQPONMLKJIHGFEDCBA".toCharArray(); //do not use '-' it is the seperator char
  int enMax = encording.length/2 + encording.length%2;
  int enMin = -encording.length/2;
  HashMap<Character, Integer> decoding = new HashMap();
  {
    for(int i=enMin;i<enMax;i++) {
      decoding.put(codonValToChar(i), i);
    }
  }

  public  int codonCharToVal(char c){
    return decoding.get(c);
  }
  public  char codonValToChar(int i){
    if (i < enMin) i = 0;
    if (i >= enMax) i = 0;
    if (i < 0) i = encording.length + i;
    return encording[i];
  }

  public double euclidLength(double[] coor){
      return Math.sqrt(Math.pow(coor[0]-coor[2],2)+Math.pow(coor[1]-coor[3],2));
  }

  public String framesToTime(double f){
      double ticks = f/settings.gene_tick_time*PLAY_SPEED;
      if(ticks >= 1000) return Math.round(ticks) +"t since";
      return nf((float)ticks, 0, 1)+"t since";
  }

  public double loopIt(double x, double len, boolean evenSplit){
      if(evenSplit){
          while(x >= len*0.5) x -= len;
          while(x < -len*0.5) x += len;
      }else{
          while(x > len-0.5) x -= len;
          while(x < -0.5) x += len;
      }

      return x;
  }

  public int loopItInt(int x, int len){
          if (len == 0)return 0;
      return (x+len*10)%len;
  }

  public String infoToString(CodonPair codon) {
    String result = codonValToChar(codon.getType().id)+""+codonValToChar(codon.getAttribute().id) + codon.getType().saveExtra() + codon.getAttribute().saveExtra();
    return result;
  }

  public int[] stringToInfo(String str) {
    int[] info = new int[str.length()];
    for (int i = 0; i < str.length(); i++) {
      char c = str.charAt(i);
      info[i] = codonCharToVal(c);
    }
    return info;
  }



  public color intToColor(int[] c) {
    return color(c[0], c[1], c[2]);
  }


  public  boolean dimWithinBox(Dim dims, double x, double y) {
    double dx = dims.getX();
    double dy = dims.getY();
    double w = dims.getW() + dx;
    double h = dims.getH() + dy;
    return dx < x && x <= w && dy < y && y <= h;
  }
}
