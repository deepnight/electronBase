class Boot extends hxd.App {
	public static var ME : Boot;

	// Very first method called on boot
	static function main() new Boot();

	// Engine/canvas ready
	override function init() {
		ME = this;

		h3d.Engine.getCurrent().backgroundColor = 0xffffff;
		hxd.Res.initEmbed();

		var p = new JQ('p');
		p.css("background-color","red");
		p.click( _->{});

		function log(str:Dynamic, ?inf) { new JQ("body").append('<pre>$str</pre>'); }
		haxe.Log.trace = log;
	}

	override function update(deltaTime:Float) {
		super.update(deltaTime);
		dn.Process.updateAll(hxd.Timer.tmod);
	}
}
