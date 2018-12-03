//
//  LookUpModel.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/2/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import Foundation

struct LookUpModel: Codable {
    let resultCount: Int
    let results: [LookUpItem]
    
    enum CodingKeys: String, CodingKey {
        case resultCount = "resultCount"
        case results = "results"
    }
}

struct LookUpItem: Codable {
    let wrapperType: String?
    let artistType: String?
    let artistName: String?
    let artistLinkURL: String?
    let artistID: Int?
    let amgArtistID: Int?
    let primaryGenreName: String?
    let primaryGenreID: Int?
    let kind: String?
    let collectionID: Int?
    let trackID: Int?
    let collectionName: String?
    let trackName: String?
    let collectionCensoredName: String?
    let trackCensoredName: String?
    let artistViewURL: String?
    let collectionViewURL: String?
    let trackViewURL: String?
    let previewURL: String?
    let artworkUrl30: String?
    let artworkUrl60: String?
    let artworkUrl100: String?
    let collectionPrice: Double?
    let trackPrice: Double?
    let releaseDate: String?
    let collectionExplicitness: String?
    let trackExplicitness: String?
    let discCount: Int?
    let discNumber: Int?
    let trackCount: Int?
    let trackNumber: Int?
    let trackTimeMillis: Int?
    let country: String?
    let currency: String?
    let isStreamable: Bool?
    let collectionArtistID: Int?
    let collectionArtistName: String?
    let collectionArtistViewURL: String?
    
    enum CodingKeys: String, CodingKey {
        case wrapperType = "wrapperType"
        case artistType = "artistType"
        case artistName = "artistName"
        case artistLinkURL = "artistLinkUrl"
        case artistID = "artistId"
        case amgArtistID = "amgArtistId"
        case primaryGenreName = "primaryGenreName"
        case primaryGenreID = "primaryGenreId"
        case kind = "kind"
        case collectionID = "collectionId"
        case trackID = "trackId"
        case collectionName = "collectionName"
        case trackName = "trackName"
        case collectionCensoredName = "collectionCensoredName"
        case trackCensoredName = "trackCensoredName"
        case artistViewURL = "artistViewUrl"
        case collectionViewURL = "collectionViewUrl"
        case trackViewURL = "trackViewUrl"
        case previewURL = "previewUrl"
        case artworkUrl30 = "artworkUrl30"
        case artworkUrl60 = "artworkUrl60"
        case artworkUrl100 = "artworkUrl100"
        case collectionPrice = "collectionPrice"
        case trackPrice = "trackPrice"
        case releaseDate = "releaseDate"
        case collectionExplicitness = "collectionExplicitness"
        case trackExplicitness = "trackExplicitness"
        case discCount = "discCount"
        case discNumber = "discNumber"
        case trackCount = "trackCount"
        case trackNumber = "trackNumber"
        case trackTimeMillis = "trackTimeMillis"
        case country = "country"
        case currency = "currency"
        case isStreamable = "isStreamable"
        case collectionArtistID = "collectionArtistId"
        case collectionArtistName = "collectionArtistName"
        case collectionArtistViewURL = "collectionArtistViewUrl"
    }
}

enum Explicitness: String, Codable {
    case cleaned = "cleaned"
    case explicit = "explicit"
    case notExplicit = "notExplicit"
}

enum Country: String, Codable {
    case usa = "USA"
}

enum Currency: String, Codable {
    case usd = "USD"
}

enum Kind: String, Codable {
    case song = "song"
}

enum WrapperType: String, Codable {
    case artist = "artist"
    case track = "track"
}

