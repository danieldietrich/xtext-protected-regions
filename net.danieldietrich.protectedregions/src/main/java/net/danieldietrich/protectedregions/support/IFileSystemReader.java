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
	 * Check if file exists.
	 * 
	 * @param uri
	 * @return
	 */
	boolean exists(URI uri);

	  /**
	 * Read contents of path.
	 * 
	 * @param fileName
	 *            Path of file.
	 * @return
	 * @throws IOException if error occurs or if !isFile(path) == true
	 */
	CharSequence readFile(URI uri) throws IOException;

  /**
   * Calls #listFiles(path, (IPathFilter) null).
   * @see #listFiles(String, IPathFilter)
   */
  Set<URI> listFiles(URI path);

  /**
   * Traverses path and returns <b>all</b> files contained in the whole subtree.
   * @param path a path containing files
   * @param filter filter, which accepts files
   * @return All files within all sub-paths of path, where isFile(element) == true, for all elements of the result
   * @throws IllegalArgumentException if !hasFiles(String path) == true
   */
  Set<URI> listFiles(URI path, IPathFilter filter);
  
  /**
   * Checks, if path contains files.
   * @param URI A URI.
   * @return true, if path has files, false otherwise.
   */
  boolean hasFiles(URI uri);
  
  /**
   * Checks, if path contains readable data.
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
