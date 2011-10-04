package net.danieldietrich.protectedregions.xtext;

import java.net.URI;

import net.danieldietrich.protectedregions.support.IFileSystemReader;

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
	 * Returns the actual URI path.
	 * 
	 * Since a FileSystemAccess may be implemented on top of virtual filesystems
	 * (e.g. platform:/), so this return a URI (e.g. file:///) rather than just
	 * a filesystem path.
	 * 
	 * @param relativePath
	 * @param slot
	 * @return
	 */
	URI getUri(String relativePath, String slot);

}
