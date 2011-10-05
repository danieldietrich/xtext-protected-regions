/**
 * 
 */
package net.danieldietrich.protectedregions.xtext;

import org.eclipse.xtext.generator.AbstractFileSystemAccess;

/**
 * Support interface to workaround issue #21, see https://github.com/danieldietrich/xtext-protectedregions/issues/21
 * 
 * @TODO Find a better, cleaner alternative.
 * @author ceefour
 *
 */
public interface IProtectedRegionSupportFactory {

  IBidiFileSystemAccess createFileSystemAccess();
  ProtectedRegionSupport createProtectedRegionSupport(IBidiFileSystemAccess delegate);
  
}
