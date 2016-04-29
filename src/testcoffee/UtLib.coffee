
rest = require("rest")
mime = require('rest/interceptor/mime')
errorCode = require('rest/interceptor/errorCode')
exec = require("child_process").exec
MongoClient = require("mongodb").MongoClient

BASE_URL = "http://#{process.env.SERVER_HOST or 'localhost'}:#{process.env.PORT or 3000}/rest/1.0"
noop = ->

UtLib = {

    testSetupInit: (done)->
        config = require("../build/nodeapp/config")

        MongoClient.connect(config.mongoUrl, (err, db)->
            if err then return done(err)
            IMPORT_CMD = "mongoimport --db #{config.db} --collection #{config.coll} --type csv --headerline"

            UtLib.db = db
            UtLib.nodeapp = require("../build/nodeapp")
            exec("#{IMPORT_CMD} --file #{__dirname}/data/sample-data.csv", done)
        )
 

    testSetupDeinit: (done)->

        if (UtLib._server)
            UtLib._server.removeAllListeners()
            return UtLib._server.close()

        productsColl = UtLib.db.collection("products")
        productsColl.drop((err)->
            if err then return done(err)

            UtLib.db.close(true, done)
        )


    _getRequest: (url, method, data)->

        body = {requests: []}

        if data.length
            data.forEach((req)-> body.requests.push(req))
        else
            body.requests.push(data);
    
        return {
            path: url
            method: method
            entity: body
        }


    # Server talk functionality
    # Prepares http-client that can make REST API call to node-webserver
    #
    _serverTalk: (request, next)->

        client = rest.wrap(mime, {
            mime : 'application/json'
        })
        .wrap(errorCode, {code: 400})

        successCb = (resp)->
            data = {}
            if resp.entity
                if (resp.headers['Content-Type'] isnt 'application/json')
                    data = JSON.parse(resp.entity)
                else
                    data = resp.entity
            if (resp.status.code is 200 or  resp.status.code is 201 or resp.status.code is 204)
                return next(null, data)
            return next(data)

        failCb = (resp)->
            if resp.entity and resp.entity.errors
                return next(resp.entity.errors)
            return next(new Error("Error: Server Talk Failed !!!"), resp.entity)

        return client(request).then(successCb, failCb)


    testTalk: (next)->

        request = UtLib._getRequest("#{BASE_URL}/ping")
        UtLib._serverTalk(request, next)
        return


    calculateVariance: (next)->

        request = UtLib._getRequest("#{BASE_URL}/productVariance")
        UtLib._serverTalk(request, next)
        return


    importCsv: (path, next)->

        config = require("../build/nodeapp/config")
        IMPORT_CMD = "mongoimport --db #{config.db} --collection #{config.coll} --type csv --headerline"
        console.log("       === Importing ... : #{path}")

        exec("#{IMPORT_CMD} --file #{path}", (err)->
            if err
                console.error err, err.stack
                return (next or noop)(err)

            console.log("       === Import Complete  : #{path}")
            (next or noop)()
        )

}

module.exports = UtLib
#END