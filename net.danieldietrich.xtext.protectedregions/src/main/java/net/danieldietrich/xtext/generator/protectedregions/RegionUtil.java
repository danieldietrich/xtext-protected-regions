package net.danieldietrich.xtext.generator.protectedregions;

import net.danieldietrich.xtext.generator.protectedregions.IDocument.IRegion;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class RegionUtil {

  private RegionUtil() {
  }

  /**
   * Merges newly generated and manually changed files,
   * regarding their marked regions.
   * 
   * @param currentDoc The new generated IDocument, containing no manual code.
   * @param previousDoc The previously generated IDocument, possibly containing manual code. 
   * @return A new IDocument instance, containing current generated contents merged with previously changed marked regions.
   */
  public static IDocument merge(IDocument currentDoc, IDocument previousDoc) {
    DefaultDocument result = new DefaultDocument();
    for (IRegion generatedRegion : currentDoc.getRegions()) {
      IRegion markedRegion = null;
      if (generatedRegion.isMarkedRegion()) {
        IRegion previousRegion = previousDoc.getMarkedRegion(generatedRegion.getId());
        if (previousRegion != null && previousRegion.isEnabled()) {
          markedRegion = previousRegion;
        }
      }
      result.addRegion((markedRegion != null) ? markedRegion : generatedRegion);
    }
    return result;
  }
  
  /**
   * 
   * @param currentDoc The new generated IDocument, containing no manual code.
   * @param previousDoc The previously generated IDocument, possibly containing manual code. 
   * @return A new IDocument instance, containing previous contents merged with generated marked regions.
   */
  public static IDocument fillIn(IDocument currentDoc, IDocument previousDoc) {
    DefaultDocument result = new DefaultDocument();
    for (IRegion previousRegion : previousDoc.getRegions()) {
      IRegion markedRegion = null;
      if (previousRegion.isMarkedRegion()) {
        IRegion generatedRegion = currentDoc.getMarkedRegion(previousRegion.getId());
        if (generatedRegion != null && previousRegion.isEnabled()) {
          markedRegion = generatedRegion;
        }
      }
      result.addRegion((markedRegion != null) ? markedRegion : previousRegion);
    }
    return result;
  }

}
