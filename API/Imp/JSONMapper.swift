//
//  JSONMapper.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/2/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import Foundation

class ModelsMapper<ModelType>: MapperProtocol {
    typealias Model = ModelType
    
    func performMapping(data: Data?) -> ModelType? {
        fatalError("ModelsMapper: models mapping should be implemented in subclasses")
    }
}

class NoResponse: NoResponseProtocol {}
