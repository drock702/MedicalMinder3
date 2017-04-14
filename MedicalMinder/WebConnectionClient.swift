//
//  WebConnectionClient.swift
//  MedicalMinder3
//
//  Created by Derrick Price on 1/20/17.
//  Copyright © 2017 DLP. All rights reserved.
//

import UIKit
import Foundation

class WebConnectionClient : NSObject {
    
    /* Shared session */
    var session: URLSession
    
    /* Authentication state */
    var sessionID : String? = nil
    //    var userID : Int? = nil
    var userKey: String? = nil
    
    // Initializers
    
    override init() {
        session = URLSession.shared
        super.init()
        
    }
    
    // Get user data of the logged in user
    func getMedicalDescription (_ medicine_name: String?, completionHandler: @escaping (_ success: Bool, _ result: String?, _ errorString: String?) -> Void) {
     
        // Send HTTP GET Request
        
        // Define server side script URL
        let scriptUrl = "https://api.fda.gov/drug/label.json"
        
        // Add one parameter
        let urlWithParams = scriptUrl + "?search=\(medicine_name!)"
        
        // Create NSURL Ibject
        guard let myUrl = URL(string: urlWithParams) else {
            return
        }
        
        // Create URL Request
        let request = NSMutableURLRequest(url:myUrl)
        
        // Set request HTTP method to GET. It could be POST as well
        request.httpMethod = "GET"
        
        // Excute HTTP Request
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error in
            
            // Default value
            let default_result = "No description found"
            
            // Check for error
            if error != nil {
                print("error=\(error?.localizedDescription)")

                completionHandler (false, default_result, error?.localizedDescription)
                return
            }
            
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    
                    guard (convertedJsonIntoDict.object(forKey: "error") == nil) else {
                        if let error_msg = convertedJsonIntoDict["error"] as? String {
                            print ("error msg: \(error_msg)")
                            
                            completionHandler (false, default_result, error_msg)
                        }
                        else {
                            
                            completionHandler (false, default_result, "Unable to get valid data.")
                        }
                        return
                    }
                    
                    
                    let med_results = convertedJsonIntoDict.value(forKey: "results") as! NSArray
                    // Check for presence of description
                    guard ((med_results[0] as AnyObject).object(forKey: "description") != nil) else {
                        completionHandler (false, default_result, "Unable to get valid description.")
                        return
                    }
                    
                    let desc_key = (med_results[0] as AnyObject).value(forKey: "description") as! NSArray                    
                    
                    guard let the_desc = desc_key[0] as? String else {
                        completionHandler (false, default_result, "Unable to get description.")
                        return
                    }
                    
                    completionHandler (true, the_desc, nil)
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
                
                completionHandler (false, default_result, "Failed to retrieve description")
            }
            
        })
        
        task.resume()
    }
    
    // Shared Instance
    class func sharedInstance() -> WebConnectionClient {
        
        struct Singleton {
            static var sharedInstance = WebConnectionClient()
        }
        
        return Singleton.sharedInstance
    }
}
