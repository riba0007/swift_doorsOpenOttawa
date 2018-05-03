//
//  BuildingDetailsViewController.swift
//  Doors Open Ottawa
//
//  Created by priscila costa on 2017-12-07.
//  Copyright © 2017 Algonquin College. All rights reserved.
//

import UIKit
import MapKit

class BuildingDetailsViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    
    //building details views
    @IBOutlet weak var buildingImageView: UIImageView!
    @IBOutlet weak var buildingName: UILabel!
    @IBOutlet weak var buildingOpenHours: UITextView!
    @IBOutlet weak var buildingDescription: UITextView!
    @IBOutlet weak var buildingAddress: UILabel!
    @IBOutlet weak var buildingMap: MKMapView!
    
    //json object
    var jsonObject: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //add scrollView with page content to the view
        view.addSubview(scrollView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //get values from json
        let name = jsonObject!["nameEN"] as? String
        let description = jsonObject!["descriptionEN"] as? String
        let address = jsonObject!["addressEN"] as? String
        let province = jsonObject!["province"] as? String
        let city = jsonObject!["city"] as? String
        //let latitute = jsonObject!["latitude"] as? Double
        //let longitude = jsonObject!["longitude"] as? Double
        
        //update view with building details
        buildingName.text = name
        buildingDescription.text = description
        buildingAddress.text = address
        buildingOpenHours.text = getBuildingOpenHours()
        getBuildingImage()
        
        //update building map
        let geocodedAddresses = CLGeocoder()
        
        //lat, long
        //let location = CLLocation(latitude: latitute!, longitude: longitude!)
        //geocodedAddresses.reverseGeocodeLocation(location, completionHandler: placeMarkerHandler)
        
        //province, city and addressEN
        let fullAddress = address! + ", " + province! + " " + city!
        geocodedAddresses.geocodeAddressString(fullAddress, completionHandler: placeMarkerHandler)
        
        //resizing description to fit the content
        buildingDescription.translatesAutoresizingMaskIntoConstraints = true
        buildingDescription.sizeToFit()
        buildingDescription.isScrollEnabled = false
        
        //repositioning views
        buildingMap.frame.origin.y = buildingDescription.frame.maxY + 20
        buildingAddress.frame.origin.y = buildingMap.frame.maxY
        
        //resize scrollView to fit screen
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: buildingAddress.frame.maxY + 20)
    }
    
    //get bulding open Hours
    func getBuildingOpenHours() -> String {
        //formatted open hours String
        var formattedHours = ""
        
        //get Saturday values from json
        if let satStartString = jsonObject!["saturdayStart"] as? String,
            let satCloseString = jsonObject!["saturdayClose"] as? String {
                
            //get Saturday date objects
            if let satStartDate = stringToDate(formatedDateString: satStartString),
                let satCloseDate = stringToDate(formatedDateString: satCloseString) {
                
                //format Saturday open hours
                formattedHours = "Saturday \(dateToString(date: satStartDate)) from \(hourToString(date: satStartDate)) to \(hourToString(date: satCloseDate)) \n"
            }
        }
        
        //get Sunday values from json
        if let sunStartString = jsonObject!["sundayStart"] as? String,
            let sunCloseString = jsonObject!["sundayClose"] as? String {
                
            //get Sunday date objects
            if let sunStartDate = stringToDate(formatedDateString: sunStartString),
                let sunCloseDate = stringToDate(formatedDateString: sunCloseString) {
                
                //format Sunday open hours
                formattedHours += "Sunday \(dateToString(date: sunStartDate)) from \(hourToString(date: sunStartDate)) to \(hourToString(date: sunCloseDate)) \n"
            }
        }
        
        //return formatted string
        return formattedHours
    }
    
    //get a date and returns a formatted string MMM dd
    func dateToString(date : Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: date)
    }
    
    //get a date and returns a formatted string HH:mm
    func hourToString(date : Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    //get a string and returns a date
    func stringToDate(formatedDateString: String) -> Date?{
        let formatting = DateFormatter()
        formatting.dateFormat = "yyyy/MM/dd HH:mm"
        return formatting.date(from: formatedDateString)!
    }
    
    func getBuildingImage() {
        // session object to make the requests
        let session: URLSession = URLSession.shared
        
        //Get the current planetId value
        if var imageURL = jsonObject!["image"] as? String {
            
            //replace spaces with %20
            imageURL = imageURL.replacingOccurrences(of: " ", with: "%20")
            
            // url with the imageURL to request the image data
            let url: URL = URL(string: "https://doors-open-ottawa.mybluemix.net/\(imageURL)")!
            // request object with url created
            let imageRequest: URLRequest = URLRequest(url: url)
            // task to get the image
            let imageTask = session.dataTask(with: imageRequest, completionHandler: imageRequestTask )
            
            // Tell the image task to run
            imageTask.resume()
        }
    }
    
    // function to handle the image request
    func imageRequestTask (_ serverData: Data?, serverResponse: URLResponse?, serverError: Error?) {
        
        // If error
        if serverError != nil {
            // log error message
            print("IMAGE LOADING ERROR: " + serverError!.localizedDescription)
            //hide image view
            self.buildingImageView.isHidden = true
        }else{
            //if success
            DispatchQueue.main.async {
                // Set the ImageView's image by converting the data object into a UIImage
                self.buildingImageView.isHidden = false
                self.buildingImageView.image = UIImage(data: serverData!)
            }
        }
    }
    
    //function to plot the building on the map
    func placeMarkerHandler (placeMarkers: Optional<Array<CLPlacemark>>, error: Optional<Error>) -> Void{
        
        if let firstMarker = placeMarkers?[0] {
            
            //create and plot the new marker
            let marker = MKPlacemark(placemark: firstMarker)
            self.buildingMap?.addAnnotation(marker)
            
            //define region zoom and add to the map
            let myRegion = MKCoordinateRegionMakeWithDistance(marker.coordinate, 300, 300)
            self.buildingMap?.setRegion(myRegion, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
