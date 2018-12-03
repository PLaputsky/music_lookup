//
//  LookUpQuerry.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/2/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import Foundation

final class LookUpQuerry: BaseApiQuery {
    
    override var method: Method { return .get }
    override var path: String { return "/lookup" }
    override var type: RequestType {
        var json: [String: String] = [:]
        json["amgArtistId"] = artistId
        json["entity"] = entity
        json["limit"] = limit
        //json["sort"] = sort
        
//        let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
//        return  .dataRequest(data, contentType: .json)
        
        return .parameterized(parameters: json)
    }
    
    //override var headers: [String : String]? { return nil }
    
    private let artistId: String
    private let entity: String
    private let limit: String
   // private let sort: String
    
    init(baseUrl: String, artistId: String, entity: String, limit: String) {//, sort: String = "recent") {
        self.artistId = artistId
        self.entity = entity
        self.limit = limit
        //self.sort = sort
        
        super.init(baseUrl: baseUrl)
    }
}
