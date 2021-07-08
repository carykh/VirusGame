package virus;

import static processing.core.PApplet.*;
import static virus.Const.*;
import static virus.Var.*;
import static virus.Method.*;
import static virus.Util.*;

public class Particle {

  protected double[] coor;
  protected double speed;
  protected double direction;
  public boolean removed = false;
  public int birthFrame;
  public ParticleType type;


  private Particle(double[] tcoor, ParticleType ttype, int b, boolean unused) {
    coor = tcoor;
    type = ttype;
    birthFrame = b;

    if (type == ParticleType.Food) world.totalFoodCount++;
    else if (type == ParticleType.Waste) world.totalWasteCount++;
  }

  public Particle(double[] tcoor, ParticleType ttype, int b) {
    this(tcoor, ttype, b, false);
    double[] vd = getRandomVelocityDirection();
    speed = vd[0];
    direction = vd[1];
  }

  public Particle(double[] tcoor, double[] v, ParticleType ttype, int b) {
    this(tcoor, ttype, b, false);
    speed = Math.sqrt(v[0]*v[0] + v[1]*v[1]);
    direction = Math.atan2(v[1],  v[0]);
  }

  public Particle(double[] tcoor, double speed, double direction, ParticleType ttype, int b) {
    this(tcoor, ttype, b, false);
    this.speed = speed;
    this.direction = direction;
  }

  void drawSelf() {

    double posx = renderer.trueXtoAppX(coor[0]);
    double posy = renderer.trueYtoAppY(coor[1]);

    if (posx > 0 && posy > 0 && posx < renderer.maxRight && posy < ORIG_W_H) {

      pushMatrix();
      renderer.dTranslate(posx, posy);
      double ageScale = Math.min(1.0, (getFrameCount() - birthFrame) * settings.age_grow_speed);
      scale((float) (renderer.camS / BIG_FACTOR * ageScale));
      noStroke();

      if (type == ParticleType.Food) {
        fill(FOOD_COLOR);
      } else if (type == ParticleType.Waste) {
        fill(WASTE_COLOR);
      }

      ellipseMode(CENTER);
      ellipse(0, 0, 0.1f * BIG_FACTOR, 0.1f * BIG_FACTOR);
      popMatrix();

    }

  }

  public void tick() {
    double[] future = {0, 0};
    CellType ct = world.getCellTypeAt(coor[0], coor[1]);

    if (ct == CellType.Locked) removeParticle(world.getCellAt(coor[0], coor[1]));

    double visc = ct == CellType.Empty ? 1 : 0.5f;
    double speedRnd = Math.random() * 0.2f + 0.9f;
    double dirRnd = (Math.random()-0.5) * PI * 0.21;
    double dirChange = (Math.random()-0.5) * PI * 0.101 * type.brownianCoefficient;
    direction += dirChange;
    direction += 4 * PI; //force positive
    direction %= 2 * PI;

    future[0] = coor[0] + speed * speedRnd * visc * PLAY_SPEED * Math.cos(direction + dirRnd);
    future[1] = coor[1] + speed * speedRnd * visc * PLAY_SPEED * Math.sin(direction + dirRnd);

    boolean cta = checkCellBoundary(coor[0], future[0]);
    boolean ctb = checkCellBoundary(coor[1], future[1]);

    if (cta || ctb) {


      CellType ft = world.getCellTypeAt(future[0], future[1]);

      if (interact(future, ct, ft)) return;

      if (ft == CellType.Locked || (type != ParticleType.Food && (ct != CellType.Empty || ft != CellType.Empty))) {

        Cell b_cell = world.getCellAt(future[0], future[1]);
        if (b_cell != null && b_cell.type.isHurtable()) {
          b_cell.hurtWall(cta && ctb ? 2 : 1);
        }

        if (cta) {
          //check if speed is in x direction
          if (direction < 0.5 * PI || direction > 1.5 * PI) {
            future[0] = Math.ceil(coor[0]) - EPS;
            direction = 2*Direction.Up.stdAngle - direction;
          } else {
            future[0] = Math.floor(coor[0]) + EPS;
            direction = 2*Direction.Down.stdAngle - direction;
          }

          direction += 4 * PI; //force positive
          direction %= 2 * PI;

          //velo[0] = -velo[0] + (Math.random() * 0.05 - 0.025) * SPEED_LOW; //why rnd? to avoid particle highways trapped between cells
        }

        if (ctb) {
          //check if speed is in y direction
          if (direction < PI) {
            future[1] = Math.ceil(coor[1]) - EPS;
            direction = 2*Direction.Left.stdAngle - direction;
          } else {
            future[1] = Math.floor(coor[1]) + EPS;
            direction = 2*Direction.Right.stdAngle - direction;
          }

          //velo[1] = -velo[1] + (Math.random() * 0.05 - 0.025) * SPEED_LOW;
        }

        Cell t_cell = world.getCellAt(coor[0], coor[1]);
        if (t_cell != null && t_cell.type.isHurtable()) {
          t_cell.hurtWall(cta && ctb ? 2 : 1);
        }

      } else {

        if (future[0] >= settings.world_size) {
          future[0] -= settings.world_size;
          border(0);
        } else if (future[0] < 0) {
          future[0] += settings.world_size;
          border(1);
        } else if (future[1] >= settings.world_size) {
          future[1] -= settings.world_size;
          border(2);
        } else if (future[1] < 0) {
          future[1] += settings.world_size;
          border(3);
        }

        hurtWalls(coor, future);
      }

    }

    coor = future;

  }

  public void randomTick() {
    if (type == ParticleType.Waste) {
      if (random(0, 1) < settings.waste_disposal_chance_random && world.getCellAt(coor[0], coor[1]) == null)
        removeParticle(null);
    }
  }

  private void border(int wid) {
    if (type == ParticleType.Waste) { //todo think about this
      if (world.pc.wastes.size() > settings.max_waste && random(0, 1) < settings.waste_disposal_chance_high)
        removeParticle(null);
      if (random(0, 1) < settings.waste_disposal_chance_low) removeParticle(null);
    }
  }

  public double[] copyCoor() {
    double[] result = new double[2];
    result[0] = coor[0];
    result[1] = coor[1];
    return result;
  }

  protected void hurtWalls(double[] coor, double[] future) {

    Cell p_cell = world.getCellAt(coor[0], coor[1]);
    if (p_cell != null) {
      if (p_cell.type.isHurtable()) {
        p_cell.hurtWall(1);
      }
      p_cell.removeParticle(this);
    }

    Cell n_cell = world.getCellAt(future[0], future[1]);
    if (n_cell != null) {
      if (n_cell.type.isHurtable()) {
        n_cell.hurtWall(1);
      }
      n_cell.addParticle(this);
    }

  }

  public void removeParticle(Cell c) {
    removed = true;
    if (c != null) c.removeParticle(this);
  }

  public void addToCellList() {
    Cell c = world.getCellAt(coor[0], coor[1]);
    if (c != null) c.addParticle(this);
  }

  protected boolean interact(double[] future, CellType cType, CellType fType) {
    return false;
  }
}

enum ParticleType {
  Food(0.8),
  Waste(1),
  UGO(0.4);

  public final double brownianCoefficient;

  ParticleType(double brownianCoefficient) {
    this.brownianCoefficient = brownianCoefficient;
  }

  public static ParticleType fromId(int id) {
    switch (id) {
      case 0:
        return ParticleType.Food;
      case 1:
        return ParticleType.Waste;
      case 2:
        return ParticleType.UGO;
    }
    return null;
  }
}
