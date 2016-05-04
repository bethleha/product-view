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

  # BEFORE: Prepare test-env by UtLib.testSetupInit
  #   1. Connect to MongoDB
  #   2. Load expApp (But Not started; For future use)
  #   3. Import sample-data to mongodb
  before((done)->
    return UtLib.testSetupInit(done)
  )

  # AFTER: Cleanup test-env by UtLib.testSetupDeinit
  #   1. If test-server is set-up(explicitly) it stops
  #   2. Drops imported-test-data
  #   3. Closes database connection
  after((done)->
    return UtLib.testSetupDeinit(done)
  )

  #
  # Products Unit test suite
  #
  describe "Unit Test/ ", ->

    it "Should Calulate Product Variance", (done)->

        # Basic verification asserts
        #  - resp.errorCode is OK
        #  - valid resp.result object
        #  - valid products in resp.result
        #  - valid competitors in resp.result
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
  # Products Integration test-suite
  #  - will make rest-api call and assert results(Use UtLib Methods to make rest-api-call)
  # TODO:
  describe "GUI Integration Test/ ", ->
