package net.danieldietrich.xtext.generator.protectedregions;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
class DefaultDocument implements IDocument {

  private List<IRegion> regions = new ArrayList<IRegion>();
  private Map<String,IRegion> protectedRegions = new HashMap<String,IRegion>();

  @Override
  public Iterable<IRegion> getRegions() {
    return Collections.unmodifiableList(regions);
  }
  
  @Override
  public IRegion getProtectedRegion(String id) {
    return protectedRegions.get(id);
  }
  
  public void addRegion(IRegion region) {
    regions.add(region);
    if (region.isProtectedRegion()) {
      if (protectedRegions.containsKey(region.getId())) {
        throw new IllegalStateException("Duplicate protected region id: " + region.getId());
      }
      protectedRegions.put(region.getId(), region);
    }
  }
  
  @Override
  public String getContents() {
    StringBuilder result = new StringBuilder();
    for (IRegion region : regions) {
      result.append(region.getText());
    }
    return result.toString();
  }
  
}
