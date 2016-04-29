#
#
#

ERROR = "ERROR"
OK = "OK"
MY_STORE = "My Store"

ProductQuery = {
  variance: [
    # Pipeline Stage I: Group by TL category and store also find avg price
    {
      $group: {
        _id: {
            categ: "$Top Level Category"
            store: "$Store"
        }
        price: {
            $avg: "$Price"
        }
      }
    }
    # Pipeline Stage II: Sort by store-name (desc) and category(asce)
    {
      $sort: {
        "_id.store": -1
        "_id.categ": 1
      }
    }
    # Regroup By category again
    {
      $group: {
        _id: "$_id.categ"
        store: {
          $push: {
            name: "$_id.store"
            price: "$price"
          }
        }
      }
    }
  ]
}

util = {
  #
  # Method to calculate product variance
  # STEPS:
  #     1. Aggregate  `products` collection by the above pipline stages
  #     2. Process aggreagted result and prepare
  #        - products
  #        - competitors
  #     3. send result
  #
  calculateVariance: (req, res, next)->
    productsColl = req.db.collection("products")

    productsColl.aggregate(ProductQuery.variance)
    .toArray((err, results)->
        if err then return res.send({errorCode: ERROR, msg: err.message})

        competitor = {}
        # Prepare products
        products = results.map((result)->
            product = {}
            product.name = result._id

            for oStore, i in result.store
                if oStore.name is MY_STORE
                    myStore = result.store.splice(i, 1)[0]
                    break

            result.store.forEach((oStore)->
                product[oStore.name] = {
                    price: oStore.price,
                    variance: oStore.price - myStore.price
                }
                competitor[oStore.name] = 1
            )
            product[MY_STORE] = { price: myStore.price }
            return product
        )

        res.send(errorCode: OK, result: {
            products: products
            competitors: Object.keys(competitor) # prepare competitors
        })
    )
}

module.exports = util
#END