package net.danieldietrich.protectedregions.xtext;

import net.danieldietrich.protectedregions.support.AbstractProtectedRegionSupport;

import org.eclipse.xtext.generator.IFileSystemAccess;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class ProtectedRegionSupport extends AbstractProtectedRegionSupport implements IFileSystemAccess {

  private final IBidiFileSystemAccess delegate;
  
  private ProtectedRegionSupport(IBidiFileSystemAccess delegate) {
    super(delegate);
    this.delegate = delegate;
  }

  @Override
  public void generateFile(String fileName, CharSequence contents) {
    generateFile(fileName, DEFAULT_OUTPUT, contents);
  }

  @Override
  public void generateFile(String fileName, String slot, CharSequence contents) {
    String path = delegate.getPath(fileName, slot);
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
