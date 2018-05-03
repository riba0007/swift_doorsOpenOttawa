//
//  BuildingsTableViewController.swift
//  Doors Open Ottawa
//
//  Created by priscila costa on 2017-12-07.
//  Copyright © 2017 Algonquin College. All rights reserved.
//

import UIKit

class BuildingsTableViewController: UITableViewController {

    //variable to store the json received
    var jsonObjects: [[String:Any]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //change the title to loading
        self.title = "Loading..."
        
        //create an URL to request the data (using request to localhost)
        let url: URL = URL(string: "https://doors-open-ottawa.mybluemix.net/buildings")!
        //create the request with the URL created
        let request: URLRequest = URLRequest(url: url)
        //create a session to make the request
        let session: URLSession = URLSession.shared
        //create the task that will load the data passing the request and callback function
        let loadTask = session.dataTask(with: request, completionHandler: requestTask )
        
        //run the task
        loadTask.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //0 by default
        var cellCount = 0
        
        //if json dictionary exists
        if let jsonObj = jsonObjects {
            //get json dictionary size
            cellCount = jsonObj.count
        }
        //return size
        return cellCount
    }

    //function that will create list items with the response data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //get the cell with identifier BuildingCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "BuildingCell", for: indexPath)
        
        //allow the table cell to have multiple lines
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        //if json dictionary exists
        if let jsonObj = jsonObjects{
            
            //get the json dictionary object that corresponds to the current cell
            let eventRow = jsonObj[indexPath.row] as [String:Any]
            
            //get title and date from json dictionary object
            let nameEN = eventRow["nameEN"] as? String
            let addressEN = eventRow["addressEN"] as? String
            
            //set cell's text with json data
            cell.textLabel?.text = nameEN! + "\n@ " + addressEN!
        }
        //return cell
        return cell
    }
    
    //function to be called when a request is made. Manages the response.
    func requestTask (_ serverData: Data?, serverResponse: URLResponse?, serverError: Error?) -> Void{
        
        //if ERROR
        if serverError != nil {
            //call the callback function passing the error message
            self.loadCallback("", error: serverError?.localizedDescription)
            // else SUCCESS
        }else{
            //stringfy the response
            let result = String(data: serverData!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            //call the callback function passing the response
            self.loadCallback(result, error: nil)
        }
    }
    
    //callback function to work with the response data received
    func loadCallback(_ responseString: String, error: String?) {
        
        // If ERROR
        if error != nil {
            //log error
            print("DATA LIST LOADING ERROR: " + error!)
            // else SUCCESS
        }else{
            //get the data from the response (transform response to data)
            if let myData: Data = responseString.data(using: String.Encoding.utf8) {
                do {
                    //try to get the JSON into a dictionary object
                    jsonObjects = try JSONSerialization.jsonObject(with: myData, options: []) as? [[String:Any]]
                    
                } catch let convertError {
                    //log error
                    print(convertError.localizedDescription)
                }
                
            }
            
            //UI updates
            DispatchQueue.main.async {
                //reload table view
                self.tableView!.reloadData()
                //change title back to Event List
                self.title = "Buildings List"
            }
        }
    }
    
    // Pass the current building to the next view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBuilding" {
            // Get a reference to the next viewController class
            let nextView = segue.destination as? BuildingDetailsViewController
            
            //get selected cell
            guard let cell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: cell) else {
                    return
            }
            
            //access the JSON dictionary if it exists
            if let jsonObj = jsonObjects{
                nextView?.jsonObject = jsonObj[indexPath.row] as [String:Any]
            }
            
        }
    }

}
