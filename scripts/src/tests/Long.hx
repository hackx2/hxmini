package tests;

import haxe.Resource;

final class Long extends Test {
	@:noCompletion override function test():Null<Bool> {
		final ini = Parser.parse(Resource.getString("testing_long_ini"));
		for (section in ini.elements()) {
			if (Type.enumEq(section.nodeType, Comment())) {
				trace(section.nodeValue);
				continue;
			}
			trace('[${section.nodeName}]');

			var i = 0;
			for (key in section.keys()) {
				trace('${key.nodeName} = ${section.get(key.nodeName)}');
				i++;
			}

			if (i > 1)
				trace('');

			for (child in section.find(node -> node.nodeName == "welcome_message")) {
				trace("FOUND IT: " + child.nodeValue);
			}
		}

		return !super.test();
	}
}
