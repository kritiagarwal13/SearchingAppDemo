//
//  MapViewController.swift
//  SearchingAppDemo
//
//  Created by Kriti on 14/03/18.
//  Copyright © 2018 Demo. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class MapViewController: UIViewController,GMSMapViewDelegate
{
    @IBOutlet var googleMapView: GMSMapView!
    var placeDict = NSDictionary()
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUi()
    }
    
    func setUpUi()
    {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
    }
    
    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        self.googleMapView.clear()
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
        marker.title = placeDict["place"] as? String
        marker.map = googleMapView
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=AIzaSyBsxodo-BBz9-v2uPyJWU5llxRip-l6Vjc")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                        
                        let preRoutes = json["routes"] as! NSArray
                        if preRoutes.count > 0
                        {
                        let routes = preRoutes[0] as! NSDictionary
                        let routeOverviewPolyline:NSDictionary = routes.value(forKey: "overview_polyline") as! NSDictionary
                        let polyString = routeOverviewPolyline.object(forKey: "points") as! String
                        
                        DispatchQueue.main.async(execute: {
                            //let polyString = routeOverviewPolyline.object(forKey: "points") as! String
                            let path = GMSPath.init(fromEncodedPath: polyString )
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeWidth = 3
                            polyline.strokeColor = UIColor(red: 99/256.0, green: 163/256.0, blue: 250/256.0, alpha: 1.0)
                            polyline.map = self.googleMapView
                            let bounds = GMSCoordinateBounds(path: path!)
                            self.googleMapView.animate(with: GMSCameraUpdate.fit(bounds))
                        })
                        }
                    }
                    
                } catch {
                    print("parsing error")
                }
            }
        })
        task.resume()
    }

}

extension MapViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        locationManager.startUpdatingLocation()
        googleMapView.isMyLocationEnabled = true
        googleMapView.settings.myLocationButton = true
    }
    
 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        googleMapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 14, bearing: 0, viewingAngle: 0)
        let destinationPoint = CLLocation(latitude: placeDict["lat"] as! Double, longitude: placeDict["lng"] as! Double)
        locationManager.stopUpdatingLocation()
        getPolylineRoute(from: location.coordinate, to: destinationPoint.coordinate)
    }
}
