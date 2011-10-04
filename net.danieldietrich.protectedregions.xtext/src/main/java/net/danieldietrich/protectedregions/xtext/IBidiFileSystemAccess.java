package net.danieldietrich.protectedregions.xtext;

import net.danieldietrich.protectedregions.support.IFileSystemReader;

import org.eclipse.xtext.generator.IFileSystemAccess;

/**
 * Bidirectional {@link IFileSystemAccess}.
 * 
 * @author Daniel Dietrich - Initial contribution and API
 */
public interface IBidiFileSystemAccess extends IFileSystemAccess, IFileSystemReader {
  
  String getPath(String fileName, String slot);
  
}
