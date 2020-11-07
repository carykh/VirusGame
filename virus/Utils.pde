
double[] getRandomVelocity() {
    double sp = Math.random() * (SPEED_HIGH - SPEED_LOW) + SPEED_LOW;
    double ang = random(0,2 * PI);
    double[] result = {sp * Math.cos(ang), sp * Math.sin(ang)};
    return result;
}

double[] combineVelocity(double[] a, double[] b) {
    double ac = a[0] + b[0] + SPEED_LOW;
    double bc = a[1] + b[1] + SPEED_LOW;
    double[] result = {ac > SPEED_HIGH ? SPEED_HIGH : ac, bc > SPEED_HIGH ? SPEED_HIGH : bc};
    return result;
}

color transperize(color col, double trans){
    return color(red(col), green(col), blue(col), (float) trans * 255);
}

boolean checkCellBoundary(double a, double b) {
    int ia = (int) Math.floor(a);
    int ib = (int) Math.floor(b);
    return (ia != ib);
}

int randomInt(int min, int max) {
  return (int) Math.floor(Math.random() * (max - min) ) + min;
}


// BEGIN JUNK //


int loopCodonInfo(int val){
    while(val < -30) val += 61;
    while(val > 30) val -= 61;
    return val;
}

int codonCharToVal(char c){
    int val = (int)(c) - (int)('A');
    return val-30;
}

String codonValToChar(int i){
    int val = (i+30) + (int)('A');
    return (char)val+"";
}

double euclidLength(double[] coor){
    return Math.sqrt(Math.pow(coor[0]-coor[2],2)+Math.pow(coor[1]-coor[3],2));
}

String framesToTime(double f){
    double ticks = f/settings.gene_tick_time;
    if(ticks >= 1000) return Math.round(ticks) + "";
    return nf((float)ticks, 0, 1);
}

double loopIt(double x, double len, boolean evenSplit){
    if(evenSplit){
        while(x >= len*0.5) x -= len;
        while(x < -len*0.5) x += len;
    }else{
        while(x > len-0.5) x -= len;
        while(x < -0.5) x += len;
    }
    
    return x;
}

int loopItInt(int x, int len){
    return (x+len*10)%len;
}

String infoToString(int[] info){
    String result = info[0]+""+info[1];
    if(info[1] == 7){
        result += codonValToChar(info[2])+""+codonValToChar(info[3]);
    }
    
    return result;
}

int[] stringToInfo(String str){
    int[] info = new int[4];
    
    for(int i = 0; i < 2; i++){
        info[i] = Integer.parseInt(str.substring(i,i+1));
    }
    
    if(info[1] == 7){
        for(int i = 2; i < 4; i++){
            char c = str.charAt(i);
            info[i] = codonCharToVal(c);
        }
    }
    
    return info;
}
