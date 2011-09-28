/**
 * 
 */
package net.danieldietrich.xtext.generator.protectedregions;

import static org.junit.Assert.*;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.regex.Pattern;

import net.danieldietrich.xtext.generator.protectedregions.IDocument;
import net.danieldietrich.xtext.generator.protectedregions.IProtectedRegionParser;
import net.danieldietrich.xtext.generator.protectedregions.ProtectedRegionParserFactory;
import net.danieldietrich.xtext.generator.protectedregions.ProtectedRegionUtil;

import org.apache.commons.io.IOUtils;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Daniel Dietrich - Initial contribution and API
 * @author ceefour
 *
 */
public class ProtectedRegionUtilTest {

    private IProtectedRegionParser javaParser;
    
    @Before
    public void setup() {
      javaParser = ProtectedRegionParserFactory.createDefaultJavaParser();
    }
    
    @Test
    public void mergeShouldMatchExpected() throws FileNotFoundException, IOException {
  
      IDocument currentDoc = javaParser.parse(new FileInputStream("src/test/resources/current.txt"));
      IDocument previousDoc = javaParser.parse(new FileInputStream("src/test/resources/previous.txt"));
  
      IDocument _merged = ProtectedRegionUtil.merge(currentDoc, previousDoc);
      String mergedContents = _merged.getContents();
      String expectedContents = IOUtils.toString(new FileReader("src/test/resources/expected.txt"));
  
      assertEquals(expectedContents, mergedContents);
    }
    
    @Test
    public void idsAreUniquePerFile() throws FileNotFoundException, IOException {
      try {
        javaParser.parse(new FileInputStream("src/test/resources/non_unique_ids.txt"));
      } catch(IllegalStateException x) {
        assertEquals(x.getMessage(), "Duplicate protected region id: uniqueId");
      }
    }

  IProtectedRegionOracle NESTED_COMMENT_ORACLE = new IProtectedRegionOracle() {
    // example: PROTECTED REGION /*1234*/ START
    private final Pattern PR_START = Pattern.compile("\\s*PROTECTED\\s*REGION\\s*/\\*\\s*[0-9]+\\s*\\*/\\s*START\\s*");
    private final Pattern PR_END = Pattern.compile("\\s*PROTECTED\\s*REGION\\s*END\\s*");

    @Override
    public boolean isProtectedRegionStart(String comment) {
      return PR_START.matcher(comment).matches();
    }

    @Override
    public boolean isProtectedRegionEnd(String comment) {
      return PR_END.matcher(comment).matches();
    }

    @Override
    public String getId(String protectedRegionStart) {
      int i = protectedRegionStart.indexOf("/*") + 1;
      int j = i + 1 + protectedRegionStart.substring(i + 1).indexOf("*/");
      return (i != -1 && j != -1) ? protectedRegionStart.substring(i + 1, j).trim() : null;
    }
  };

  @Test
  public void scaleHasNestedComments() throws FileNotFoundException, IOException {
    IProtectedRegionParser parser = new DefaultProtectedRegionParser().addNestableComment("/*", "*/").addComment("//")
        .setOracle(NESTED_COMMENT_ORACLE);
    IDocument doc = parser.parse(new FileInputStream("src/test/resources/nested_comments.txt"));
    // Scala does not recognize nested comment-like id's
    assertTrue(doc.getProtectedRegion("1234") != null);
  }

  @Test
  public void javaHasntNestedComments() throws FileNotFoundException, IOException {
    IProtectedRegionParser parser = new DefaultProtectedRegionParser().addComment("/*", "*/").addComment("//")
        .setOracle(NESTED_COMMENT_ORACLE);
    IDocument doc = parser.parse(new FileInputStream("src/test/resources/nested_comments.txt"));
    // Java does not recognize nested comment-like id's
    assertTrue(doc.getProtectedRegion("1234") == null);
  }

}
