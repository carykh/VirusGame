class Renderer {

    boolean wasMouseDown = false; //todo is this needed here?
    double MIN_CAM_S = ((float)W_H)/settings.world_size;
    double camX = 0;
    double camY = 0;
    double camS = MIN_CAM_S;
    private int maxRight;

    int flashCursorRed = 0;
    int activeCursorRed = 0;
    boolean activeCursorHighLow = false;

    public Renderer( Settings settings ) {
        camS = ((float) ORIG_W_W) / settings.world_size;
        maxRight = settings.show_ui ? ORIG_W_H : ORIG_W_W;
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
            if(util.euclidLength(editor.arrow) > settings.min_length_to_produce){
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
            translate(ORIG_W_H,0);
            fill(0);
            noStroke();
            rect(0, 0, UI_THICKNESS, ORIG_W_H);
            fill(255);
            textFont(font,40);
            textAlign(LEFT);
            text( "FPS: " + (int) Math.floor(frameRate), 25, 60);
            text( "Start: " + util.framesToTime(frameCount), 25, 100);
            text( "Edit: " + util.framesToTime(frameCount-world.lastEditFrame), 25, 140);
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

        if( settings.show_debug ) {

            int c = 20;
            int lines = 5;

            fill( 255, 255, 255, 180 );
            rect( 20, 20, 285, 21 * lines );

            fill(0);
            textFont(font, 20);
            textAlign(LEFT);

            text( "FPS: " + (int) Math.floor(frameRate) + ", frame: " + frameCount, 20, c += 20 );
            text( "Graph high: " + graph.getHighest(false) + ", offset: " + graph.offset + " p: " + settings.graph_update_period, 20, c += 20 );
            text( "Selected: " + editor.isOpened() + ", at: " + editor.selx + ", " + editor.sely, 20, c += 20 );
            text( "CamS: " + String.format("%.2f", camS) + ", CamX: " + String.format("%.2f", camX ) + ", CamY: " + String.format("%.2f", camY ), 20, c += 20 );
            text( "Mutability: " + settings.mutability, 20, c += 20 );

        }

    }

    void drawCredits() {
        pushMatrix();
        translate(4, ORIG_W_H - 6);
        fill( COPYRIGHT_TEXT_COLOR );
        noStroke();
        textFont(font, 12/scalefactor);
        textAlign(LEFT);
        text("Copyright (C) 2020 Cary Huang, sirati & magistermaks", 0, 0);
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

    void drawSpeedControl(){
        fill(80);
        noStroke();
        for(int i=0;i<3;i++)
        {
            rect(10+i*75,10,65,40);
        }
        textFont(font,48);
        fill(255);
        textAlign(CENTER, CENTER);
        text("<<", 43, 30);
        text(">>", (10+75*2+33), 30);
        textFont(font,38);
        text("x"+String.format("%.1f", PLAY_SPEED), (10+75+33), 30);
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

        text("total: " + world.totalFoodCount, 200, 200);
        text("total: " + world.totalWasteCount, 200, 230);
        text("total: " + world.totalUGOCount, 200, 260);

        graph.drawSelf( 10, ORIG_W_H - 10 );
    }
    
    void drawDivineTable(Dim dims){ //todo add the divine table if(p < 0){
        double x = dims.getX();
        double y = dims.getY();
        double w = dims.getW();
        double h = dims.getH();
  
        double appW = w - MARGIN * 2;
        int p = editor.codonToEdit[0];

        pushMatrix();
        textFont(font,30);
        textAlign(CENTER);
        translate( (float) x, (float) y );

        double appChoiceHeight = h / DIVINE_CONTROLS.length;
        for(int i = 0; i < DIVINE_CONTROLS.length; i++){
            double appY = appChoiceHeight*i;
            fill( editor.isDivineControlAvailable(i) ? DIVINE_CONTROL_COLOR : DIVINE_DISABLED_COLOR );
            dRect(MARGIN,appY+MARGIN,appW,appChoiceHeight-MARGIN*2);
            fill(255);
            dText(DIVINE_CONTROLS[i],w*0.5,appY+appChoiceHeight/2+11);
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
        float head_size = (float)(0.3*camS); //changed from 0.3 to 0.2
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
        rect(ORIG_W_W-130,10,120,140);
        fill(255);
        textAlign(CENTER);
        if(drawUGO){
            textFont(font,48);
            text("MAKE",ORIG_W_W-70,70);
            text("UGO",ORIG_W_W-70,120);
        }else{
            textFont(font,36);
            text("CANCEL",ORIG_W_W-70,95);
        }
    }

    public void drawGenomeAsList(Genome g, Dim dims) {
        double x = dims.getX();
        double y = dims.getY();
        double w = dims.getW();
        double h = dims.getH();
        int GENOME_LENGTH = g.codons.size();
        int offset = Math.max(0, Math.min(g.scrollOffset, GENOME_LENGTH-VIEW_FIELD_DIS_CNT));
        boolean scrolling = false;

        if (GENOME_LENGTH > VIEW_FIELD_DIS_CNT) {
            GENOME_LENGTH = VIEW_FIELD_DIS_CNT;
            scrolling = true;
        }
        double appCodonHeight = h/GENOME_LENGTH;
        double appW = w*0.5-MARGIN;
        textFont(font,30);
        textAlign(CENTER);
        pushMatrix();
        dTranslate(x,y);
        if (g.rotateOn >= offset && g.rotateOn < offset+VIEW_FIELD_DIS_CNT) {
            pushMatrix();
            dTranslate(0, appCodonHeight*(g.appRO-offset+0.5f));

            if(!CellType.UGO_Editor.isType(editor.selected)){
                if(editor.ugoSelected == null){ //todo verify UGO viewer
                    drawGenomeArrows(w,appCodonHeight);
                }
            }

            popMatrix();
        }

        double redflashFac = 0;
        for(int i = 0; i < GENOME_LENGTH; i++){
            if (i+offset == editor.dragAndDropCodonId) continue;
            double appY = appCodonHeight*i;
            Codon codon = g.codons.get(i+offset);

            drawCodon(codon, 0, appY, w, appW, appCodonHeight);
            for(int p = 0; p < 2; p++){
                double extraX = (w*0.5-MARGIN)*p;
                if(p == editor.codonToEdit[0] && i + offset == editor.codonToEdit[1]){
                    double highlightFac = 0.5f+0.5f*sin(frameCount*0.25f);
                    fill(255,255,255,(float)(highlightFac*140));
                    dRect(extraX+MARGIN,appY+MARGIN,appW,appCodonHeight-MARGIN*2);
                    if (flashCursorRed > 0) {

                        redflashFac = sin(frameCount*0.25*4/3); //quick = attention
                        redflashFac *= redflashFac;


                        if (!activeCursorHighLow & redflashFac > 0.99f) {
                            activeCursorHighLow = true;
                        } else if (activeCursorHighLow & redflashFac < 0.01f) {
                            activeCursorHighLow = false;
                            flashCursorRed--;
                            if (millis()-activeCursorRed>400) {
                                flashCursorRed = 0;
                                activeCursorRed = 0;
                            }
                        }

                        fill(255,0,0,(float)(redflashFac*255));
                        dRect(extraX+MARGIN,appY+MARGIN,appW,appCodonHeight-MARGIN*2);
                    }
                }
            }
        }

        if(scrolling) {
            double unit = h/g.codons.size();
            double scrbar_h = unit*20;
            double scrbar_y = unit*offset;

            fill(255);
            dRect(x+w+40-5,scrbar_y,5,scrbar_h);
            fill(255,0,0,(float)(redflashFac*255));
            dRect(x+w+40-5,scrbar_y,5,scrbar_h);
        }

        if(CellType.UGO_Editor.isType(editor.selected)){
            fill(255);
            textFont(font,60);
            double avgY = (h+ORIG_W_H-y)/2;
            dText("( - )",w*0.25,avgY+11);
            dText("( + )",w*0.75-MARGIN,avgY+11);
        }

        double arrowUIX =  (mouseX/scalefactor) - x - ORIG_W_H;
        double arrrowUIY = (mouseY/scalefactor) - y + appCodonHeight/2;
        int rowAY = (int)(arrrowUIY/appCodonHeight);

        //drag and drop
        if (editor.dragAndDropCodonId >= 0 && editor.dragAndDropCodonId<g.codons.size()) {


            double minX =-0.25*w;
            double maxX =+1.25*w;

            if (rowAY >= 0 && rowAY <= GENOME_LENGTH && arrowUIX > minX && arrowUIX <= maxX) {

                fill(255);
                drawAddArrows(0, rowAY*appCodonHeight, min(80, (float)appCodonHeight), false);

                drawAddArrows(w, rowAY*appCodonHeight, min(80, (float)appCodonHeight), true);
            }

            textFont(font,30);
            textAlign(CENTER);
            drawCodon(g.codons.get(editor.dragAndDropCodonId), (mouseX/scalefactor)-x-ORIG_W_H-editor.dragAndDropRX, (mouseY/scalefactor)-y-editor.dragAndDropRY, w, appW, appCodonHeight);

        } else {
            //add button

            if (rowAY >= 0 && rowAY <= GENOME_LENGTH && arrowUIX >= -70 && arrowUIX <= 25) {

                fill(color(100,255,0));
                drawAddArrows(0, rowAY*appCodonHeight, min(80, (float)appCodonHeight), false);
            }

            //remove button
            double crossUIX =  (mouseX/scalefactor) - x - ORIG_W_H - w;
            double crossUIY = (mouseY/scalefactor) - y;
            int rowCY = (int)(crossUIY/appCodonHeight);
            if (rowCY >= 0 && rowCY < GENOME_LENGTH && crossUIX >= -25 && crossUIX <= 70) {
                drawRemoveCross(w+30, (rowCY+0.5)*appCodonHeight, min(60, (float)(appCodonHeight-2*MARGIN)), 60, 15);
            }
        }
        popMatrix();
    }



    void drawCodon(Codon codon, double x, double y, double w, double appW, double appCodonHeight) {
        for (int p = 0; p < 2; p++) {
            double extraX = (w*0.5-MARGIN)*p;
            color fillColor = codon.getColor(p);
            color textColor = codon.getTextColor(p);
            fill(0);
            dRect(x+extraX+MARGIN, y+MARGIN, appW, appCodonHeight-MARGIN*2);
            if (codon.hasSubstance()) {
                fill(fillColor);
                double trueW = appW*codon.codonHealth;
                double trueX = x+extraX+MARGIN;
                if (p == 0) {
                    trueX += appW*(1-codon.codonHealth);
                }
                dRect(trueX, y+MARGIN, trueW, appCodonHeight-MARGIN*2);
            }
            fill(textColor);
            dText(codon.getText(p), x+extraX+w*0.25, y+appCodonHeight/2+11);
        }
    }

    void drawButtonTable(Dim dims, Button[] buttons) {
        double x = dims.getX();
        double y = dims.getY();
        double w = dims.getW();
        double h = dims.getH();
        double appW = w-MARGIN*2;
        textFont(font, 30);
        textAlign(CENTER);

        int p = editor.codonToEdit[0];
        int s = editor.codonToEdit[2];
        int e = editor.codonToEdit[3];
        if (p >= 0) {
            pushMatrix();
            dTranslate(x, y);
            double appChoiceHeight = h/buttons.length;
            for (int i = 0; i < buttons.length; i++) {
                double appY = appChoiceHeight*i;
                buttons[ i].drawButton(MARGIN,appY+MARGIN,appW,appChoiceHeight-MARGIN*2);
            }
            popMatrix();
        }
    }

    void drawAddArrows(double x, double y, float arrowH, boolean left){
        dTranslate(x, y);
        beginShape();
        vertex(left?5:-5,0);
        vertex(left?45:-45, -arrowH/2);
        vertex(left?45:-45,  arrowH/2);
        endShape(CLOSE);
        dTranslate(-x, -y);
    }

    void drawRemoveCross(double x, double y, float cSize, float baseScale, float cWidth){
        cWidth *= cSize/baseScale;

        dTranslate(x, y);
        fill(color(160,30,30));
        beginShape();
        float min = -cSize/2;
        float max = cSize/2;
        float pythagorasC = sqrt(1/(float)2)*cWidth;


        vertex(min+pythagorasC, min);
        vertex(min, min+pythagorasC);
        vertex(max-pythagorasC, max);

        vertex(max-pythagorasC, max);
        vertex(max, max-pythagorasC);
        vertex(min+pythagorasC, min);




        vertex(min, max-pythagorasC);
        vertex(min+pythagorasC, max);
        vertex(max, min+pythagorasC);

        vertex(max, min+pythagorasC);
        vertex(max-pythagorasC, min);
        vertex(min, max-pythagorasC);


        endShape(CLOSE);
        dTranslate(-x, -y);
    }

    void drawOverEmpty() {
        pushMatrix();
        translate(ORIG_W_W, 0);
        fill(0);
        noStroke();
        rect(0, 0, ORIG_W_W*10, ORIG_W_H); //arbitrary size, just want to cover everything outside render range
        fill(0);
        popMatrix();
    }
    void drawFormattingError() {
        textFont(font, 150);
        fill(color(138,0,0));
        textAlign(CENTER);
        dText("Genome Formatting Error!", ORIG_W_W*0.5,ORIG_W_H*0.5);
    }

}

static class Dim{
    private final double x;
    private final double y;
    private final double w;
    private final double h;

    public Dim(double x, double y, double w, double h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    public double getX() {
        return x;
    }

    public double getY() {
        return y;
    }

    public double getW() {
        return w;
    }

    public double getH() {
        return h;
    }

}
