package net.danieldietrich.protectedregions.xtext;

import static org.junit.Assert.assertEquals;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import net.danieldietrich.protectedregions.core.IRegionParser;
import net.danieldietrich.protectedregions.core.RegionParserBuilder;
import net.danieldietrich.protectedregions.support.IPathFilter;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.generator.IGenerator;
import org.junit.Before;
import org.junit.Test;

public class ProtectedRegionSupportTest {

  private IRegionParser htmlParser;
  private IRegionParser phpParser;
  private IRegionParser jsParser;
  private IRegionParser cssParser;

  @Before
  public void setup() {
    htmlParser = new RegionParserBuilder().addComment("<!--", "-->").build();
    phpParser = new RegionParserBuilder().addComment("/*", "*/").addComment("//").addComment("#").build();
    jsParser = new RegionParserBuilder().addComment("/*", "*/").addComment("//").build();
    cssParser = new RegionParserBuilder().addComment("/*", "*/").build();
  }
  
  @Test
  public void generatorTest() throws Exception {
    
    TestFileSystemAccess delegate = new TestFileSystemAccess();
    
    IFileSystemAccess fsa = new ProtectedRegionSupport.Builder(delegate)
      .addParser(htmlParser, ".html")
      .addParser(phpParser, ".html")
      .addParser(jsParser, ".html")
      .addParser(cssParser, ".html")
      .read("src/test/resources", new IPathFilter() {
        @Override
        public boolean accept(String path) {
          return path.endsWith("_previous.html");
        }})
      .build();

    new TestGenerator().doGenerate("src/test/resources/multilang_current.html", fsa);
    
    String mergedContents = delegate.getResults().values().iterator().next().toString();
    String expectedContents = IOUtils.toString(new FileReader("src/test/resources/multilang_expected.html"));
    
    assertEquals(expectedContents, mergedContents);
  }
  
  private static class TestGenerator implements IGenerator {
    public void doGenerate(String fileName, IFileSystemAccess fsa) {
      CharSequence in = null;
      try {
        in = FileUtils.readFileToString(new File(fileName));
      } catch (IOException e) {
        throw new RuntimeException("error reading file " + fileName);
      }
      fsa.generateFile(fileName, in);
    }
    @Override
    public void doGenerate(Resource resource, IFileSystemAccess fsa) {
      throw new RuntimeException("Please call doGenerate(String, IFileSystemAccess) instead.");
    }
  }
  
  // write to Map
  private static class TestFileSystemAccess extends BidiJavaIoFileSystemAccess {
    private Map<String,CharSequence> results = new HashMap<String,CharSequence>();
    @Override
    public void generateFile(String fileName, String slot, CharSequence contents) {
      results.put(slot+"/"+fileName, contents);
    }
    Map<String,CharSequence> getResults() { return results; }
  }
  
}
