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
		var fp = dn.FilePath.fromFile(fileName);
		if( fp.extension==null )
			fp.extension = "html";

		if( fp.directory==null )
			fp.appendDirectory( App.APP_ASSETS_DIR+'/tpl' );

		var path = fp.full;
		App.LOG.fileOp('Loading page template: $path');

		var raw = NT.readFileString(path);
		if( raw==null )
			throw "Page not found: "+fileName+" in "+path+"( cwd="+ET.getAppResourceDir()+")";

		if( vars!=null ) {
			for(k in Reflect.fields(vars))
				raw = StringTools.replace( raw, '::$k::', Reflect.field(vars,k) );
		}

		jPage
			.off()
			.removeClass()
			.addClass(fp.fileName)
			.html(raw);
	}
}