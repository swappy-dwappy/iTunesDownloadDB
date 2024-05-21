//
//  ThumbnailEndPoint.swift
//  Acharya Prashant
//
//  Created by Sonkar, Swapnil on 12/05/24.
//

import Foundation

enum ThumbnailApi {
    case thumbnail(domain: String, basePath: String, key: String)
}

extension ThumbnailApi: EndPointType {
    
    var environmentBaseURL: String {
        switch self {
        case .thumbnail(let domain, _, _):
            switch NetworkManager.environment {
            case .production: return domain
            case .qa: return domain
            case .staging: return domain
            }
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else {
            fatalError("Base URL could not be configured.")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .thumbnail(_, let basePath, let key):
            return "/" + basePath + "/0/" + key
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .thumbnail(_, _, _):
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .thumbnail(_, _, _):
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .thumbnail(_, _, _):
            return nil
        }
    }
}
