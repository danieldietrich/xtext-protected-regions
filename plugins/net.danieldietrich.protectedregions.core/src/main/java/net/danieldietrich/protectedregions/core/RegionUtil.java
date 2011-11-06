package net.danieldietrich.protectedregions.core;

import java.util.Map;

import net.danieldietrich.protectedregions.core.IDocument.IRegion;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class RegionUtil {

  private RegionUtil() {
  }

  /**
   * Calls {@link #merge(IDocument, HasMarkedRegions)}.
   * @param currentDoc A newly generated document.
   * @param previousDoc An IDocument with previously generated code which probably has manual changes.
   * @return A new IDocument instance, containing current generated contents merged with previously changed marked regions.
   */
  public static IDocument merge(IDocument currentDoc, final IDocument previousDoc) {
    return merge(currentDoc, new HasMarkedRegions() {
      //@Override
      public IRegion get(String id) {
        return previousDoc.getMarkedRegion(id);
      }
    });
  }
  
  /**
   * Calls {@link #merge(IDocument, HasMarkedRegions)}
   * @param currentDoc A newly generated document.
   * @param pool An pool of IRegions containing previously generated code which probably has manual changes.
   * @return A new IDocument instance, containing current generated contents merged with previously changed marked regions.
   */
  public static IDocument merge(IDocument currentDoc, final Map<String,IRegion> pool) {
    return merge(currentDoc, new HasMarkedRegions() {
      //@Override
      public IRegion get(String id) {
        return pool.get(id);
      }
    });
  }
  
  /**
   * Interface needed to generalize merge method.
   */
  private static interface HasMarkedRegions {
    IRegion get(String id);
  }
  
  /**
   * Merges newly generated and manually changed files,
   * regarding their marked regions.
   * 
   * @param currentDoc The new generated IDocument, containing no manual code.
   * @param hasMarkedRegion An arbitrary source of previously generated IRegions which probably contain manual changes.
   * @return A new IDocument instance, containing current generated contents merged with previously changed marked regions.
   */
  private static IDocument merge(IDocument currentDoc, HasMarkedRegions hasMarkedRegions) {
    DefaultDocument result = new DefaultDocument();
    for (IRegion generatedRegion : currentDoc.getRegions()) {
      IRegion markedRegion = null;
      if (generatedRegion.isMarkedRegion()) {
        IRegion previousRegion = hasMarkedRegions.get(generatedRegion.getId());
        if (previousRegion != null && previousRegion.isEnabled()) {
          markedRegion = previousRegion;
        }
      }
      result.addRegion((markedRegion != null) ? markedRegion : generatedRegion);
    }
    return result;
  }
  
  /**
   * Fills in generated regions, if switchable && enabled or !switchable.
   * By default the whole document is protected.
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
