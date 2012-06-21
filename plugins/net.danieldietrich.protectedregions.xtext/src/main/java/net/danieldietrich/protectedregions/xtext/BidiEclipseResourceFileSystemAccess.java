package net.danieldietrich.protectedregions.xtext;
 
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;
 
import net.danieldietrich.protectedregions.core.IOUtil;
import net.danieldietrich.protectedregions.support.IFileSystemReader;
import net.danieldietrich.protectedregions.support.IPathFilter;
import net.danieldietrich.protectedregions.support.IProtectedRegionSupport;
 
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.Path;
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
 
import com.google.common.base.Function;
import com.google.common.collect.Lists;
import com.google.common.collect.Sets;
import com.google.inject.Inject;
 
/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class BidiEclipseResourceFileSystemAccess extends EclipseResourceFileSystemAccess2 implements
    IFileSystemReader {
 
  private transient Logger logger = LoggerFactory.getLogger(BidiEclipseResourceFileSystemAccess.class);
 
  @Inject
  IWorkspaceRoot root;
 
  private final IProtectedRegionSupport support;
  private IPathFilter filter;
 
  public BidiEclipseResourceFileSystemAccess(IProtectedRegionSupport support) {
    this.support = support;
  }
  
  protected IProtectedRegionSupport getSupport() {
    return support;
  }
  
  @Override
  public void setOutputPath(String path) {
    setOutputPath(DEFAULT_OUTPUT, path);
  }
 
  @Override
  public void setOutputPath(String outputName, String path) {
    super.setOutputPath(outputName, path);
    logger.info("Adding slot {} at {}", path, outputName);
    support.readRegions(this, outputName);
  }
 
  @Override
  public void generateFile(String fileName, CharSequence contents) {
    URI uri = getUri(fileName);
    logger.debug("Generating {} at {} => {}", new Object[] { fileName, DEFAULT_OUTPUT, uri});
    CharSequence mergedContents = support.mergeRegions(this, fileName, DEFAULT_OUTPUT, contents);
    super.generateFile(fileName, mergedContents);
  }
 
  @Override
  public void generateFile(String fileName, String slot, CharSequence contents) {
    URI uri = getUri(fileName, slot);
    logger.debug("Generating {} at {} => {}", new Object[] { fileName, slot, uri });
    CharSequence mergedContents = support.mergeRegions(this, fileName, slot, contents);
    super.generateFile(fileName, slot, mergedContents);
  }
  
//  @Override
//  public void setRoot(IWorkspaceRoot root) {
//    super.setRoot(root);
//    this.root = root;
//  }
 
  protected IFile getFile(URI uri) {
    return root.getFile(new Path(uri.getPath()));
  }
 
  //@Override
  public IPathFilter getFilter() {
    return filter;
  }
  
  //@Override
  public void setFilter(IPathFilter filter) {
    this.filter = filter;
  }
  
  //@Override
  public CharSequence readFile(URI uri) throws IOException {
    IFile file = getFile(uri);
    try {
      return IOUtil.toString(file.getContents());
    } catch (CoreException e) {
      throw new IOException("Error reading " + file, e);
    }
  }
 
  //@Override
  public Set<URI> listFiles(URI path) {
    final IFolder folder = root.getFolder(new Path(path.getPath()));
    try {
      List<URI> memberList = Lists.transform( Arrays.asList(folder.members()), new Function<IResource, URI>() {
 
        //@Override
        public URI apply(IResource from) {
          try {
            return new URI("eclipse", from.getFullPath().toString(), null);
          } catch (URISyntaxException e) {
            logger.error("Cannot get URI for {} in {}", from, folder);
            throw new RuntimeException("Cannot get URI for " + from + " in " + folder, e);
          }
        }
        
      });
      return Sets.newHashSet(memberList);
    } catch (CoreException e) {
      logger.error("Error listing files in {}", folder);
      throw new RuntimeException("Error listing files in " + folder, e);
    }
  }
 
  //@Override
  public boolean hasFiles(URI path) {
    IFile file = getFile(path);
    return file.getType() != IResource.FILE;
  }
 
  //@Override
  public boolean isFile(URI path) {
    IFile file = getFile(path);
    return file.getType() == IResource.FILE;
  }
 
  /**
   * Return absolute path relative to workspace.
   */
  //@Override
  public String getCanonicalPath(URI path) {
    IFile file = getFile(path);
    return file.getFullPath().toString();
  }
 
  //@Override
  public URI getUri(String relativePath) {
    return getUri(relativePath, DEFAULT_OUTPUT);
  }
  
  //@Override
  public URI getUri(String relativePath, String slot) {
    Map<String, String> pathes = getPathes();
    if (pathes.size() == 0) {
      throw new IllegalStateException("No slots initialized!? Call #setOutputPath(...)");
    }
    String slotPath = pathes.get((slot == null) ? DEFAULT_OUTPUT : slot);
    if (slotPath == null) {
      throw new IllegalStateException("Slot " + slot + " not found.");
    }
    try {
      return new URI("eclipse", slotPath + "/" + relativePath, null);
    } catch (URISyntaxException e) {
      throw new RuntimeException("Cannot get URI for " + relativePath + " at " + slot, e);
    }
  }
 
  //@Override
  public boolean exists(URI uri) {
    IFile file = getFile(uri);
    return file.exists();
  }
 
}
