//
//  GenericDecodableMapper.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/2/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import Foundation

class GenericDecodableMapper<T: Decodable>: ModelsMapper<T> {
    override func performMapping(data: Data?) -> T? {
        guard let data = data else { return nil }
        
        do {
             return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
}
