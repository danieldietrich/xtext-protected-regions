package net.danieldietrich.protectedregions.xtext;

import net.danieldietrich.protectedregions.support.IFileSystemReader;

import org.eclipse.xtext.generator.AbstractFileSystemAccess;
import org.eclipse.xtext.generator.IFileSystemAccess;

/**
 * Bidirectional {@link IFileSystemAccess} with extended read operations, useful
 * for implementing protected region support.
 * 
 * @author Daniel Dietrich - Initial contribution and API
 * @author Hendy Irawan
 */
public interface IBidiFileSystemAccess extends IFileSystemAccess,
		IFileSystemReader {

  /**
   * Sets the default output path. This simpler form is required because the
   * default {@link AbstractFileSystemAccess#setOutputPath(String)} implementation
   * does not call {@link AbstractFileSystemAccess#setOutputPath(String, String)} but rather
   * setting the map directly via its protected {@link AbstractFileSystemAccess#getPathes()}.
   * 
   * @TODO I don't think that's right... rethink this decision. ~ceefour
   * 
   * @param path
   */
  public void setOutputPath(String path);

  /**
   * Sets an output path.
   * 
   * The default output slot name is {@link IFileSystemAccess#DEFAULT_OUTPUT}.
   * 
   * @param outputName
   * @param path
   */
  public void setOutputPath(String outputName, String path);

}
