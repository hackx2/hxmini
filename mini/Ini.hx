package mini;

import mini.types.EntryType;

using StringTools;
using Lambda;

/**
 * Represents a node inside of an **INI** document tree.
 * 
 * An `Ini` instance can be one of several types (`Document`, `Section`
 * `KeyValue`, `Comment`) and **may** contain children nodes. 
 * This class can be used to parse build, modify, and serialize INI files.
 * 
 * The tree-like structure is mutable: each node holds a reference to its `parent`
 * and it's list of `children.
 * 
 * @see http://en.wikipedia.org/wiki/INI_file/
 */
class Ini {
	public var parent:Null<Ini>;

	/**
	 * The type of this node.
	 *
	 * Determines whether this node represents a `Document`, `Section`,
	 * `KeyValue`, or `Comment`.  
	 * This value controls how the node behaves within the INI tree and
	 * how it is serialized.
	 */
	public var nodeType(default, null):Null<EntryType>;

	/**
	 * The name associated with this node.
	 *
	 * For `Section` nodes, this is the section name.  
	 * For `KeyValue` nodes, this is the key name.  
	 * It is typically `null` for `Document` and `Comment` nodes.
	 */
	public var nodeName:Null<String>;

	/**
	 * The value associated with this node.
	 *
	 * Used primarily by `KeyValue` nodes to store the key's value.  
	 * `Section` and `Document` nodes normally do not use this field, and it
	 * may also be used for comment text depending on the implementation.
	 */
	public var nodeValue:Null<String>;

	/**
	 * Parse a string.
	 * @param str data
	 * @return Ini
	 */
	public static function parse(str:String):Ini {
		return Parser.parse(str);
	}

	/**
	 * This instances children.
	 */
	public var children:Array<Ini>;

	/**
	 * `mini.Ini`'s constructor
	 * @param type Note Type (Document, Section, Comment, KeyValue)
	 * @param name Name (Used for sections)
	 * @param value Value (Used for key values)
	 */
	public function new(type:EntryType, ?name:String, ?value:String):Void {
		this.nodeType = type;
		this.nodeName = name;
		this.nodeValue = value;
		this.children = new Array<Ini>();
		this.__disposed = false;
	}

	/**
	 * Create a document.
	 * @return Ini
	 */
	public static function createDocument():Ini {
		return new Ini(Document);
	}

	/**
	 * Create a section
	 * @param s The Section Name.
	 * @return Ini
	 */
	public static function createSection(s:String, ?parent:Ini):Ini {
		return new Ini(Section, s);
	}

	/**
	 * Create a key
	 * @param k The Key Name.
	 * @param v The Value.
	 * @return Ini
	 */
	public static function createKey(k:String, v:String):Ini {
		return new Ini(KeyValue, k, v);
	}

	@:noCompletion var __disposed:Bool = false;

	/**
	 * Disposes this node and all of its descendants.
	 *
	 * After disposal, the node becomes unusable.
	 */
	public function dispose():Void {
		if (__disposed)
			return;

		if (children != null && children.length > 0) {
			for (child in children) {
				if (child != null) {
					child.dispose();
				}
			}
		}
		if (children.length < 0)
			children.resize(0);

		parent = null;
		nodeName = null;
		nodeValue = null;
		nodeType = null;
		children = null;

		__disposed = true;
	}

	/**
	 * This method allows you to dangerous inject data.
	 * NOTICE: SINCE YOU'RE INJECTING THE TYPE `DangerousInner` YOU WONT BE ABLE TO USE .get() WITHOUT RE PARSING EVERYTHING. 
	 * 
	 * @param data The given data.
	 * @since 1.0.2
	 */
	public function dangerouslyInject(data:Dynamic) {
		addChild(new Ini(DangerousInner, null, data));
	}

	/**
	 * Adds/Pushes a child into the tree.
	 * @param x child
	 */
	public function addChild<T:Ini>(x:T):T {
		if (__disposed)
			return null;
		if (x.parent != null)
			x.parent.removeChild(x);
		children.push(x);
		x.parent = this;
		return x;
	}

	/**
	 * Removes a child from the children tree.
	 * @param x child
	 * @return Bool
	 */
	public function removeChild(x:Ini):Bool {
		if (!__disposed && children.remove(x)) {
			x.parent = null;
			return true;
		}
		return false;
	}

	/**
	 * Returns all elements.
	 * @return Iterator<Ini>
	 */
	public function elements():Iterator<Ini> {
		return children.iterator();
	}

	/**
	 * This gets all elements with the name v
	 * @param name the element name.
	 * @return Iterator<Ini>
	 */
	public function elementsNamed(name:String):Iterator<Ini> {
		return children.filter(c -> c.nodeName == name).iterator();
	}

	/**
	 * Looks up a key within this section and returns its value.
	 *
	 * Only works when called on a `Section` node.
	 * 
	 * @param name The key name.
	 * @return The value string, or `null` if the key does not exist.
	 */
	public function get(name:String):Null<String> {
		if (nodeType == Section || nodeType == Document) {
			for (c in children) {
				if (c != null && c.nodeType == KeyValue && c.nodeName == name) {
					return c.nodeValue;
				}
			}
		}
		return null;
	}

	/**
	 * Set a variable.
	 * @param name The name of the variable
	 * @param value The value.
	 */
	public function set(name:String, value:String):Void {
		if (nodeType == Section) {
			for (c in children) {
				if (c.nodeType == KeyValue && c.nodeName == name) {
					c.nodeValue = value;
					return;
				}
			}
			addChild(createKey(name, value));
		}
	}

	/**
	 * Create a comment.
	 * @param value 
	 */
	public function comment(value:String):Void {
		addChild(new Ini(Comment, null, value));
	}

	/**
	 * Converts a string into useable .ini data.
	 * This method is deprecated please use `mini.Parser.parse()` instead.
	 * @param data Data from an .ini file.
	 * @return Ini
	 */
	@:deprecated("This method is deprecated please use `mini.Parser.parse(v1)` instead,.")
	@:from public static function fromString(data:String):Ini {
		return Parser.parse(data);
	}

	/**
	 * Convert's this into a readable string.
	 * @return StringBuf
	 */
	@:to public function toString():String {
		return Printer.serialize(this);
	}

	/**
	 * Returns an iterator of all child sections.
	 */
	public function sections():Iterator<Ini> {
		return children.filter(c -> c.nodeType == Section).iterator();
	}

	/**
	 * Returns an iterator of all child key/value pairs.
	 */
	public function keys():Iterator<Ini> {
		return children.filter(c -> c.nodeType == KeyValue).iterator();
	}

	/**
	 * Returns an iterator of all child comments.
	 */
	public function comments():Iterator<Ini> {
		return children.filter(c -> c.nodeType == Comment).iterator();
	}

	/**
	 * Finds all children matching a predicate.
	 * @param predicate Function to test each node.
	 * @return Array<Ini> of matching nodes.
	 */
	public function find(predicate:Ini->Bool):Array<Ini> {
		return children.filter(predicate);
	}
}

@:deprecated("Use mini.EntryType instead")
typedef IniType = EntryType;
