package net.danieldietrich.protectedregions.support;

import java.util.Set;

/**
 * Abstraction of a readable file system.
 * 
 * @author Daniel Dietrich - Initial contribution and API
 */
public interface IFileSystemReader {
  
  /**
   * Read contents of path.
   * @param fileName Path of file.
   * @return
   * @throws IllegalArgumentException if !isFile(path) == true
   */
  CharSequence readFile(String fileName);
  
  /**
   * Calls #listFiles(path, (IPathFilter) null).
   * @see #listFiles(String, IPathFilter)
   */
  Set<String> listFiles(String path);

  /**
   * Traverses path and returns <b>all</b> files contained in the whole subtree.
   * @param path a path containing files
   * @param filter filter, which accepts files
   * @return All files within all sub-paths of path, where isFile(element) == true, for all elements of the result
   * @throws IllegalArgumentException if !hasFiles(String path) == true
   */
  Set<String> listFiles(String path, IPathFilter filter);
  
  /**
   * Checks, if path contains files.
   * @param path A path
   * @return true, if path has files, false otherwise.
   */
  boolean hasFiles(String path);
  
  /**
   * Checks, if path contains readable data.
   * @param path A path
   * @return true, if path is file, false otherwise.
   */
  boolean isFile(String path);
  
  /**
   * Returns a unique representation of path.
   * @param path A path
   * @return A unique representation of path.
   */
  String getCanonicalPath(String path);

}
