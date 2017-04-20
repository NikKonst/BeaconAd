//
//  BeaconAd.swift
//  BeaconAdSDK
//
//  Created by Nikita Konstantinovskiy on 18.04.17.
//  Copyright © 2017 BeaconAd. All rights reserved.
//

import Foundation
import ZXingObjC

public class BeaconAd {    
    internal let UID: String
    var beaconsUUID: [String] = []
    var status = ["status": false, "message": "No beacons"]
    
    public init(companyUID: String, completion: (result: Bool) -> ()) {
        UID = companyUID
        self.GetBeacons(completion)
    }
    
    public func getStatus() -> [String: AnyObject] {
        return status
    }
    
    func GetBeacons(completion: (result: Bool) -> ()) {
        WebRequest.GetBeacons(UID) { (data, response, err) in
            if (err != nil) {
                self.status["message"] = "server error"
                completion(result: false)
            }
            else {
                var jsonData = NSDictionary()
                do {
                    jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                } catch
                {
                    self.status["message"] = "Ad UID error"
                    completion(result: false)
                }
                
                var dict: [String: AnyObject] = jsonData as! [String: AnyObject]
                
                if dict["status"] as! String == "error" {
                    self.status["message"] = dict["mes"] as! String
                    completion(result: false)
                }
                else {
                    self.status["status"] = true
                    self.status["message"] = "OK"
                    
                    self.beaconsUUID = dict["beacons"] as! [String]
                    completion(result: true)
                }
                
            }
        }
    }
}

