package virusgame;

import processing.data.JSONArray;
import processing.data.JSONObject;


import static virusgame.Var.*;
import static virusgame.Const.*;
import static virusgame.Method.*;
import static virusgame.Util.*;

public class Settings {
  
    private JSONObject settings;
    private JSONObject world;
    
    // Runtime settings:
    public boolean show_ui = true;
    public boolean show_tampered = false;
    public boolean show_debug = false;
    
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
    public double mutability;
    public int graph_length;
    public boolean graph_downscale;
    public int graph_update_period;
  
    public Settings() {
    
        settings = loadJSONObject("settings.json");
        world = loadJSONObject("world.json");
        
        genome = settings.getString("genome");
        editor_default = settings.getString("editor_default");
        gene_tick_time = settings.getDouble("gene_tick_time");
        max_food = settings.getInt("max_food");
        max_waste = settings.getInt("max_waste");
        codon_degrade_speed = settings.getDouble("codon_degrade_speed");
        graph_length = settings.getInt("graph_length");
        graph_update_period = settings.getInt("graph_update_period");
        graph_downscale = settings.getBoolean("graph_downscale");
        wall_damage = settings.getDouble("wall_damage");
        gene_tick_energy = settings.getDouble("gene_tick_energy");
        mutability = settings.getDouble("mutability");
        waste_disposal_chance_high = settings.getDouble("waste_disposal_chance_high");
        waste_disposal_chance_low = settings.getDouble("waste_disposal_chance_low");
        waste_disposal_chance_random = settings.getDouble("waste_disposal_chance_random");
        cell_wall_protection = settings.getDouble("cell_wall_protection");
        particles_per_rand_update = settings.getInt("particles_per_rand_update");
        max_codon_count = settings.getInt("max_codon_count");
        laser_linger_time = settings.getInt("laser_linger_time");
        age_grow_speed = settings.getDouble("age_grow_speed");
        min_length_to_produce = settings.getDouble("min_length_to_produce");
        world_size = world.getInt("world_size");
        loadWorld( world.getJSONArray("map"), world_size );
    
    }
    
    public void loadWorld(JSONArray json, int size ) {
        map_data = new int[ size ][ size ];
        
        for( int y = 0; y < size; y ++ ) {
            JSONArray row = json.getJSONArray(y);
            for( int x = 0; x < size; x ++ ) {
                map_data[x][y] = row.getInt(x);
            }
        }
    }
  
}
