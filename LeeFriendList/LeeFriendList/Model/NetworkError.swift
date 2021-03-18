//
//  NetworkError.swift
//  LeeFriendList
//
//  Created by Lee McCormick on 3/16/21.
//

import Foundation

enum NetworkError: LocalizedError {
    
    case invalidURL
    case thrownError(Error)
    case noData
    case unableToDecode
    case repeatRequest
    
    var errorDescription: String? {
        switch self {
        case .thrownError(let error):
            return "Error: \(error.localizedDescription) -> \(error)"
        case .invalidURL:
            return "Unable to reach the server."
        case .noData:
            return "The server responded with no data."
        case .unableToDecode:
            return "The server responded with bad data."
        case.repeatRequest:
            return "This user already has a pending request from you"
        }
    }
}
