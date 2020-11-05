
boolean isPressed = false;
boolean doubleClick = false; // not realy double click - find better name
boolean wasMouseDown = false;
double clickWorldX = -1;
double clickWorldY = -1;

void keyPressed() {
  
    // disable/enble GUI
    if( key == 'x' || key == 'X' ) {
        settings.show_ui = !settings.show_ui;
        renderer.maxRight = settings.show_ui ? height : width;
    }
  
}

void mouseWheel(MouseEvent event) {
  
    double thisZoomF = event.getCount() == 1 ? 1/1.05 : 1.05;
    double worldX = mouseX/renderer.camS+renderer.camX;
    double worldY = mouseY/renderer.camS+renderer.camY;
    renderer.camX = (renderer.camX-worldX)/thisZoomF+worldX;
    renderer.camY = (renderer.camY-worldY)/thisZoomF+worldY;
    renderer.camS *= thisZoomF;
    
}

void detectMouse(){
  
    if (mousePressed) {
        editor.arrow = null;
        if(!wasMouseDown) {
            if(mouseX < renderer.maxRight){
                editor.codonToEdit[0] = editor.codonToEdit[1] = -1;
                clickWorldX = renderer.appXtoTrueX(mouseX);
                clickWorldY = renderer.appYtoTrueY(mouseY);
                isPressed = true;
            }else{
                editor.checkInput();
                isPressed = false;
            }
            doubleClick = true;
        }else if(isPressed){
          
            double newCX = renderer.appXtoTrueX(mouseX);
            double newCY = renderer.appYtoTrueY(mouseY);
            
            if(newCX != clickWorldX || newCY != clickWorldY){
                doubleClick = false;
            }
            if(editor.selected == editor.ugo){
                stroke(0, 0, 0);
                editor.arrow = new double[]{clickWorldX,clickWorldY,newCX,newCY};
            }else{
                renderer.camX -= (newCX-clickWorldX);
                renderer.camY -= (newCY-clickWorldY);
            }
        }
        
    }else{
        if(wasMouseDown) {
            if(editor.selected == editor.ugo && editor.arrow != null){
                if(euclidLength(editor.arrow) > settings.min_length_to_produce){
                    editor.produce();
                }
            }
            if(doubleClick && isPressed){
                Cell clickedCell = world.getCellAtUnscaled(clickWorldX, clickWorldY);
                if(editor.selected != editor.ugo){
                    editor.close();
                }
                if(clickedCell != null && clickedCell.type == CellType.Normal){
                    editor.open( clickedCell );
                }
            }
        }
        clickWorldX = -1;
        clickWorldY = -1;
        editor.arrow = null;
    }
    wasMouseDown = mousePressed;
}
