package net.danieldietrich.protectedregions.core;

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
  private Map<String,IRegion> markedRegions = new HashMap<String,IRegion>();

  //@Override
  public Iterable<IRegion> getRegions() {
    return Collections.unmodifiableList(regions);
  }
  
  //@Override
  public IRegion getMarkedRegion(String id) {
    return markedRegions.get(id);
  }
  
  public void addRegion(IRegion region) {
    regions.add(region);
    if (region.isMarkedRegion()) {
      if (markedRegions.containsKey(region.getId())) {
        throw new IllegalStateException("Duplicate marked region id: " + region.getId());
      }
      markedRegions.put(region.getId(), region);
    }
  }
  
  //@Override
  public String getContents() {
    StringBuilder result = new StringBuilder();
    for (IRegion region : regions) {
      result.append(region.getText());
    }
    return result.toString();
  }
  
}
