package net.danieldietrich.xtext.generator.protectedregionsupport.runtime;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
class DefaultDocument implements IDocument {

  private List<IPart> parts = new ArrayList<IPart>();
  private Map<String,IPart> protectedRegions = new HashMap<String,IPart>();

  @Override
  public Iterable<IPart> getParts() {
    return Collections.unmodifiableList(parts);
  }
  
  @Override
  public IPart getProtectedRegion(String id) {
    return protectedRegions.get(id);
  }
  
  public void addPart(IPart part) {
    parts.add(part);
    if (part.isProtectedRegion()) {
      protectedRegions.put(part.getId(), part);
    }
  }
  
  @Override
  public String getContents() {
    StringBuilder result = new StringBuilder();
    for (IPart part : parts) {
      result.append(part.getText());
    }
    return result.toString();
  }
  
}
