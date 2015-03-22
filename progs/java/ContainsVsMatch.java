import java.io.*;
import java.util.*;

public class ContainsVsMatch  {

  List<String> wordList;
  String allWords;

  public ContainsVsMatch()  {
    wordList = new ArrayList<String>();
    allWords = "";

    BufferedReader b = new BufferedReader(new File("/tmp/words.txt"));
    String line = "";
    while( (line = b.readLine()) != null )  {
      word = line.trim().toLowerCase();
      allWords += words;
      wordList.put(word);
    }
  }

  public boolean contains(String token) {
    return wordList.contains(token);
  }

  public boolean found(String token)  {
    return allWords.contains(token);
  }

  public static void main(String a[]) {
    String token = "general";

    ContainsVsMatch c = new ContainsVsMatch();
    c.contains(token);

    c.found(token);
  }
}
