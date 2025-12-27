package tests;

import haxe.Resource;

final class Normal extends Test {
	@:noCompletion override function test():Null<Bool> {
		final ini:Ini = Parser.parse(Resource.getString('testing_ini'));
		trace(ini.get('hai'));
		final main:Ini = ini.elementsNamed("Main").next();
		trace('[Global]');
		trace(main.get('hello'));
		trace(main.get('name'));
		trace(main.get('meows'));
		trace('"${main.get('multiline')}"');

		final general:Ini = ini.elementsNamed("General").next();
		trace('[General]');
		trace(general.get("version"));
		trace(general.get("theme"));

		return !super.test();
	}
}
