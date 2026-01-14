package tests;

final class Creation extends Test {
	@:noCompletion override function test():Null<Bool> {
		final ini:Ini = Ini.createDocument();
		ini.comment('owha', HASHTAG);
		ini.set('owo', 'haii');
		ini.comment('owha');
		final general:Ini = Ini.createSection("General");
		general.set("name", "CustomIni");
		general.set("version", "1.0.0");
		general.comment("This is a comment...");
		ini.addChild(general);

		final user:Ini = Ini.createSection("User");
		user.set("username", "Pretzel");
		user.set("role", "Admin");
		ini.addChild(user);

		final net:Ini = Ini.createSection("Network");
		net.set("ip", "127.0.0.1");
		net.set("port", "5000");
		ini.addChild(net);

		ini.comment('Goodbye');

		trace(ini.toString());

		return !super.test();
	}
}
