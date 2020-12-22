package virusgame;

public enum CellType {
  Empty,
  Locked,
  Normal,
  Shell,
  UGO_Editor;

  public boolean isAlive() {
    return this == Normal || this == Shell;
  }

  public boolean isHurtable() {
    return this == Normal;
  }

  public boolean isType(Cell cell) {
    if (cell == null) return false;
    return this == cell.type;
  }
}
