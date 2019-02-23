from django.conf import settings
from django.shortcuts import render
from django.http import HttpResponse

import googlemaps
from datetime import datetime

def index(request):
    return render(request, 'index/index.html', {'api_key': settings.GOOGLE_MAPS_API_KEY})

def maps(request):

    gmaps = googlemaps.Client(key=settings.GOOGLE_MAPS_API_KEY)
    # Request directions via public transit
    now = datetime.now()
    directions_result = gmaps.directions("Sydney Town Hall",
                                        "Parramatta, NSW",
                                        mode="transit",
                                        departure_time=now)
    print(directions_result)
    return render(request, 'index/index.html', {'api_key': settings.GOOGLE_MAPS_API_KEY})