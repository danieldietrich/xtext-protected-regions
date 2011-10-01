package net.danieldietrich.protectedregions.support;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import net.danieldietrich.protectedregions.core.IDocument;
import net.danieldietrich.protectedregions.core.IRegionParser;
import net.danieldietrich.protectedregions.core.RegionUtil;
import net.danieldietrich.protectedregions.core.IDocument.IRegion;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public abstract class AbstractProtectedRegionSupport implements IProtectedRegionSupport {

  private IFileSystemReader reader;
  private Map<IPathFilter,IRegionParser> parsers;
  private Map<String,IRegion> protectedRegionPool;

  protected AbstractProtectedRegionSupport(IFileSystemReader reader) {
    this.reader = reader;
  }
  
  @Override
  public CharSequence mergeProtectedRegions(String fileName, CharSequence contents) {
    IDocument document = null;
    for (IPathFilter filter : parsers.keySet()) {
      if (!filter.accept(fileName)) {
        continue;
      }
      IRegionParser parser = parsers.get(filter);
      if (document == null) {
        document = parser.parse(contents);
      } else {
        // parse document again with different parser
        document = parser.parse(document.getContents());
      }
      if (parser.isInverse()) {
        CharSequence input = reader.readFile(fileName);
        if (input == null) {
          continue;
        }
        document = RegionUtil.fillIn(document, parser.parse(input));
      } else {
        document = RegionUtil.merge(document, protectedRegionPool);
      }
    }
    return (document == null) ? contents : document.getContents();
  }
  
  @Override
  public void setParsers(Map<IPathFilter,IRegionParser> parsers) {
    this.parsers = parsers;
  }
  
  @Override
  public void setProtectedRegionPool(Map<String,IRegion> protectedRegionPool) {
    this.protectedRegionPool = protectedRegionPool;
  }
  
  /**
   * 
   * @param <T>
   */
  public static class Builder<T extends AbstractProtectedRegionSupport> implements IBuilder<T> {
    
    private final IFileSystemReader reader;
    private final IFactory<T> factory;
    
    private Map<IPathFilter,IRegionParser> parsers = new HashMap<IPathFilter,IRegionParser>();
    private Map<String,IRegion> protectedRegionPool = new HashMap<String,IRegion>();
    
    private Set<String> visitedPaths = new HashSet<String>();
    private boolean addParser_locked = false;

    public Builder(IFileSystemReader reader, IFactory<T> factory) {
      this.reader = reader;
      this.factory = factory;
    }
    
    @Override
    public Builder<T> addParser(IRegionParser parser) {
      addParser(parser, (IPathFilter) null);
      return this;
    }

    @Override
    public Builder<T> addParser(IRegionParser parser, String... fileExtensions) {
      addParser(parser, new FileExtensionFilter(fileExtensions));
      return this;
    }

    @Override
    public Builder<T> addParser(IRegionParser parser, IPathFilter filter) {
      if (addParser_locked) {
        throw new IllegalStateException("#addParser methods are not allowed to be called after a #read method has been called.");
      }
      parsers.put(filter, parser);
      return this;
    }

    @Override
    public Builder<T> read(String path) {
      read(path, null);
      return this;
    }
    
    @Override
    public Builder<T> read(String path, IPathFilter filter) {
      if (parsers.isEmpty()) {
        throw new IllegalStateException("#addParser methods have to be called before #read methods.");
      }
      if (!reader.hasFiles(path)) {
        throw new IllegalArgumentException("no directory: " + path);
      }
      String canonicalPath = reader.getCanonicalPath(path);
      if (visitedPaths.contains(canonicalPath)) {
        return this;
      }
      internal_read(path, filter);
      visitedPaths.add(canonicalPath);
      addParser_locked = true;
      return this;
    }
    
    private void internal_read(String path, IPathFilter filter) {
      
      // get all files within the current directory
      Iterable<String> files = (filter == null) ? reader.listFiles(path) : reader.listFiles(path, filter);
      for (String file : files) {

        // all parsers have the chance to parse the file 
        for (IPathFilter parserFilter : parsers.keySet()) {
          
          // check, if the current file makes it through the filter of the parser
          if (!parserFilter.accept(file)) {
            continue; // next parser
          }

          // parse file
          IRegionParser parser = parsers.get(parserFilter);
          CharSequence input = reader.readFile(file);
          IDocument document = parser.parse(input);
          
          // add protected regions to pool
          for (IRegion region : document.getRegions()) {
            
            // process protected regions only
            if (region.isMarkedRegion()) {
              
              // get unique id
              String id = region.getId();
              if (protectedRegionPool.containsKey(id)) {
                throw new IllegalStateException("Duplicate protected region id: '" + id + "'. Protected regions have to be globally unique.");
              }
              
              // store current protected region in pool
              protectedRegionPool.put(id, region);
            }
          }
        }
      }
    }
    
    @Override
    public T build() {
      T result = factory.createInstance();
      result.setParsers(parsers);
      result.setProtectedRegionPool(protectedRegionPool);
      return result;
    }
    
    /**
     *
     */
    private static class FileExtensionFilter implements IPathFilter {
      private String[] fileExtensions;
      public FileExtensionFilter(String[] fileExtensions) {
        this.fileExtensions = fileExtensions;
      }
      @Override
      public boolean accept(String path) {
        for (String fileExtension : fileExtensions) {
          if (path.endsWith(fileExtension)) {
            return true;
          }
        }
        return false;
      }
    }
  }
  
  /**
   *
   * @param <T>
   */
  public static interface IFactory<T> {
    T createInstance();
  }

}
