/////////////////////////////////////////////////////////
//  local_overlay userChrome.js loader for GNU IceCat  //
/////////////////////////////////////////////////////////
// this code provides a simple userChrome.js loader,   //
// controlled by 'custom.userchromejs' that attempts   //
// to import and load userChrome.js <profile>/chrome.  //
// --------------------------------------------------  //
// !! NOTE THAT THIS SCRIPT IS RUN WITH IN THE FULL !! //
// !! CHROME CONTEXT AND CAN LITERALLY DO ANYTHING  !! //
/////////////////////////////////////////////////////////

// import required modules (this shouldn't fail and are visible to the target) 
const { FileUtils } = ChromeUtils.import("resource://gre/modules/FileUtils.jsm");
const { console   } = ChromeUtils.import("resource://gre/modules/Console.jsm");

// this failing shouldn't be a fatal error
try { do {
	// get preferences service
	const prefs = Cc["@mozilla.org/preferences-service;1"].getService(Ci.nsIPrefService);

	// check if loader is enabled
	try {
		// not enabled
		if (!prefs.getBoolPref("custom.userchromejs"))
			break;
	} catch {
		// default to not enabled
		prefs.setBoolPref("custom.userchromejs", false);
		break;
	}

	// target script to load
	const script = FileUtils.getDir("UChrm", ["userChrome.js"]);

	// nothing to load
	if (!script.exists())
		break;
	
	// give a warning in the browser console
	console.warn("!!! userChrome.js loader enabled !!!");

	// temporary manifest to allow loading the script from a chrome:// URL
	// (ChromeUtils.import() only trusts chrome:// and resource:// protocols)
	let manifest;

	// find unused filename for manifest
	while (1)
	{
		// try randomized filenames
		let name = `chrome-${Math.trunc(Math.random()*0xFFFFFFFF).toString(16)}.manifest`;
		manifest = FileUtils.getDir("TmpD", [name]);

		// use this filename
		if (!manifest.exists()) {
			manifest.create(Ci.nsIFile.NORMAL_FILE_TYPE, 0600);
			break;
		}
	}

	// open and truncate the manifest
	const stream = FileUtils.openFileOutputStream(
		manifest, FileUtils.MODE_TRUNCATE | FileUtils.MODE_WRONLY);
	
	// write the manifest
	const line = `content custom ${script.path}\n`
	stream.write(line, line.length);
	stream.flush();
	stream.close();

	// register the manifest
	Components.manager.QueryInterface(Ci.nsIComponentRegistrar).autoRegister(manifest);

	// the file is no longer needed
	manifest.remove(false);

	// get the script loader service (can't get it through Services.jsm this early apparently)
	const loader = Cc["@mozilla.org/moz/jssubscript-loader;1"].getService(Ci.mozIJSSubScriptLoader);

	// try executing the userChrome.js script
	try {
		loader.loadSubScriptWithOptions(
			"chrome://custom/content/userChrome.js", { ignoreCache: true });
	} catch (e) {
		// print exception to console
		console.error("!!! Failed to execute userChrome.js !!!");
		console.error(e);

		// wait for browser window to show up so we can show a notification
		const obs = Cc["@mozilla.org/observer-service;1"].getService(Ci.nsIObserverService);
		obs.addObserver(function () {
			// disconnect observer
			obs.removeObserver(this, "xul-window-visible");

			// get window mediator service 	
			const wm = Cc["@mozilla.org/appshell/window-mediator;1"].getService(Ci.nsIWindowMediator);

			// get window notification box
			const box = wm.getMostRecentBrowserWindow().gNotificationBox;

			// add notification about failure (a button to open the file would
			// probably be nice but it looks like shit with compact UI and I
			// can't be bothered implementing it at the moment)
			box.appendNotification(
				"UserChromeError", {
					priority: box.PRIORITY_CRITICAL_LOW,
					label: "Failed to execute userChrome.js (see browser console)" });
		}, "xul-window-visible");
	}

// handle possible errors
} while (0); } catch (e) {
	console.error("!!! Failed to execute userChrome.js loader !!!");
	console.error(e);
}

