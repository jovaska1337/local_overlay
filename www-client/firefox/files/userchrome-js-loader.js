/////////////////////////////////////////////////////////
//  local_overlay userChrome.js loader for GNU IceCat  //
/////////////////////////////////////////////////////////
// this code provides a simple userChrome.js loader,   //
// controlled by 'custom.userchromejs' that attempts   //
// to import and load <profile>/chrome/userChrome.js   //
// --------------------------------------------------  //
// !! NOTE THAT THIS SCRIPT IS RUN WITH IN THE FULL !! //
// !! CHROME CONTEXT AND CAN LITERALLY DO ANYTHING  !! //
/////////////////////////////////////////////////////////

// avoid polluting global namespace, userChrome.js
// will have to import its own modules, etc.
(() => {
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */ 

// constants
const PREF_KEY = "custom.userchromejs";

// import required modules
const { FileUtils } = ChromeUtils.importESModule("resource://gre/modules/FileUtils.sys.mjs");
const { console   } = ChromeUtils.importESModule("resource://gre/modules/Console.sys.mjs");

// notifications to display in the notification box
const notifications = [];

// display notifications after startup
Services.obs.addObserver(function (subject, topic, data) {
	// remove observer
	Services.obs.removeObserver(this, topic);

	// add notifications
	const box = subject.gNotificationBox;
	for (const [msg, level] of notifications)
		box.appendNotification("custom-userchromejs",
			{ priority: box[`PRIORITY_${level}`], label: msg });
}, "browser-delayed-startup-finished");

// we want to inject the script immediately
try {
	// check if loader is enabled
	try {
		// not enabled
		if (!Services.prefs.getBoolPref(PREF_KEY))
			return;
	} catch {
		// disable by default
		Services.prefs.setBoolPref(PREF_KEY, false);
		notifications.push([`userChrome.js loader disabled by default. (enable in about:config with ${PREF_KEY})`, "INFO_HIGH"]);
		return;
	}

	// target script to load
	const script = FileUtils.getDir("UChrm", ["userChrome.js"]);

	// nothing to load
	if (!script.exists())
		return;

	// give a warning in the browser console (no notifications)
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
	const line = `content custom file://${script.path}\n`;
	stream.write(line, line.length);
	stream.close();

	// register the manifest
	Components.manager.QueryInterface(Ci.nsIComponentRegistrar).autoRegister(manifest);

	// the file is no longer needed
	manifest.remove(false);

	// try executing the userChrome.js script
	try {
		Services.scriptloader.loadSubScriptWithOptions(
			"chrome://custom/content/userChrome.js", { ignoreCache: true });
	} catch (e) {
		// print exception to console
		console.error("!!! Failed to execute userChrome.js !!!");
		console.error(e);

		// set up a notification
		notifications.push(["Failed to execute userChrome.js. (check browser console)", "CRITICAL_HIGH"]);
	}

// catch errors with this script
} catch (e) {
	// print error and exception into browser console
	console.error("!!! Failed to execute userChrome.js loader !!!");
	console.error(e);

	// if possible, set up a notification
	notifications.push(["Failed to execute userChrome.js loader. (check browser console)", "CRITICAL_HIGH"]);
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */ 
})();
