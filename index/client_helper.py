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


# DEBUG
def show_report(historyDistance, bestChromosome, firstChromosome, destinations, method):
    print("\n===== Complete! =====")
    print("First Fitness\t: {:.9f}".format(firstChromosome.fitness() / bestChromosome.fitness()))
    print("First Distance\t: {:.5f} {}".format(firstChromosome.distance()/(1000 if method == "distance" else 3600), "km" if method == "distance" else "h"))
    print("Best Fitness\t: {:.9f}".format(1))
    print("Best Distance\t: {:.5f} {}".format(bestChromosome.distance()/(1000 if method == "distance" else 3600), "km" if method == "distance" else "h"))

    plt.figure(1)
    plt.subplot(211)
    plt.plot(range(len(historyDistance)), historyDistance, color='g')
    plt.ylabel('Distance')
    plt.xlabel('Generations')
    plt.title('GA : Performance by {}'.format(method))

    gmaps = gm.Client("AIzaSyBwMwayIZrYwfwotUim0QOvKVu4YZPEnw8")
    targets = []
    for d in destinations:
        geo = gmaps.geocode(d)[0]['geometry']['location']
        targets.append((geo['lng'], geo['lat']))

    plt.figure(2)
    plt.axis('off')
    x, y = zip(*targets)
    plt.plot(x, y, 'ro')
    last = bestChromosome.sequence[-1]
    for i, s in enumerate(bestChromosome.sequence):
        x, y = zip(targets[last], targets[s])
        last = s
        plt.plot(x, y, 'r')
    for i, txt in enumerate(destinations):
        plt.annotate(txt, tuple(targets[i]))
    plt.title('GA : Best Path @ {}={:.5f}{}'.format(method, bestChromosome.distance()/(1000 if method == "distance" else 3600), "km" if method == "distance" else "h"))
    plt.show(block=False)

    # plt.figure(3)
    # plt.axis('off')
    # x, y = zip(*targets)
    # plt.plot(x, y, 'ro')
    # last = firstChromosome.sequence[-1]
    # for i, s in enumerate(firstChromosome.sequence):
    #     x, y = zip(targets[last], targets[s])
    #     last = s
    #     plt.plot(x, y, 'r')
    # for i, txt in enumerate(destinations):
    #     plt.annotate(txt, tuple(targets[i]))
    # plt.title('GA : First Path @ {}={:.5f}{}'.format(method, firstChromosome.distance()/(1000 if method == "distance" else 3600), "km" if method == "distance" else "h"))
    plt.show()


def geodetic_to_geocentric(lat, lon):
    """
    Compute the Geocentric (Cartesian) Coordinates X, Y, Z
    given the Geodetic Coordinates lat, lon + Ellipsoid Height h
    """
    a, rf = (6378137, 298.257223563)
    lat_rad = math.radians(lat)
    lon_rad = math.radians(lon)
    N = a / math.sqrt(1 - (1 - (1 - 1 / rf) ** 2) * (math.sin(lat_rad)) ** 2)
    Y = (N) * math.cos(lat_rad) * math.cos(lon_rad)
    X = (N) * math.cos(lat_rad) * math.sin(lon_rad)
    return X, Y
