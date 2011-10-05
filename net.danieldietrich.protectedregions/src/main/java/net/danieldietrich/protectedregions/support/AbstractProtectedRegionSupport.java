package net.danieldietrich.protectedregions.support;

import java.io.IOException;
import java.net.URI;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import net.danieldietrich.protectedregions.core.IDocument;
import net.danieldietrich.protectedregions.core.IDocument.IRegion;
import net.danieldietrich.protectedregions.core.IRegionParser;
import net.danieldietrich.protectedregions.core.RegionUtil;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public abstract class AbstractProtectedRegionSupport implements IProtectedRegionSupport {

  private transient final Logger logger = LoggerFactory.getLogger(AbstractProtectedRegionSupport.class);
  private IFileSystemReader reader;
  private Map<IPathFilter,IRegionParser> parsers;
  private Map<String,IRegion> protectedRegionPool;

  protected AbstractProtectedRegionSupport(IFileSystemReader reader) {
    this.reader = reader;
  }
  
  @Override
  public CharSequence mergeProtectedRegions(URI fileName, CharSequence contents) {
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
        CharSequence input;
		try {
			input = reader.readFile(fileName);
	        document = RegionUtil.fillIn(document, parser.parse(input));
		} catch (Exception e) {
		  logger.warn("Cannot read {}", fileName);
		}
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
    
    private transient final Logger logger = LoggerFactory.getLogger(Builder.class);
    
    private static final IPathFilter ACCEPT_ALL_FILTER = new IPathFilter() {
      @Override
      public boolean accept(URI path) {
        return true;
      }
    };
    
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
      if (fileExtensions == null || fileExtensions.length == 0) {
        throw new IllegalArgumentException("File extensions cannot be null or empty.");
      }
      addParser(parser, new FileExtensionFilter(fileExtensions));
      return this;
    }

    @Override
    public Builder<T> addParser(IRegionParser parser, IPathFilter filter) {
      if (parser == null) {
        throw new IllegalArgumentException("Parser cannot be null.");
      }
      if (addParser_locked) {
        throw new IllegalStateException("#addParser methods are not allowed to be called after a #read method has been called.");
      }
      IPathFilter parserFilter = (filter == null) ? ACCEPT_ALL_FILTER : filter;
      parsers.put(parserFilter, parser);
      return this;
    }

    @Override
    public Builder<T> read(String path) {
      read(path, null, null);
      return this;
    }
    
    @Override
    public Builder<T> read(String path, IPathFilter filter) {
      read(path, null, filter);
      return this;
    }
    
    @Override
    public Builder<T> read(String path, String slot) {
      read(path, slot, null);
      return this;
    }
    
    @Override
    public Builder<T> read(String path, String slot, IPathFilter filter) {
      if (parsers.isEmpty()) {
        throw new IllegalStateException("#addParser methods have to be called before #read methods.");
      }
      final URI uri = reader.getUri(path, slot);
      if (!reader.exists(uri)) {
        return this;
      }
      if (!reader.hasFiles(uri)) {
        throw new IllegalArgumentException("no directory: " + path);
      }
      String canonicalPath = reader.getCanonicalPath(uri);
      if (isVisited(canonicalPath)) {
        logger.warn("skipping already visited path '{}'.", path);
        return this;
      }
      internal_read(uri, filter);
      visitedPaths.add(canonicalPath);
      addParser_locked = true;
      return this;
    }
    
    private boolean isVisited(String canonicalPath) {
      for (String path : visitedPaths) {
        if (canonicalPath.startsWith(path)) {
          return true;
        }
      }
      return false;
    }
    
    private void internal_read(URI path, IPathFilter filter) {
      
      Set<String> visitedRegions = new HashSet<String>();
      
      // get all files within the current directory
      Iterable<URI> files = (filter == null) ? reader.listFiles(path) : reader.listFiles(path, filter);
      for (URI file : files) {

        visitedRegions.clear();
        
        // all parsers have the chance to parse the file 
        for (IPathFilter parserFilter : parsers.keySet()) {
          
          // check, if the current file makes it through the filter of the parser
          if (!parserFilter.accept(file)) {
            continue; // next parser
          }

          // parse file
          IRegionParser parser = parsers.get(parserFilter);
          CharSequence input;
          try {
            input = reader.readFile(file);
            IDocument document = parser.parse(input);

            // add protected regions to pool
            for (IRegion region : document.getRegions()) {
              
              // process protected regions only
              if (region.isMarkedRegion()) {
                
                // get unique id
                String id = region.getId();
                
                // check if region already visited. this happens if two parsers have the same comment starts(!)
                if (visitedRegions.contains(id)) {
                  continue;
                }
                visitedRegions.add(id);
                
                // store current protected region in pool
                if (protectedRegionPool.containsKey(id)) {
                  throw new IllegalStateException("Duplicate protected region id: '" + id + "'. Protected region ids have to be globally unique.");
                }
                protectedRegionPool.put(id, region);
              }
            }

          } catch (IOException e) {
            logger.warn("Cannot read {}", file);
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
      public boolean accept(URI uri) {
        String path = uri.getPath();
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
