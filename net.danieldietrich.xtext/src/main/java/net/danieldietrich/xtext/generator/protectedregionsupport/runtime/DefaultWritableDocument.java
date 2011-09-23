package net.danieldietrich.xtext.generator.protectedregionsupport.runtime;

import java.util.regex.Pattern;

/**
 * Default implementation of IWritableDocument.<br>
 * <br>
 * Protected regions are defined as follows (<em>whitespace allowed</em>):<br>
 * <code>&#47;*PROTECTED REGION ID(<em>qualified.java.identifier</em>) START*&#47;</code><br>
 * <code>&#47;*PROTECTED REGION END*&#47;</code><br>
 * <br>
 * where a qualified Java identifier has the following regular expression:<br>
 * <code>ID ('.' ID)*</code><br>
 * <br>
 * and a Java identifier (<em>here: ID</em>) looks like:<br>
 * <code>('a'..'z'|'A'..'Z'|'$'|'_') ('a'..'z'|'A'..'Z'|'$'|'_'|'0'..'9')*</code>
 * 
 * @author Daniel Dietrich - Initial contribution and API
 */
class DefaultWritableDocument extends DefaultDocument implements IWritableDocument {

  private StringBuffer current = new StringBuffer(); // here goes the current parser output
  private StringBuffer dump = new StringBuffer(); // here goes the buffered parser output when saving
  private boolean protectedRegion = false; // current state. document starts outside of a protected region
  private String id = null; // current protected region id
  private boolean flushed = false;
  
  @Override
  public void dump(String s) {
    
    checkFlushed();
    
    current.append(s);
  }

  @Override
  public void save(boolean comment) {
    
    checkFlushed();
    
    // something buffered yet by the parser?
    if (current.length() == 0) {
      return;
    }
    
    String s = current.toString();
    current.setLength(0);
    
    if (!comment) {
      // entering a comment (may be currently in a protected region or not).
      // storing current characters on dump and waiting for more characters from parser...
      dump.append(s);
    }
    
    else {
      
      // just finishing a comment.
      // test if comment is protected region start or end.
      if (protectedRegion && isProtectedRegionEnd(s)) {
        
        // currently we are in a protected region and the end of it is reached
        dump.append(s); // save the protected region end marker/comment
        IPart part = new Part(true, id, dump.toString()); // create document part
        addPart(part); // store part
        dump.setLength(0); // release dump
        id = null; // reset protected region id
        protectedRegion = false; // update state
        
      }
      
      else if (!protectedRegion && isProtectedRegionStart(s)) {
        
        // we are entering a protected region, but first save the previous document part...
        IPart part = new Part(false, null, dump.toString()); // create document part
        addPart(part); // store part
        id = getId(s); // remember protected region id
        dump.setLength(0); // release old part
        dump.append(s); // save the actual protected region start marker/comment
        protectedRegion = true; // update state
        
      }
      
      else {
        // it is an ordinary comment. append it to the ongoing part (may be a protected region or not(!))
        dump.append(s);
      }
      
    }
  }
  
  @Override
  public void flush() {
    
    if (flushed) {
      return;
    }
    
    dump.append(current);
    current.setLength(0);
    current = null;
    
    String text = dump.toString();
    dump.setLength(0);
    dump = null;
    
    if (text.length() > 0) {
      IPart part = new Part(protectedRegion, id, text);
      addPart(part);
    }
    
    flushed = true;
    
  }
  
  private void checkFlushed() {
    if (flushed) {
      throw new IllegalStateException("Document already flushed. No further calls of dump(String) and save(boolean) possible.");
    }
  }
  
  private String getId(String s) {
    int i = s.indexOf("(");
    int j = i + 1 + s.substring(i+1).indexOf(")");
    return (i != -1 && j != -1) ? s.substring(i+1, j).trim() : null;
  }

  private static final String ID = "([a-zA-Z_$][a-zA-Z\\d_$]*\\.)*[a-zA-Z_$][a-zA-Z\\d_$]*";
  private static final Pattern PR_START = Pattern.compile("/\\*\\s*PROTECTED\\s*REGION\\s*ID\\s*\\(\\s*" + ID + "\\s*\\)\\s*START\\s*\\*/");
  private boolean isProtectedRegionStart(String s) {
    return PR_START.matcher(s).matches();
  }
  
  private static final Pattern PR_END = Pattern.compile("/\\*\\s*PROTECTED\\s*REGION\\s*END\\s*\\*/");
  private boolean isProtectedRegionEnd(String s) {
    return PR_END.matcher(s).matches();
  }
  
  private static class Part implements IPart {
    
    final boolean protectedRegion;
    final String id;
    final String text;
    
    Part(boolean protectedRegion, String id, String text) {
      this.protectedRegion = protectedRegion;
      this.id = id;
      this.text = text;
    }
    
    @Override
    public boolean isProtectedRegion() {
      return protectedRegion;
    }

    @Override
    public String getId() {
      return id;
    }

    @Override
    public String getText() {
      return text;
    }
  }
  
}
