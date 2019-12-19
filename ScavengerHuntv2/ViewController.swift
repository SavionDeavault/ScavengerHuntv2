//
//  ViewController.swift
//  ScavengerHuntv2
//
//  Created by Savion DeaVault on 12/9/19.
//  Copyright © 2019 Savion DeaVault. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import CoreData

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    //MARK: - ViewController instance
    static let instance = ViewController()

    //MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    //MARK: - CoreData manager
    var inventoryManager: [NSManagedObject] = []
    //MARK: - JSON encoder and decoder
    var encoder = JSONEncoder()
    var decoder = JSONDecoder()
    //MARK: - Location variables
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    //MARK: - Map camera variables
    var bearingAngle = 270.0
    var angleOfView = 65.0
    var zoomLevel: Float = 18
    //MARK: - Custom user marker variables
    var userMarker = GMSMarker()
    let userMarkerimageView = UIImageView(image: UIImage.gifImageWithName("player"))
    var isUserLocationEnabled: Bool = false
    var markerCount: Int = 0
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0){
                self.checkUserPermission()
                self.initializeMap()
                self.addRandomMarkers()
            }
        }else{
            self.checkUserPermission()
            self.initializeMap()
            self.addRandomMarkers()
        }
        fetchData()
        print(inventoryManager.count)
    }

    func initializeMap() {
        self.mapView.delegate = self as GMSMapViewDelegate
           
        let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: zoomLevel, bearing: bearingAngle, viewingAngle: angleOfView)
           self.mapView.camera = camera
        
           setMapTheme(theme: "Night")
           
           //Interaction with map
           self.mapView.settings.tiltGestures = false
           self.mapView.settings.rotateGestures = false
           //self.mapView.settings.zoomGestures = false
           self.mapView.settings.compassButton = false
           mapView.settings.allowScrollGesturesDuringRotateOrZoom = true
           mapView.settings.indoorPicker = false
           //mapView.isBuildingsEnabled = false
           self.mapView.settings.scrollGestures = false
           fetchData()
    }
    
    //MARK: - Map settings
    func setMapTheme(theme: String) {
        if theme == "Day" {
            do {
                if let styleURL = Bundle.main.url(forResource: "DayStyle", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find DayStyle.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        } else if theme == "Evening" {
            do {
                if let styleURL = Bundle.main.url(forResource: "EveningStyle", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find EveningStyle.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        } else {
            do {
                if let styleURL = Bundle.main.url(forResource: "NightStyle", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find NightStyle.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        }
    }
    
    func checkUserPermission() {
        if CLLocationManager.locationServicesEnabled() {
            if (CLLocationManager.locationServicesEnabled()){
                locationManager.delegate = self as CLLocationManagerDelegate
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
                locationManager.startUpdatingHeading()
                isUserLocationEnabled = true
                centerMapAtUserLocation()
            }else{
                
            }
        } else {
            print("Location is denied/restriced!")
        }
    }
    
    func centerMapAtUserLocation() {
        //Uncomment isMyLocationEnabled to hide blue marker underneath the player
        //mapView.isMyLocationEnabled = true
        userMarkerimageView.frame = CGRect(x: 0, y: 0, width: 40, height: 70)
        
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: zoomLevel, bearing: bearingAngle, viewingAngle: angleOfView)
        self.mapView.animate(to: camera)
    }
    
    //MARK: - Map Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last ?? CLLocation(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: zoomLevel, bearing: bearingAngle, viewingAngle: angleOfView)
        self.mapView.animate(to: camera)
        mapView.animate(toBearing: newHeading.magneticHeading)
        //delete the old user location marker first
        userMarker.map = nil
        userMarker.position = CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
        userMarker.iconView = userMarkerimageView
        userMarker.groundAnchor = CGPoint(x: 0.5, y: 1.0)
        userMarker.map = mapView
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let distanceinMiles = round(100*distanceInMeters(marker: marker)*0.00062137)/100
        print(distanceinMiles)
       // if distanceinMiles <= 0.2 {
            addItemToInventory(item: marker.title!)
            marker.map = nil
            markerCount -= 1
            if(markerCount <= 0){
                addRandomMarkers()
            }
        
        /* }else{
            hiddenLabel.text = "That is too far away!(\(distanceinMiles) miles)!"
            hiddenLabel.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                self.hiddenLabel.text = ""
                self.hiddenLabel.isHidden = true
            }
        } */
        return true
    }
    
    //MARK: - Utils
    func randomCoordinate(lat: CLLocationDegrees, lng: CLLocationDegrees) -> (processedLat: Double, processedLng: Double) {
       /* let r = 25
        let sqaureRoot = sqrt(u).hashValue
        let w = r * sqaureRoot
        let t = 2 * Double.pi * v
        let _cos = cos(t).hashValue
        let _sin = sin(t).hashValue
        let x = w * _cos
        let y = w * _sin
        
        let newX = Double(x) / cos(Double(y))*/
        
        let radius : Double = 1100 // this is in meters so 100 KM
        let radiusInDegrees: Double = radius / 111000
        let u : Double = Double(arc4random_uniform(100)) / 100.0
        let v : Double = Double(arc4random_uniform(100)) / 100.0
        let w : Double = radiusInDegrees * u.squareRoot()
        let t : Double = 2 * Double.pi * v
        let x : Double = w * cos(t)
        let y : Double = w * sin(t)

        // Adjust the x-coordinate for the shrinking of the east-west distances
        //in cos converting degree to radian
        let new_x : Double = x / cos(lat * .pi / 180 )

        let processedLat = new_x + lat
        let processedLng = y + lng

        return (processedLat, processedLng)
    }
    
    func distanceInMeters(marker: GMSMarker) -> CLLocationDistance {
        let markerLocation = CLLocation(latitude: marker.position.latitude , longitude: marker.position.longitude)
        let metres = locationManager.location?.distance(from: markerLocation)
        return Double(metres ?? -1) //will be in metres
    }
    
    func randomString(length: Int) -> String {

        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }
    
    func deleteAllData(entity: String){
        let ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do { try AppDelegate.persistentContainer().viewContext.execute(DelAllReqVar) }
        catch { print(error) }
    }
    
    func addRandomMarkers() {
        let markerImage = UIImage.gifImageWithName("diamond1")
        let markerView = UIImageView(image: markerImage)
        for i in 0..<Int.random(in: 2..<5) {
            var marker:  GMSMarker?
            let latitude = self.randomCoordinate(lat: (self.locationManager.location?.coordinate.latitude)!, lng: (self.locationManager.location?.coordinate.longitude)!).processedLat
            let longitude = self.randomCoordinate(lat: (self.locationManager.location?.coordinate.latitude)!, lng: (self.locationManager.location?.coordinate.longitude)!).processedLng
            let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            marker = GMSMarker(position: position)
            marker?.map = mapView
            marker?.iconView = markerView
            marker?.title = "diamond-markers"
            print("Marker count \(i+1)")
            markerCount = i+1
        }
    }
    
    func addItemToInventory(item: String){
        let context = AppDelegate.persistentContainer().viewContext
        
        let inventory = NSEntityDescription.entity(forEntityName: "Inventory", in: context)!
        
        let value = NSManagedObject(entity: inventory, insertInto: context)
            
        value.setValue(item, forKeyPath: "diamondmarkers")
        
        do {
          try context.save()
          inventoryManager.append(value)
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchData(){
        let managedContext =
          AppDelegate.persistentContainer().viewContext
        
        //2
        let fetchRequest =
          NSFetchRequest<NSManagedObject>(entityName: "Inventory")
        
        //3
        do {
          inventoryManager = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    
}

