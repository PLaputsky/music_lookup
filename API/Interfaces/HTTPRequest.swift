//
//  HTTPRequest.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/2/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import Foundation

enum Method: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

public enum ContentType {
    case json
    
    var header: [String : String] {
        switch self {
        case .json: return ["Content-Type" : "application/json"]
        }
    }
}

public enum RequestType {
    
    /// A request with no additional data.
    case plain
    
    /// A requests body set with data.
    case dataRequest(Data, contentType: ContentType)
    
    /// A requests body set with encoded parameters.
    case parameterized(parameters: [String: Any])
    
}

protocol HTTPRequest {
    
    var udid: String { get }
    
    var method: Method { get }
    var path: String { get }
    var baseUrl: String { get }
    
    var headers: [String : String]? { get }
    
    var type: RequestType { get }
    var isCancelled: Bool { get set }
}


protocol HTTPPaginationRequest: HTTPRequest {
    func configureQueryParams() -> [String : Any]
}
