package net.danieldietrich.protectedregions.xtext;

import java.net.URI;

import net.danieldietrich.protectedregions.support.AbstractProtectedRegionSupport;

import org.eclipse.xtext.generator.IFileSystemAccess;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class ProtectedRegionSupport extends AbstractProtectedRegionSupport implements IFileSystemAccess {

  private final transient Logger logger = LoggerFactory.getLogger(ProtectedRegionSupport.class);
  private final IBidiFileSystemAccess delegate;
  
  private ProtectedRegionSupport(IBidiFileSystemAccess delegate) {
    super(delegate);
    this.delegate = delegate;
  }

  /**
   * Helper method to workaround Xtend's inability to instantiate static inner classes. :-(
   * @param delegate
   * @return
   */
  public static Builder createBuilder(IBidiFileSystemAccess delegate) {
    return new Builder(delegate);
  }
  
  @Override
  public void generateFile(String fileName, CharSequence contents) {
    generateFile(fileName, DEFAULT_OUTPUT, contents);
  }

  @Override
  public void generateFile(String fileName, String slot, CharSequence contents) {
    URI path = delegate.getUri(fileName, slot);
    logger.debug("Merging {} at {}, URI={}", new Object[] { fileName, slot, path });
    CharSequence mergedContents = mergeProtectedRegions(path, contents);
    delegate.generateFile(fileName, slot, mergedContents);
  }

  @Override
  public void deleteFile(String fileName) {
    delegate.deleteFile(fileName);
  }
  
  public static class Builder extends AbstractProtectedRegionSupport.Builder<ProtectedRegionSupport> {
    public Builder(final IBidiFileSystemAccess reader) {
      super(reader, new IFactory<ProtectedRegionSupport>() {
        @Override
        public ProtectedRegionSupport createInstance() {
          return new ProtectedRegionSupport(reader);
        }
      });
    }
  }
}
