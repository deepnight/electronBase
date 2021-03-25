class Page extends dn.Process {
	var jPage(get,never) : js.jquery.JQuery; inline function get_jPage() return App.ME.jPage;

	function new() {
		super(App.ME);
		App.LOG.general("Page started: "+Type.getClassName( Type.getClass(this) )+"()" );
	}

	public function onAppBlur() {}
	public function onAppMouseDown() {}
	public function onAppMouseUp() {}
	public function onAppFocus() {}
	public function onAppResize() {}
	public function onKeyPress(keyCode:Int) {}

	/**
		If `fileName` doesn't provide a path, the file will be loaded from the `tpl` folder in app assets.
	**/
	public function loadPageTemplate(fileName:String, ?vars:Dynamic) {
		var tpl = App.ME.loadTemplate(fileName,vars);
		jPage
			.off()
			.removeClass()
			.addClass(tpl.fp.fileName)
			.append( tpl.jq );
	}
}