package net.danieldietrich.protectedregions.support;

import java.util.Map;

import net.danieldietrich.protectedregions.core.IRegionParser;
import net.danieldietrich.protectedregions.core.IDocument.IRegion;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public interface IProtectedRegionSupport {

  /**
   * Merge protected regions into contents. Using fileName to determine parser, reading regions from pool.
   * 
   * @param fileName Caution: physical file name (probably not equal to generated, e.g. if using s.th. like slots)
   * @param contents generated contents
   * @return merged contents
   */
  CharSequence mergeProtectedRegions(String fileName, CharSequence contents);
  void setParsers(Map<IPathFilter,IRegionParser> parsers);
  void setProtectedRegionPool(Map<String,IRegion> protectedRegionPool);
  
  /**
   * <h1>Caution:</h1>
   * 
   * <h2>Same Comment Starts</h2>
   * Different IRegionParsers may parse same files (because their IPathFilter accepts the same file or
   * they where added with the same file extension). If these parsers have the same comment starts,
   * protected regions are potentially parsed twice. Example: PHP and JavaScript both use <code>/*</code>
   * start string for multiline comments. Implementations of IBuilder have to be robust in the manner,
   * that already parsed protected regions are not taken into account when parsing them again (within
   * the same file). On the other hand an IllegalStateException has to be thrown, if different files
   * contain the same protected region id.
   * 
   * <h2>Nested Comments</h2>
   * There may be border cases, where nested comment parsers are colliding with non-nested comment parsers
   * in the manner, that protected regions are only partially read. In real life these cases have to be
   * constructed and thus it is safe to disregard them.
   * 
   * <h2>Different Languages</h2>
   * Also there may be side effects when using parsers for same files and different languages.<br>
   * <br>
   * 
   * @param <T> Type returned by {@link #build()}
   */
  static interface IBuilder<T extends IProtectedRegionSupport> {
    IBuilder<T> addParser(IRegionParser parser);
    IBuilder<T> addParser(IRegionParser parser, String... fileExtensions);
    IBuilder<T> addParser(IRegionParser parser, IPathFilter filter);
    IBuilder<T> read(String path);
    IBuilder<T> read(String path, IPathFilter filter);
    T build();
  }
}
