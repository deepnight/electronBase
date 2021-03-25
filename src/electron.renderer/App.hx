import electron.renderer.IpcRenderer;


typedef HtmlTemplate = {
	var fp : dn.FilePath;
	var jq : js.jquery.JQuery;
	var fromCache : Bool;
}

class App extends dn.Process {
	public static var ME : App;
	public static var LOG : dn.Log = new dn.Log(5000);

	public static var APP_RESOURCE_DIR(get,never) : String; // with trailing slash
		static inline function get_APP_RESOURCE_DIR() {
			var fp = dn.FilePath.fromDir( ET.getAppResourceDir() );
			fp.useSlashes();
			return fp.directoryWithSlash;
		}

	public static var APP_ASSETS_DIR(get,never) : String;
		static inline function get_APP_ASSETS_DIR() return APP_RESOURCE_DIR+"electron/appAssets/";

	public var jDoc(get,never) : JQ; inline function get_jDoc() return new JQ(js.Browser.document);
	public var jBody(get,never) : JQ; inline function get_jBody() return new JQ("body");
	public var jPage(get,never) : JQ; inline function get_jPage() return new JQ("#page");
	public var jCanvas(get,never) : JQ; inline function get_jCanvas() return new JQ("#heaps");

	public var args: dn.Args;
	public var focused(default,null) = true;
	var curPage : Null<Page>;
	var keyDowns : Map<Int,Bool> = new Map();
	var mouseButtonDowns : Map<Int,Bool> = new Map();

	public function new() {
		super();

		// Init logging
		LOG.logFilePath = dn.FilePath.fromFile( ET.getExeDir()+"/app.log" ).full;
		LOG.trimFileLines();
		LOG.emptyEntry();
		#if debug
		LOG.printOnAdd = true;
		#end
		LOG.add("BOOT","App started");
		LOG.add("BOOT","ExePath: "+ET.getExeDir());
		LOG.add("BOOT","Resources: "+ET.getAppResourceDir());

		// App arguments
		args = ET.getArgs();
		LOG.add("BOOT", args.toString());

		// Init
		ME = this;
		createRoot(Boot.ME.s2d);

		// Heaps canvas isn't visible by default
		disableHeapsCanvas();

		// Init window
		IpcRenderer.on("winClose", onWindowCloseButton);

		var win = js.Browser.window;
		win.onblur = onAppBlur;
		win.onfocus = onAppFocus;
		win.onresize = onAppResize;
		win.onmousemove = onAppMouseMove;

		// Track mouse buttons
		jDoc.mousedown( onAppMouseDown );
		jDoc.mouseup( onAppMouseUp );

		// Keyboard events
		jBody
			.on("keydown", onJsKeyDown )
			.on("keyup", onJsKeyUp );

		// Heaps events
		Boot.ME.s2d.addEventListener(onHeapsEvent);

		// Notify electron main
		IpcRenderer.invoke("appReady");

		// Load first page
		delayer.addS( ()->{
			loadPage( ()->new page.HelloWorld() );
		}, 0.1);
	}

	public function enableHeapsCanvas() {
		App.ME.jCanvas.removeClass("hidden");
	}

	public function disableHeapsCanvas() {
		App.ME.jCanvas.addClass("hidden");
	}


	function getArgPath() : Null<dn.FilePath> {
		if( args.getLastSoloValue()==null )
			return null;

		var fp = dn.FilePath.fromFile( args.getAllSoloValues().join(" ") );
		if( fp.fileWithExt!=null )
			return fp;

		return null;
	}


	function onHeapsEvent(e:hxd.Event) {
		switch e.kind {
			case EKeyDown: onHeapsKeyDown(e);
			case EKeyUp: onHeapsKeyUp(e);
			case _:
		}
	}



	function onJsKeyDown(ev:js.jquery.Event) {
		if( ev.keyCode==K.ALT )
			ev.preventDefault();

		keyDowns.set(ev.keyCode, true);
		onKeyPress(ev.keyCode);
	}

	function onJsKeyUp(ev:js.jquery.Event) {
		keyDowns.remove(ev.keyCode);
	}

	function onHeapsKeyDown(ev:hxd.Event) {
		keyDowns.set(ev.keyCode, true);
		onKeyPress(ev.keyCode);
	}

	function onHeapsKeyUp(ev:hxd.Event) {
		keyDowns.remove(ev.keyCode);
	}

	// Called when window "close" button is used
	function onWindowCloseButton() {
		exit(false);
	}

	public inline function isKeyDown(keyId:Int) return keyDowns.get(keyId)==true;
	public inline function isShiftDown() return keyDowns.get(K.SHIFT)==true;
	public inline function isCtrlDown() return (NT.isMacOs() ? keyDowns.get(K.LEFT_WINDOW_KEY) || keyDowns.get(K.RIGHT_WINDOW_KEY) : keyDowns.get(K.CTRL))==true;
	public inline function isAltDown() return keyDowns.get(K.ALT)==true;
	public inline function hasAnyToggleKeyDown() return isShiftDown() || isCtrlDown() || isAltDown();

	public inline function hasInputFocus() {
		return jBody.find("input:focus, textarea:focus").length>0;
	}

	function onKeyPress(keyCode:Int) {
		if( hasPage() && !curPage.isPaused() )
			curPage.onKeyPress(keyCode);

		switch keyCode {
			// Fullscreen
			case K.F11 if( !hasAnyToggleKeyDown() && !hasInputFocus() ):
				ET.setFullScreen( !ET.isFullScreen() );

			case _:
		}
	}

	function clearAppMask() {
		jBody.find("#appFadeMask").remove();
	}

	/** Display a color mask all over the app window **/
	function createAppMask() {
		clearAppMask();
		jBody.append('<div id="appFadeMask"/>');
		return jBody.find("#appFadeMask");
	}

	public function miniNotif(html:String, fadeDelayS=0.5, persist=false) {
		var e = jBody.find("#miniNotif");
		delayer.cancelById("miniNotifFadeOut");
		e.empty()
			.stop(false,true)
			.hide()
			.show()
			.html(html);

		if( !persist )
			delayer.addS( "miniNotifFadeOut", ()->e.fadeOut(2000), fadeDelayS );
	}

	function clearMiniNotif() {
		jBody.find("#miniNotif")
			.stop(false,true)
			.fadeOut(1500);
	}

	function onAppMouseDown(e:js.jquery.Event) {
		mouseButtonDowns.set(e.button,true);
		if( hasPage() && !curPage.isPaused() )
			curPage.onAppMouseDown();
	}

	function onAppMouseUp(e:js.jquery.Event) {
		mouseButtonDowns.remove(e.button);
		if( hasPage() && !curPage.isPaused() )
			curPage.onAppMouseUp();
	}

	public inline function isMouseButtonDown(btId:Int) {
		return mouseButtonDowns.exists(btId);
	}

	public inline function anyMouseButtonDown() {
		return Lambda.count(mouseButtonDowns)==0;
	}

	function onAppMouseMove(e:js.html.MouseEvent) {
	}

	function onAppFocus(ev:js.html.Event) {
		focused = true;
		keyDowns = new Map();
		if( hasPage() )
			curPage.onAppFocus();
		hxd.System.fpsLimit = -1;
	}

	function onAppBlur(ev:js.html.Event) {
		focused = false;
		keyDowns = new Map();
		if( hasPage() )
			curPage.onAppBlur();
		hxd.System.fpsLimit = 4;
	}

	function onAppResize(ev:js.html.Event) {
		if( hasPage() )
			curPage.onAppResize();
	}


	/** Remove currently loaded Page. **/
	function clearCurPage() {
		jPage
			.empty()
			.off()
			.removeClass("locked");

		hxd.System.fpsLimit = -1;

		if( curPage!=null ) {
			curPage.destroy();
			curPage = null;
		}
	}

	/** Return TRUE if any page was loaded using `loadPage()` **/
	public inline function hasPage() {
		return curPage!=null && !curPage.destroyed;
	}


	/** Load a Page class. Only 1 page can be displayed at a time. **/
	public function loadPage( fadeAnimation=true, create:()->Page ) {
		function _load() {
			clearCurPage();
			LOG.flushToFile();
			curPage = create();
			curPage.onAppResize();
			if( fadeAnimation ) {
				var jMask = createAppMask();
				jMask.fadeOut(200, ()->jMask.remove());
			}
		}

		if( fadeAnimation && curPage!=null ) {
			curPage.pause();
			jPage.off().find("*").off();
			var jMask = createAppMask();
			jMask.hide().fadeIn( 100, ()->_load() );
		}
		else {
			clearAppMask();
			_load();
		}
	}


	/** Retrieve HTML file path from a template ID **/
	function getTemplatePath(id:String) : dn.FilePath {
		var fp = dn.FilePath.fromFile(id);
		if( fp.extension==null )
			fp.extension = "html";

		if( fp.directory==null )
			fp.appendDirectory( App.APP_ASSETS_DIR+'/tpl' );

		return fp;
	}



	/**
		If `id` doesn't provide a file path, the template will be loaded from the `tpl` folder in app assets.
		The `vars` parameter should be an anonymous object containing variables to be used in the HTML template file. Example: HTML contains `::myVar::` string anywhere in it, the expected `vars` parameter should be `{ myVar : "the replacement value" }`.
	**/
	public function loadTemplate(id:String, ?vars:Dynamic) : HtmlTemplate {
		var fp = getTemplatePath(id);

		App.LOG.fileOp('Loading page template: ${fp.full}');

		var raw = NT.readFileString(fp.full);
		if( raw==null )
			throw "Page not found: "+id+" in "+fp.full+"( cwd="+ET.getAppResourceDir()+")";

		if( vars!=null && Type.typeof(vars)==TObject ) {
			for(k in Reflect.fields(vars))
				raw = StringTools.replace( raw, '::$k::', Reflect.field(vars,k) );
		}

		return { fp:fp, fromCache:false, jq:new JQ(raw) };
	}


	override function onDispose() {
		super.onDispose();
		if( ME==this )
			ME = null;
	}

	/** Set app window title (or revert to its default value) **/

	public function setWindowTitle(?str:String) {
		var base = Const.APP_NAME;
		if( str==null )
			str = base;
		else
			str = str + "    --    "+base;

		ET.setWindowTitle(str);
	}

	/** Quit app **/
	public function exit(ignoreUnsaved=false) {
		ET.exitApp();
	}

	public function reloadRendererWindow() {
		ET.reloadWindow();
	}

	override function update() {
		super.update();
	}
}
