$(document).ready(function () {
    $(".loader").hide();
    let count = 0;
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

function calculateAndDisplayRoute(directionsService, directionsDisplay) {
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
            let start = "";
            let points = [];
            for (let i = 0; i < result.sequence.city.length; i++) {
                if (i === 0) {
                    start = result.sequence.city[i];
                } else {
                    points.push({
                        location: result.sequence.city[i],
                        stopover: true
                    });
                }
            }
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
                    }
                } else {

                }
            });
        },
        error: (error) => {
            $("#submit").attr("disabled", false);
            $(".loader").hide();
            console.log("yo it broke")
        }
    })
}