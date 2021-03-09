import electron.main.App;
import electron.main.IpcMain;
import js.Node.__dirname;
import js.Node.process;

class ElectronMain {
	static var mainWindow : electron.main.BrowserWindow;

	static function main() {
		App.whenReady().then( (_)->createAppWindow() );

		// Mac
		App.on('window-all-closed', function() {
			mainWindow = null;
			App.quit();
		});
		App.on('activate', ()->{
			if( electron.main.BrowserWindow.getAllWindows().length == 0 )
				createAppWindow();
		});

		initIpcBindings();
	}


	static function initIpcBindings() {
		// *** invoke/handle *****************************************************

		IpcMain.handle("exit", function(event) {
			App.exit();
		});

		IpcMain.handle("reload", function(event) {
			mainWindow.reload();
		});

		IpcMain.handle("setFullScreen", function(event,flag) {
			mainWindow.setFullScreen(flag);
		});

		IpcMain.handle("setWinTitle", function(event,args) {
			mainWindow.title = args;
		});


		// *** sendSync/on *****************************************************

		IpcMain.on("getScreenWidth", function(event) {
			event.returnValue = electron.main.Screen.getPrimaryDisplay().size.width;
		});

		IpcMain.on("getScreenHeight", function(event) {
			event.returnValue = electron.main.Screen.getPrimaryDisplay().size.height;
		});

		IpcMain.on("getCwd", function(event) {
			event.returnValue = process.cwd();
		});

		IpcMain.on("getArgs", function(event) {
			event.returnValue = process.argv;
		});

		IpcMain.on("getAppResourceDir", function(event) {
			event.returnValue = App.getAppPath();
		});

		IpcMain.on("getExeDir", function(event) {
			event.returnValue = App.getPath("exe");
		});

		IpcMain.on("getUserDataDir", function(event) {
			event.returnValue = App.getPath("userData");
		});
		IpcMain.on("isFullScreen", function(event) {
			event.returnValue = mainWindow.isFullScreen();
		});
	}


	static function fatalError(err:String) {
		electron.main.Dialog.showErrorBox("Fatal error", err);
		App.quit();
	}

	static function createAppWindow() {
		// Init window
		mainWindow = new electron.main.BrowserWindow({
			webPreferences: { nodeIntegration:true },
			fullscreenable: true,
			show: false,
			title: "LDtk",
			icon: __dirname+"/appIcon.png",
			backgroundColor: '#1e2229'
		});
		mainWindow.once("ready-to-show", ev->{
			var disp = electron.main.Screen.getPrimaryDisplay();
			mainWindow.webContents.setZoomFactor(1);
		});

		// Window menu
		#if debug
		enableDebugMenu();
		#else
		mainWindow.setMenu(null);
		#end

		// Load app page
		var p = mainWindow.loadFile('assets/app.html');
		mainWindow.maximize();
		p.then( (_)->{}, (_)->fatalError('"app.html" was not found in app assets!') );

		// Destroy
		mainWindow.on('closed', function() {
			mainWindow = null;
		});

		// Misc bindings
		dn.electron.Dialogs.initMain(mainWindow);
		dn.electron.ElectronUpdater.initMain(mainWindow);
	}


	// Create a custom debug menu
	#if debug
	static function enableDebugMenu() {
		var menu = electron.main.Menu.buildFromTemplate([{
			label: "Debug tools",
			submenu: cast [
				{
					label: "Reload",
					click: function() mainWindow.reload(),
					accelerator: "CmdOrCtrl+R",
				},
				{
					label: "Dev tools",
					click: function() mainWindow.webContents.toggleDevTools(),
					accelerator: "CmdOrCtrl+Shift+I",
				},
			]
		}]);

		mainWindow.setMenu(menu);
	}
	#end
}
