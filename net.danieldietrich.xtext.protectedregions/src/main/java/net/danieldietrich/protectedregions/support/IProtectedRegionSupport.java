package net.danieldietrich.protectedregions.support;

import java.util.Map;

import net.danieldietrich.protectedregions.core.IRegionParser;
import net.danieldietrich.protectedregions.core.IDocument.IRegion;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public interface IProtectedRegionSupport {

  /**
   * Merge protected regions into contents.
   * Using fileName to determine parser, reading regions from pool.
   * 
   * @param fileName Caution: physical file name (probably not equal to generated, e.g. if using s.th. like slots)
   * @param contents generated contents
   * @return merged contents
   */
  CharSequence mergeProtectedRegions(String fileName, CharSequence contents);
  void setParsers(Map<IPathFilter,IRegionParser> parsers);
  void setProtectedRegionPool(Map<String,IRegion> protectedRegionPool);
  
  static interface IBuilder<T extends IProtectedRegionSupport> {
    IBuilder<T> addParser(IRegionParser parser);
    IBuilder<T> addParser(IRegionParser parser, String... fileExtensions);
    IBuilder<T> addParser(IRegionParser parser, IPathFilter filter);
    IBuilder<T> read(String path);
    IBuilder<T> read(String path, IPathFilter filter);
    T build();
  }
}
