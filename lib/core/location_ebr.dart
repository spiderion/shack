import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:template_package/base_br/business_rules.dart';

class LocationEBR extends EBR {
  final location = Location();

  Future<LocationInfo?> getLocationData() async {
    try {
      LocationData currentLocation = await location.getLocation();
      final coordinates = new Coordinates(currentLocation.latitude!, currentLocation.longitude!);
      var addresses = (await Geocoder.local.findAddressesFromCoordinates(coordinates)).first;
      return LocationInfo(currentLocation, addresses);
    } catch (e) {
      return null;
    }
  }
}

class LocationInfo {
  final LocationData locationData;
  final Address address;

  LocationInfo(this.locationData, this.address);
}
