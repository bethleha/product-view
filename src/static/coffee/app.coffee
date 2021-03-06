
if window.XMLHttpRequest is undefined
    window.XMLHttpRequest = ()->
        try
            # Use latest version of ActiveX object if available
            return new ActiveXObject("Msxml2.XMLHTTP.6.0")
        catch e
            try
                # ... Otherwise fall back on older version
                return new ActiveXObject("Msxml2.XMLHTTP.3.0")
            catch e
                # ... Otherwise throw an error
                return new Error("XMLHttpRequest is not supported")

#
# Function to GET a REST API
#
get = (url, callback)->
    request = new XMLHttpRequest()
    request.open("GET", url)

    request.onreadystatechange = ()->
        if request.readyState is 4 and (request.status >= 200 and request.status < 400)
            response = JSON.parse(request.responseText)
            if response.errorCode is "OK"
                callback(response.result)

    return request.send(null)

#
# Function to get rgb() value for variance
#
getRgb = (variance)->
    hue = Math.abs(variance)
    if variance < 0
        return "rgb(255, #{225 - hue}, #{225 - hue})"
    if hue < 50
        return "rgb( #{255-(hue*5)}, 255, #{255-(hue*5)})"
    return "rgb(0, #{200 - Math.min(150, hue)}, 0)"

#
# Function to generate product-category-variance cell
# STEPS:
#   1. Create td element
#   2. For a competitor;
#       - add store-price
#       - add variance-heat-color
#
getCell = (oProduct, competitor)->
    tdE = document.createElement("td")
    store = oProduct[competitor] or {}

    if store.price
      variance = Math.floor(store.variance)
      tdE.innerHTML = "#{Math.floor(store.price)} $ (#{variance})"
      tdE.style.backgroundColor = getRgb(variance)
    else
      tdE.innerHTML = " "

    return tdE

#
# Function to prepare Product Variance Heatmap
# STEPS:
#   1. Get HeatMap element (table)
#   2. Add table-header of competitors
#   3. Add category variance rows for each product-category 
#
prepareProductView = (data)->
    tableE = document.getElementById("productVarianceTable")
    rowE = document.createElement("tr")
    thE = document.createElement("th")
    rowE.appendChild(thE)

    data.competitors.forEach((competitor)->
        thE = document.createElement("th")
        thE.innerHTML = competitor
        rowE.appendChild(thE)
    )
    tableE.appendChild(rowE)

    data.products.forEach((oProduct)->
        rowE = document.createElement("tr")
        tdE = document.createElement("td")
        tdE.innerHTML = oProduct.name
        rowE.appendChild(tdE)
        data.competitors.forEach((competitor)->
            rowE.appendChild(getCell(oProduct, competitor))
        )
        tableE.appendChild(rowE)
    )
    return


get("/rest/1.0/productVariance", prepareProductView)
#END