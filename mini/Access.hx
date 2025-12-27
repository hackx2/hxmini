package mini;

import mini.Ini;
import mini.types.EntryType;

/**
 * This API provides dot-access to commonly used `mini.Ini` methods, this class is inspired by [`haxe.xml.Access`](https://api.haxe.org/haxe/xml/Access.html).
 * 
 * This isn't required or really needed to access data stored in the Ini class.
 * I just want dot-access to be available to those who need/want it. ~orbl
 * 
 * @see https://api.haxe.org/haxe/xml/Access.html
 */
@:nullSafety(Strict)
abstract Access(Ini) {
	/**
	 * The **Ini** class this **Access** `abstract` is bound to.
	 */
	public var ini(get, never):Ini;
	@:noCompletion inline function get_ini():Ini {
		return this;
	}

	/**
	 * Access to a named child **key**.
	 * 
	 * Throws an exception if the section doesn't exists.
	 * Make sure to use `has` to make sure the section exists before attempting to require.
	 * 
	 * ```haxe
	 * final ini = mini.Parser.parse('\n[General]\nversion=1.0\n\ntheme=dark');
	 * final access = new mini.Access(ini);
	 * final section = access.has.section.General ? access.section.General : null;
	 * if (section != null) {
	 * 		if(section.has.key.version) {
	 *			trace(section.key.version); // 1.0
	 *		}	
	 * }
	 * ```
	 */
	public var key(get, never):KeyAccess;
	@:noCompletion inline function get_key():KeyAccess {
		return this;
	}

	/**
	 * Access to a named child **section**.
	 * 
	 * Throws an exception if the section doesn't exists.
	 * Make sure to use `has` to make sure the section exists before attempting to require.
	 * 
	 * ```haxe
	 * final ini = mini.Parser.parse('\n[General]\nversion=1.0\n\ntheme=dark');
	 * final access = new mini.Access(ini);
	 * 
	 * trace(access.has.section.General); // true
	 * ```
	 */
	public var section(get, never):SectionAccess;
	@:noCompletion inline function get_section():SectionAccess {
		return this;
	}

	/**
	 * Check the existence of a section or key from the given name. 
	 */
	public var has(get, never):HasAccess;
	@:noCompletion inline function get_has():HasAccess {
		return this;
	}

	/**
	 * Return an `Iterable` of all sections.
	 */
	public var sections(get, never):Iterable<Access>;
	@:noCompletion inline function get_sections():Iterable<Access> {
		return iterableFromIterator(mapIterator(this.sections(), i -> new Access(i)));
	}

	/**
	 * Return an `Iterable` of all keys.
	 */
	public var keys(get, never):Iterable<Access>;
	@:noCompletion inline function get_keys():Iterable<Access> {
		return iterableFromIterator(mapIterator(this.keys(), i -> new Access(i)));
	}

	/**
	 * Return an `Iterable` of all comments.
	 */
	public var comments(get, never):Iterable<Access>;
	@:noCompletion inline function get_comments():Iterable<Access> {
		return iterableFromIterator(mapIterator(this.comments(), i -> new Access(i)));
	}

	/**
	 * Get the value of this node (used for KeyValue or Comment).
	 */
	public var value(get, never):Null<String>;
	@:noCompletion inline function get_value():Null<String> {
		return this.nodeValue;
	}

	/**
	 * Get the name of this node.
	 */
	public var name(get, never):Null<String>;
	@:noCompletion inline function get_name():Null<String> {
		return this.nodeName;
	}

	/**
	 * Get the type of this `Ini` object.
	 */
	public var type(get,never):Null<EntryType>;
	@:noCompletion inline function get_type():Null<EntryType> {
		return this.nodeType;
	}

	public inline function new(i:Ini):Access {
		if (i == null)
			throw new Exception(ECustom("Cannot wrap null Ini node"));
		this = i;
	}

	/////////////////////////////////////////////////////////////////////////////////////

	@:noPrivateAccess @:noCompletion inline static function mapIterator<T, R>(it:Iterator<T>, fn:T->R):Iterator<R> {
		return {
			hasNext: it.hasNext,
			next: () -> fn(it.next())
		};
	}

	@:noPrivateAccess @:noCompletion inline static function iterableFromIterator<T>(it:Iterator<T>):Iterable<T> {
		return {
			iterator: () -> it
		};
	}
}

@:nullSafety(Strict)
abstract KeyAccess(Ini) from Ini to Ini {
	@:op(A.B)
	public function res(v:String):Null<String> {
		if (this.nodeType != EntryType.Section)
			throw new Exception(ECustom('Cannot get key "$v" from non section node: ${this.nodeType}'));
		for (c in this.children) {
			if (c.nodeType == EntryType.KeyValue && c.nodeName == v)
				return c.nodeValue;
		}
		throw new Exception(ECustom('Key "$v" not found in section "${this.nodeName}"'));
	}
}

@:nullSafety(Strict)
abstract SectionAccess(Ini) from Ini to Ini {
	@:op(A.B)
	public function res(v:String):Access {
		if (this.nodeType != EntryType.Document && this.nodeType != EntryType.Section)
			throw new Exception(ECustom('Cannot get section "$v" from node type: ${this.nodeType}'));
		for (c in this.children) {
			if (c.nodeType == EntryType.Section && c.nodeName == v)
				return new Access(c);
		}
		throw new Exception(ECustom('Section "$v" not found under "${this.nodeName}"'));
	}
}

@:nullSafety(Strict)
abstract HasAccess(Ini) from Ini {
	public var key(get, never):HasKeyAccess;
	inline function get_key():HasKeyAccess return this;
	
	public var section(get, never):HasSectionAccess;
	inline function get_section():HasSectionAccess return this;
}

abstract HasKeyAccess(Ini) from Ini {
	@:op(A.B)
	public function res(v:String):Bool {
		if (this.nodeType != EntryType.Section)
			throw new Exception(ECustom('Cannot check key "$v" on non section node: ${this.nodeType}'));
		for (c in this.children) {
			if (c.nodeType == EntryType.KeyValue && c.nodeName == v)
				return true;
		}
		return false;
	}
}

abstract HasSectionAccess(Ini) from Ini {
	@:op(A.B)
	public function res(v:String):Bool {
		if (this.nodeType != EntryType.Section && this.nodeType != EntryType.Document)
			throw new Exception(ECustom('Cannot check section "$v" on node type: ${this.nodeType}'));
		for (c in this.children) {
			if (c.nodeType == EntryType.Section && c.nodeName == v)
				return true;
		}
		return false;
	}
}
