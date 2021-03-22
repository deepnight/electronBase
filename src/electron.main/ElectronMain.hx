import electron.main.App;
import electron.main.IpcMain;
import js.Node.__dirname;
import js.Node.process;

import dn.js.ElectronTools as ET;

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
			mainWindow.webContents.setZoomFactor( ET.getZoomToFit(800, 600));
			trace(mainWindow.webContents.getZoomFactor());
		});

		// Inits
		initIpcBindings();
		ET.initMain(mainWindow);
		dn.js.ElectronDialogs.initMain(mainWindow);
		dn.js.ElectronUpdater.initMain(mainWindow);

		// Window menu
		#if debug
		ET.m_createDebugMenu();
		#else
		mainWindow.setMenu(null);
		#end

		// Load app page
		var path = 'electron/appAssets/boot.html';
		var p = mainWindow.loadFile(path);
		mainWindow.maximize();
		p.then( (_)->{}, (_)->ET.fatalError('File not found: (${ET.getAppResourceDir()}/$path)!') );

		// Destroy
		mainWindow.on('closed', function() {
			mainWindow = null;
		});
	}

	static function initIpcBindings() {
		// Called once when `App` class is ready in renderer
		IpcMain.handle("appReady", function(ev) {
			// Manage window "close" button event
			mainWindow.on('close', function(ev) {
				if( !dn.js.ElectronUpdater.isIntalling ) {
					ev.preventDefault();
					mainWindow.webContents.send("winClose");
				}
			});
		});
	}
}
