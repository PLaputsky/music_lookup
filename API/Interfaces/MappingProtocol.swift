//
//  MappingProtocol.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/2/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import Foundation

protocol MapperProtocol {
    associatedtype Model
    
    func performMapping(data: Data?) -> Model?
}

protocol NoResponseProtocol {}
