/**
 * 
 */
package net.danieldietrich.xtext.generator.protectedregions;

import static org.junit.Assert.assertEquals;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

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

  private IProtectedRegionParser parser;
  
  @Before
  public void setup() {
    parser = ProtectedRegionParserFactory.createDefaultJavaParser();
  }
  
  @Test
  public void mergeShouldMatchExpected() throws FileNotFoundException, IOException {

    IDocument currentDoc = parser.parse(new FileInputStream("src/test/resources/current.txt"));
    IDocument previousDoc = parser.parse(new FileInputStream("src/test/resources/previous.txt"));

    IDocument _merged = ProtectedRegionUtil.merge(currentDoc, previousDoc);
    String mergedContents = _merged.getContents();
    String expectedContents = IOUtils.toString(new FileReader("src/test/resources/expected.txt"));

    assertEquals(expectedContents, mergedContents);
  }
  
  @Test
  public void idsAreUniquePerFile() throws FileNotFoundException, IOException {
    
    try {
      parser.parse(new FileInputStream("src/test/resources/non_unique_ids.txt"));
    } catch(IllegalStateException x) {
      assertEquals(x.getMessage(), "Duplicate protected region id: uniqueId");
    }
  }

}
