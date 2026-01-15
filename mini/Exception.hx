package mini;

import haxe.Exception;
import mini.types.ExceptionKind;

class Exception extends haxe.Exception {
	public var line:Int;
	public var kind:ExceptionKind;

	// MINI EXCEPTION seems so cringe
	public function new(kind:ExceptionKind, ?line:Int) {
		super('[hxmini] : [EXCEPTION]:${line != null ? '$line:' : ''} ' + to(kind));
		this.kind = kind;
		this.line = line ?? 0;
	}

	static function to(kind:ExceptionKind):String {
		return switch kind {
			case EMalformedSection(key): 'Malformed section header "$key"';
			case EUnknownLine: 'Unrecognized line format';
			case EUnterminatedMultilineValue(key): 'Unterminated multiline value for key "$key"';
			case ECustom(e): '$e';
		}
	}
}
