/**
 * 
 */
package net.danieldietrich.protectedregions.xtext;

import java.util.Map;
import java.util.Map.Entry;

import net.danieldietrich.protectedregions.xtext.ProtectedRegionSupport.Builder;

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
  IProtectedRegionSupportConfigurer prsFactory;
  ProtectedRegionSupport prs;
  
  public JavaIoWrapper(IProtectedRegionSupportConfigurer prsConfigurer) {
    this.prsFactory = prsConfigurer;
  }

  /**
   * Creates and configures an inner {@link ProtectedRegionSupport} if not yet initialized.
   */
  protected void prepareInner() {
    if (prs == null) {
      Map<String, String> pathes = getPathes();
      logger.debug("Creating ProtectedRegionSupport with slots: {}", pathes);
      IBidiFileSystemAccess delegate = new BidiJavaIoFileSystemAccess();
      for (Entry<String, String> path : pathes.entrySet()) {
        delegate.setOutputPath(path.getKey(), path.getValue());
      }
      Builder builder = new ProtectedRegionSupport.Builder(delegate);
      prsFactory.configure(builder);
      this.prs = builder.build();
    }
  }
  
  @Override
  public void generateFile(String fileName, String slot, CharSequence contents) {
    prepareInner();
    prs.generateFile(fileName, slot, contents);
  }
  
  @Override
  public void deleteFile(String fileName) {
    prepareInner();
    prs.deleteFile(fileName);
  }

}
