pragma Singleton

import QtQml 2.12

QtObject {
    id: root

    readonly property string localeName: Qt.locale().name.replace('_', '-')
    readonly property string apiKey: "71f92ea9dd2f4790b92ea9dd2f779061"

    readonly property var locationCaches: ({})
    readonly property var locationPromises: ({})
    readonly property var currentCaches: ({})
    readonly property var currentPromises: ({})
    readonly property var hourlyCaches: ({})
    readonly property var hourlyPromises: ({})

    function searchLocation(query) {
        return new Promise(function (resolve, reject) {

            const cache = locationCaches[query];

            if (cache) {
                resolve(cache);
                return;
            }

            var promises = locationPromises[query];

            if (promises) {
                promises.push({ resolve: resolve, reject: reject });
                return;
            }

            promises = [];
            locationPromises[query] = promises; // mark as pending

            console.log("searching location for: " + query);

            const url = "https://api.weather.com/v3/location/search?apiKey=" +
                        apiKey + "&query=" + encodeURIComponent(query) +
                        "&format=json&language=" + localeName;

            const xhr = new XMLHttpRequest();
            xhr.responseType = 'json';
            xhr.onerror = function () {
                const msg = "cannot retrieve location: " + xhr.status + " " + xhr.statusText;
                promises.forEach(promise => promise.reject(msg));
                delete locationPromises[query];
                reject(msg);
            }
            xhr.onload = function () {
                if (xhr.status >= 200 && xhr.status < 300) {
                    const json = xhr.response.location;
                    const result = [];
                    for (let i = 0; i < json.address.length; ++i) {
                        result.push({
                            address: json.address[i],
                            geocode: json.latitude[i] + ',' + json.longitude[i],
                            placeid: json.placeId[i],
                            postalkey: json.postalKey[i]
                        });
                    }
                    locationCaches[query] = result;
                    promises.forEach(promise => promise.resolve(result));
                    delete locationPromises[query];
                    resolve(result);
                } else {
                    xhr.onerror();
                }
            }
            xhr.open("GET", url);
            xhr.send();
        });
    }

    function validateWeather(data) {
        return Date.now() - data.timestamp < 900000; // ~15 min
    }

    function queryCurrentWeather(code) {
        const url = "https://api.weather.com/v3/wx/observations/current?apiKey=" +
                    apiKey + "&geocode=" + encodeURIComponent(code) +
                    "&format=json&units=m&language=" + localeName;

        return doQuery(currentCaches, currentPromises, url, code);
    }

    function queryForecastHourly(code) {
        const url = "https://api.weather.com/v1/geocode/" + code.replace(',','/') +
                    "/forecast/hourly/6hour.json?apiKey=" + apiKey +
                    "&units=m&language=" + localeName;

        return doQuery(hourlyCaches, hourlyPromises, url, code);
    }

    function doQuery(dataCaches, dataPromises, url, code) {
        return new Promise(function (resolve, reject) {
            var promises = dataPromises[code];

            if (promises) {
                promises.push({ resolve: resolve, reject: reject });
                return;
            }

            const cache = dataCaches[code];

            if (cache) {
                if (validateWeather(cache)) {
                    resolve(cache);
                    return;
                }
            }

            promises = [];
            dataPromises[code] = promises; // mark as pending

            console.log("retrieving weahter data for: " + code);

            const xhr = new XMLHttpRequest();
            xhr.responseType = 'json';
            xhr.onerror = function () {
                const msg = "cannot retrieve weather data: " + xhr.status + " " + xhr.statusText;
                promises.forEach(promise => promise.reject(msg));
                delete dataPromises[code];
                reject(msg);
            }
            xhr.onload = function () {
                if (xhr.status >= 200 && xhr.status < 300) {
                    const result = xhr.response;
                    result.timestamp = new Date().getTime();

                    dataCaches[code] = result;
                    promises.forEach(promise => promise.resolve(result));
                    delete dataPromises[code];
                    resolve(result);
                } else {
                    xhr.onerror();
                }
            }
            xhr.open("GET", url);
            xhr.send();
        });
    }
}
