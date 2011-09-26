/**
 * 
 */
package net.danieldietrich.xtext.bifsa;

import java.io.IOException;

import org.eclipse.xtext.generator.IFileSystemAccess;

/**
 * {@link IFileSystemAccess} interface with extended read operations,
 * useful for implementing protected region support.
 * 
 * @author ceefour
 */
public interface IBiFileSystemAccess extends IFileSystemAccess {

	/**
	 * Check if file exists.
	 * @param fileName
	 * @return
	 */
	public boolean fileExists(String fileName);
	
	/**
	 * Return file contents.
	 * @param fileName
	 * @return
	 * @throws IOException
	 */
	public String getFileContents(String fileName) throws IOException;
	
}
