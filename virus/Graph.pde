class Graph {

    private GraphFrame[] frames;
    private int offset = 0;
    private int highest = 0;
    private boolean redraw = true;
    private PGraphics canvas = null;
    private boolean rescan = true;

    public Graph( int len, int w, int h ) {
        frames = new GraphFrame[len];
        canvas = createGraphics( w, h );
        for(int i = 0; i < len; i++) frames[i] = new GraphFrame();
    }
    
    public void append( GraphFrame frame ) {
        offset = (offset + 1) % frames.length;
        frames[offset] = frame;
        int h = frame.getHighest();
        
        if( h >= highest ) {
            highest = h;
        }else if( highest > 200 && rescan ) {
            highest = getHighest(true);
        }
        
        redraw = true;
    }
    
    public void setRescan( boolean rescan ) {
        this.rescan = rescan; 
    }
    
    public void resize( int w, int h ) {
         canvas = createGraphics( w, h );
         redraw = true;
    }
    
    public void drawSelf( float x, float y ) {
      
        if( redraw ) {
          
            final int hi = max( 200, highest );
            final float uy = (float) canvas.height / hi;
            final float ux = (float) canvas.width / (frames.length - 1);
            final float ls = hi / 16.0f;
            final float ly = ((float) canvas.height - 20) / hi;
          
            canvas.beginDraw();
            canvas.strokeWeight(4);
            
            canvas.fill(80);
            canvas.noStroke();
            canvas.rect( 0, 0, canvas.width, canvas.height );
            
            canvas.fill(255, 255, 255, 150);
            canvas.textAlign(LEFT);
            canvas.textFont(font, 20);
            
            for( int i = 16; i >= 0; i -- ) {
                canvas.text( "" + floor( ls * i ), 4, (16 - i) * ls * ly + 20 );
            }

            GraphFrame last = frames[ (offset + 1) % frames.length ];
        
            for( int i = 2; i <= frames.length; i ++ ) {
                int pos = (offset + i) % frames.length;
            
                float x1 = ux * (i - 2);
                float x2 = ux * (i - 1);
                
                //canvas.stroke(0, 0, 0, 32);
                //canvas.strokeWeight(1);
                //canvas.line(x2, 0, x2, canvas.height);
                //canvas.strokeWeight(4);
            
                last = frames[ pos ].drawSelf( canvas, x1, x2, uy, canvas.height, last );
            }
        
            canvas.endDraw();
            redraw = false;
            
        }
        
        image(canvas, x, y - canvas.height);
      
    }
    
    public int getHighest( boolean update ) {
        if( !update ) return highest;
        
        int hi = frames[0].getHighest();
        
        for( int i = 1; i <= frames.length; i ++ ) {
            int pos = (offset + i) % frames.length;
            int h = frames[pos].getHighest();
            if( h > hi ) hi = h;
        }
        
        return hi;
    }

}

class GraphFrame {
  
    public int wastes = 0;
    public int ugos = 0;
    public int cells = 0;
    
    public GraphFrame( int wastes, int ugos, int cells ) {
        this.wastes = wastes;
        this.ugos = ugos;
        this.cells = cells;
    }
    
    public GraphFrame() {
        super();
    }
    
    public int getHighest() {
        int a = max( wastes, ugos );
        return max( a, cells );
    }
    
    public GraphFrame drawSelf( PGraphics canvas, float x1, float x2, float u, float h, GraphFrame last ) {
      
        canvas.stroke(GRAPH_WASTES);
        canvas.line( x1, h - last.wastes * u, x2, h - this.wastes * u );
        
        canvas.stroke(GRAPH_UGOS);
        canvas.line( x1, h - last.ugos * u, x2, h - this.ugos * u );
        
        canvas.stroke(GRAPH_CELLS);
        canvas.line( x1, h - last.cells * u, x2, h - this.cells * u );
      
        return this;
    }
  
}
