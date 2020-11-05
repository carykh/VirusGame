class CodonInfoClass{
  
    public int[][][] cols = {
        {{0,0,0}, {100,0,200}, {180,160,10}, {0,150,0}, {200,0,100}, {70,70,255}, {0,0,220}},
        {{0,0,0}, {200,50,50}, {100,65,0}, {160,80,160}, {80,180,80}, {0,100,100}, {0,200,200}, {140,140,140}, {90,90,90}, {90,90,90}}
    };
    
    String[][] names = {
        {"none","digest","remove","repair","move hand","read","write"},
        {"none","food","waste","wall","weak loc","inward","outward","RGL","- RGL start +","- RGL end +"}
    };
    
    //String[][] _names = {
    //    { "none", "digest", "remove", "repair", "move hand", "read", "write" },
    //    { "none" },
    //    { "none", "food", "waste", "wall" },
    //    { "none", "food", "waste", "wall" },
    //    { "none", "wall" },
    //    { "none", "inward", "outward", "value #1" },
    //    { "none", "range #1 #2" },
    //    { "none", "range #1 #2" }
    //};
  
    public color getColor(int p, int t){
        int[] c = cols[p][t];
        return color(c[0], c[1], c[2]);
    }

    public String getText(int p, int[] codonInfo){
        String result = names[p][codonInfo[p]].toUpperCase();
        if(p == 1 && codonInfo[1] == 7){
            result += " ("+codonInfo[2]+" to "+codonInfo[3]+")";
        }
        return result;
    }
    
    public String _getText(int[] info){
        //TODO
        return "";
    }
  
    public String getTextSimple(int p, int t, int start, int end){
        String result = names[p][t].toUpperCase();
        if(p == 1 && t == 7){
            result += " ("+start+" to "+end+")";
        }
        return result;
    }
  
    public int getOptionSize(int p){
        return names[p].length;
    }
  
}

// Ugly work-around for Processing's design problems
CodonInfoClass CodonInfo = new CodonInfoClass();
