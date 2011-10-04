package net.danieldietrich.protectedregions.xtext;

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

}
