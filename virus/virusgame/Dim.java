package virusgame;

public class Dim {
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
