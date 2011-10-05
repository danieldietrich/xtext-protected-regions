/**
 * 
 */
package net.danieldietrich.protectedregions.xtext;

import java.util.Map;
import java.util.Map.Entry;

import org.eclipse.xtext.generator.AbstractFileSystemAccess;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Wraps a {@link ProtectedRegionSupport} so it can be Guice-injected as a {@link JavaIoFileSystemAccess}.
 * See https://github.com/danieldietrich/xtext-protectedregions/issues/21
 * 
 * @author ceefour
 *
 */
public class JavaIoWrapper extends JavaIoFileSystemAccess {

  private final transient Logger logger = LoggerFactory.getLogger(JavaIoWrapper.class); 
  IProtectedRegionSupportFactory prsFactory;
  ProtectedRegionSupport prs;
  
  public JavaIoWrapper(IProtectedRegionSupportFactory prsFactory) {
    this.prsFactory = prsFactory;
  }
  
  @Override
  public void generateFile(String fileName, String slot, CharSequence contents) {
    if (prs == null) {
      Map<String, String> pathes = getPathes();
      logger.debug("Creating ProtectedRegionSupport with slots: {}", pathes);
      IBidiFileSystemAccess delegate = prsFactory.createFileSystemAccess();
      for (Entry<String, String> path : pathes.entrySet()) {
        delegate.setOutputPath(path.getKey(), path.getValue());
      }
      this.prs = prsFactory.createProtectedRegionSupport(delegate);
    }
    prs.generateFile(fileName, slot, contents);
  }
  
  @Override
  public void deleteFile(String fileName) {
    prs.deleteFile(fileName);
  }

//  @Override
//  public void setOutputPath(String path) {
//    prs.setOutputPath(DEFAULT_OUTPUT, path);
//  }
//  
//  @Override
//  public void setOutputPath(String outputName, String path) {
//    prs.setOutputPath(outputName, path);
//  }

}
