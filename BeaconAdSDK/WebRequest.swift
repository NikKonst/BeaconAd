//
//  WebRequest.swift
//  BeaconAdSDK
//
//  Created by Nikita Konstantinovskiy on 18.04.17.
//  Copyright © 2017 BeaconAd. All rights reserved.
//

import Foundation

class WebRequest {
    static let url = "http://flask-env.ubjap2jffs.us-east-1.elasticbeanstalk.com/api/"
    
    static let getbeacons = "getbeacons/"
    static let getclientuid = "getclientuid"
    static let getad = "getad"
    
    static func makePostRequest(path: String, body: String, completion: (data: NSData?, response: NSURLResponse?, err: NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        let URL = NSURL(string: url + path)
        let request = NSMutableURLRequest(URL: URL!)
        
        request.HTTPMethod = "POST"
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request, completionHandler: completion)
        task.resume()
    }
    
    static func makeGetRequest(path: String, completion: (data: NSData?, response: NSURLResponse?, err: NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        let URL = NSURL(string: url + path)
        
        let request = NSMutableURLRequest(URL: URL!)
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request, completionHandler: completion)
        task.resume()
    }
    
    static internal func GetBeacons(uid: String, completion: (data: NSData?, response: NSURLResponse?, err: NSError?) -> Void) {
        makeGetRequest(getbeacons + uid, completion: completion)
    }
    
    static internal func GetClientUID(email: String, completion: (data: NSData?, response: NSURLResponse?, err: NSError?) -> Void) {
        let params = "?email=" + email
        makeGetRequest(getclientuid + params, completion: completion)
    }
    
    static internal func GetAd(client_uid: String, adcompany_uid: String, completion: (data: NSData?, response: NSURLResponse?, err: NSError?) -> Void) {
        let postString = "user_uid=\(client_uid)&adcompany_uid=\(adcompany_uid)"
        
        makePostRequest(getad, body: postString, completion: completion)
    }
}
