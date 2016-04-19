//
//  OAuth2+Alamofire.swift
//  FetLife
//
//  Created by Jose Cortinas on 2/5/16.
//  Copyright © 2016 BitLove Inc. All rights reserved.
//

import Foundation
import p2_OAuth2
import Alamofire

extension OAuth2 {
    public func request(
        method: Alamofire.Method,
        _ URLString: URLStringConvertible,
        parameters: [String: AnyObject]? = nil,
        encoding: Alamofire.ParameterEncoding = .URL,
        headers: [String: String]? = nil)
        -> Alamofire.Request
    {
        
        var hdrs = headers ?? [:]
        
        if let token = accessToken {
            hdrs["Authorization"] = "Bearer \(token)"
        }
        return Alamofire.request(method, URLString, parameters: parameters, encoding: encoding, headers: hdrs)
    }
}
