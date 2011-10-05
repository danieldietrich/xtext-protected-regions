/**
 * 
 */
package net.danieldietrich.protectedregions.xtext;

import org.eclipse.xtext.generator.JavaIoFileSystemAccess;

/**
 * Wraps a {@link ProtectedRegionSupport} so it can be Guice-injected as a {@link JavaIoFileSystemAccess}.
 * See https://github.com/danieldietrich/xtext-protectedregions/issues/21
 * 
 * @author ceefour
 *
 */
public class JavaIoWrapper extends JavaIoFileSystemAccess {

  ProtectedRegionSupport prs;
  
  public JavaIoWrapper(ProtectedRegionSupport prs) {
    this.prs = prs;
  }
  
  @Override
  public void generateFile(String fileName, String slot, CharSequence contents) {
    prs.generateFile(fileName, slot, contents);
  }
  
  @Override
  public void deleteFile(String fileName) {
    prs.deleteFile(fileName);
  }

  @Override
  public void setOutputPath(String path) {
    prs.setOutputPath(DEFAULT_OUTPUT, path);
  }
  
  @Override
  public void setOutputPath(String outputName, String path) {
    prs.setOutputPath(outputName, path);
  }

}
