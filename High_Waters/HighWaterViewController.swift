//
//  HighWaterViewController.swift
//  High_Waters
//
//  Created by Toleen Jaradat on 7/28/16.
//  Copyright © 2016 Toleen Jaradat. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CloudKit

class HighWaterViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate {

    var container: CKContainer!
    var publicDB: CKDatabase!
    var privateDB: CKDatabase!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager :CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.container = CKContainer.defaultContainer()
        self.publicDB = self.container.publicCloudDatabase
        self.privateDB = self.container.privateCloudDatabase
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.mapView.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        self.mapView.showsUserLocation = true
        
        populateHighWaterPins()

    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        
        if event?.subtype == UIEventSubtype.MotionShake
        {
            print("Device was shaken")
        }
        
        // Add new annotaion to map
        
        let pinAnnotation = MKPointAnnotation()
        pinAnnotation.title = " "
        pinAnnotation.coordinate = self.mapView.userLocation.coordinate
        
        self.mapView.addAnnotation(pinAnnotation)
        
        // Saving annotaion record to CloudKit
        
        let highWaterRecord = CKRecord(recordType: "CautionRecord")
        highWaterRecord["HighWaterArea"] = self.mapView.userLocation.location
        
        self.publicDB.saveRecord(highWaterRecord) { (record :CKRecord?, error :NSError?) in
            
        }
                
    }
    
    private func populateHighWaterPins() {
        
        let query = CKQuery(recordType: "CautionRecord", predicate: NSPredicate(value: true))
        
        self.publicDB.performQuery(query, inZoneWithID: nil) { (records :[CKRecord]?, erro :NSError?) in
            
            for record in records! {
                
                //print(record["HighWaterArea"])
                
                let pinAnnotation = MKPointAnnotation()
                pinAnnotation.title = " "
                let pinAnnotaionLocation = record["HighWaterArea"] as! CLLocation
                pinAnnotation.coordinate = pinAnnotaionLocation.coordinate
            
                self.mapView.addAnnotation(pinAnnotation)

            }
        }
    }
    
    
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        
        // Distinguish the user location annotation from the rest of the annotations
        for index in 0...views.count-1 {
            
        if   (views[index].annotation! is MKUserLocation) {
            
                    let region = MKCoordinateRegionMakeWithDistance(views.first!.annotation!.coordinate, 650, 650)
                    self.mapView.setRegion(region, animated: true)
                    
                }
        }
    }

    
    private func createAccessoryView() -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 20))
        
        let widthConstraint = NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 20)
        view.addConstraint(widthConstraint)
        
        let heightConstraint = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 20)
        view.addConstraint(heightConstraint)
        
        return view
        
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var cautionAnnotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier("CautionAnnotationView")
        
        if cautionAnnotationView == nil {
            
            cautionAnnotationView = CautionAnnotationView(annotation: annotation, reuseIdentifier: "CautionAnnotationView")
            
        }
        
        cautionAnnotationView?.canShowCallout = true
        
        cautionAnnotationView?.detailCalloutAccessoryView = self.createAccessoryView()
        
        
        let dangerLabel = UILabel(frame: CGRectMake(0, 0, 90, 20))
        dangerLabel.text = "Be Careful!"
        cautionAnnotationView!.leftCalloutAccessoryView = dangerLabel
        
        let deleteButton = UIButton(type: UIButtonType.Custom)
        deleteButton.frame = CGRectMake(0,0,35,35)
        deleteButton.setImage(UIImage(named: "trash.png"), forState: UIControlState.Normal)
        cautionAnnotationView!.rightCalloutAccessoryView = deleteButton;
        
        return cautionAnnotationView
        
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            print("Disclosure Pressed!")
            
        // delete the location query from the cloudkit
        
        print(view.annotation!.coordinate)
        let location = CLLocation(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)

            let query = CKQuery(recordType: "CautionRecord", predicate: NSPredicate(format: "HighWaterArea = %@", location))
        
                    self.publicDB.performQuery(query, inZoneWithID: nil) { (records :[CKRecord]?, error :NSError?) in
        
                        if let records = records {
        
                            if let record = records.first {
        
                                self.publicDB.deleteRecordWithID(record.recordID, completionHandler: { (recordId :CKRecordID?, error :NSError?) in
        
                                })
        
                            }
                        
                        }
                    }
        
                }
        
        // delete the selected pin
        mapView.removeAnnotation(view.annotation!)
    
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

   

}
