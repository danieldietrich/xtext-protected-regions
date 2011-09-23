package net.danieldietrich.xtext.generator.protectedregionsupport.runtime;

import java.io.IOException;

import org.antlr.runtime.ANTLRFileStream;
import org.antlr.runtime.ANTLRStringStream;
import org.antlr.runtime.CharStream;
import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.RecognitionException;

import net.danieldietrich.xtext.generator.protectedregionsupport.runtime.IDocument.IPart;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class ProtectedRegionUtil {

  private ProtectedRegionUtil() {
  }
  
  /**
   * Parses a specific file which contains protected regions.
   * 
   * @param fileName
   * @return
   */
  public static IDocument parse(String fileName) {
    try {
      return parse(new ANTLRFileStream(fileName));
    } catch(IOException x) {
      throw new RuntimeException("unable to open file " + fileName, x);
    }
  }
  
  public static IDocument parse(CharSequence input) {
    return parse(new ANTLRStringStream(input.toString()));
  }
  
  private static IDocument parse(CharStream input) {
    ProtectedRegionSupportLexer lexer = new ProtectedRegionSupportLexer(input);
    CommonTokenStream tokenStream = new CommonTokenStream(lexer);
    ProtectedRegionSupportParser parser = new ProtectedRegionSupportParser(tokenStream);
    IWritableDocument doc = new DefaultWritableDocument();
    try {
      parser.document(doc);
    } catch(RecognitionException x) {
      throw new RuntimeException("error parsing protected regions", x);
    }
    return doc;
  }
  
  /**
   * Merges newly generated and manually changed files,
   * regarding their protected regions.
   * 
   * @param _generated The new
   * @param _protected
   * @return
   */
  public static IDocument merge(IDocument _generated, IDocument _protected) {
    DefaultDocument result = new DefaultDocument();
    for (IPart gPart : _generated.getParts()) {
      IPart pPart = null;
      if (gPart.isProtectedRegion()) {
        pPart = _protected.getProtectedRegion(gPart.getId());
      }
      result.addPart( (pPart != null) ? pPart : gPart );
    }
    return result;
  }
  
}
