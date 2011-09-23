package net.danieldietrich.xtext.generator.protectedregionsupport.generator;
import org.antlr.Tool;

// @see http://www.eclipse.org/forums/index.php/t/216713/
public class Gen {

  private static final String INPUT_PATH = "src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/";
  private static final String OUTPUT_PATH = "src-gen/net/danieldietrich/xtext/generator/protectedregionsupport/runtime";
  
  public static void main(String[] args) {
    
    Tool tool = new Tool();
    tool.setOutputDirectory(OUTPUT_PATH);
    tool.setForceAllFilesToOutputDir(true);
    tool.addGrammarFile(INPUT_PATH + "ProtectedRegionSupport.g");
    tool.process();
    
  }
  
}
