#
# Products Spec
# -- Unit and Integration spec of Product is added here
#

process.env.NODE_ENV = "test"
assert = require("chai").assert
UtLib = require("./UtLib")
routeUtil = require("../build/nodeapp/route-util")
OK = "OK"
ERROR = "ERROR"

noop = ->

describe "Products Spec/ ", ->

  before((done)->
    return UtLib.testSetupInit(done)
  )

  after((done)->
    return UtLib.testSetupDeinit(done)
  )

  #
  # Products Unit test suite
  #
  describe "Unit Test", ->

    it "Should Calulate Product Variance", (done)->

        verifyCb = (resp)->
          assert.equal resp.errorCode, OK
          assert.isObject resp.result
          assert.isArray resp.result.competitors
          assert.isArray resp.result.products
          return done()

        req = { db: UtLib.db }
        res = { send: verifyCb } # VerifyCb is attached as res.send method for testing purpose
        return routeUtil.calculateVariance(req, res)

  #
  # Products Unit test suite
  # TODO:
  describe "GUI Integration Test", ->
