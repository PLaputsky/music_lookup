//
//  HTTPResponse.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/2/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import Foundation

@objc extension NSError {
    func isNoInternetConnectionError() -> Bool {
        return self.domain == NSURLErrorDomain && self.code == NSURLErrorNotConnectedToInternet
    }
}

struct HTTPResponse {
    var headers: [AnyHashable : Any] = [:]
    var data: Data?
    var error: Error?
    var code: Int = NSNotFound
    
    var isSuccessfull: Bool { return code < 300 && code >= 200 }
    
    func apiError() -> AppUserError {
        if isSuccessfull { return .undefined }
        
        guard let data = data else {
            return ((error as NSError?)?.isNoInternetConnectionError() ?? false) ? .noInternetConnection : .undefined
        }
        return configureApiError(from: data)
    }
    
    // MARK: Private
    
    private func configureApiError(from data: Data) -> AppUserError {
        guard let errorJSON = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String : Any],
            let errorKey = errorJSON["errorKey"] as? String else {
                return AppUserError.undefined
        }
        let apiError = APIErrorBuilder(rawError: errorKey).build()
        return apiError
    }
}
