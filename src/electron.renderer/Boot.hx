class Boot extends hxd.App {
	public static var ME : Boot;

	// Very first method called on boot
	static function main() new Boot();

	// Engine/canvas ready
	override function init() {
		ME = this;

		h3d.Engine.getCurrent().backgroundColor = 0xffffff;
		hxd.Res.initEmbed();

		trace("hello world");
	}

	override function update(deltaTime:Float) {
		super.update(deltaTime);
		dn.Process.updateAll(hxd.Timer.tmod);
	}
}
