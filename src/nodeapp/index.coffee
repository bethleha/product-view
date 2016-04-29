
express = require('express')
path = require('path')
favicon = require('serve-favicon')
cookieParser = require('cookie-parser')
logger = require("morgan")
bodyParser = require('body-parser')
MongoClient = require('mongodb').MongoClient
config = require('./config')
util = require("./route-util")

app = express()
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }))
app.use(cookieParser())
app.use(logger("dev"))
app.use(express.static(path.join(__dirname, '../public/')))


app.get('/rest/1.0/ping', (req, res)->
    res.send("PONG")
)

app.use((req, res, next)->
    MongoClient.connect(config.mongoUrl, (err, db)->
        if err then return next(err)
        req.db = db
        next()
    )
)

app.get('/rest/1.0/productVariance', util.calculateVariance)

app.use((req, res, next)->
    req.db.close()
    next()
)

module.exports = app
#END