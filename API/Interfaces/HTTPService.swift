//
//  HTTPService.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/2/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import Foundation

protocol HTTPClient {
    
    func performRequest(_ request: HTTPRequest)
    func performRequest(_ request: HTTPRequest, completion: @escaping (HTTPResponse?) -> Void)
    func performRequest(_ request: HTTPRequest, completion: @escaping (HTTPResponse?) -> Void, cancelClosure: ((HTTPRequest) -> Void)?)
    
    func cancelRequest(_ request: HTTPRequest)
    func cancelAll()
    
}



