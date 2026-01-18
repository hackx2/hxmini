package mini;

using StringTools;

enum Token {
	SectionStart;
	SectionEnd;
	Identifier(s:String);
	StringLit(s:String);
	SectionName(name:String);
	Equals;
	Newline;
	Comment(comment:String);
	Eof;
}

@:nullSafety(Strict)
class Lexer {
	public var data:String;
	public var pos:Int = 0;
	public var line:Int = 1;

	public function new(data:String): Void this.data = data;
	
	public function nextToken():Token {
		while (true) {
			final code:Int = next();

			if (code == -1) {
				return Eof;
			}

			if (isSpace(code)) {
				continue;
			}

			if (isNewline(code)) {
				line++;
				inRawValue = false;
				return Newline;
			}

			if (isCommentPrefix(code)) {
				return readComment();
			}

			if (code == Unicode.DOUBLE_QUOTE || code == Unicode.SINGLE_QUOTE) {
				return readString(code);
			}

			switch code {
				case Unicode.LBRACKET: inSectionHeader = true; return SectionStart;
				case Unicode.RBRACKET: inSectionHeader = false; return SectionEnd;
				case Unicode.EQ: inRawValue = true; return Equals;
				case Unicode.CR: return Newline;
			}

			if (inRawValue) {
				return readRawValue(code);
			}

			// identifiers -w-
			if (isIdentChar(code)) {
				return inSectionHeader ? readSectionName(code) : readIdentifier(code);
			}

			// anything and everything else is invalid so throw
			throw new Exception(ECustom('Unexpected character $code \'${String.fromCharCode(code)}\' at line ${line}'));
		}
	}

	// todo: states???
	// maybe not...

	function readIdentifier(first:Int):Token {
		final start:Int = pos - 1;
		while (isIdentChar(peek())) {
			next();
		}
		return Identifier(data.substr(start, pos - start));
	}

	function readComment():Token {
		final start:Int = pos;
		while (!isNewline(peek()) && peek() != -1) {
			next();
		}
		return Comment(data.substr(start, pos - start).trim());
	}

	var inRawValue:Bool = false;
	
	function readRawValue(first:Int):Token {
		final start:Int = pos - 1;

		while (true) {
			final c:Int = peek();
			if (c == -1 || isNewline(c))
				break;
			next();
		}

		return Identifier(data.substr(start, pos - start).trim());
	}

	var inSectionHeader:Bool = false;

	function readSectionName(first:Int):Token {
		final start:Int = pos - 1;

		while (true) {
			final c:Int = peek();
			if (c == -1 || c == Unicode.RBRACKET || isNewline(c)) {
				break;
			}
			next();
		}

		return SectionName(data.substr(start, pos - start).trim());
	}

	function readString(quote:Int):Token {
		final buf:StringBuf = new StringBuf();
		final isTriple:Bool = peek() != -1 && peek() == quote && pos + 1 < data.length && data.fastCodeAt(pos + 1) == quote;

		if (isTriple) {
			pos += 2; // skip extra quotes
		}

		while (true) {
			if (pos >= data.length) {
				throw new Exception(ECustom('Unexpected end of input: unclosed ${isTriple ? "triple-quoted" : "single-quoted"} string starting at line ${line}')); //bwah
			}

			final code:Int = next();

			// End of triple-quoted string
			if (isTriple && code == quote && peek() != -1 && peek() == quote && pos + 1 < data.length && data.fastCodeAt(pos + 1) == quote) {
				pos += 2;
				break;
			}

			// End of single-quoted string
			if (!isTriple && code == quote) {
				break;
			}

			// Escaped character
			if (code == Unicode.BACK_SLASH /* '\' */ && pos < data.length) {
				final nextCode:Int = next();
				switch nextCode {
					case Unicode.DOUBLE_QUOTE: buf.addChar(Unicode.DOUBLE_QUOTE); // "
					case Unicode.SINGLE_QUOTE: buf.addChar(Unicode.SINGLE_QUOTE); // '
					case Unicode.BACK_SLASH: buf.addChar(Unicode.BACK_SLASH); // \
					case 'n'.code: buf.addChar(Unicode.NEW_LINE); // \n
					case 'r'.code: buf.addChar(Unicode.CR); // \r
					case 't'.code: buf.addChar(Unicode.TAB); // \t
					default: buf.addChar(nextCode);
				}
				continue;
			}

			if (isNewline(code)) {
				line++;
			}

			buf.addChar(code);
		}

		return StringLit(buf.toString());
	}


	// Helper function to skip escaped newlines
	inline function skipEscapedNewline():Void {
		next(); // skip the \n or \r
		if (peek() == Unicode.NEW_LINE) next(); // skip \r\n
		line++; // meow
	}
	
	inline function peek():Int return pos < data.length ? data.fastCodeAt(pos) : -1;
	inline function next():Int return pos < data.length ? data.fastCodeAt(pos++) : -1;

	inline function isSpace(c:Int):Bool return c == Unicode.SPACE || c == Unicode.TAB;
	inline function isNewline(c:Int):Bool return c == Unicode.NEW_LINE;
	inline function isCommentPrefix(c:Int):Bool return c == Unicode.SEMI || c == Unicode.HASH;
	inline function isIdentChar(c:Int):Bool return (c >= 'a'.code && c <= 'z'.code) || (c >= 'A'.code && c <= 'Z'.code) || (c >= '0'.code && c <= '9'.code) || c == '_'.code || c == '-'.code || c == '.'.code || c=='$'.code;

	// ---

	public static function tokenize(data:String):Array<Token> {
		final lexer:Lexer = new Lexer(data);
		final tokens:Array<Token> = new Array<Token>();
		while (true) {
			final token:Token = lexer.nextToken();
			tokens.push(token);
			if (token == Eof) break;
		}
		return tokens;
	}
}

// backwards compatibility
@:deprecated typedef LToken = Token;