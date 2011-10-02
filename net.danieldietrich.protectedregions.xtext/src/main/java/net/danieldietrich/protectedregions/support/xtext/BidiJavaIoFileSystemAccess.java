package net.danieldietrich.protectedregions.support.xtext;

import java.io.File;
import java.io.IOException;
import java.util.Collection;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import net.danieldietrich.protectedregions.support.IPathFilter;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.TrueFileFilter;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class BidiJavaIoFileSystemAccess extends JavaIoFileSystemAccess implements IBidiFileSystemAccess {

  @Override
  public boolean exists(String fileName) {
    return new File(fileName).exists();
  }
  
  @Override
  public CharSequence readFile(String fileName) {
    try {
      return FileUtils.readFileToString(new File(fileName));
    } catch (IOException e) {
      throw new RuntimeException("error reading file " + fileName);
    }
  }

  @Override
  public Set<String> listFiles(String path) {
    return listFiles(path, TRUE_PATH_FILTER);
  }

  @Override
  public Set<String> listFiles(String path, IPathFilter filter) {
    // TODO(@@dd): use filter to retrieve files
    Collection<File> files = FileUtils.listFiles(new File(path), TrueFileFilter.INSTANCE, TrueFileFilter.INSTANCE);
    Set<String> result = new HashSet<String>();
    for (File file : files) {
      result.add(file.getPath());
    }
    return result;
  }

  @Override
  public boolean hasFiles(String path) {
    return new File(path).isDirectory();
  }

  @Override
  public boolean isFile(String path) {
    return new File(path).isFile();
  }

  @Override
  public String getCanonicalPath(String path) {
    try {
      return new File(path).getCanonicalPath();
    } catch (IOException e) {
      throw new RuntimeException("cannot determine canonical path of " + path);
    }
  }

  @Override
  public String getPath(String relativePath, String slot) {
    Map<String, String> pathes = getPathes();
    return toSystemFileName(pathes.get(slot) + "/" + relativePath);
  }
  
  private static final IPathFilter TRUE_PATH_FILTER = new IPathFilter() {
    @Override
    public boolean accept(String path) {
      return true;
    }
  };
}
