package mini.types;

enum abstract EntryType(Int) {
	final Document:EntryType = 0; // 0

	/**
	 * Section
	 * Example: [BlahBlahBlah]
	 */
	final Section:EntryType = 1; // 1

	/**
	 * Comment
	 * Example: `; BlahBlahBlah` or `# BlahBlahBlah`.
	 */
	final Comment:EntryType = 2; // 2

	/**
	 * Key Value
	 * Example: BlahBlahBlah = WhatTheSigma
	 */
	final KeyValue:EntryType = 3; // 3

	/**
	 * This enum-like type is used for dangerously injecting data.
	 * 
	 * !! Unless you know what you are doing. DO NOT USE THIS !!
	 * !! (NOTICE: ANYTHING YOU INJECT HAS A CHANCE TO BREAK THE PARSER). !!
	 * 
	 * @since 1.0.2
	 */
	final DangerousInner:EntryType = 0x04;

	/**
	 * Convert type to string.
	 * @return String
	 */
	@:to public function toString():String {
		return switch (cast this : EntryType) {
			case Document: "Document";
			case Section: "Section";
			case Comment: "Comment";
			case KeyValue: "KeyValue";
			case DangerousInner: "DangerousInner";
		};
	}

	/**
	 * Converts a string to a type.
	 * @param str Option
	 * @return EntryType
	 */
	@:from public static function fromString(str:String):EntryType {
		return switch str.toLowerCase() {
			case "document": Document;
			case "section": Section;
			case "comment": Comment;
			case "keyvalue": KeyValue;
			case 'dangerousinner': DangerousInner;
			default: throw 'Unknown Type: $str';
		};
	}
}