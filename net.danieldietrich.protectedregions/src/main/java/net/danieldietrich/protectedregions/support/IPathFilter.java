package net.danieldietrich.protectedregions.support;

import java.net.URI;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public interface IPathFilter {

  /**
   * Checks whether a given path makes it through this filter.
   * 
   * @param path
   * @return true, if path is accepted, false otherwise.
   */
  boolean accept(URI path);

}
