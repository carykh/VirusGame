package virusgame;

import java.awt.*;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.StringSelection;
import java.awt.datatransfer.UnsupportedFlavorException;
import java.io.IOException;

public class ClipboardHelper {

  public static void copyStringToClipboard(String selection) {
    StringSelection data = new StringSelection(selection);
    Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
    clipboard.setContents(data, null);
  }

  public static String getStringFromClipboard() {
    Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
    try {
      return (String)clipboard.getData(DataFlavor.stringFlavor);
    } catch (UnsupportedFlavorException e) {
      return null;
    } catch (IOException e) {
      return null;
    }
  }

}
