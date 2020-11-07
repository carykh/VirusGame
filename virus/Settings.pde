class Settings {
  
    private JSONObject settings;
    private JSONObject world;
    
    // Runtime Settings:
    public boolean show_ui = true;
    
    // Settings:
    public String genome;
    public String editor_default;
    public double gene_tick_time;
    public int max_food;
    public int max_waste;
    public double codon_degrade_speed;
    public double wall_damage;
    public double gene_tick_energy;
    public int world_size;
    public int[][] map_data;
    public double waste_disposal_chance_high;
    public double waste_disposal_chance_low;
    public double waste_disposal_chance_random;
    public double cell_wall_protection;
    public int particles_per_rand_update;
    public int max_codon_count;
    public int laser_linger_time;
    public double age_grow_speed;
    public double min_length_to_produce;
  
    public Settings() {
    
        settings = loadJSONObject("settings.json");
        world = loadJSONObject("world.json");
        
        genome = settings.getString("genome");
        editor_default = settings.getString("editor_default");
        gene_tick_time = settings.getDouble("gene_tick_time");
        max_food = settings.getInt("max_food");
        max_waste = settings.getInt("max_waste");
        codon_degrade_speed = settings.getDouble("codon_degrade_speed");
        wall_damage = settings.getDouble("wall_damage");
        gene_tick_energy = settings.getDouble("gene_tick_energy");
        waste_disposal_chance_high = settings.getDouble("waste_disposal_chance_high");
        waste_disposal_chance_low = settings.getDouble("waste_disposal_chance_low");
        waste_disposal_chance_random = settings.getDouble("waste_disposal_chance_random");
        cell_wall_protection = settings.getDouble("cell_wall_protection");
        particles_per_rand_update = settings.getInt("particles_per_rand_update");
        max_codon_count = settings.getInt("max_codon_count");
        laser_linger_time = settings.getInt("laser_linger_time");
        age_grow_speed = settings.getDouble("age_grow_speed");
        min_length_to_produce = settings.getDouble("min_length_to_produce");
        world_size = world.getInt("world_size") + 2;
        loadWorld( world.getJSONArray("map"), world_size - 2 );
    
    }
    
    public void loadWorld( JSONArray json, int size ) {
        map_data = new int[ size ][ size ];
        
        for( int y = 0; y < size; y ++ ) {
            JSONArray row = json.getJSONArray(y);
            for( int x = 0; x < size; x ++ ) {
                map_data[x][y] = row.getInt(x);
            }
        }
    }
  
}
