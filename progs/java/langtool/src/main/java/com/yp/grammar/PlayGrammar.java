package com.yp.grammar;

import java.io.*;
import java.util.*;
import org.languagetool.*;
import org.languagetool.rules.*;

public class PlayGrammar {
  public PlayGrammar()  {
  }
  public static void main(String a[]) throws IOException {
    JLanguageTool langTool = new JLanguageTool(Language.AMERICAN_ENGLISH);
    langTool.activateDefaultPatternRules();
    List<RuleMatch> matches = langTool.check(a[0],true,JLanguageTool.ParagraphHandling.ONLYNONPARA);
    for (RuleMatch match : matches) {
      List<String> replacements = match.getSuggestedReplacements();
      StringTokenizer tokens = new StringTokenizer(a[0].substring(match.getFromPos()));
      System.out.println(tokens.nextToken());
      System.out.println(match.getShortMessage() + "|" + a[0].substring(match.getFromPos(),match.getToPos()) + "|" + replacements.get(0) + "|");
    }
  }
}
