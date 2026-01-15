package mini;

import haxe.extern.EitherType;
import mini.Lexer.Token;
import mini.types.CommentVariant;

using StringTools;

@:nullSafety(Strict)
class Parser {
    public var tokens:Array<Token>;
    public var pos:Int = 0;
    public var line:Int = 1;

    public function new(tokens:Array<Token>) : Void  this.tokens = tokens;

    public function parseDocument():Ini {
        final doc:Ini = Ini.createDocument();

        while (peek() != Eof) {
            switch peek() {
                case SectionStart: doc.addChild(parseSection());
                case Identifier(_): doc.addChild(parseKeyValue());
                case Comment(c):
                    next();
                    doc.addChild(new Ini(NodeType.Comment(getCommentVariant(c))));
                case Newline: next();
                case Eof: break;
                default: throw new Exception(ECustom("Unexpected token at line " + line + ": " + Std.string(peek())));
            }
        }

        return doc;
    }

    function parseSection():Ini {
        expect(SectionStart);

        final nextToken:Token = next();
        var sectionName:String;
        switch nextToken {
            case SectionName(s): sectionName = s;
            case Identifier(s): sectionName = s;
            default: throw new Exception(ECustom('Expected section name at line $line'));
        }

        expect(SectionEnd);
        if (peek() == Newline) next();

        final section:Ini = Ini.createSection(sectionName);

        // Parse section contents until next section or END OF FILE :<
        while (true) {
            switch peek() {
                case Identifier(_): section.addChild(parseKeyValue());
                case Comment(c):
                    next();
                    section.addChild(new Ini(NodeType.Comment(getCommentVariant(c))));
                case Newline: next();
                case SectionStart, Eof: return section;
                default: throw new Exception(ECustom('Unexpected token inside section $sectionName at line $line: ${Std.string(peek())}'));
            }
        }
    }

    function parseKeyValue():Ini {
        final keyToken:Token = next();
        var key:String;

        switch keyToken {
            case Identifier(s): key = s;
            default: throw new Exception(ECustom("Expected key at line " + line));
        }

        expect(Equals);

        final valueToken:Token = next();
        var value:String;
        switch valueToken {
            case StringLit(s): value = s;
            case Identifier(s): value = s;
            default: throw new Exception(ECustom('Expected value after key $key at line $line'));
        }

        final keyNode:Ini = Ini.createKey(key, value);

        // don't add comments to non document & sections
        if (peek() == Newline) next();

        return keyNode;
    }

	inline function getCommentVariant(c:String):CommentVariant return c.startsWith(";") ? CommentVariant.SEMICOLON : CommentVariant.HASHTAG;

	// ---

	inline function peek():Token return pos < tokens.length ? tokens[pos] : Eof; // -w-
    inline function next():Token {
        if (pos >= tokens.length) throw new Exception(ECustom("Unexpected end of input at line " + line));
        final token:Token = tokens[pos++];
        if (token == Newline) line++;
        return token;
    }
	inline function expect(expected:Token):Void {
		final token:Token = next();
		if (!Type.enumEq(token, expected)) { // mrrp~
			throw new Exception(ECustom('Expected ${Std.string(expected)} but got ${Std.string(token)} at line $line'));
		}
	}

	// ---

	/**
	 * Parses a list of tokens or a string into a `Ini` class.
	 * @param tokens Either `String` or `Array<Token>`
	 * @return Returned a fully structured `Ini` class.
	 */
    public static function parse(tokens:EitherType<String, Array<Token>>):Ini {
		final tokens:Array<Token> = tokens is String ? Lexer.tokenize(tokens) : cast tokens;
        return new Parser(tokens).parseDocument();
    }
}
