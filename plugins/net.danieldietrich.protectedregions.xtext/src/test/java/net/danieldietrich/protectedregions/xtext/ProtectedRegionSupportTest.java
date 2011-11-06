package net.danieldietrich.protectedregions.xtext;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.io.FileReader;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

import net.danieldietrich.protectedregions.core.IRegionParser;
import net.danieldietrich.protectedregions.core.RegionParserFactory;
import net.danieldietrich.protectedregions.support.IPathFilter;
import net.danieldietrich.protectedregions.support.IProtectedRegionSupport;
import net.danieldietrich.protectedregions.support.ProtectedRegionSupport;

import org.apache.commons.io.IOUtils;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.generator.IGenerator;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class ProtectedRegionSupportTest {

  private TestGenerator testGenerator;

  private IRegionParser cssParser;
  private IRegionParser htmlParser;
  private IRegionParser javaParser;
  private IRegionParser jsParser;
  private IRegionParser phpParser;
  private IRegionParser xmlParser;

  @Before
  public void setup() {

    // generator
    testGenerator = new TestGenerator();

    // parsers
    cssParser = RegionParserFactory.createCssParser();
    htmlParser = RegionParserFactory.createHtmlParser();
    javaParser = RegionParserFactory.createJavaParser();
    jsParser = RegionParserFactory.createJavaScriptParser();
    phpParser = RegionParserFactory.createPhpParser();
    xmlParser = RegionParserFactory.createXmlParser();

  }

  @Test
  public void mergeOfMultilanguageFilesShouldMatchExpected() throws Exception {

    /*
     * css has escaped double quotes in strings, html/xml not. that's currently not considered here
     * when combining parsers(!)
     */
    IProtectedRegionSupport support = new ProtectedRegionSupport();
    support.addParser(htmlParser, ".html");
    support.addParser(phpParser, ".html");
    support.addParser(jsParser, ".html");
    support.addParser(cssParser, ".html");

    // create FileSystemAccess, which reads protected regions when calling setOuputPath(...)
    TestableBidiJavaIoFileSystemAccess fsa = new TestableBidiJavaIoFileSystemAccess(support);
    fsa.setFilter(new EndsWithFilter("multilang_previous.html"));
    fsa.setOutputPath("src/test/resources");

    // start generator (writing via fsa.generateFile(...))
    testGenerator.doGenerate("src/test/resources/multilang_current.html", fsa);

    // test results
    String mergedContents = fsa.getSingleResult();
    String expectedContents =
        IOUtils.toString(new FileReader("src/test/resources/multilang_expected.html"));

    assertEquals(expectedContents, mergedContents);
  }

  @Test
  public void nonUniqueIdsShouldBeGloballyDetected() throws Exception {

    IProtectedRegionSupport support = new ProtectedRegionSupport();
    support.addParser(javaParser, ".java");

    TestableBidiJavaIoFileSystemAccess fsa = new TestableBidiJavaIoFileSystemAccess(support);
    fsa.setFilter(new PatternFilter(".*\\/duplicate_id_\\d.java"));

    try {
      fsa.setOutputPath("src/test/resources");
      assertTrue("Duplicate id not recognized", false);
    } catch (IllegalStateException x) {
      assertTrue("Other exception catched as expected: " + x.getMessage(),
          "Duplicate protected region id: 'duplicate'. Protected region ids have to be globally unique."
              .equals(x.getMessage()));
    }
  }

  @Test
  public void protectedRegionStartInStringLiteralShouldBeIgnored() throws Exception {

    IProtectedRegionSupport support = new ProtectedRegionSupport();
    support.addParser(javaParser, ".java");

    TestableBidiJavaIoFileSystemAccess fsa = new TestableBidiJavaIoFileSystemAccess(support);
    fsa.setFilter(new EndsWithFilter("string_literals_ignore_start.java"));

    try {
      fsa.setOutputPath("src/test/resources");
    } catch (IllegalStateException x) {
      assertTrue("Protected region start in string literal not ignored. Original message: "
          + x.getMessage(), false);
    }
  }

  @Test
  public void protectedRegionEndInStringLiteralShouldBeIgnored() throws Exception {

    IProtectedRegionSupport support = new ProtectedRegionSupport();
    support.addParser(javaParser, ".java");

    TestableBidiJavaIoFileSystemAccess fsa = new TestableBidiJavaIoFileSystemAccess(support);
    fsa.setFilter(new EndsWithFilter("string_literals_ignore_end.java"));

    try {
      fsa.setOutputPath("src/test/resources");
    } catch (IllegalStateException x) {
      assertTrue("Protected region end in string literal not ignored. Original message: "
          + x.getMessage(), false);
    }
  }

  @Test
  public void protectedRegionStartInXmlCDATAShouldBeIgnored() throws Exception {

    IProtectedRegionSupport support = new ProtectedRegionSupport();
    support.addParser(xmlParser, ".xml");

    TestableBidiJavaIoFileSystemAccess fsa = new TestableBidiJavaIoFileSystemAccess(support);
    fsa.setFilter(new EndsWithFilter("string_literals_ignore_cdata.xml"));

    try {
      fsa.setOutputPath("src/test/resources");
    } catch (IllegalStateException x) {
      assertTrue("Protected region end in xml CDATA not ignored. Original message: "
          + x.getMessage(), false);
    }
  }

  @Test
  public void commentsInStringLiteralsShouldBeIgnored() throws URISyntaxException {

    IProtectedRegionSupport support = new ProtectedRegionSupport();
    support.addParser(javaParser, ".java");

    TestableBidiJavaIoFileSystemAccess fsa = new TestableBidiJavaIoFileSystemAccess(support);
    fsa.setFilter(new EndsWithFilter("string_literals_ignore_comments.java"));

    try {
      fsa.setOutputPath("src/test/resources");
    } catch (IllegalStateException x) {
      assertTrue(
          "Comments in string literals are not ignored. Original message: " + x.getMessage(), false);
    }
  }
  
  @Test
  public void ensureStringLiteralsParsedCorrectly() {
	  
	IProtectedRegionSupport support = new ProtectedRegionSupport();
	support.addParser(javaParser, ".java");
	
	TestableBidiJavaIoFileSystemAccess fsa = new TestableBidiJavaIoFileSystemAccess(support);
	fsa.setFilter(new EndsWithFilter("ensure_str_literals_parsed_correctly.java"));
	
	fsa.setOutputPath("src/test/resources");
  }

  /**
   * A Generator taking a (String) fileName instead of a Resource as argument.
   */
  static class TestGenerator implements IGenerator {
    //@Override
    public void doGenerate(Resource input, IFileSystemAccess fsa) {
      throw new IllegalStateException("Call #doGenerate(String, IFileSystemAccess) instead.");
    }

    public void doGenerate(String fileName, IFileSystemAccess fsa) throws IOException {
      // simulating current generated file by reading an existing file
      String current = IOUtils.toString(new FileReader(fileName));
      fsa.generateFile(fileName, current);
    }
  }

  /**
   * Writes files to an in-memory Map of fileName => Contents.
   */
  static class TestableBidiJavaIoFileSystemAccess extends BidiJavaIoFileSystemAccess {

    private Map<String, String> results = new HashMap<String, String>();

    public TestableBidiJavaIoFileSystemAccess(IProtectedRegionSupport support) {
      super(support);
    }

    @Override
    public void generateFile(String fileName, CharSequence contents) {
      String mergedContents =
          getSupport().mergeRegions(this, fileName, DEFAULT_OUTPUT, contents).toString();
      results.put(fileName, mergedContents);
    }

    @Override
    public void generateFile(String fileName, String slot, CharSequence contents) {
      String mergedContents = getSupport().mergeRegions(this, fileName, slot, contents).toString();
      results.put(fileName, mergedContents);
    }

    public Map<String, String> getResults() {
      return results;
    }

    public String getSingleResult() {
      if (results.size() == 0) {
        throw new IllegalStateException("result is empty");
      }
      if (results.size() > 1) {
        throw new IllegalStateException("not a single result");
      }
      return results.values().iterator().next();
    }
  }

  /**
   * Filter checking if a path ends with a name.
   */
  static class EndsWithFilter implements IPathFilter {

    private String name;

    EndsWithFilter(String name) {
      this.name = name;
    }

    //@Override
    public boolean accept(URI path) {
      return path.getPath().endsWith(name);
    }
  }

  /**
   * Filter checking if a pattern matches a path.
   */
  static class PatternFilter implements IPathFilter {

    private final Pattern pattern;

    PatternFilter(String pattern) {
      this.pattern = Pattern.compile(pattern);
    }

    //@Override
    public boolean accept(URI path) {
      return pattern.matcher(path.getPath()).matches();
    }
  }
}
