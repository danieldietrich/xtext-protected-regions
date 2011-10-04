package net.danieldietrich.protectedregions.xtext;

import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.util.Collection;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import net.danieldietrich.protectedregions.support.IFileSystemReader;
import net.danieldietrich.protectedregions.support.IPathFilter;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.TrueFileFilter;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author Daniel Dietrich - Initial contribution and API
 * @author Hendy Irawan
 */
public class BidiJavaIoFileSystemAccess extends JavaIoFileSystemAccess
    implements IBidiFileSystemAccess, IFileSystemReader {

  private transient Logger logger = LoggerFactory.getLogger(BidiJavaIoFileSystemAccess.class);
  
  @Override
  public boolean exists(URI uri) {
    return new File(uri).exists();
  }

  @Override
  public CharSequence readFile(URI uri) throws IllegalArgumentException,
      IOException {
    final File file = new File(uri);
    return FileUtils.readFileToString(file);
  }

  @Override
  public Set<URI> listFiles(URI path) {
    return listFiles(path, TRUE_PATH_FILTER);
  }

  @Override
  public Set<URI> listFiles(URI path, IPathFilter filter) {
    Collection<File> files = FileUtils.listFiles(new File(path),
        TrueFileFilter.INSTANCE, TrueFileFilter.INSTANCE);
    Set<URI> result = new HashSet<URI>();
    for (File file : files) {
      URI uri = file.toURI();
      if (filter.accept(uri)) {
        result.add(uri);
      }
    }
    return result;
  }

  @Override
  public boolean hasFiles(URI uri) {
    return new File(uri).isDirectory();
  }

  @Override
  public boolean isFile(URI uri) {
    return new File(uri).isFile();
  }

  @Override
  public String getCanonicalPath(URI uri) {
    try {
      return new File(uri).getCanonicalPath();
    } catch (IOException e) {
       logger.warn("Cannot get canonical path for {}", uri);
       return null;
    }
  }

  @Override
  public URI getUri(String relativePath, String slot) {
    Map<String, String> pathes = getPathes();
    return new File(pathes.get(slot) + "/" + relativePath).toURI();
  }

  private static final IPathFilter TRUE_PATH_FILTER = new IPathFilter() {
    @Override
    public boolean accept(URI path) {
      return true;
    }
  };

}
