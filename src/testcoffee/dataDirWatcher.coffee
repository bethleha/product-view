
chokidar = require("chokidar")
UtLib = require("./UtLib")

startWatcher = ()->
    console.log("   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    console.log("   ~~~~~~~~~~~~ Data dir watcher runing ~~~~~~~~~~~~")
    console.log("   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	watcher = chokidar.watch("#{__dirname}/data", {
		ignored: /[\/\\]\./
		persistent: true
	})
	watcher.on("add", (path)-> UtLib.importCsv(path))

module.exports = {
	start: startWatcher
}
