package net.danieldietrich.xtext.generator.protectedregions;

import java.util.regex.Pattern;

/**
 * Default protected regions identifiers are defined as follows (<em>whitespace allowed</em>):<br>
 * <code>PROTECTED REGION ID(<em>qualified.identifier</em>) START</code><br>
 * <code>PROTECTED REGION END</code><br>
 * <br>
 * A qualified identifier has the following regular expression:<br>
 * <code>ID ('.' ID)*</code><br>
 * <br>
 * where ID looks like:<br>
 * <code>('a'..'z'|'A'..'Z'|'$'|'_') ('a'..'z'|'A'..'Z'|'$'|'_'|'0'..'9')*</code>
 * 
 * @author Daniel Dietrich - Initial contribution and API
 */
public class DefaultProtectedRegionOracle implements IProtectedRegionOracle {

  private static final String ID = "([a-zA-Z_$][a-zA-Z\\d_$]*\\.)*[a-zA-Z_$][a-zA-Z\\d_$]*";
  private static final Pattern PR_START = Pattern.compile("\\s*PROTECTED\\s*REGION\\s*ID\\s*\\(\\s*" + ID + "\\s*\\)\\s*START\\s*");
  private static final Pattern PR_END = Pattern.compile("\\s*PROTECTED\\s*REGION\\s*END\\s*");
  
  @Override
  public boolean isProtectedRegionStart(String s) {
    return PR_START.matcher(s).matches();
  }
  
  @Override
  public boolean isProtectedRegionEnd(String s) {
    return PR_END.matcher(s).matches();
  }

  @Override
  public String getId(String protectedRegionStart) {
    int i = protectedRegionStart.indexOf("(");
    int j = i + 1 + protectedRegionStart.substring(i+1).indexOf(")");
    return (i != -1 && j != -1) ? protectedRegionStart.substring(i+1, j).trim() : null;
  }

}
