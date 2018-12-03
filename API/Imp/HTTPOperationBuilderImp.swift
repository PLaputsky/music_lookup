//
//  HTTPOperationBuilderImp.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/2/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import Foundation

class HTTPOperationBuilderImp: HTTPOperationsBuilder {
    
    func operation(for request: HTTPRequest, with completion: ((HTTPResponse?) -> Void)?) -> HTTPAsyncOperation {
        return HTTPNetworkOperationImp(request: request, completion: completion)
    }
}
