//
//  ViewController.swift
//  Lab7Maps
//
//  Created by user237042 on 3/18/24.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate  {

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationMapView.delegate = self
    }
    
    @IBOutlet weak var currentSpeedLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var maxAcclerationlabel: UILabel!
    @IBOutlet weak var speedExceedLimitLabel: UILabel!
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var tripIndicatorLabel: UILabel!
    

    @IBAction func startTripButton(_ sender: Any) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        locationMapView.showsUserLocation = true
        tripIndicatorLabel.backgroundColor = UIColor.systemGreen
    }
    
    @IBAction func stopTripButton(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        locationMapView.showsUserLocation = false
        tripIndicatorLabel.backgroundColor = UIColor.systemGray
    }
    
    var startLocation : CLLocation!
    var lastLocation : CLLocation!
    var distanceTravelled : Double = 0
    var previousSpeed : Double = 0
    var maxAccelerationValue : Double = 0
    var previousTime : Date? = Date()
    var speedsArray:[Double] = []
    let locationManager : CLLocationManager = CLLocationManager()
    var distanceBeforeExceedingDisplayed = false
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        manager.startUpdatingLocation()
        render(location)

        if startLocation == nil{
            startLocation = locations.first!
        }
        else{
            let lastLocation = locations.last!
            let distance = startLocation.distance(from: lastLocation)
            startLocation = lastLocation
            distanceTravelled = distanceTravelled + distance;
        }

        if (location.speed * 3.6) > 115 && !distanceBeforeExceedingDisplayed {
        
            print("Driver Travels Before Exceeding the Speed limit : \(round(distanceTravelled * 100 / 1000) / 100.0) km !")
            distanceBeforeExceedingDisplayed = true
        }
        
        distanceLabel.text = "\(round(distanceTravelled*100/1000)/100.0) km"
        currentSpeedLabel.text = "\(String(format: "%.2f", location.speed * 3.6)) km/h"
        speedsArray.append(location.speed*3.6)
        maxSpeedLabel.text = "\(String(format: "%.2f", speedsArray.max() ?? 0)) km/h"

        var totalSpeed : Double = 0.0
        speedsArray.forEach{ speed in
            totalSpeed = totalSpeed + speed
        }

        let avgSpeedMeasured = totalSpeed/Double(speedsArray.count)

        if(previousSpeed != 0){
            let speedDifference = location.speed - previousSpeed
            let timeDifference = Date().timeIntervalSince(previousTime!)
            let acceleration = speedDifference/timeDifference
           
            maxAccelerationValue =  max(acceleration, maxAccelerationValue)
            maxAcclerationlabel.text = String (format : "%.3f", maxAccelerationValue) + " m/s^2"
        }

        previousSpeed = location.speed
        previousTime = Date()
        averageSpeedLabel.text = "\(String(format: "%.2f", avgSpeedMeasured)) km/h"
        
        speedExceedLimitLabel.backgroundColor = (location.speed * 3.6) > 115 ? UIColor.red : UIColor.white
    }
    
    func render (_ location: CLLocation) {

        let coordinate = CLLocationCoordinate2D (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude )
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta:0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        let pin = MKPointAnnotation ()
        pin.coordinate = coordinate

        locationMapView.addAnnotation(pin)
        locationMapView.setRegion(region, animated: true)

       }
}

