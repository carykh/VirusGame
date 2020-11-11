class Graph {

    GraphFrame[] frames;
    int offset = 0;
    int highest = 0;
    //int first;

    public Graph( int len ) {
        frames = new GraphFrame[len];
        //first = len;
        for(int i = 0; i < len; i++) frames[i] = new GraphFrame();
    }
    
    public void append( GraphFrame frame ) {
        offset = (offset + 1) % frames.length;
        frames[offset] = frame;
        int h = frame.getHighest();
        
        if( h > highest ) {
            highest = h;
        }else{
            highest = getHighest(true);
        }
        
        //first --;
    }
    
    public void drawSelf( float x, float y, float w, float h ) {
      
        int hi = max( 200, highest );
        float uy = h / hi;
        float ux = w / (frames.length - 1);
        float ls = hi / 16.0f;
        float ly = (h - 20) / hi;
        
        pushMatrix();
        translate(x, y - h);
        strokeWeight(4);
        
        // draw background
        fill(80);
        rect( 0, 0, w, h );
        
        // draw scale
        fill(255, 255, 255, 150);
        textAlign(LEFT);
        textFont(font, 20);
        for( int i = 16; i >= 0; i -- ) {
            text( "" + floor( ls * i ), 4, (16 - i) * ls * ly + 20 );
        }
        
        GraphFrame last = frames[ (offset + 1) % frames.length ];
        
        for( int i = 2; i <= frames.length; i ++ ) {
            int pos = (offset + i) % frames.length;
            //if( i < first ) continue;
            
            float x1 = ux * (i - 2);
            float x2 = ux * (i - 1);
            
            last = frames[ pos ].drawSelf( x1, x2, uy, h, last );
        }
        
        popMatrix();
      
    }
    
    public int getHighest( boolean update ) {
        if( !update ) return highest;
        
        int hi = highest;
        
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
    
    public GraphFrame drawSelf( float x1, float x2, float u, float h, GraphFrame last ) {
      
        stroke(GRAPH_WASTES);
        line( x1, h - last.wastes * u, x2, h - this.wastes * u );
        
        stroke(GRAPH_UGOS);
        line( x1, h - last.ugos * u, x2, h - this.ugos * u );
        
        stroke(GRAPH_CELLS);
        line( x1, h - last.cells * u, x2, h - this.cells * u );
      
        return this;
    }
  
}
