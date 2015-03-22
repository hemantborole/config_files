
import java.io.File;
import java.io.IOException;

import org.apache.commons.io.LineIterator;
import org.apache.commons.io.FileUtils;

public class Grep {
  public static void main(String a[]) throws IOException {
    LineIterator it = FileUtils.lineIterator(new File("/tmp/dict.txt"), "UTF-8");
    try{
      while (it.hasNext()){
        String line = it.nextLine();
        if(line.matches(".*\\bsome\\b.*")){
          System.out.println("Found word");
        }
      }
    } finally {
      LineIterator.closeQuietly(it);
    }
  }
}
