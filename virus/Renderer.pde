class Renderer {
  
    private double camX = 0;
    private double camY = 0;
    private double camS = 0;
    private int maxRight;
    
    public Renderer( Settings settings ) {
        camS = ((float) width) / settings.world_size;
        maxRight = settings.show_ui ? height : width;
    }
    
    double trueXtoAppX(double x){
        return (x-camX)*camS;
    }
    
    double trueYtoAppY(double y){
        return (y-camY)*camS;
    }
    
    double appXtoTrueX(double x){
        return x/camS+camX;
    }
    
    double appYtoTrueY(double y){
        return y/camS+camY;
    }
    
    double trueStoAppS(double s){
        return s * camS; 
    }
    
    void dRect(double x, double y, double w, double h){
        rect((float)x, (float)y, (float)w, (float)h);
    }

    void dText(String s, double x, double y){
        text(s, (float)x, (float)y);
    }

    void dTranslate(double x, double y){
        translate((float)x, (float)y);
    }
    
    void scaledLine(double[] a, double[] b){
        float x1 = (float)trueXtoAppX(a[0]);
        float y1 = (float)trueYtoAppY(a[1]);
        float x2 = (float)trueXtoAppX(b[0]);
        float y2 = (float)trueYtoAppY(b[1]);
        strokeWeight((float)(0.03*camS));
        line(x1,y1,x2,y2);
    }
    
    void drawBackground(){
        background(255);
    }
  
    void drawCells() {
        for( int y = 0; y < settings.world_size; y++ ) {
            for( int x = 0; x < settings.world_size; x++ ) {
                Cell cell = world.cells[y][x];
                if( cell != null ) cell.drawSelf();
            }
        }
    }
    
    void drawParticles(){
        for( Particle p : world.pc.foods ) p.drawSelf();
        for( Particle p : world.pc.wastes ) p.drawSelf();
        for( Particle p : world.pc.ugos ) p.drawSelf();
    }
    
    void drawExtras(){
        if(editor.arrow != null){
            if(euclidLength(editor.arrow) > settings.min_length_to_produce){
                stroke(0);
            }else{
                stroke(150);
            }
            drawArrow(editor.arrow[0], editor.arrow[1], editor.arrow[2], editor.arrow[3]);
        }
    }
    
    void drawUI(){
        
        editor.drawSelection();
        
        if( settings.show_ui ) {
          
            pushMatrix();
            translate(height,0);
            fill(0);
            noStroke();
            rect(0,0,width-height,height);
            fill(255);
            textFont(font,40);
            textAlign(LEFT);
            text( "FPS: " + (int) Math.floor(frameRate), 25, 60);
            text( "Start: " + framesToTime(frameCount), 25, 100);
            text( "Edit: " + framesToTime(frameCount-world.lastEditFrame), 25, 140);
            textFont(font, 28);
            text("Initial: " + world.initialCount, 340, 50);
            text("Alive: " + world.aliveCount, 340, 75);
            text("Dead: " + world.deadCount, 340, 100);
            text("Shells: " + world.shellCount, 340, 125);
            text("Infected: " + world.infectedCount, 340, 150);
            if( editor.isOpened() ){
                editor.drawSelf();
            }else{
                drawWorldStats();
            }
            popMatrix();
            drawUGObutton( !editor.isOpened() );
        }
        
    }
    
    void drawCredits() {
        pushMatrix();
        translate(4, height - 6);
        fill( COPYRIGHT_TEXT_COLOR );
        noStroke();
        textFont(font, 18);
        textAlign(LEFT);
        text("Copyright (C) 2020 Cary Huang & magistermaks", 0, 0);
        popMatrix();
    }

    void drawGenomeArrows(double dw, double dh){
        float w = (float)dw;
        float h = (float)dh;
        fill(255);
        beginShape();
        vertex(-5,0);
        vertex(-45,-40);
        vertex(-45,40);
        endShape(CLOSE);
        beginShape();
        vertex(w+5,0);
        vertex(w+45,-40);
        vertex(w+45,40);
        endShape(CLOSE);
        noStroke();
        rect(0, -h/2, w, h);
    }

    void drawBar(color col, double stat, String s, double y){
        fill(150);
        rect(25,(float)y,500,60);
        fill(col);
        rect(25,(float)y,(float)(stat*500),60);
        fill(0);
        textFont(font,48);
        textAlign(LEFT);
        text(s+": "+nf((float)(stat*100),0,1)+"%",35,(float)y+47);
    }
    
    void drawWorldStats() {
        fill(255);
        textAlign(LEFT);
        textFont(font, 30);
        text("Foods: " + world.pc.foods.size(), 25, 200);
        text("Wastes: " + world.pc.wastes.size(), 25, 230);
        text("UGOs: " + world.pc.ugos.size(), 25, 260);
        
        graph.drawSelf( 10, height - 10, width - height - 20, height - 300 );
    }
    
    void drawEditTable(double[] dims){
        double x = dims[0];
        double y = dims[1];
        double w = dims[2];
        double h = dims[3];
  
        double appW = w - MARGIN * 2;
        int p = editor.codonToEdit[0];
        
        pushMatrix();
        textFont(font,30);
        textAlign(CENTER);
        translate( (float) x, (float) y );
        
        // Codon editor
        if(p >= 0){
          
            int s = editor.codonToEdit[2];
            int e = editor.codonToEdit[3];
            int choiceCount = CodonInfo.getOptionSize(editor.codonToEdit[0]);
            double appChoiceHeight = h/choiceCount;
            for(int i = 0; i < choiceCount; i++){
                double appY = appChoiceHeight*i;
                color fillColor = CodonInfo.getColor(p,i);
                fill(fillColor);
                dRect(MARGIN,appY+MARGIN,appW,appChoiceHeight-MARGIN*2);
                fill(255);
                dText(CodonInfo.getTextSimple(p, i, s, e),w*0.5,appY+appChoiceHeight/2+11);
            }
            
        // Divine editor
        }else{
         
            double appChoiceHeight = h / DIVINE_CONTROLS.length;
            for(int i = 0; i < DIVINE_CONTROLS.length; i++){
                double appY = appChoiceHeight*i;
                fill( editor.isDivineControlAvailable(i) ? DIVINE_CONTROL_COLOR : DIVINE_DISABLED_COLOR );
                dRect(MARGIN,appY+MARGIN,appW,appChoiceHeight-MARGIN*2);
                fill(255);
                dText(DIVINE_CONTROLS[i],w*0.5,appY+appChoiceHeight/2+11);
            }
          
        }
        
        popMatrix();
        
    }
    
    void drawArrow(double dx1, double dx2, double dy1, double dy2){
        float x1 = (float)trueXtoAppX(dx1);
        float y1 = (float)trueYtoAppY(dx2);
        float x2 = (float)trueXtoAppX(dy1);
        float y2 = (float)trueYtoAppY(dy2);
        strokeWeight((float)(0.03*camS));
        line(x1,y1,x2,y2);
        float angle = atan2(y2-y1,x2-x1);
        float head_size = (float)(0.3*camS);
        float x3 = x2+head_size*cos(angle+PI*0.8);
        float y3 = y2+head_size*sin(angle+PI*0.8);
        line(x2,y2,x3,y3);
        float x4 = x2+head_size*cos(angle-PI*0.8);
        float y4 = y2+head_size*sin(angle-PI*0.8);
        line(x2,y2,x4,y4);
    }
  
    void drawUGObutton(boolean drawUGO){
        fill(80);
        noStroke();
        rect(width-130,10,120,140);
        fill(255);
        textAlign(CENTER);
        if(drawUGO){
            textFont(font,48);
            text("MAKE",width-70,70);
            text("UGO",width-70,120);
        }else{
            textFont(font,36);
            text("CANCEL",width-70,95);
        }
    }
    
    void drawGenomeAsList(Genome g, double[] dims){
        double x = dims[0];
        double y = dims[1];
        double w = dims[2];
        double h = dims[3];
        int GENOME_LENGTH = g.codons.size();
        double appCodonHeight = h/GENOME_LENGTH;
        double appW = w*0.5-MARGIN;
        textFont(font,30);
        textAlign(CENTER);
        pushMatrix();
        dTranslate(x,y);
        pushMatrix();
        dTranslate(0,appCodonHeight*(g.appRO+0.5));
        
        if(editor.selected != editor.ugo){
            drawGenomeArrows(w,appCodonHeight);
        }
        
        popMatrix();
        for(int i = 0; i < GENOME_LENGTH; i++){
            double appY = appCodonHeight*i;
            Codon codon = g.codons.get(i);
            for(int p = 0; p < 2; p++){
                double extraX = (w*0.5-MARGIN)*p;
                color fillColor = codon.getColor(p);
                fill(0);
                dRect(extraX+MARGIN,appY+MARGIN,appW,appCodonHeight-MARGIN*2);
                if(codon.hasSubstance()){
                    fill(fillColor);
                    double trueW = appW*codon.codonHealth;
                    double trueX = extraX+MARGIN;
                    if(p == 0){
                        trueX += appW*(1-codon.codonHealth);
                    }
                    dRect(trueX,appY+MARGIN,trueW,appCodonHeight-MARGIN*2);
                }
                fill(255);
                dText(codon.getText(p),extraX+w*0.25,appY+appCodonHeight/2+11);
      
                if(p == editor.codonToEdit[0] && i == editor.codonToEdit[1]){
                    double highlightFac = 0.5+0.5*sin(frameCount*0.25);
                    fill(255,255,255,(float)(highlightFac*140));
                    dRect(extraX+MARGIN,appY+MARGIN,appW,appCodonHeight-MARGIN*2);
                }
            }
        }
        
        if(editor.selected == editor.ugo){
            fill(255);
            textFont(font,60);
            double avgY = (h+height-y)/2;
            dText("( - )",w*0.25,avgY+11);
            dText("( + )",w*0.75-MARGIN,avgY+11);
        }
        
        popMatrix();
    }
    
  
}
