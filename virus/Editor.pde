class Editor {
  
    private boolean open = false;
    public Cell ugo;
    public Cell selected;
    
    public int[] codonToEdit = {-1,-1,0,0};
    public double[] arrow = null;
    
    Editor( Settings settings ) {
        ugo = new Cell(-1, -1, CellType.Normal, 0, 1, settings.editor_default);
    }
    
    public void open( Cell c ) {
        open = true;
        selected = c;
    }
    
    public void openUGO() {
        open = true;
        selected = ugo;
    }
    
    public void close() {
        open = false;
        selected = null;
    }
    
    public boolean isOpened() {
        return open; 
    }
 
    public void drawSelf() {
        boolean isNotUGO = (selected != ugo);
        
        fill(80);
        noStroke();
        rect(10, 160, 530, height - 10);
        
        if(isNotUGO){
            rect(540, 160, 200, 270);
        }
        
        fill(255);
        textFont(font, 96);
        textAlign(LEFT);
        text(selected.getCellName(), 25, 255);
        
        if(isNotUGO){
            textFont(font,32);
            text("Inside this cell,",555,200);
            text("there are:",555,232);
            text("total: " + selected.getParticleCount(null), 555, 296);
            text("food: " + selected.getParticleCount(ParticleType.Food), 555, 328);
            text("waste: " + selected.getParticleCount(ParticleType.Waste), 555, 360);
            text("UGOs: " + selected.getParticleCount(ParticleType.UGO), 555, 392);
            renderer.drawBar(ENERGY_COLOR, selected.energy, "Energy", 290);
            renderer.drawBar(WALL_COLOR, selected.wall, "Wall health", 360);
        }
        
        renderer.drawGenomeAsList(selected.genome, GENOME_LIST_DIMS);
        renderer.drawEditTable(EDIT_LIST_DIMS);
        
        if(isNotUGO){
            textFont(font, 32);
            textAlign(LEFT);
            text("Memory: " + selected.getMemory(), 25, 940);
        }
    }
  
    public void checkInput() {
        if(open) {
          
            if(codonToEdit[0] >= 0) {
                checkEditListClick();
            }
            
            checkGenomeListClick();
        }
        
        if(editor.selected == editor.ugo) {
            if((mouseX >= height + 530 && codonToEdit[0] == -1) || mouseY < 160) {
                close();
            }
        }else if(mouseX > width - 160 && mouseY < 160) {
            openUGO();
        }
    }
    
    void checkGenomeListClick() {
      
        double rmx = ((mouseX - height) - GENOME_LIST_DIMS[0]) / GENOME_LIST_DIMS[2];
        double rmy = (mouseY - GENOME_LIST_DIMS[1]) / GENOME_LIST_DIMS[3];
    
        if(rmx >= 0 && rmx < 1 && rmy >= 0){
            if(rmy < 1){
                codonToEdit[0] = (int) (rmx * 2);
                codonToEdit[1] = (int) (rmy * selected.genome.codons.size());
            }else if(selected == ugo){
                String genomeString = (rmx < 0.5) 
                    ? ugo.genome.getGenomeStringShortened() 
                    : ugo.genome.getGenomeStringLengthened();
                    
                selected = ugo = new Cell(-1, -1, CellType.Normal, 0, 1, genomeString);
            }
        }
        
    }

    void checkEditListClick() {
      
        double rmx = ((mouseX - height) - EDIT_LIST_DIMS[0]) / EDIT_LIST_DIMS[2];
        double rmy = (mouseY - EDIT_LIST_DIMS[1]) / EDIT_LIST_DIMS[3];
    
        if(rmx >= 0 && rmx < 1 && rmy >= 0 && rmy < 1) {
          
            int optionCount = CodonInfo.getOptionSize(codonToEdit[0]);
            int choice = (int) (rmy * optionCount);
            
            if(codonToEdit[0] == 1 && choice >= optionCount-2){
              
                int diff = (rmx < 0.5) ? -1 : 1;
                int index = (choice == optionCount - 2) ? 2 : 3;
                
                codonToEdit[index] = loopCodonInfo(codonToEdit[index] + diff);
                
            }else{
              
                Codon tc = selected.genome.codons.get(codonToEdit[1]);
                
                if(codonToEdit[0] == 1 && choice == 7){
                  
                    if(tc.info[1] != 7 || tc.info[2] != codonToEdit[2] || tc.info[3] != codonToEdit[3]){
                        tc.setInfo(1, choice);
                        tc.setInfo(2, codonToEdit[2]);
                        tc.setInfo(3, codonToEdit[3]);
                    }else{ return; }
                    
                }else{
                  
                    if(tc.info[codonToEdit[0]] != choice){
                        tc.setInfo(codonToEdit[0], choice);
                    }else{ return; }
                    
                }
                
                if(selected != ugo) {
                    world.lastEditFrame = frameCount;
                    selected.tamper();
                }
                
            }
            
        }else{
          
            codonToEdit[0] = codonToEdit[1] = -1;
            
        }
        
    }
    
    void produce(){
      
        if(world.getCellAtUnscaled(arrow[0], arrow[1]) == null){
          
            Particle p = new UGO(arrow, ugo.genome.getGenomeString());
            world.addParticle(p);
            world.lastEditFrame = frameCount;
            
        }
        
    }
  
  
}
