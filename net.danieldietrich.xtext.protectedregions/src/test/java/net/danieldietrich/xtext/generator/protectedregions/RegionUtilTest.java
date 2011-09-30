/**
 * 
 */
package net.danieldietrich.xtext.generator.protectedregions;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.regex.Pattern;

import org.apache.commons.io.IOUtils;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Daniel Dietrich - Initial contribution and API
 * @author ceefour
 *
 */
public class RegionUtilTest {

    private IRegionParser javaParser;
    
    @Before
    public void setup() {
      javaParser = RegionParserFactory.createJavaParser(MergeStyle.PROTECTED_REGION, true);
    }
    
    @Test
    public void mergeShouldMatchExpected() throws FileNotFoundException, IOException {
  
      IDocument currentDoc = javaParser.parse(new FileInputStream("src/test/resources/protected_current.txt"));
      IDocument previousDoc = javaParser.parse(new FileInputStream("src/test/resources/protected_previous.txt"));
  
      IDocument _merged = RegionUtil.merge(currentDoc, previousDoc);
      String mergedContents = _merged.getContents();
      String expectedContents = IOUtils.toString(new FileReader("src/test/resources/protected_expected.txt"));
  
      assertEquals(expectedContents, mergedContents);
    }
    
    @Test
    public void idsAreUniquePerFile() throws FileNotFoundException, IOException {
      try {
        javaParser.parse(new FileInputStream("src/test/resources/non_unique_ids.txt"));
      } catch(IllegalStateException x) {
        assertEquals(x.getMessage(), "Duplicate marked region id: uniqueId");
      }
    }

  IRegionOracle NESTED_COMMENT_ORACLE = new IRegionOracle() {
    // example: PROTECTED REGION /*1234*/ START
    private final Pattern PR_START = Pattern.compile("\\s*PROTECTED\\s+REGION\\s+/\\*\\s*[0-9]+\\s*\\*/\\s+(ENABLED\\s+)?START\\s*");
    private final Pattern PR_END = Pattern.compile("\\s*PROTECTED\\s+REGION\\s+END\\s*");

    @Override
    public boolean isMarkedRegionStart(String comment) {
      return PR_START.matcher(comment).matches();
    }

    @Override
    public boolean isMarkedRegionEnd(String comment) {
      return PR_END.matcher(comment).matches();
    }

    @Override
    public String getId(String markedRegionStart) {
      int i = markedRegionStart.indexOf("/*") + 1;
      int j = i + 1 + markedRegionStart.substring(i + 1).indexOf("*/");
      return (i != -1 && j != -1) ? markedRegionStart.substring(i + 1, j).trim() : null;
    }
    
    @Override
    public boolean isEnabled(String markedRegionStart) {
      return markedRegionStart.contains("ENABLED");
    }
  };

  @Test
  public void scaleHasNestedComments() throws FileNotFoundException, IOException {
    IRegionParser parser = RegionParserFactory.createDefaultScalaParser();
    parser.setOracle(NESTED_COMMENT_ORACLE);
    IDocument doc = parser.parse(new FileInputStream("src/test/resources/nested_comments.txt"));
    // Scala does not recognize nested comment-like id's
    assertTrue(doc.getMarkedRegion("1234") != null);
  }

  @Test
  public void javaHasntNestedComments() throws FileNotFoundException, IOException {
    IRegionParser parser = RegionParserFactory.createDefaultJavaParser();
    parser.setOracle(NESTED_COMMENT_ORACLE);
    IDocument doc = parser.parse(new FileInputStream("src/test/resources/nested_comments.txt"));
    // Java does not recognize nested comment-like id's
    assertTrue(doc.getMarkedRegion("1234") == null);
  }
  
  @Test
  public void switchedRegions() throws FileNotFoundException, IOException {

    IDocument currentDoc = javaParser.parse(new FileInputStream("src/test/resources/switched_current.txt"));
    IDocument previousDoc = javaParser.parse(new FileInputStream("src/test/resources/switched_previous.txt"));

    IDocument _merged = RegionUtil.merge(currentDoc, previousDoc);
    String mergedContents = _merged.getContents();
    String expectedContents = IOUtils.toString(new FileReader("src/test/resources/switched_expected.txt"));

    assertEquals(expectedContents, mergedContents);
  }
  
  IRegionOracle FILL_IN_ORACLE = new IRegionOracle() {
    // example: GENERATED ID(1234) START
    private final Pattern PR_START = Pattern.compile("\\s*GENERATED\\s+ID\\s*\\(\\s*[0-9]+\\s*\\)\\s+(DISABLED\\s+)?START\\s*");
    private final Pattern PR_END = Pattern.compile("\\s*GENERATED\\s+END\\s*");

    @Override
    public boolean isMarkedRegionStart(String comment) {
      return PR_START.matcher(comment).matches();
    }

    @Override
    public boolean isMarkedRegionEnd(String comment) {
      return PR_END.matcher(comment).matches();
    }

    @Override
    public String getId(String markedRegionStart) {
      int i = markedRegionStart.indexOf("(");
      int j = i + 1 + markedRegionStart.substring(i + 1).indexOf(")");
      return (i != -1 && j != -1) ? markedRegionStart.substring(i + 1, j).trim() : null;
    }
    
    @Override
    public boolean isEnabled(String markedRegionStart) {
      return !markedRegionStart.contains("DISABLED");
    }
  };

  @Test
  public void fillIn() throws FileNotFoundException, IOException {

    IRegionParser parser = RegionParserFactory.createDefaultJavaParser();
    parser.setOracle(FILL_IN_ORACLE);
    
    IDocument currentDoc = parser.parse(new FileInputStream("src/test/resources/fill_in_current.txt"));
    IDocument previousDoc = parser.parse(new FileInputStream("src/test/resources/fill_in_previous.txt"));

    IDocument _merged = RegionUtil.fillIn(currentDoc, previousDoc);
    String mergedContents = _merged.getContents();
    String expectedContents = IOUtils.toString(new FileReader("src/test/resources/fill_in_expected.txt"));

    assertEquals(expectedContents, mergedContents);
  }
  
  IRegionOracle SIMPLE_ORACLE = new IRegionOracle() {
    @Override public boolean isMarkedRegionStart(String s) {
      String _s = s.trim();
      return _s.startsWith("$(") && _s.endsWith(")-{");
    }
    @Override public boolean isMarkedRegionEnd(String s) {
      return "}-$".equals(s.trim());
    }
    @Override public String getId(String s) {
        int i = s.indexOf("(");
        int j = i + 1 + s.substring(i+1).indexOf(")");
        return (i != -1 && j != -1) ? s.substring(i+1, j).trim() : null;
    }
    @Override public boolean isEnabled(String s) {
      return true;
    }
  };
  
  @Test
  public void otherRegionNotation() throws FileNotFoundException, IOException {
    
    IRegionParser parser = new RegionParserBuilder()
    .addComment("/*", "*/")
    .addComment("//")
    .setMergeStyle(MergeStyle.PROTECTED_REGION)
    .setSwitchable(false)
    .build();
    
    parser.setOracle(SIMPLE_ORACLE);
    
    IDocument currentDoc = parser.parse(new FileInputStream("src/test/resources/simple_current.txt"));
    IDocument previousDoc = parser.parse(new FileInputStream("src/test/resources/simple_previous.txt"));
    
    IDocument _merged = RegionUtil.merge(currentDoc, previousDoc);
    String mergedContents = _merged.getContents();
    String expectedContents = IOUtils.toString(new FileReader("src/test/resources/simple_expected.txt"));

    assertEquals(expectedContents, mergedContents);
  }
  
  @Test
  public void xmlGenerator() throws FileNotFoundException, IOException {
    
    IRegionParser parser = RegionParserFactory.createDefaultXmlParser();
    
    IDocument currentDoc = parser.parse(new FileInputStream("src/test/resources/xml_current.txt"));
    IDocument previousDoc = parser.parse(new FileInputStream("src/test/resources/xml_previous.txt"));

    IDocument _merged = RegionUtil.merge(currentDoc, previousDoc);
    String mergedContents = _merged.getContents();
    String expectedContents = IOUtils.toString(new FileReader("src/test/resources/xml_expected.txt"));

    assertEquals(expectedContents, mergedContents);
  }
  
}
