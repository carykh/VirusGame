package virus;

import static java.lang.Math.PI;

public enum Direction {
    Up(0, 1, 0.5),
    Down(0, -1, 1.5),
    Left(-1, 0, 1),
    Right(1, 0, 0),
    ;

    public final int modX;
    public final int modY;
    public final double stdAngle;

    Direction(int modX, int modY, double stdAngle) {
        this.modX = modX;
        this.modY = modY;
        this.stdAngle = stdAngle * PI;
    }
}
