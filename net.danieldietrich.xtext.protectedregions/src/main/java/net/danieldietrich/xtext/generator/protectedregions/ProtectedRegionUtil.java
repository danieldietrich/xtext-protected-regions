package net.danieldietrich.xtext.generator.protectedregions;

import net.danieldietrich.xtext.generator.protectedregions.IDocument.IRegion;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class ProtectedRegionUtil {

  private ProtectedRegionUtil() {
  }
  
  /**
   * Merges newly generated and manually changed files,
   * regarding their protected regions.
   * 
   * @param currentDoc The new generated IDocument, containing no manual code.
   * @param previousDoc The previously generated IDocument, possibly containing manual code. 
   * @return A new IDocument instance, containing current generated contents merged with previously changed protected regions.
   */
  public static IDocument merge(IDocument currentDoc, IDocument previousDoc) {
    DefaultDocument result = new DefaultDocument();
    for (IRegion generatedRegion : currentDoc.getRegions()) {
      IRegion protectedRegion = null;
      if (generatedRegion.isProtectedRegion()) {
        protectedRegion = previousDoc.getProtectedRegion(generatedRegion.getId());
      }
      result.addRegion((protectedRegion != null) ? protectedRegion : generatedRegion);
    }
    return result;
  }
  
}
