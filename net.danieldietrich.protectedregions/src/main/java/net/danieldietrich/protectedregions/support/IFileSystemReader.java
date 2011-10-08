package net.danieldietrich.protectedregions.support;

import java.io.IOException;
import java.net.URI;
import java.util.Set;

/**
 * Abstraction of a readable file system.
 * 
 * @author Daniel Dietrich - Initial contribution and API
 * @author Hendy Irawan
 */
public interface IFileSystemReader {

  /**
   * Returns an IPathFilter accepting paths read by this IFileSystemReader.
   * 
   * @return
   */
  IPathFilter getFilter();
  
  /**
   * Set the IPathFilter accepting paths read by this IFileSystemReader.
   * 
   * @param filter
   */
  void setFilter(IPathFilter filter);
  
  /**
   * Returns the resolved URI path of the given relative path on the {@link IFileSystemAccess#DEFAULT_OUTPUT} slot.
   * 
   * @param relativePath
   * @return
   */
  URI getUri(String relativePath);
  
  /**
   * Returns the URI path.
   * 
   * Since a FileSystemAccess may be implemented on top of virtual filesystems (e.g. platform:/), so
   * this returns a URI (e.g. file:/ or platform:/) rather than just a filesystem path.
   * 
   * @param relativePath
   * @param slot
   * @return
   */
  URI getUri(String relativePath, String slot);

  /**
   * Check if file exists.
   * 
   * @param uri
   * @return
   */
  boolean exists(URI uri);

  /**
   * Read contents of path.
   * 
   * @param fileName Path of file.
   * @return
   * @throws IOException if error occurs or if !isFile(path) == true
   */
  CharSequence readFile(URI uri) throws IOException;

  /**
   * Traverses path and returns <b>all</b> files contained in the whole subtree.
   * 
   * @param path a path containing files
   * @return All files within all sub-paths of path, where isFile(element) == true, for all elements
   *         of the result
   * @throws IllegalArgumentException if !hasFiles(String path) == true
   */
  Set<URI> listFiles(URI path);

  /**
   * Checks, if path contains files.
   * 
   * @param URI A URI.
   * @return true, if path has files, false otherwise.
   */
  boolean hasFiles(URI uri);

  /**
   * Checks, if path contains readable data.
   * 
   * @param uri A path URI
   * @return true, if path is file, false otherwise.
   */
  boolean isFile(URI uri);

  /**
   * Returns a unique representation of a path. The meaning of this path if filesystem-specific.
   * 
   * @param uri URI
   * @return A unique representation of path.
   */
  String getCanonicalPath(URI uri);

}
