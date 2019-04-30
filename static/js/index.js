let count = 0;
$(document).ready(function () {
    $(".loader").hide();
    count = 0;
    $("#addwaypoint").on("click", () => {
        insertWaypoint();
        updateLabels();
    });
    $(document).on("click", ".remove", function () {
        $(this).parent().remove();
        updateLabels();
        count--;
    });
    $("#loc-search").on('keypress', (e) => {
        var code = e.keyCode || e.which;
        if (code === 13) {
            insertWaypoint();
            updateLabels();
        }
    });

    function insertWaypoint() {
        let selectedVal = $('#loc-search').val();
        if (selectedVal === "") return;
        if (count < 10) {
            $("#loc-search").val("");
            $('#waypoint-list').append(
                `<div class="waypoint-entry">
                        <span class="waypoint-code">m</span>
                        <div class="waypoint-name">${selectedVal}</div>
                        <button type="button" class="close remove" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>`);
            count++;
        } else {
            $('#exampleModal').modal("show");
        }
    }

    function updateLabels() {
        document.querySelectorAll('.waypoint-code').forEach((element, index) => {
            element.innerHTML = (index + 1).toString(10);
        });
    }
});

let map;

function initMap() {
    let directionsService = new google.maps.DirectionsService;
    let directionsDisplay = new google.maps.DirectionsRenderer({suppressMarkers: true});
    map = new google.maps.Map(document.getElementById('map'), {
        zoom: 15,
        center: {longitude: -6.21462, latitude: 106.84513},
        styles: [
            {
                "featureType": "landscape",
                "stylers": [
                    {
                        "color": "#e1f2ff"
                    }
                ]
            },
            {
                "featureType": "poi",
                "elementType": "geometry.fill",
                "stylers": [
                    {
                        "color": "#b5dfff"
                    }
                ]
            },
            {
                "featureType": "poi.business",
                "stylers": [
                    {
                        "visibility": "off"
                    }
                ]
            },
            {
                "featureType": "poi.park",
                "elementType": "geometry.fill",
                "stylers": [
                    {
                        "color": "#adfed7"
                    }
                ]
            },
            {
                "featureType": "poi.sports_complex",
                "elementType": "geometry.fill",
                "stylers": [
                    {
                        "color": "#82f4ca"
                    }
                ]
            },
            {
                "featureType": "road",
                "elementType": "labels.icon",
                "stylers": [
                    {
                        "visibility": "off"
                    }
                ]
            },
            {
                "featureType": "road.highway",
                "elementType": "geometry.fill",
                "stylers": [
                    {
                        "color": "#ffd926"
                    }
                ]
            },
            {
                "featureType": "road.highway",
                "elementType": "geometry.stroke",
                "stylers": [
                    {
                        "color": "#eac100"
                    }
                ]
            },
            {
                "featureType": "transit",
                "stylers": [
                    {
                        "visibility": "off"
                    }
                ]
            },
            {
                "featureType": "water",
                "elementType": "geometry.fill",
                "stylers": [
                    {
                        "color": "#739fea"
                    }
                ]
            }
        ]
    });

    let input = document.getElementById('loc-search');
    let searchBox = new google.maps.places.SearchBox(input);
    // map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);

    let markers = [];
    // Listen for the event fired when the user selects a prediction and retrieve
    // more details for that place.
    searchBox.addListener('places_changed', function () {
        let places = searchBox.getPlaces();
        if (places.length == 0) {
            return;
        }
        // Clear out the old markers.
        markers.forEach(function (marker) {
            marker.setMap(null);
        });
        markers = [];

        // For each place, get the icon, name and location.
        let bounds = new google.maps.LatLngBounds();
        places.forEach(function (place) {
            if (!place.geometry) {
                console.log("Returned place contains no geometry");
                return;
            }
            let icon = {
                url: place.icon,
                size: new google.maps.Size(71, 71),
                origin: new google.maps.Point(0, 0),
                anchor: new google.maps.Point(17, 34),
                scaledSize: new google.maps.Size(25, 25)
            };

            // Create a marker for each place.
            markers.push(new google.maps.Marker({
                map: map,
                icon: icon,
                title: place.name,
                position: place.geometry.location
            }));

            if (place.geometry.viewport) {
                // Only geocodes have viewport.
                bounds.union(place.geometry.viewport);
            } else {
                bounds.extend(place.geometry.location);
            }
        });
        map.fitBounds(bounds);
    });

    directionsDisplay.setMap(map);

    document.getElementById('submit').addEventListener('click', function () {
        calculateAndDisplayRoute(directionsService, directionsDisplay);
    });
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function (position) {
            initialLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
            map.setCenter(initialLocation);
        });
    }
}

let markers = [];

function calculateAndDisplayRoute(directionsService, directionsDisplay) {
    $("#alert-board").empty();
    if (count <= 1) {
        $("#alert-board").prepend(`
            <div class="alert alert-danger report" role="alert">
                You should have at least 2 waypoints!
            </div>`);
        $(".report")[0].scrollIntoView({behavior: "smooth", block: "end"});
        return;
    }
    let waypts = [];
    let checkboxArray = document.getElementsByClassName("waypoint-name");
    for (let i = 0; i < checkboxArray.length; i++) {
        waypts.push(checkboxArray[i].innerHTML);
    }
    let method = $('#method-choice input:radio:checked').val();
    let query = {"destinations": waypts, "method": method};
    console.log(query);

    $(".loader").show();
    $("#submit").attr("disabled", true);
    $.ajax({
        url: 'process/',
        traditional: true,
        type: 'POST',
        dataType: 'json',
        data: JSON.stringify(query),
        success: (result) => {
            $(".loader").hide();
            $("#submit").attr("disabled", false);
            console.log(result);
            let message;
            if (result.method === "distance") {
                let dist = result.cost / 1000;
                message = `<b>${dist.toFixed(1)} km</b> far`;
            } else {
                let hour = Math.floor(result.cost / 3600);
                let mins = Math.floor((result.cost - (hour * 3600)) / 60);
                if (hour.toFixed(0) !== "0") {
                    hour = `${hour.toFixed(0)} hr `;
                } else hour = "";
                if (mins.toFixed(0) !== "0") {
                    mins = `${mins.toFixed(0)} min `;
                } else mins = "";
                message = `<b>${hour}${mins}</b>long`;
            }
            $("#alert-board").prepend(`
                <div class="alert alert-success report" role="alert">
                    <h4 class="alert-heading">scooted!</h4>
                    <p>Your order of waypoints have been optimized based on trip <b>${result.method}</b>. The trip will be ${message}.</p>
                    <hr>
                    <p class="mb-0">Have a safe journey!</p>
                </div>`);
        $(".report")[0].scrollIntoView({behavior: "smooth", block: "start"});

            let start = "";
            let points = [];
            let sequence = [];
            for (let i = 0; i < result.sequence.city.length; i++) {
                sequence.push(result.sequence.index[i]);
                if (i === 0) {
                    start = result.sequence.city[i];
                } else {
                    points.push({
                        location: result.sequence.city[i],
                        stopover: true
                    });
                }
            }
            document.querySelectorAll('.waypoint-code').forEach((element, index) => {
                element.innerHTML = (sequence[index] + 1).toString(10);
            });
            markers.forEach(marker => {
                marker.setMap(null);
            });
            markers = [];
            directionsService.route({
                origin: start,
                destination: start,
                waypoints: points,
                optimizeWaypoints: false,
                travelMode: 'DRIVING'
            }, function (response, status) {
                if (status === google.maps.DirectionsStatus.OK) {
                    directionsDisplay.setDirections(response);
                    var my_route = response.routes[0];
                    for (var i = 0; i < my_route.legs.length; i++) {
                        var marker = new google.maps.Marker({
                            position: my_route.legs[i].start_location,
                            label: "" + (i + 1),
                            map: map
                        });
                        markers.push(marker);
                    }
                }
            });
        },
        error: (error) => {
            $("#submit").attr("disabled", false);
            $(".loader").hide();
            let message;
            try {
                message = error.responseJSON.error;
            } catch (e) {
                message = "An error has occurred!";
            }
            $("#alert-board").prepend(`
                <div class="alert alert-danger report" role="alert">
                    ${message}
                </div>`);
        $(".report")[0].scrollIntoView({behavior: "smooth", block: "end"});
        }
    })
}