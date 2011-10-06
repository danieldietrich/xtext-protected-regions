/**
 * 
 */
package net.danieldietrich.protectedregions.xtext;

/**
 * Support interface to workaround issue #21, see https://github.com/danieldietrich/xtext-protectedregions/issues/21
 * 
 * @TODO Find a better, cleaner alternative.
 * @author ceefour
 *
 */
public interface IProtectedRegionSupportConfigurer {

  /**
   * The consumer-provided implementation should configure the builder (add parsers, etc.)
   * Example:
   * 
   * <code>
   *         @Override
   *         public void configure(ProtectedRegionSupport.Builder builder) {
   *             builder.addParser(RegionParserFactory.createJavaParser(), ".java")
   *                 .addParser(RegionParserFactory.createXmlParser(), ".xml")
   *                 .read("", IFileSystemAccess.DEFAULT_OUTPUT);
   *         }
   * </code>
   * 
   * @param builder
   */
  void configure(ProtectedRegionSupport.Builder builder);
  
}
