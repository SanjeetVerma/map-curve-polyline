//
//  ViewController.swift
//  MapDemo
//
//  Created by Sanjeet Verma on 15/06/20.
//  Copyright © 2020 Sanjeet Verma. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {


    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var defaultDelta = 0.01
    var straighLineFlag = false
    var curveLineFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
    }
    
    func checkLocationServices() {
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter =  10.0
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    func startUpdating() {
        locationManager.startUpdatingLocation()
    }
    
    func endUpdating() {
        locationManager.stopUpdatingLocation()
    }
    
    func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .notDetermined:
                self.requestAuthorization()
            case .restricted:
                self.requestAuthorization()
            case .denied:
                self.requestAuthorization()
            case .authorizedAlways:
                self.startUpdating()
            case .authorizedWhenInUse:
                self.startUpdating()
            default:
                break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.animateToLocation(location: locations.last!.coordinate)
//        let LAX = CLLocation(latitude: (locations.last?.coordinate.latitude)!, longitude:(locations.last?.coordinate.longitude)!)
//        let JFK = CLLocation(latitude: 23.0802, longitude:72.5244)
        
        /*let LAX = CLLocation(latitude: 33.9424955, longitude: -118.4080684)
        let JFK = CLLocation(latitude: 40.6397511, longitude: -73.7789256)*/

        /*var coordinates = [LAX.coordinate, JFK.coordinate]
        let geodesicPolyline = MKGeodesicPolyline(coordinates: &coordinates, count: 2)
        mapView.addOverlay(geodesicPolyline)*/
        
        /*let coordinates = [LAX.coordinate, JFK.coordinate]
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)*/
        
        self.createStraightline(locations)
        self.perform(#selector(createCurveLine(_:)), with: locations, afterDelay: 0.5)
        
        self.endUpdating()
    }
    
    func createStraightline( _ locations:[CLLocation]){
        self.straighLineFlag = true
        let LAX = CLLocation(latitude: (locations.last?.coordinate.latitude)!, longitude:(locations.last?.coordinate.longitude)!)
        let JFK = CLLocation(latitude: 23.0802, longitude:72.5244)
        let coordinates = [LAX.coordinate, JFK.coordinate]
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        
        mapView.addOverlay(polyline)
    }
    
    @objc func createCurveLine(_ locations:[CLLocation]){
        self.curveLineFlag = true
        let LAX = CLLocation(latitude: (locations.last?.coordinate.latitude)!, longitude:(locations.last?.coordinate.longitude)!)
        let JFK = CLLocation(latitude: 23.0802, longitude:72.5244)
        let coordinates = [LAX.coordinate, JFK.coordinate]
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        
        mapView.addOverlay(polyline)
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        var renderer = MKOverlayRenderer()
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        
        if self.straighLineFlag{
            renderer = MKOverlayRenderer(overlay: polyline)
            renderer.strokeColor = UIColor.lightGray
            renderer.lineWidth = 5
        }
        
        if self.curveLineFlag{
            renderer = GradientPathRenderer(polyline: polyline, colors: [UIColor.black])
            renderer.showsBorder = true
            renderer.lineWidth = 5.0
            renderer.createPath()
        }
        return renderer
    }
    
    func animateToLocation(location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: defaultDelta, longitudeDelta: defaultDelta))
        DispatchQueue.main.async {
            self.mapView.setRegion(region, animated: true)
        }
    }
    
}

