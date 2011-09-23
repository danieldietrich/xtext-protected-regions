import net.danieldietrich.xtext.generator.protectedregionsupport.runtime.IDocument;
import net.danieldietrich.xtext.generator.protectedregionsupport.runtime.ProtectedRegionUtil;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class Main {

  public static void main(String[] args) throws Exception {
    
    IDocument _generated = ProtectedRegionUtil.parse("test/generated.txt");
    IDocument _protected = ProtectedRegionUtil.parse("test/protected.txt");
    IDocument _merged = ProtectedRegionUtil.merge(_generated, _protected);
    
    System.out.println( _merged.getContents() );
    
  }
  
}
