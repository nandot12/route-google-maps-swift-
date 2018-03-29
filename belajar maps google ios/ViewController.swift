//
//  ViewController.swift
//  belajar maps google ios
//
//  Created by Nando Septian Husni on 3/28/18.
//  Copyright © 2018 imastudio. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

import Alamofire
import SwiftyJSON


class ViewController: UIViewController,CLLocationManagerDelegate{
    var lokasi : CLLocationManager? = nil
    
    
    @IBOutlet weak var mapsView: GMSMapView!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
      
        
       
        
        
        let camera = GMSCameraPosition.camera(withLatitude: -6.192539,
                                              longitude: 106.8001511,
                                              zoom: 14)
        //let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        
        
        
        let marker = GMSMarker()
        marker.position = camera.target
        marker.snippet = "Hello World"
       // marker.appearAnimation = GMSMarkerAnimation.
        marker.map = mapsView
        
       // view = mapView
        
        
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        let subView = UIView(frame: CGRect(x: 0, y: 65.0, width: 350.0, height: 45.0))
        
        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
      //  view = mapView
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //ambil koordinat gps
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //get koordinat
        let koordinat = locations.last?.coordinate
        
        //get lat long
        let lat = koordinat?.latitude
        let lon = koordinat?.longitude
        
        tampil(lat: lat!, lon: lon!)
       
        
        //view = mapsview
 
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func tampil (lat : Double , lon : Double){
        
        
        let camera = GMSCameraPosition.camera(withLatitude: lat,
                                              longitude: lon,
                                              zoom: 14)
        //let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        
        let marker = GMSMarker()
        
        mapsView.camera = camera
        marker.position = camera.target
        marker.snippet = "lokasiku"
        // marker.appearAnimation = GMSMarkerAnimation.
        marker.map = mapsView
        
        mapsView.settings.compassButton = true
        mapsView.settings.myLocationButton = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Handle the user's selection.
    
}

extension ViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.coordinate.latitude)")
        print("Place address: \(place.coordinate.longitude)")
        print("Place address: \(place.name)")
        
        tampil(lat: place.coordinate.latitude, lon: place.coordinate.longitude)
        
        route(lat: place.coordinate.latitude, lon: place.coordinate.longitude)
        // print("Place attributions: \(place.attributions)")
    }
    

    func route(lat : Double , lon : Double)  {
        //withLatitude: -6.192539,
      //  longitude: 106.8001511
        let awal = "-6.192539,106.8001511"
        let tujuan = String(lat)+","+String(lon)
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin="+awal+"&destination="+tujuan
        
        Alamofire.request(url).responseJSON { (responseroute) in
            
            //check
            responseroute.result.ifSuccess {
                
                //get all json
                let alljson = JSON(responseroute.result.value as Any)
                //get array route
                let route = alljson["routes"].arrayValue
                
                let object = route[0].dictionaryValue
                
                let overview = object["overview_polyline"]?.dictionaryValue
                
                //string point
                let point = overview!["points"]?.stringValue
                
                let path =  GMSPath(fromEncodedPath: point!)
                
                let polyline = GMSPolyline(path: path)
                polyline.strokeColor = .blue
                polyline.strokeWidth = 5.0
                polyline.map = self.mapsView
                polyline.geodesic = true
                
                
                
                
            }
        }
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
