#
# Tool to watch data dir
# Assumption:
#   - CSV (possibly new files) are exported from source to the data-dir for analytics
# NOTE:
#   - This watcher looks fo rnew (CSV) file added to data-dir
#   - On new file; Imports tha product-info from the csv.
#   - Mongo aggregation faramework is furhter used to find variance of product-categ as in route-util 
#

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
