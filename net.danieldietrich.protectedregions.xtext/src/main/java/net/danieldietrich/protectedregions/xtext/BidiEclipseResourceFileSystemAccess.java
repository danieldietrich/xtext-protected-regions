package net.danieldietrich.protectedregions.xtext;

import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.util.Map;
import java.util.Set;

import net.danieldietrich.protectedregions.support.IFileSystemReader;
import net.danieldietrich.protectedregions.support.IPathFilter;
import net.danieldietrich.protectedregions.support.IProtectedRegionSupport;

import org.apache.commons.io.IOUtils;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.Path;
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess;

import com.google.inject.Inject;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class BidiEclipseResourceFileSystemAccess extends EclipseResourceFileSystemAccess implements
    IFileSystemReader {

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
    super.setOutputPath(path);
    support.readRegions(this, path);
  }

  @Override
  public void setOutputPath(String path, String slot) {
    super.setOutputPath(path, slot);
    support.readRegions(this, path);
  }

  @Override
  public void generateFile(String fileName, CharSequence contents) {
    CharSequence mergedContents = support.mergeRegions(this, fileName, DEFAULT_OUTPUT, contents);
    super.generateFile(fileName, mergedContents);
  }

  @Override
  public void generateFile(String fileName, String slot, CharSequence contents) {
    CharSequence mergedContents = support.mergeRegions(this, fileName, slot, contents);
    super.generateFile(fileName, slot, mergedContents);
  }
  
  @Override
  public void setRoot(IWorkspaceRoot root) {
    super.setRoot(root);
    this.root = root;
  }

  protected IFile getFile(URI uri) {
    return root.getFile(new Path(uri.getPath()));
  }

  @Override
  public IPathFilter getFilter() {
    return filter;
  }
  
  @Override
  public void setFilter(IPathFilter filter) {
    this.filter = filter;
  }
  
  @Override
  public CharSequence readFile(URI uri) throws IOException {
    IFile file = getFile(uri);
    try {
      return IOUtils.toString(file.getContents());
    } catch (CoreException e) {
      throw new IOException("Error reading " + file, e);
    }
  }

  @Override
  public Set<URI> listFiles(URI path) {
    // TODO Auto-generated method stub
    return null;
  }

  @Override
  public boolean hasFiles(URI path) {
    IFile file = getFile(path);
    return file.getType() != IResource.FILE;
  }

  @Override
  public boolean isFile(URI path) {
    IFile file = getFile(path);
    return file.getType() == IResource.FILE;
  }

  /**
   * Return absolute path relative to workspace.
   */
  @Override
  public String getCanonicalPath(URI path) {
    IFile file = getFile(path);
    return file.getFullPath().toString();
  }

  @Override
  public URI getUri(String path) {
    return new File(path).toURI();
  }
  
  @Override
  public URI getUri(String relativePath, String slot) {
    Map<String, String> pathes = getPathes();
    if (pathes.size() == 0) {
      throw new IllegalStateException("No slots initialized!? Call #setOutputPath(...)");
    }
    String slotPath = pathes.get((slot == null) ? DEFAULT_OUTPUT : slot);
    if (slotPath == null) {
      throw new IllegalStateException("Slot " + slot + " not found.");
    }
    return new File(slotPath + "/" + relativePath).toURI();
  }

  @Override
  public boolean exists(URI uri) {
    IFile file = getFile(uri);
    return file.exists();
  }

}
