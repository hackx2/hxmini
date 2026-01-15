package mini;

using StringTools;

/**
 * matter.ini's utility class.
 * 
 * This class contains all methods / variables utilized by matter.ini
 */
final class Utils {
	/**
	 * Determines whether the first character of the given string is a whitespace character.
	 * @param c The input string to check.
	 * @return `true` if the first character is a whitespace character; otherwise, `false`.
	 *
	 * @see https://en.wikipedia.org/wiki/Whitespace_character
	 */
	@:deprecated
	@:pure public inline static function isWhitespace(c:String):Bool {
		final _code:Null<Int> = c.charCodeAt(0);
		return _code == 32 /* space */
			|| _code == 9 /* character tabulation */
			|| _code == 13 /* carriage return */
			|| _code == 10 /* line feed ??? */;
	}

	/**
	 * Trims trailing whitespace from the given string.
	 *
	 * This function is deprecated in favor of `StringTools.rtrim`, which provides the same behavior.
	 * It removes common trailing whitespace characters (space, tab, carriage return, line feed).
	 *
	 * @param s The input string to trim.
	 * @return A new string with trailing whitespace removed.
	 * 
	 * @see https://api.haxe.org/StringTools.html#rtrim
	 */
	@:deprecated
	public inline static function trim_right(s:String):String { // LET ME SLEEP PLEASE
		var i:Int = (s.length - 1);
		while (i >= 0 && isWhitespace(s.charAt(i))) {
			i--;
		}
		return s.substring(0, i + 1);
	}

	/**
	 * Wraps multiline strings.
	 * @param b given string
	 * @return wrapped string.
	 */
	@:noUsing public inline static function wrapMultiline(b:String):String {
		if (b == null) return "";

		var needsQuotes:Bool = false;

		// Check whether it contains any special characters
		for (i in 0...b.length) {
			final code:Int = b.charCodeAt(i);
			if (code == Unicode.NEW_LINE || code == Unicode.SPACE || code == Unicode.DOUBLE_QUOTE || code == Unicode.SINGLE_QUOTE) {
				needsQuotes = true;
				break;
			}
		}

		if (needsQuotes) {
			final escaped:String = b.replace("\"", "\\\"");
			return '"${escaped}"';
		}

		return b;
	}

	@:deprecated("mini.Utils.fixMultiline is deprecated, use mini.Utils.wrapMultiline instead")
	public static inline function fixMultiline(b:String):String {
		return Utils.wrapMultiline(b);
	}
}
