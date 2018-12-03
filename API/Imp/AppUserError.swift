//
//  AppUserError.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/2/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import Foundation

enum AppUserError: Error {
    case undefined
    case custom(message: String)
    case noInternetConnection
    
    var message: String {
        switch self {
        case .custom(let message): return message
        case .noInternetConnection: return "No Internet Connection"
        default: return "Something was going wrong. Please try again"
        }
    }
}

final class APIErrorBuilder {
    private var rawError: String
    
    init(rawError: String) {
        self.rawError = rawError
    }
    
    func build() -> AppUserError {
        return APIErrorKey(rawValue: rawError)?.apiError ?? .undefined
    }
}

private enum APIErrorKey: String {
    case undefined
    
    var apiError: AppUserError {
        switch self {
        case .undefined: return .undefined
        }
    }
    
//    case userDoesntExist = "auth.problem.user_missing"
//    case socialAlreadyConnected = "connect.problem.social_is_already_connected_to_another_account"
//
//    var apiError: AppUserError {
//        switch self {
//        case .userDoesntExist: return .userDoesntExist
//        case .socialAlreadyConnected: return .socialAlreadyConnected
//        }
//    }
}
