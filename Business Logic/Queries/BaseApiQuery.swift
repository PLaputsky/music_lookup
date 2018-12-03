//
//  BaseApiQuery.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/2/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import Foundation

class BaseApiQuery: HTTPRequest {
    
    private(set) var udid: String = NSUUID().uuidString
    
    var method: Method { fatalError("Method: should be overriden in a subclass") }
    var path: String { fatalError("path: should be overriden in a subclass") }
    
    var baseUrl: String
    
    var headers: [String : String]? { return nil }
    var type: RequestType { fatalError("RequestType: should be overriden in a subclass") }
    
    var isCancelled: Bool = false
    
    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
}
