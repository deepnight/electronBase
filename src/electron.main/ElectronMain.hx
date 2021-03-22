import electron.main.App;
import electron.main.IpcMain;
import js.Node.__dirname;
import js.Node.process;

import dn.js.ElectronTools as ET;

class ElectronMain {
	static var mainWindow : electron.main.BrowserWindow;

	static function main() {
		App.whenReady().then( (_)->createAppWindow() );

		// macOS
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
			webPreferences: {
				nodeIntegration: true,
				contextIsolation: false,
			},
			fullscreenable: true,
			show: false,
			title: "Electron base",
			icon: __dirname+"/appIcon.png",
			backgroundColor: '#1e2229'
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

		// Load boot document
		var path = 'electron/appAssets/boot.html';
		var p = mainWindow.loadFile(path);
		mainWindow.maximize();
		p.then( (_)->{}, (_)->ET.fatalError('File not found: (${ET.getAppResourceDir()}/$path)!') );

		// Destroy event
		mainWindow.on('closed', function() {
			mainWindow = null;
		});

		// Window is ready
		mainWindow.once("ready-to-show", ev->{
			/*
				Zoom the main window to fit specified dimensions inside in its bounds.

				This ensures consistency between DOM scaling on various resolutions. Without it, the page elements would appear tiny on large resolutions (eg. 4k). Note: the zoom factor cannot go below `1/pixelRatio` to prevent font blurring.
			*/
			mainWindow.webContents.setZoomFactor( ET.getZoomToFit(800, 600) );
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
