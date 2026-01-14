package tests;

import mini.types.EntryType;

final class Miscellaneous extends Test {
	@:noCompletion override function test():Null<Bool> {
		// trace(['Document', EntryType.fromString('Document') is Int]);
		// trace(['Comment', EntryType.fromString('Comment') is Int]);
		// trace(['DangerousInner', EntryType.fromString('DangerousInner') is Int]);
		// trace(['KeyValue', EntryType.fromString('KeyValue') is Int]);
		// trace(['Section', EntryType.fromString('Section') is Int]);

		return !super.test();
	}
}
