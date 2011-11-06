package net.danieldietrich.protectedregions.core;

import java.io.IOException;
import java.io.InputStream;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import net.danieldietrich.protectedregions.core.IDocument.IRegion;
import net.danieldietrich.protectedregions.support.ProtectedRegionSupport;

import org.apache.commons.io.IOUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Parses InputStream, returning an IDocument which consists of IRegions.
 * <ul>
 * <li>Each IRegion is either marked or not marked.</li>
 * <li>Marked and not marked regions are alternating.</li>
 * <li>The marked region start and end comments are outside of the marked region</li>
 * <li>The indentation of a marked region start comment may not be restored in the 'fill-in'
 * scenario.</li>
 * <li>The indentation of a marked region end comment may not be restored in the 'protected region'
 * scenario.</li>
 * </ul>
 * 
 * @author Daniel Dietrich - Initial contribution and API
 */
class DefaultRegionParser implements IRegionParser {

	/**
	 * CAUTION: the order of this new line strings is sufficient, by the following means:<br>
	 * For all end of line flavors there is an order defined as follows:<br>
	 * s_i.contains(s_j) => i < j, for all i,j where i != j.<br>
	 * (The first match wins, see {@link #getSinglelineComment(ParserContext, CommentOccurrence))
	 */
	private static final String[] END_OF_LINE_FLAVORS = new String[] { "\r\n", "\n", "\r" };

	private final String name;
	private final List<ICommentType> commentTypes;
	private final List<ICDataType> cdataTypes;
	private final IRegionOracle oracle;
	private final boolean inverse;

	DefaultRegionParser(String name, List<ICommentType> commentTypes, List<ICDataType> cdataTypes, IRegionOracle oracle,
			boolean inverse) {
		this.name = name;
		this.commentTypes = commentTypes;
		this.cdataTypes = cdataTypes;
		this.oracle = oracle;
		this.inverse = inverse;
	}

	@Override
	public String toString() {
		return name;
	}

	/**
	 * @see #parse(CharSequence)
	 */
	//@Override
	public IDocument parse(InputStream in) throws IOException {
		return parse(IOUtils.toString(in));
	}

	/**
	 * This implementation first reads the whole InputStream. Then the document is read region by
	 * region until no more regions exist.<br>
	 * <br>
	 * Reading the whole document before parsing it is very performant. Index based parsers are able
	 * to search the next token with n operations, where n = number of different comment flavors. Then
	 * the complexity < O(r*n), where r = number of regions (= small number).<br>
	 * <br>
	 * Note: If the stream would be interpreted char by char, with every read operation the occurrence
	 * of a comment flavor has to be testet. With m characters in the stream and n comment flavors
	 * this would be a complexity of O(n*m), where m is a great number compared to the number of
	 * regions (one can count factor 1000).
	 * 
	 * @see #getNextRegion(Input)
	 */
	//@Override
	public IDocument parse(CharSequence in) {

		DefaultDocument result = new DefaultDocument();
		Input input = new Input(in.toString());

		// subsequentially read regions until end of input reached
		while (!input.endOfDocumentReached()) {
			IRegion region = getNextRegion(input);
			if (region.getText().length() > 0) { // because of technical reasons the first region is empty
				result.addRegion(region);
			}
		}

		// consider buffered input
		if (input.hasRemaining()) {
			result.addRegion(remainingRegion(input));
		}

		return result;
	}

	//@Override
	public boolean isInverse() {
		return inverse;
	}

	//@Override
	public Iterable<ICommentType> getCommentTypes() {
		return Collections.unmodifiableCollection(commentTypes);
	}

	//@Override
	public Iterable<ICDataType> getCDataTypes() {
		return Collections.unmodifiableCollection(cdataTypes);
	}

	/**
	 * Try to find the nearest occurrence of a start character sequence of one of the comments
	 * configured with this RegionParser. If there are no more comments, return the last Region (i.e.
	 * the remaining input). If there is another comment, then read the next region accordingly to the
	 * type of the comment (singleline, multiline etc.).
	 * 
	 * @param input
	 * @return
	 */
	private IRegion getNextRegion(Input input) {

		// find marked region start/end
		String comment;
		boolean stateChanged;
		boolean isMarkedRegionStart;
		boolean isMarkedRegionEnd;

		// read input until marked region is entered, leaved or eof reached
		do {

			// Find next comment start (which is not necessarily a marked region start/end)
			ICommentType commentType = getNextCommentType(input);

			// no more comments => last region found (a not marked one)
			if (commentType == null) {
				return remainingRegion(input);
			}

			// deal with different comment styles
			if (commentType.isMultiline()) {
				if (commentType.isNestable()) {
					comment = getMultilineNestableComment(input, commentType);
				} else {
					comment = getMultilineComment(input, commentType);
				}
			} else {
				if (!commentType.isNestable()) {
					comment = getSinglelineComment(input, commentType);
				} else {
					throw new IllegalStateException("Nestable singleline comments do not exist!");
				}
			}

			isMarkedRegionStart = oracle.isMarkedRegionStart(comment);
			isMarkedRegionEnd = oracle.isMarkedRegionEnd(comment);
			if (!input.isMarkedRegion() && isMarkedRegionEnd) {
				Input.Between between = input.getPosition();
				throw new IllegalStateException("Detected marked region end without corresponding marked region start "
						+ between + ", near [" + comment + "].");
			}
			stateChanged = (!input.isMarkedRegion() && isMarkedRegionStart) || (input.isMarkedRegion() && isMarkedRegionEnd);

		} while (/* comment != null && */!stateChanged);

		// finished, if no more comments or no marked regions entered/leaved
		if (/* comment == null || */!stateChanged) {
			return remainingRegion(input);
		}

		// comment != null && state changed => current comment is a marked region start or end
		if (isMarkedRegionStart) {
			String id = oracle.getId(comment);
			boolean enabled = oracle.isEnabled(comment);
			String text = input.enterMarkedRegion(id, enabled);
			return new Region(text);
		} else if (isMarkedRegionEnd) {
			String id = input.getMarkedRegionId();
			boolean enabled = input.isMarkedRegionEnabled();
			String text = input.leaveMarkedRegion();
			return new Region(id, text, enabled);
		} else {
			throw new IllegalStateException("tertium non datur");
		}
	}

	/**
	 * Get the remaining text of input, performing sanity checks.
	 * 
	 * @param input
	 * @return
	 */
	private IRegion remainingRegion(Input input) {
		if (input.isMarkedRegion()) {
			throw new IllegalStateException("Marked region does not end properly. ID: " + input.getMarkedRegionId());
		} else {
			return new Region(input.remaining());
		}
	}

	/**
	 * Gathers information about the next occurrence of a comment (added via one of the #addComment()
	 * methods). The information is not sufficient to tell if it is a marked region start/end. This
	 * information will be parsed later.
	 * 
	 * @param input
	 * @return
	 */
	private ICommentType getNextCommentType(Input input) {

		// extractComment() will break the loop and return null if nothing was found
		while (true) {
			// find lowest index of any character data start (-1 if not found)
			IndexOfObject<ICDataType> firstCData = findLowestIndex(input,
					new InnerIterator<ICDataType, String>(cdataTypes.iterator()) {
						@Override
						protected String getInner(ICDataType outer) {
							return outer.getStart();
						}
					});

			// find lowest index of any comment start (-1 if not found)
			IndexOfObject<ICommentType> firstComment = findLowestIndex(input, new InnerIterator<ICommentType, String>(
					commentTypes.iterator()) {
				@Override
				protected String getInner(ICommentType outer) {
					return outer.getStart();
				}
			});

			if (firstCData.object == null) {
				// no character data found => return comment type (null, if not found)
				return extractComment(input, firstComment.object, firstComment.index);
			} else {
				// -1 <= firstComment.index, firstCData.index >= 0,
				if (firstComment.index < firstCData.index) {
					// comment in front of character data => return comment type (null, if not found)
					return extractComment(input, firstComment.object, firstComment.index);
				} else {
					// character data in front of comment => find character data end
					findEndOfCharacterData(input, firstCData);
				}
			}
		}
	}

	/**
	 * Assuming that the start of a character data was already found, the end is searched here.
	 * 
	 * 
	 * @param input
	 * @param cdata
	 */
	private void findEndOfCharacterData(Input input, IndexOfObject<ICDataType> cdata) {
		input.update(cdata.index, cdata.object.getStart().length());
		String end = cdata.object.getEnd();
		String escapeString = cdata.object.getEscapeString();
		while (true) {
			int indexOfEscapeString = (escapeString != null) ? input.indexOf(escapeString) : -1;
			int indexOfCDataEnd = input.indexOf(end);
			// cdata end not found
			if (indexOfEscapeString == -1) {
				if (indexOfCDataEnd == -1) {
					Input.Between between = input.getPosition();
					throw new IllegalStateException("Character data end '" + end + "' not found " + between);
				} else {
					input.update(indexOfCDataEnd, end.length());
					break;
				}
			} else {
				if (indexOfCDataEnd != -1 && indexOfCDataEnd < indexOfEscapeString) {
					input.update(indexOfCDataEnd, end.length());
					break;
				} else {
					// length of escape string + length of escaped character = 2
					input.update(indexOfEscapeString, 2);
					// continue finding end of current character data
				}
			}
		}
	}

	/**
	 * Update Input and return new comment type (possibly null).
	 * 
	 * @param input
	 * @param commentType
	 * @param index
	 * @return
	 */
	private ICommentType extractComment(Input input, ICommentType commentType, int index) {
		if (commentType == null) {
			input.noCommentFound();
			return null;
		} else {
			input.setCommentStart(index);
			input.update(index, commentType.getStart().length());
			return commentType;
		}
	}

	/**
	 * Generic search method. Given an InnerIterator, which iterates over inner String objects of
	 * outer/host objects (of type T), the lowest index of a String within input is searched. When an
	 * occurence is found, the corresponding outer object is stored with the index.
	 * 
	 * @param input
	 * @param strings
	 * @return IndexOfObject<T>, guaranteed not to be null
	 */
	private <T> IndexOfObject<T> findLowestIndex(Input input, InnerIterator<T, String> strings) {
		T object = null;
		int lowestIndex = Integer.MAX_VALUE;
		for (String string : strings) {
			int i = input.indexOf(string);
			if (i != -1 && i < lowestIndex) { // the first match wins, because of '<'
				lowestIndex = i;
				object = strings.currentOuter();
			}
		}
		return new IndexOfObject<T>(lowestIndex, object);
	}

	/**
	 * Read the content of a multiline comment (not supporting nested comments).
	 * 
	 * @param input
	 * @param type
	 * @return
	 */
	private String getMultilineComment(Input input, ICommentType type) {
		int i = input.indexOf(type.getEnd());
		if (i == -1) {
			throw new IllegalArgumentException("Comment does not end properly: " + input.getStringAtCursor());
		}
		return input.consume(i, type.getEnd().length()); // text between start and end of comment
	}

	/**
	 * Read the content of a multiline comment (supporting nested comments).
	 * 
	 * @param input
	 * @param type
	 * @return
	 */
	private String getMultilineNestableComment(Input input, ICommentType type) {
		StringBuilder result = new StringBuilder();
		int depth = 1;
		int endIndex;
		do {
			int startIndex = input.indexOf(type.getStart());
			endIndex = input.indexOf(type.getEnd());
			if (startIndex != -1 && startIndex < endIndex) {
				depth++;
				// nested comment start strings are part of the comment
				String part = input.consume(startIndex + type.getStart().length(), 0);
				result.append(part);
			} else if (endIndex != -1) {
				depth--;
				String part;
				if (depth == 0) {
					// omit last comment end string
					part = input.consume(endIndex, type.getEnd().length());
				} else {
					// nested comment end strings are part of the comment
					part = input.consume(endIndex + type.getEnd().length(), 0);
				}
				result.append(part);
			} else {
				throw new IllegalArgumentException("Comment does not end properly: " + input.getStringAtCursor());
			}
		} while (depth > 0);
		return result.toString();
	}

	/**
	 * Read the content of a singleline comment.
	 * 
	 * @param input
	 * @param type
	 * @return
	 */
	private String getSinglelineComment(Input input, ICommentType type) {
		String eol = null;
		int lowestIndex = Integer.MAX_VALUE;
		for (String currentEol : END_OF_LINE_FLAVORS) {
			int i = input.indexOf(currentEol);
			if (i != -1 && i < lowestIndex) { // the first match wins, because of '<'
				lowestIndex = i;
				eol = currentEol;
			}
		}
		if (eol == null) {
			return input.getStringAtCursor(); // EOF reached, reading all.
		} else {
			return input.consume(lowestIndex, eol.length());
		}
	}

	// --- The following helper classes contain only data
	// --- and are helping to unclutter the code and make
	// --- it more readable.

	/**
	 * Encapsulating the parser input read while parsing. In particular there is no business logic.<br>
	 * <br>
	 * Invariant: 0 <= marker <= cursor <= document.length()
	 */
	private static class Input {

		final String document;
		String markedRegionId;
		boolean markedRegionEnabled;
		int marker = 0;
		int index = 0;
		int lastIndex = 0;

		// Take care of comment starts because of marked region end comments,
		// which are not part of marked regions.
		int commentStart;

		// read InputStream into String
		Input(String document) {
			this.document = document;
		}

		// cursor reached end?
		boolean endOfDocumentReached() {
			return index >= document.length();
		}

		// all characters read (i.e. marker reached end)?
		boolean hasRemaining() {
			return marker < document.length();
		}

		// read rest of document, starting at marker position
		String remaining() {
			String result = document.substring(marker);
			marker = document.length();
			index = marker; // consumed all
			return result;
		}

		// read rest of document, starting at cursor position
		String getStringAtCursor() {
			return document.substring(index);
		}

		// read document part, moving cursor
		String consume(int endIndex, int additionalChars) {
			String result = document.substring(index, endIndex);
			lastIndex = index; // save last index for calculating cursor (@see #getCursor())
			index = endIndex + additionalChars;
			return result;
		}

		// move cursor
		void update(int endIndex, int additionalChars) {
			if (index > endIndex + additionalChars) {
				throw new IllegalStateException("cannot step back - bug in the parser!");
			}
			index = endIndex + additionalChars;
		}

		// index of a substring, starting at current cursor position
		int indexOf(String substring) {
			return document.indexOf(substring, index);
		}

		// entering marked region => remembering id and returning previous region
		String enterMarkedRegion(String id, boolean enabled) {
			markedRegionId = id;
			markedRegionEnabled = enabled;
			String result = document.substring(marker, commentStart); // marked region start comment part of marked region
			marker = commentStart;
			return result;
		}

		// leaving marked region => clearing id and returning previous region
		String leaveMarkedRegion() {
			markedRegionId = null;
			markedRegionEnabled = false;
			String result = document.substring(marker, index); // marked region end comment part of marked region
			marker = index;
			return result;
		}

		// marker currently within marked region? (cursor may be outside)
		boolean isMarkedRegion() {
			return markedRegionId != null;
		}

		// get marked region id (null, if isMarkedRegion() == false)
		String getMarkedRegionId() {
			return markedRegionId;
		}

		boolean isMarkedRegionEnabled() {
			return markedRegionEnabled;
		}

		void setCommentStart(int index) {
			commentStart = index;
		}

		void noCommentFound() {
			commentStart = -1;
		}

		private static final Pattern EOL = Pattern.compile("(\\r\\n|\\n|\\r)");

		Between getPosition() {
			return new Between(internal_getCursor(lastIndex), internal_getCursor(index));
		}

		private Cursor internal_getCursor(int idx) {
			// calculate line & column number. performance should be ok, because it is not called
			// continuously.
			String documentToCursor = document.substring(0, idx);
			Matcher matcher = EOL.matcher(documentToCursor);
			int line = 1; // reset
			while (matcher.find()) {
				line++;
			}
			int eol = Math.max(documentToCursor.lastIndexOf("\r"), documentToCursor.lastIndexOf("\n"));
			int len = documentToCursor.length();
			int column = (len == 0) ? 1 : (len - ((eol == -1) ? 0 : eol));
			return new Cursor(line, column);
		}

		static class Cursor {
			final int line;
			final int column;

			Cursor(int line, int column) {
				this.line = line;
				this.column = column;
			}

			@Override
			public String toString() {
				return new StringBuilder("(").append(line).append(",").append(column).append(")").toString();
			}
		}

		static class Between {
			final Cursor start;
			final Cursor end;

			Between(Cursor start, Cursor end) {
				this.start = start;
				this.end = end;
			}

			@Override
			public String toString() {
				return new StringBuilder("between ").append(start.toString()).append(" and ").append(end.toString()).toString();
			}
		}
	}

	/**
	 * A default implementation of IDocument.IRegion, returned by the #parse(InputStream) method and
	 * needed to merge documents (@see RegionUtil#merge(IDocument, IDocument)).
	 */
	private static class Region implements IRegion {

		final Boolean enabled;
		final String id;
		final String text;

		Region(String text) {
			this.enabled = null;
			this.id = null;
			this.text = text;
		}

		Region(String id, String text, Boolean enabled) {
			if (id == null) {
				throw new IllegalArgumentException("Id of region cannot be null.");
			}
			if (enabled == null) {
				throw new IllegalArgumentException("Region has to be enabled or disabled.");
			}
			this.enabled = enabled;
			this.id = id;
			this.text = text;
		}

		@Override
		public String toString() {
			return id;
		}

		//@Override
		public boolean isMarkedRegion() {
			return id != null;
		}

		//@Override
		public boolean isEnabled() {
			return enabled != null && enabled;
		}

		//@Override
		public String getId() {
			return id;
		}

		//@Override
		public String getText() {
			return text;
		}
	}

	/**
	 * Special Iterator.
	 * 
	 * @param <O> outer elements
	 * @param <I> inner element of a specific outer element
	 */
	private abstract static class InnerIterator<O, I> implements Iterable<I>, Iterator<I> {
		private final Iterator<O> outerIterator;
		private O currentOuter;

		InnerIterator(Iterator<O> outerIterator) {
			this.outerIterator = outerIterator;
		}

		//@Override
		public Iterator<I> iterator() {
			return this;
		}

		//@Override
		public boolean hasNext() {
			return outerIterator.hasNext();
		}

		//@Override
		public I next() {
			currentOuter = outerIterator.next();
			return getInner(currentOuter);
		}

		//@Override
		public void remove() {
		}

		public O currentOuter() {
			return currentOuter;
		}

		protected abstract I getInner(O outer);
	}

	/**
	 * Encapsulates an index of a specific String.
	 */
	private static class IndexOfObject<T> {

		final int index;
		final T object;

		IndexOfObject(int index, T object) {
			this.index = index;
			this.object = object;
		}
	}
}
