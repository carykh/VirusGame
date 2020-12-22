package virus;

import processing.core.PFont;

import static virus.Const.*;

public final class Var {

  //###SCREEN
  public static int W_W = ORIG_W_W;
  public static int W_H = ORIG_W_H;

  //###VAR
  public static float PLAY_SPEED = DEBUG_WORLD?40:0.6f;
  public static float scalefactor = 1;

  public static Settings settings;
  public static World world;
  public static Renderer renderer;
  public static Editor editor;
  public static Graph graph;
  public static PFont font;

  public static VirusGame game = new VirusGame();
  public static Input input = new Input();
}
