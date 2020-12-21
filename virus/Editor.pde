class Editor {

    private boolean open = false;
    public Cell ugoCell;
    public Cell selected;
    public UGO ugoSelected;
    public int dragAndDropCodonId = -1;
    double dragAndDropRX;
    double dragAndDropRY;


    public int selx = 0;
    public int sely = 0;

    public int[] codonToEdit = {-1,-1,0,0};
    public double[] arrow = null;

    Editor( Settings settings ) {
        ugoCell = new Cell(-1, -1, CellType.Normal, 0, 1, settings.editor_default);
    }

    public void select( int x, int y ) {
        open = true;
        selected = world.getCellAt( x, y );
        selx = x;
        sely = y;
        ugoSelected = null;
    }

    public void openUGO() {
        open = true;
        selected = ugoCell;
        ugoSelected = null;
    }

    public void openUGO(UGO ugo) {
        open = true;
        selected = null;
        ugoSelected = ugo;
    }

    public void close() {
        open = false;
        selected = null;
        ugoSelected = null;
    }

    public boolean isOpened() {
        return open;
    }

    public void drawSelf() {
        boolean isNotUGO = (selected != ugoCell);

        fill(80);
        noStroke();
        rect(10, 160, 530, ORIG_W_H - 10);  //changed from 170 to 10, why?

        if (selected != null) {

            if(isNotUGO){
                rect(540, 160, 200, 270);
            }

            fill(255);
            textFont(font, 96);
            textAlign(LEFT);
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

                    {//This is writing out epigenetics info //todo make pretty
                        textAlign(RIGHT);
                        int offset = 0;
                        List<Codon> codons = selected.genome.codons;
                        SortedSet<Integer> foundIds = new TreeSet(); //i know this is very wasteful of objects but we cannot do better than this, luckily just once per frame
                        HashMap<Integer, Integer> from = new HashMap();
                        HashMap<Integer, Integer> to = new HashMap();
                        for(int i = 0; i < codons.size();i++) {
                            Codon c = codons.get(i);
                            foundIds.addAll(c.memorySetFrom);
                            for(int j:c.memorySetFrom) {
                                from.put(j, i);
                            }
                            for(int j:c.memorySetTo) {
                                to.put(j, i);
                            }
                        }
                        for (int i:foundIds) {
                            text(i + ":" + from.get(i) + ", " + to.get(i),545,440+(offset++)*32);
                        }
                    }
                }

                renderer.drawButtonTable(EDIT_LIST_DIMS, codonToEdit[0]==0?codonTypeButtons:codonAttributeButtons);
            }

        } else if (ugoSelected != null) {
            fill(255);
            textFont(font, 96);
            textAlign(LEFT);
            text("Selected UGO", 25, 255);
            renderer.drawGenomeAsList(ugoSelected.genome, GENOME_LIST_DIMS);
        } else{
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

            checkEditListClick(codonToEdit[0] < 0);
            if( selected != null && selected.hasGenome() )checkGenomeListClick();

            if(mouseX > ORIG_W_W - 160 && mouseY < 160) {
                close();
            }
        } else if(mouseX > ORIG_W_W - 160 && mouseY < 160) {
            openUGO();
        }
    }

    void checkGenomeListClick() {
        if (dragAndDropCodonId > 0)return;
        double gx = GENOME_LIST_DIMS.getX(); //GENOME_LIST_DIMS[0]
        double gy = GENOME_LIST_DIMS.getY(); //GENOME_LIST_DIMS[1]
        double gw = GENOME_LIST_DIMS.getW(); //GENOME_LIST_DIMS[2]
        double gh = GENOME_LIST_DIMS.getH(); //GENOME_LIST_DIMS[3]
        double rmx = (((mouseX/scalefactor)-ORIG_W_H)-gx)/gw;
        double rmy = ((mouseY/scalefactor)-gy)/gh;

        //add arrow
        Genome g = selected.genome;
        int GENOME_LENGTH = g.codons.size();
        int offset = Math.max(0, Math.min(g.scrollOffset, GENOME_LENGTH-VIEW_FIELD_DIS_CNT));

        if (GENOME_LENGTH > VIEW_FIELD_DIS_CNT) {
            GENOME_LENGTH = VIEW_FIELD_DIS_CNT;
        }

        double appCodonHeight = gh/GENOME_LENGTH;

        double arrowUIX =  (mouseX/scalefactor) - gx - ORIG_W_H;
        double arrowUIY = (mouseY/scalefactor) - gy + appCodonHeight/2;
        int arrowRowY = (int)(arrowUIY/appCodonHeight);
        double arrowH = min(80, (float)appCodonHeight);

        double crossUIX =  (mouseX/scalefactor) - gx - ORIG_W_H - gw;
        double crossUIY = (mouseY/scalefactor) - gy;
        int rowCY = (int)(crossUIY/appCodonHeight);

        if(rmx >= 0 && rmx < 1 && rmy >= 0){
            if(rmy < 1){
                codonToEdit[0] = (int) (rmx * 2);
                codonToEdit[1] = (int)(rmy*min(selected.genome.codons.size(), VIEW_FIELD_DIS_CNT)) + selected.genome.scrollOffset;
            }else if(selected == ugoCell){
                String genomeString = (rmx < 0.5)
                        ? ugoCell.genome.getGenomeStringShortened()
                        : ugoCell.genome.getGenomeStringLengthened();

                selected = ugoCell = new Cell(-1, -1, CellType.Normal, 0, 1, genomeString);
            }
        } else if (arrowRowY >= 0 && arrowRowY <= GENOME_LENGTH && arrowUIX >= -50 && arrowUIX <= 5) {
            g.codons.add(arrowRowY + offset, new Codon());
        } else if (rowCY >= 0 && rowCY < GENOME_LENGTH && crossUIX >= -5 && crossUIX <= 50) {
            g.codons.remove(rowCY + offset);
            if (g.codons.size() == 0) {
                g.codons.add(new Codon());
            }

        }

    }
    void checkEditListClick( boolean divineControls ) {
        double ex = EDIT_LIST_DIMS.getX(); //EDIT_LIST_DIMS[0]
        double ey = EDIT_LIST_DIMS.getY(); //EDIT_LIST_DIMS[1]
        double ew = EDIT_LIST_DIMS.getW(); //EDIT_LIST_DIMS[2]
        double eh = EDIT_LIST_DIMS.getH(); //EDIT_LIST_DIMS[3] //todo verify

        //codon rows
        double rmx = (((mouseX/scalefactor)-ORIG_W_H)-ex)/ew;
        double rmy = ((mouseY/scalefactor)-ey)/eh;
        if(rmx >= 0 && rmx < 1 && rmy >= 0 && rmy < 1) {
            Button[] currentButtons = codonToEdit[0]==0?codonTypeButtons:codonAttributeButtons;


            int optionCount = divineControls ? DIVINE_CONTROLS.length : currentButtons.length;
            int choice = (int)(rmy*optionCount);

            if( divineControls ) {
                divineIntervention( choice );
                return;
            }

            boolean changeMade = currentButtons[choice].onClick(rmx, rmy);
            if(changeMade && selected != ugoCell){
                changeMade = true;
                game.lastEditTimeStamp = frameCount;
                selected.tamper();
            }

            if (codonToEdit[0] == 1 && choice >= optionCount-2) {
                int diff = 1;
                if (rmx < 0.5) {
                    diff = -1;
                }
                if (choice == optionCount-2) {
                    codonToEdit[2] = util.loopCodonInfo(codonToEdit[2]+diff);
                } else {
                    codonToEdit[3] = util.loopCodonInfo(codonToEdit[3]+diff);
                }

                if(selected != ugoCell) {
                    world.lastEditFrame = frameCount;
                    selected.tamper();
                }
            }

        }else{
            codonToEdit[0] = codonToEdit[1] = -1;
            input.scrollLocked = true;
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

            UGO u = new UGO(arrow, ugoCell.genome.getGenomeString());
            u.markDivine();
            world.addParticle(u);
            world.lastEditFrame = frameCount;

        }

    }

    void checkGLdrag() {
        double gx = GENOME_LIST_DIMS.getX();
        double gy = GENOME_LIST_DIMS.getY();
        double gw = GENOME_LIST_DIMS.getW();
        double gh = GENOME_LIST_DIMS.getH();
        double rmx = (((mouseX/scalefactor)-ORIG_W_H)-gx)/gw;
        double rmy = ((mouseY/scalefactor)-gy)/gh;

        Genome g = selected.genome;
        int GENOME_LENGTH = g.codons.size();
        if (GENOME_LENGTH > VIEW_FIELD_DIS_CNT) {
            GENOME_LENGTH = VIEW_FIELD_DIS_CNT;
        }
        double appCodonHeight = gh/GENOME_LENGTH;

        if(rmx >= 0 && rmx < 1 && rmy >= 0 && rmy < 1){
            if(rmy < 1){

                dragAndDropCodonId = (int)(rmy*min(g.codons.size(), VIEW_FIELD_DIS_CNT)) + g.scrollOffset;
                dragAndDropRX = rmx * gw;
                dragAndDropRY = rmy * gh - appCodonHeight * (dragAndDropCodonId - g.scrollOffset);
                codonToEdit[0] = codonToEdit[1] = -1;
            }
        }
    }


    void releaseGLdrag() {
        double gx = GENOME_LIST_DIMS.getX();
        double gy = GENOME_LIST_DIMS.getY();
        double gw = GENOME_LIST_DIMS.getW();
        double gh = GENOME_LIST_DIMS.getH();

        double minX =-0.25*gw;
        double maxX =+1.25*gw;


        Genome g = selected.genome;
        int GENOME_LENGTH = g.codons.size();
        if (GENOME_LENGTH > VIEW_FIELD_DIS_CNT) {
            GENOME_LENGTH = VIEW_FIELD_DIS_CNT;
        }
        double appCodonHeight = gh/GENOME_LENGTH;

        double arrowUIX =  (mouseX/scalefactor) - gx - ORIG_W_H;
        double arrowUIY = (mouseY/scalefactor) - gy + appCodonHeight/2;
        int arrowRowY = (int)(arrowUIY/appCodonHeight);
        if (arrowRowY >= 0 && arrowRowY <= GENOME_LENGTH && arrowUIX > minX && arrowUIX <= maxX) {
            Codon dragged =g.codons.get(dragAndDropCodonId);
            int newId = arrowRowY + g.scrollOffset;
            if (newId != dragAndDropCodonId) {
                if (newId > dragAndDropCodonId)newId--;
                g.codons.remove(dragAndDropCodonId);
                g.codons.add(newId, dragged);
            }
        }
        dragAndDropCodonId = -1;

    }



    Button[] codonAttributeButtons = new Button[CodonAttributes.values().length];
    AttributeRGL editRGL = new AttributeRGL(0,0);
    AttributeMemoryLocation editMemoryLoc = new AttributeMemoryLocation(0);
    AttributeMark editMark = new AttributeMark(0);
    AttributeDegree editDegree = new AttributeDegree(0);
    {
        ArrayList<Button> buttons = new ArrayList();

        for(int i = 0; i < CodonAttributes.values().length; i++){
            CodonAttribute att = CodonAttributes.values()[i].v;
            if (att instanceof AttributeRGL)att=editRGL;  //todo OOP this
            if (att instanceof AttributeMemoryLocation)att=editMemoryLoc;
            if (att instanceof AttributeMark)att=editMark;
            if (att instanceof AttributeDegree)att=editDegree;
            buttons.add(new ButtonEditAttribute(att));
        }

        int rglPos = CodonAttributes.RGL00.ordinal() + 1;
        buttons.add(rglPos, new ButtonChangeRGL(editRGL, "- RGL end +", false));
        buttons.add(rglPos, new ButtonChangeRGL(editRGL, "- RGL start +", true));
        int memLocPos = CodonAttributes.MemoryLocation.ordinal() + 3;
        buttons.add(memLocPos, new ButtonChangeMemoryLocation(editMemoryLoc, "- MemLoc Id +"));
        int markPos = CodonAttributes.Mark.ordinal() + 4;
        buttons.add(markPos, new ButtonChangeMark(editMark, "- Mark Id +"));
        int degPos = CodonAttributes.Degree.ordinal() + 5;
        buttons.add(degPos, new ButtonChangeDegree(editDegree, "-- -  0  + ++"));

        codonAttributeButtons = buttons.toArray(new Button[buttons.size()]);
    }



    Button[] codonTypeButtons = new Button[CodonTypes.values().length];
    {
        for(int i = 0; i < CodonTypes.values().length; i++){
            codonTypeButtons[i] = new ButtonEditCodonType(CodonTypes.values()[i].v);
        }
    }

}

class Button {
    private String text;
    color foreColor;
    color backColor;

    public Button(String text, color foreColor, color backColor) {
        this.text = text;
        this.foreColor = foreColor;
        this.backColor = backColor;
    }

    public String getText() {
        return text;
    }

    public boolean onClick(double rMouseX, double rMouseY) {
        return false;//noOp
    }

    protected void drawButton(double x, double y, double w, double h, color back, color fore, String text) {
        fill(back);
        renderer.dRect(x,y,w,h);
        fill(fore);
        renderer.dText(text,x+ w*0.5,y+h/2+11);
    }

    public void drawButton(double x, double y, double w, double h) {
        drawButton(x,y,w,h,backColor,foreColor, getText());
    }
}

class ButtonChangeRGL extends Button{
    boolean start;
    AttributeRGL editRGL;
    public ButtonChangeRGL(AttributeRGL editRGL, String text, boolean start) {
        super(text, color(255,255,255), color(90,90,90));
        this.start = start;
        this.editRGL = editRGL;
    }

    public boolean onClick(double rMouseX, double rMouseY) {
        int diff = 1;
        if(rMouseX < 0.5){
            diff = -1;
        }

        if (start) {
            editRGL.loc += diff;
        } else {

            editRGL.end += diff;
        }
        return false;
    }
}

class ButtonChangeMemoryLocation extends Button{
    private final AttributeMemoryLocation editMemoryLoc;

    public ButtonChangeMemoryLocation(AttributeMemoryLocation editMemoryLoc, String text) {
        super(text, color(255,255,255), color(90,90,90));
        this.editMemoryLoc = editMemoryLoc;
    }

    public boolean onClick(double rMouseX, double rMouseY) {
        int diff = 1;
        if(rMouseX < 0.5){
            diff = -1;
        }


        editMemoryLoc.memoryId += diff;
        return false;
    }
}

class ButtonChangeMark extends Button{
    private final AttributeMark editMark;

    public ButtonChangeMark(AttributeMark editMark, String text) {
        super(text, color(255,255,255), color(90,90,90));
        this.editMark = editMark;
    }

    public boolean onClick(double rMouseX, double rMouseY) {
        int diff = 1;
        if(rMouseX < 0.5){
            diff = -1;
        }


        editMark.markId += diff;
        return false;
    }
}


class ButtonChangeDegree extends Button{
    private AttributeDegree editDegree;

    public ButtonChangeDegree(AttributeDegree editDegree, String text) {
        super(text, color(255,255,255), color(90,90,90));
        this.editDegree = editDegree;
    }

    public boolean onClick(double rMouseX, double rMouseY) {
        int id = (int)(rMouseX*5);
        switch (id) {
            case 0:
                editDegree.setDegree(editDegree.getDegree()-45);
                break;
            case 1:
                editDegree.setDegree(editDegree.getDegree()-1);
                break;
            case 2:
                editDegree.setDegree(0);
                break;
            case 3:
                editDegree.setDegree(editDegree.getDegree()+1);
                break;
            case 4:
                editDegree.setDegree(editDegree.getDegree()+45);
                break;
        }
        return false;
    }

    private String[] buttons = {"--", "-", "0", "+", "++"};
    public void drawButton(double x, double y, double w, double h) {
        double offset = w/5;
        for(int i=0;i<5;i++) {
            drawButton(x+offset*i,y,w/5,h,backColor,foreColor, buttons[i]);
        }
    }
}



class ButtonCommon extends Button {
    CommonBase common;

    public ButtonCommon(CommonBase common) {
        super(common.getTextSimple(), util.intToColor((common.getTextColor())), util.intToColor(common.getColor()));
        this.common = common;
    }


    public String getText() {
        return common.getTextSimple();
    }

}



class ButtonEditAttribute extends ButtonCommon {
    CodonAttribute attribute;

    public ButtonEditAttribute(CodonAttribute attribute) {
        super(attribute);
        this.attribute = attribute;
    }

    public boolean onClick(double rMouseX, double rMouseY) {
        Codon thisCodon = editor.selected.genome.codons.get(editor.codonToEdit[1]);

        //why what so confused, can we get rid  of this, not supposed to be here!
        AttributeRGL oldRGL = thisCodon.getAttribute() instanceof AttributeRGL?(AttributeRGL)thisCodon.getAttribute():null;
        if (oldRGL == null || oldRGL.getStartLocation() != editor.codonToEdit[2] || oldRGL.getEndLocation() != editor.codonToEdit[3]) {
            thisCodon.setAttribute(new AttributeRGL(editor.codonToEdit[2], editor.codonToEdit[3]));
        } else {
            return false;
        }
        thisCodon.setAttribute(attribute);
        return true;
    }
}

class ButtonEditCodonType extends ButtonCommon {
    CodonType type;

    public ButtonEditCodonType(CodonType type) {
        super(type);
        this.type = type;
    }

    public boolean onClick(double rMouseX, double rMouseY) {
        Codon thisCodon = editor.selected.genome.codons.get(editor.codonToEdit[1]);
        thisCodon.setType(type);
        return true;
    }

}
