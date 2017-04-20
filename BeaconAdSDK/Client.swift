//
//  Client.swift
//  BeaconAdSDK
//
//  Created by Nikita Konstantinovskiy on 19.04.17.
//  Copyright © 2017 BeaconAd. All rights reserved.
//

import Foundation

class Client {
    public var uid: String = String()
    public var email: String
    var _status = false
    
    var Status: Bool {
        get {
            return _status
        }
    }
    
    public init (email: String, completion: (result: Bool) -> ()) {
        self.email = email
        self.getUID(completion)
    }
    
    func getUID(completion: (result: Bool) -> ()) {
        WebRequest.GetClientUID(email) { (data, response, err) in
            if (err != nil) {
                completion(result: false)
            }
            else {
                var jsonData = NSDictionary()
                do {
                    jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                } catch
                {
                    completion(result: false)
                }
                
                var dict: [String: AnyObject] = jsonData as! [String: AnyObject]
                
                if dict["status"] as! String == "error" {
                    completion(result: false)
                }
                else {
                    self._status = true
                    
                    self.uid = dict["uid"] as! String
                    completion(result: true)
                }
                
            }
        }
    }
}
