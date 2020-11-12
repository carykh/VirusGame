class Editor {
  
    private boolean open = false;
    public Cell ugo;
    public Cell selected;
    
    public int selx = 0;
    public int sely = 0;
    
    public int[] codonToEdit = {-1,-1,0,0};
    public double[] arrow = null;
    
    Editor( Settings settings ) {
        ugo = new Cell(-1, -1, CellType.Normal, 0, 1, settings.editor_default);
    }
    
    public void select( int x, int y ) {
        open = true;
        selected = world.getCellAt( x, y );
        selx = x;
        sely = y;
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
        
        if( selected != null ) {
          
            text(selected.getCellName(), 25, 255);
        
            if(isNotUGO && (selected.type != CellType.Locked)){
          
                int c = 200;
                textFont(font, 22);
                text("This cell is " + (selected.tampered ? "TAMPERED" : "NATURAL"), 555, c);
                text("Contents:", 555, c += 22);
                text("    total: " + selected.getParticleCount(null), 555, c += 44);
                text("    food: " + selected.getParticleCount(ParticleType.Food), 555, c += 22);
                text("    waste: " + selected.getParticleCount(ParticleType.Waste), 555, c += 22);
                text("    UGOs: " + selected.getParticleCount(ParticleType.UGO), 555, c += 22);
                
                renderer.drawBar(ENERGY_COLOR, selected.energy, "Energy", 290);
                renderer.drawBar(WALL_COLOR, selected.wall, "Wall health", 360);
                
            }
            
            if( selected.type == CellType.Normal ) {
                renderer.drawGenomeAsList(selected.genome, GENOME_LIST_DIMS);
                
                if(isNotUGO){
                    textFont(font, 32);
                    textAlign(LEFT);
                    text("Memory: " + selected.getMemory(), 25, 940);
                }
            }
            
            renderer.drawEditTable(EDIT_LIST_DIMS);
            
        }else{
            text("Empty Cell", 25, 255);
            renderer.drawEditTable(EDIT_LIST_DIMS);
        }

    }
    
    private void drawSelection() {

        if( open && selected != ugo ) {
            pushMatrix();
            translate( (float) renderer.trueXtoAppX(selx), (float) renderer.trueYtoAppY(sely) );
            scale( (float) (renderer.camS / BIG_FACTOR) );
            noFill();
            stroke(0,255,255,155 + (int) (100 * Math.sin(frameCount / 10.f)));
            strokeWeight(4);
            rect(0, 0, BIG_FACTOR, BIG_FACTOR);
            popMatrix();
        }
      
    }
  
    public void checkInput() {
        if(open) {
          
            checkEditListClick( codonToEdit[0] < 0 );
            checkGenomeListClick();
            if(mouseX > width - 160 && mouseY < 160) close();
            
        }else{
            if(mouseX > width - 160 && mouseY < 160) openUGO();
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

    void checkEditListClick( boolean divineControls ) {
      
        double rmx = ((mouseX - height) - EDIT_LIST_DIMS[0]) / EDIT_LIST_DIMS[2];
        double rmy = (mouseY - EDIT_LIST_DIMS[1]) / EDIT_LIST_DIMS[3];
    
        if(rmx >= 0 && rmx < 1 && rmy >= 0 && rmy < 1) {
          
            int optionCount = divineControls ? DIVINE_CONTROLS.length : CodonInfo.getOptionSize(codonToEdit[0]);
            int choice = (int) (rmy * optionCount);
            
            if( divineControls ) { 
                divineIntervention( choice );
                return;
            }
            
            if(codonToEdit[0] == 1 && (choice == 8 || choice == 9)){
              
                int diff = (rmx < 0.5) ? -1 : 1;
                int index = (choice == 8) ? 2 : 3;
                
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
    
    public void divineIntervention( int id ) {
      
        if( !isDivineControlAvailable(id) ) return;
        
        switch( id ) {
            case 0: // Remove
                world.setCellAt( selx, sely, null );
                break;
            
            case 1: // Revive
                world.aliveCount ++;
                world.setCellAt( selx, sely, new Cell( selx, sely, CellType.Normal, 0, 1, settings.genome ) );
                break;
            
            case 2: // Heal
                selected.healWall();
                break;
            
            case 3: // Energize
                selected.giveEnergy();
                break;
            
            case 4: // Make Wall
                world.setCellAt( selx, sely, new Cell( selx, sely, CellType.Locked, 0, 1, settings.genome ) );
                break;
            
            case 5: // Make Shell
                world.shellCount ++;
                world.setCellAt( selx, sely, new Cell( selx, sely, CellType.Shell, 0, 1, settings.genome ) );
                break;
        }
        
        editor.select( selx, sely );
        world.lastEditFrame = frameCount;
      
    }
    
    public boolean isDivineControlAvailable( int id ) {
        // For meaning of the specific id see 'DIVINE_CONTROLS' defined in 'Virus',
        // where id is the offset into that array.
        
        if( selected == ugo || !open ) return false;
        if( id == 0 ) return (selected != null);
        if( id == 2 || id == 3 ) return (selected != null && selected.type != CellType.Locked);
        if( id == 1 ) return (selected == null || selected.type != CellType.Normal);
        if( id == 4 ) return (selected == null || selected.type != CellType.Locked);
        if( id == 5 ) return (selected == null || selected.type != CellType.Shell);
        return true;
      
    }
    
    void produce(){
      
        if(world.getCellAtUnscaled(arrow[0], arrow[1]) == null){
          
            UGO u = new UGO(arrow, ugo.genome.getGenomeString());
            u.markDivine();
            world.addParticle(u);
            world.lastEditFrame = frameCount;
            
        }
        
    }
  
  
}
