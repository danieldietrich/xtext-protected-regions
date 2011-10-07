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
  void addParser(IRegionParser parser, String... fileExtensions);
  void addParser(IRegionParser parser, IPathFilter filter);

  /** read protected regions using parsers added before */
  void readRegions(IFileSystemReader reader, String relativePath);
  void clearRegions();

  /** merge protected regions read before into contents */
  CharSequence mergeRegions(IFileSystemReader reader, String fileName, String slot,
      CharSequence contents);

}
