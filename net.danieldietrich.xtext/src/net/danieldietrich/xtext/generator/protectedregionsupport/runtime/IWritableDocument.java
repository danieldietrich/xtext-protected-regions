package net.danieldietrich.xtext.generator.protectedregionsupport.runtime;

/**
 * IWritableDocument is intended to be used in conjunction with parsers, which subsequentially
 * call <code>dump(String)</code>, <code>save(boolean)</code> and finally <code>flush()</code>.
 *
 * @author Daniel Dietrich - Initial contribution and API
 */
public interface IWritableDocument extends IDocument {

  /**
   * Dump is called continually while collecting characters.
   * 
   * @param s should not be null
   * 
   * @see #flush()
   */
  void dump(String s);
  
  /**
   * When entering a comment save(false) is called
   * (i.e. the previously dumped characters are outside of a comment, if there are any(!)).
   * When leaving a comment save(true) is called
   * (i.e. the previously dumped characters are inside of a comment).<br>
   * <br>
   * <em>Hint: Implementations should test, if a comment is the
   * start or end of a protected region.</em>
   * 
   * @param comment
   * 
   * @see #flush()
   */
  void save(boolean comment);
  
  /**
   * Called when parser determines EOF to save pending buffers.
   * Subsequent calls of flush() will cause no side effects.<br>
   * <br>
   * After calling flush(), calls of dump(String) and save(boolean)
   * are disallowed and result in an IllegalStateException.
   */
  void flush();

}
