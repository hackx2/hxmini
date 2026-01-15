package;

/**
 * This class serves as the core for testing each submodule inside of the ./tests/ directory.
 * 
 * Instead of dynamically loading each module from the ./tests/ directory, we've decided to manually load each module using rest.
 * Yes, dynamically loading each one would me more effective, however, it seems pointless on a project this small.
 * Also, dynamically loading modules would require the use of a macro, and i'm lazy. :3c
 */
class Main {
	static function main():Void {
		haxe.Log.trace = (str:Dynamic, ?_:haxe.PosInfos) -> { // remove posInfos formatting
			#if js
			if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
				(untyped console).log(str);
			#elseif lua
			untyped __define_feature__("use._hx_print", _hx_print(str));
			#elseif sys
			Sys.println(str);
			#else
			throw new haxe.exceptions.NotImplementedException()
			#end
		}

		final time:Float = haxe.Timer.stamp();
		trace('<---------------------- Testing ---------------------->\n');

		(function(...rest) {
			for (i in rest.toArray()) {
				trace([i]);
				trace('-----------------------------------');
				Type.createEmptyInstance(i).test();
				trace('-----------------------------------\n');
			}
		})(tests.Normal, tests.Long, tests.Creation, tests.Access, tests.DangerouslyInject, tests.Lexer);

		final timeTaken:Float = (haxe.Timer.stamp() - time)*1000;
		trace('Finished in $timeTaken seconds!\nAll tests passed!\n');
	}
}
