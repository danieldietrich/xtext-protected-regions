package net.danieldietrich.protectedregions.support.xtext;

import java.util.Set;

import net.danieldietrich.protectedregions.support.IPathFilter;

import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class BidiEclipseResourceFileSystemAccess extends EclipseResourceFileSystemAccess implements IBidiFileSystemAccess {

// TODO
//  @Inject IWorkspaceRoot root;

// TODO
//  @Override
//  public void setRoot(IWorkspaceRoot root) {
//    super.setRoot(root);
//    this.root = root;
//  }
  
  @Override
  public boolean exists(String fileName) {
// TODO
//    IFile file = root.getFile(new Path(fileName));
//    return file.exists();
    return false;
  }
  
  @Override
  public CharSequence readFile(String fileName) {
//    IFile file = root.getFile(new Path(fileName));
//    try {
//      return IOUtils.toString(file.getContents());
//    } catch (CoreException e) {
//      throw new IOException("Error reading " + file, e);
//    }
    return null;
  }

  @Override
  public Set<String> listFiles(String path) {
    // TODO Auto-generated method stub
    return null;
  }

  @Override
  public Set<String> listFiles(String path, IPathFilter filter) {
    // TODO Auto-generated method stub
    return null;
  }

  @Override
  public boolean hasFiles(String path) {
    // TODO Auto-generated method stub
    return false;
  }

  @Override
  public boolean isFile(String path) {
    // TODO Auto-generated method stub
    return false;
  }

  @Override
  public String getCanonicalPath(String path) {
    // TODO Auto-generated method stub
    return null;
  }

  @Override
  public String getPath(String fileName, String slot) {
    // TODO Auto-generated method stub
    return null;
  }
}
