package net.danieldietrich.protectedregions.support;

import net.danieldietrich.protectedregions.core.IRegionParser;

/**
 * Convenient interface.
 * 
 * @author Daniel Dietrich - Initial contribution and API
 */
public interface IProtectedRegionSupport {

  /** add protected region parsers */
  void addParser(IRegionParser parser);
  /** add protected region parsers and associate with file extensions */
  void addParser(IRegionParser parser, String... fileExtensions);
  /** add protected region parsers and associate with a {@link IPathFilter} */
  void addParser(IRegionParser parser, IPathFilter filter);

  /**
   * Read protected regions using parsers added before
   * @param reader
   * @param slot The slot name, for example {@link IFileSystemAccess#DEFAULT_SLOT}.
   */
  void readRegions(IFileSystemReader reader, String slot);
  /**
   * makes an instance reusable
   */
  void clearRegions();

  /** merge protected regions read before into contents */
  CharSequence mergeRegions(IFileSystemReader reader, String fileName, String slot,
      CharSequence contents);

}
