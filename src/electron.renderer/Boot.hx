/**
	This class is the very first JS code called from `boot.html`.
	It initializes Heaps with existing WebGL canvas, then creates an App instance. This is also the place where all low-level initializations should happen (assets, localization etc.)
**/

class Boot extends hxd.App {
	public static var ME(default,null) : Boot;

	// Very first method called during boot sequence
	static function main() {
		// Force Heaps to use "#heaps" HTML canvas instead of default "#webgl"
		var canvas : js.html.CanvasElement = cast new js.jquery.JQuery('#heaps').get(0);
		new hxd.Window(canvas).setCurrent();

		// Init app
		new Boot();
	}

	// Engine is ready, we can start doing stuff
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

		dn.Process.updateAll( hxd.Timer.tmod );
	}
}
