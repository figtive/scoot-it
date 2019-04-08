import googlemaps as gm
from datetime import datetime
import matplotlib.pyplot as plt
import math


def get_matrix(destinations, method='distance'):
    gmaps = gm.Client("AIzaSyBwMwayIZrYwfwotUim0QOvKVu4YZPEnw8")
    cleaned = {}
    for i, d in enumerate(destinations[:-1]):
        cleaned = {**clean(i, gmaps.distance_matrix(
            origins=[d],
            destinations=destinations[i+1:],
            mode="driving",
            departure_time=datetime.now()
        ), method), **cleaned}

    return cleaned


def clean(origin, mapping, method):
    cleaned = {}
    for i, destination in enumerate(mapping['rows'][0]['elements']):
        cleaned[(origin, origin+i+1)] = destination[method]['value']
    # for origin in mapping['rows']:
    #     row = []
    #     for destination in origin['elements']:
    #         row.append(destination[method]['value'])
    #     cleaned.append(row)
    return cleaned


def check_range(mapping, radius):
    maximum = max([d for d in [max(p) for p in mapping]])
    print(mapping)
    print(maximum)
    return maximum >= radius
