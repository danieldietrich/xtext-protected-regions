package net.danieldietrich.protectedregions.support;

import java.io.IOException;
import java.net.URI;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import net.danieldietrich.protectedregions.core.IDocument;
import net.danieldietrich.protectedregions.core.IDocument.IRegion;
import net.danieldietrich.protectedregions.core.IRegionParser;
import net.danieldietrich.protectedregions.core.RegionUtil;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.collect.Iterables;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class ProtectedRegionSupport implements IProtectedRegionSupport {

  private transient final Logger logger = LoggerFactory.getLogger(ProtectedRegionSupport.class);

  private static final IPathFilter ACCEPT_ALL_FILTER = new IPathFilter() {
    //@Override
    public boolean accept(URI path) {
      return true;
    }
  };

  private Map<IPathFilter, IRegionParser> parsers = new HashMap<IPathFilter, IRegionParser>();
  private Map<String, IRegion> protectedRegionPool = new HashMap<String, IRegion>();
  private Set<String> visitedPaths = new HashSet<String>();

  //@Override
  public void addParser(IRegionParser parser) {
    addParser(parser, (IPathFilter) null);
  }

  //@Override
  public void addParser(IRegionParser parser, String... fileExtensions) {
    if (fileExtensions == null || fileExtensions.length == 0) {
      throw new IllegalArgumentException("File extensions cannot be null or empty.");
    }
    addParser(parser, new FileExtensionFilter(fileExtensions));
  }

  //@Override
  public void addParser(IRegionParser parser, IPathFilter filter) {
    if (parser == null) {
      throw new IllegalArgumentException("Parser cannot be null.");
    }
    IPathFilter parserFilter = (filter == null) ? ACCEPT_ALL_FILTER : filter;
    parsers.put(parserFilter, parser);
  }

  //@Override
  public void readRegions(IFileSystemReader reader, String slot) {
    if (parsers.isEmpty()) {
      throw new IllegalStateException("#addParser methods have to be called before #read methods.");
    }
    URI uri = reader.getUri("", slot);
    if (!reader.exists(uri)) {
      logger.warn("path does not exist: {}", uri.getPath());
      return;
    }
    if (!reader.hasFiles(uri)) {
      throw new IllegalArgumentException("no directory: " + uri);
    }
    String canonicalPath = reader.getCanonicalPath(uri);
    if (isVisited(canonicalPath)) {
      logger.warn("skipping already visited path '{}'.", uri);
      return;
    }
    internal_read(reader, uri);
    visitedPaths.add(canonicalPath);
  }

  private boolean isVisited(String canonicalPath) {
    for (String path : visitedPaths) {
      if (canonicalPath.startsWith(path)) {
        return true;
      }
    }
    return false;
  }

  private void internal_read(IFileSystemReader reader, URI path) {

    Set<String> visitedRegions = new HashSet<String>();

    // get all files within the current directory
    Iterable<URI> files = reader.listFiles(path);
    logger.debug("Path {} has {} files matching the readers filter.", path, Iterables.size(files));
    for (URI file : files) {
      visitedRegions.clear();

      // all parsers have the chance to parse the file
      for (IPathFilter parserFilter : parsers.keySet()) {

        IRegionParser parser = parsers.get(parserFilter);
        
        // check, if the current file makes it through the filter of the parser
        if (!parserFilter.accept(file)) {
          logger.trace("Parser {} skips {}.", parser, file.getPath());
          continue; // next parser
        }

        // parse file
        logger.debug("{} is parsing {}", parser, file);
        CharSequence input;
        try {
          input = reader.readFile(file);
          IDocument document;
          try {
            document = parser.parse(input);
          } catch (Exception ex) {
            throw new RuntimeException(parser + " failed parsing " + file, ex);
          }
          logger.debug("{} found {} regions in {} : {}", new Object[] {
              parser, Iterables.size(document.getRegions()), file, document.getRegions()});

          // add protected regions to pool
          for (IRegion region : document.getRegions()) {

            // process protected regions only
            if (region.isMarkedRegion()) {

              // get unique id
              String id = region.getId();

              // check if region already visited. this happens if two parsers have the same comment
              // starts(!)
              if (visitedRegions.contains(id)) {
                logger.warn("parser {} found region {} which was parsed by another parser before.", parser, id);
                continue;
              }
              visitedRegions.add(id);

              logger.trace("Put Pool {} = {}", id, region.getText());

              // store current protected region in pool
              if (protectedRegionPool.containsKey(id)) {
                throw new IllegalStateException("Duplicate protected region id: '" + id
                    + "'. Protected region ids have to be globally unique.");
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
  
  //@Override
  public void clearRegions() {
    protectedRegionPool.clear();
    visitedPaths.clear();
  }

  //@Override
  public CharSequence mergeRegions(IFileSystemReader reader, String fileName, String slot, CharSequence contents) {
    IDocument document = null;
    URI path = reader.getUri(fileName, slot);
    for (IPathFilter filter : parsers.keySet()) {
      if (!filter.accept(path)) {
        continue;
      }
      IRegionParser parser = parsers.get(filter);
      if (document == null) {
        document = parser.parse(contents);
      } else {
        // parse document again with different parser
        document = parser.parse(document.getContents());
      }
      logger.debug("Source document has {} regions: {}", Iterables.size(document.getRegions()),
          document.getRegions());

      if (parser.isInverse()) {
        CharSequence input;
        try {
          input = reader.readFile(path);
          document = RegionUtil.fillIn(document, parser.parse(input));
        } catch (Exception e) {
          logger.warn("Cannot read {}", path);
        }
      } else {
        logger.debug("Pool contains {} regions: {}", protectedRegionPool.size(),
            protectedRegionPool.keySet());
        for (Entry<String, IRegion> region : protectedRegionPool.entrySet()) {
          logger.trace("Pool {} = {}", region.getKey(), region.getValue().getText());
        }
        document = RegionUtil.merge(document, protectedRegionPool);
        logger.debug("Merged document has {} regions: {}", Iterables.size(document.getRegions()),
            document.getRegions());
      }
    }
    return (document == null) ? contents : document.getContents();
  }

  /**
   * Filter accepting files with specific extensions.
   */
  private static class FileExtensionFilter implements IPathFilter {
    private String[] fileExtensions;

    public FileExtensionFilter(String[] fileExtensions) {
      this.fileExtensions = fileExtensions;
    }

    //@Override
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
