package mini;

// Until i've made the decision on whether i'm going to refactor this, it'll stay private.
// i have made my decision

@:publicFields
enum abstract Unicode(Int) from Int to Int {
	static inline var SPACE:Int = 32; // ' '
	static inline var TAB:Int = 9; // '\t'
	static inline var NEW_LINE:Int = 10; // '\n'
	static inline var CR:Int = 13; // '\r'
	static inline var LBRACKET:Int = 91; // '['
	static inline var RBRACKET:Int = 93;
	static inline var SEMI:Int = 59; // ';'
	static inline var HASH:Int = 35; // '#'
	static inline var EQ = 61; // '='
	static inline var DOUBLE_QUOTE = 34; // '"'
	static inline var SINGLE_QUOTE = 39; // '
    static inline var BACK_SLASH = 92; // \
}
