package net.danieldietrich.protectedregions.support.xtext;

import net.danieldietrich.protectedregions.support.IFileSystemReader;

import org.eclipse.xtext.generator.IFileSystemAccess;

/**
 * Bidirectional FileSystemAccess
 * 
 * @author Daniel Dietrich - Initial contribution and API
 */
public interface IBidiFileSystemAccess extends IFileSystemAccess, IFileSystemReader {
  
  String getPath(String fileName, String slot);
  
}
