class Boot extends hxd.App {
	public static var ME : Boot;

	// Very first method called during boot sequence
	static function main() new Boot();

	// Engine & canvas ready
	override function init() {
		ME = this;

		// Inits
		h3d.Engine.getCurrent().backgroundColor = 0x0;
		hxd.Res.initEmbed();

		// Start app process
		new App();
	}

	override function update(deltaTime:Float) {
		super.update(deltaTime);
		dn.Process.updateAll(hxd.Timer.tmod);
	}
}
