package mini;

import haxe.io.Bytes;

using StringTools;

// backwards compatibility
@:deprecated typedef LToken = Token;

enum Token {
	Section(section:String); // [ 𝑥 ]
	Key(key:String); // 𝑥 = 𝑦
	Value(value:String); // 𝑥 = 𝑦
	Comment(comment:String); // ; 𝑥
	Equals; // =
	Newline; // \n
	Eof; // end of file
}

// Until i've made the decision on whether i'm going to refactor this, it'll stay private.
@:allow(mini.Lexer) 
@:noPrivateAccess 
@:private enum abstract Code(Int) from Int to Int {
	public static inline var SPACE:Int = 32; // ' '
	public static inline var TAB:Int = 9; // '\t'
	public static inline var NL:Int = 10; // '\n'
	public static inline var LBRACKET:Int = 91; // '['
	public static inline var SEMI:Int = 59; // ';'
	public static inline var HASH:Int = 35; // '#'
}

@:nullSafety(Strict)
class Lexer {
	/**
	 * Turns the given `string` into an list of tokens.
	 * @param input input string
	 * @return Outputs Array<LToken>
	 */
	public static function tokenize(data:String):Array<Token> {
		// Helper method: checks whether a character is a comment prefix (; or #)
		inline function isComment(c:Null<Int>):Bool
			return c == null ? false : c == Code.SEMI || c == Code.HASH;

		// An array to store the final tokens.
		final tokens:Array<Token> = new Array<Token>();

		// Convert the input string into bytes for easier line parsing.
		final bytes:Bytes = Bytes.ofString(data);

		// Current reading position and line number.
		var pos:Int = 0, lineNo:Int = 1;

		// Read a line from input bytes.
		// Returns a String for the line, or null if at the end of input.
		inline function readLine():Null<String> {
			// If the position is greater than the bytes length, return a null.
			if (pos >= bytes.length) return null;

			// Create a constant of the starting position.
			final startPosition:Int = pos;

			// Move forward until we reach a newline character or the end of input.
			while (pos < bytes.length && bytes.get(pos) != Code.NL) pos++;

			// Extract the bytes from `startPosition` to `pos` and convert them to a String.
			final extractedLine:String = bytes.sub(startPosition, pos - startPosition).toString();

			// If the current byte is a newline, skip it for the next read.
			if (pos < bytes.length && bytes.get(pos) == Code.NL) pos++;

			// Increment the line counter.
			lineNo++;

			// Return the extracted line.
			return extractedLine;
		}

		// Read the initial line.
		var line:Null<String> = readLine();

		while (line != null) {
			// Constant mirror of the current line.
			final l:Null<String> = line;

			// Constant trimmed mirror of the current line.
			final trimmed:String = l.trim();

			// If the line is blank, we're going to push a `NewLine` token to the array.
			// Then we're going to read the next line.
			if (trimmed == "") {
				tokens.push(Newline);
				line = readLine();
				continue;
			}

			// Get the first character of the trimmed line.
			final f:Null<Int> = trimmed.charCodeAt(0);
			if (f == null) continue;

			// If the line starts with a comment symbol, create Comment token.
			if (isComment(f)) {
				// Push the trimmed comment and a new line token.
				tokens.concat([Comment(trimmed.substring(1).trim()), Newline]);
				line = readLine();
				continue;
			}

			// Section line [ 𝑥 ].
			if (f == Code.LBRACKET) {
				// Find the closing bracket.
				final closeIndex:Int = trimmed.indexOf("]");
				if (closeIndex == -1) throw new Exception(EMalformedSection(trimmed), lineNo - 1);

				// Check for inline comment after section.
				final t:String = trimmed.substring(closeIndex + 1).ltrim();
				if (t.length > 0 && !isComment(t.charCodeAt(0))) throw new Exception(EMalformedSection(trimmed), lineNo - 1);

				// Push Section token.
				tokens.push(Section(trimmed.substring(1, closeIndex).trim()));

				// Push Comment token if there is an inline comment.
				if (t.length > 0) {
					// Always push a newline after section.
					tokens.push(Comment(t.substring(1).trim()));
				}

				// Push a new line token, then read the next line.
				tokens.push(Newline);
				line = readLine();
				continue;
			}

			// Key = Value
			final indexOf:Int = trimmed.indexOf("=");

			// Whether the key index has been found, or not.
			if (indexOf != -1) {
				// Extract key
				final key:String = trimmed.substring(0, indexOf).rtrim();

				// Unknown line throw.
				if (key == "" || key.length > 0 && isComment(key.charCodeAt(0))) throw new Exception(EUnknownLine, lineNo - 1);

				var value:String = trimmed.substring(indexOf + 1).ltrim();

				// Inlined comment.
				var comment:String = "";

				// Comment position on the line.
				var commentPos:Int = -1;

				// Loop through the value until a comment marker is found.
				for (i in 0...value.length) {
					// Whether the comment has been found, or not.
					if (isComment(value.charCodeAt(i))) {
						// Set the comment position on the line to `i`, then break.
						commentPos = i;
						break;
					}
				}
				
				// Whether the comment position has been found, or not.
				if (commentPos != -1) {
					// Set the `comment` variable with the value.
					comment = value.substring(commentPos + 1).rtrim();
					// Set the `value` variable without the comment.
					value = value.substring(0, commentPos).rtrim();
				}

				// Handle multiline / triple-quoted values
				var buf:StringBuf; (buf = new StringBuf()).add(value);

				// Whether the value starts with a triple-quote maker, or not.
				final isTripleQuote:Bool = value.startsWith('"""') || value.startsWith("'''");

				// If it is a triple-quote, create a new instance, then add the trimmed value.
				if (isTripleQuote) 
					(buf = new StringBuf()).add(value.substring(3).rtrim());

				// The triple-quote maker reference.
				final tripleMarker:Null<Null<String>> = isTripleQuote ? value.substr(0, 3) : null;

				while (true) {
					// Triple-quoted multiline handling
					// Whether we're inside a triple-quoted multiline, or not.
					if (isTripleQuote && tripleMarker != null) {
						// Reads the next line of input.
						// If `EOF` happens before closing marker, throw an exception.
						// This forces multilines to be closed.
						final nxtLine:Null<String> = readLine();
						if (nxtLine == null) throw new Exception(EUnterminatedMultilineValue(key), lineNo - 1);
						
						// Find the closing triple quote marker.
						final idx:Int = nxtLine.indexOf(tripleMarker);

						// Whether the closing marker has been found.
						if (idx != -1) {
							// Append content before the marker.
							buf.add('\n${nxtLine.substring(0, idx)}');
							
							// Handle anything after the marker.
							final t:String = nxtLine.substring(idx + 3).ltrim();

							// Only comments are allowed after the closing triple quotes.
							// If present, they're extracted and stored as a `Comment` token
							if (t != "" && isComment(t.charCodeAt(0))) tokens.push(Comment(t.substring(1).trim()));

							// End the loop.
							break;
						}

						// If the marker is not found. Append it (with a newline), then keep looping to read the next line.
						buf.add('\n$nxtLine');
						continue;
					}

					// Line continuation using backslash.
					final s:String = buf.toString();
					if (!s.endsWith("\\")) break;

					// Create a new string buffer, then add trim the prev buffer.
					(buf = new StringBuf()).add(s.substring(0, s.length - 1).rtrim());
					
					// Read the next line, then push the trimmed mirror of it to the string buffer.
					final nxtLine:Null<String> = readLine();
					if (nxtLine == null) break;
					buf.add('\n' + StringTools.trim(nxtLine));
				}

				// Set the value to the buffer.
				value = buf.toString();

				// Remove surrounding quotes.
				final vl:Int = value.length;
				if ((vl >= 2) && ((value.charAt(0) == '"' && value.charAt(vl - 1) == '"') || (value.charAt(0) == "'" && value.charAt(vl - 1) == "'"))) 
					value = value.substring(1, vl - 1);

				// Push comment token if exists.
				if (comment != "") tokens.push(Comment(comment.trim()));

				// Push Key, Equals, Value, and Newline tokens.
				for (i in [Key(key), Equals, Value(value), Newline]) tokens.push(i);

				// Read the next line then set it to the `line` variable.
				line = readLine();
				continue;
			}

			// Unknown line, for an exception.
			throw new Exception(EUnknownLine, lineNo - 1);
		}

		// Push EoF (End of File) Token.
		tokens.push(Eof); 
		return tokens;
	}
}
