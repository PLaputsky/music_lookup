//
//  HTTPNetworkOperationImp.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/2/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import Foundation
import UIKit

class HTTPNetworkOperationImp: AsyncOperation, HTTPNetworkOperation {
    
    required init(request: HTTPRequest, completion: ((HTTPResponse?) -> Void)?) {
        self.request = request
        self.completion = completion
    }
    
    override func main() {
        let session = URLSession.shared
        session.configuration.httpShouldSetCookies = true
        
        DispatchQueue.main.async { UIApplication.shared.isNetworkActivityIndicatorVisible = true }
        let request = configureURLRequest()
        sessionTask = session.dataTask(with: request) { [weak self] data, res, error in
            var response = HTTPResponse()
            
            response.data = data
            response.error = error
            response.headers = (res as? HTTPURLResponse)?.allHeaderFields ?? [:]
            response.code = (res as? HTTPURLResponse)?.statusCode ?? NSNotFound
            
            DispatchQueue.main.async { UIApplication.shared.isNetworkActivityIndicatorVisible = false }
            self?.state = .finished
            self?.completion?(response)
        }
        sessionTask?.resume()
    }
    
    override func cancel() {
        sessionTask?.cancel()
        super.cancel()
    }
    
    // MARK: Private
    
    private var sessionTask: URLSessionTask?
    private var request: HTTPRequest
    private var completion: ((HTTPResponse?) -> Void)?
    
    private func configureURLRequest() -> URLRequest {
        let urlString = String(format: "%@%@", request.baseUrl, request.path)
        guard var urlComponents = URLComponents(string: urlString) else {
            fatalError("HTTPNetworkOperationImp: invalid url - \(urlString)")
        }
        
        var requestData: Data?
        var headers: [String : String]?
        
        switch request.type {
        case .parameterized(let params):
            urlComponents.queryItems = params.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
            
        case .dataRequest(let data, let contentType):
            requestData = data
            headers = contentType.header
            
        case .plain:
            break
        }
        
        guard let url = urlComponents.url else {
            fatalError("HTTPNetworkOperationImp: invalid url - \(urlString)")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = requestData
        urlRequest.cachePolicy = .reloadIgnoringCacheData
        
        headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        request.headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        return urlRequest
    }
    
}
