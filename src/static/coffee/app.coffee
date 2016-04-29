RGB = [200, 120, 255]

if window.XMLHttpRequest is undefined
    window.XMLHttpRequest = ()->
        try
            # Use latest version of ActiveX object if available
            return new ActiveXObject("Msxml2.XMLHTTP.6.0")
        catch e
            try
                # ... Otherwise fall back on older version
                return new ActiveXObject("Msxml2.XMLHTTP.6.0")
            catch e
                # ... Otherwise throw an error
                return new Error("XMLHttpRequest is not supported")


get = (url, callback)->
    request = new XMLHttpRequest()
    request.open("GET", url)

    request.onreadystatechange = ()->
        if request.readyState is 4 and (request.status >= 200 and request.status < 400)
            response = JSON.parse(request.responseText)
            if response.errorCode is "OK"
                callback(response.result)

    return request.send(null)


getCell = (oProduct, competitor)->
    tdE = document.createElement("td")
    store = oProduct[competitor] or {}

    if store.price
      variance = Math.floor(store.variance)
      tdE.innerHTML = "#{Math.floor(store.price)} $ (#{variance})"
      tdE.style.backgroundColor = "rgb(#{RGB[0] + variance}, #{RGB[1] + variance}, #{RGB[2]})"
    else
      tdE.innerHTML = " "

    return tdE


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