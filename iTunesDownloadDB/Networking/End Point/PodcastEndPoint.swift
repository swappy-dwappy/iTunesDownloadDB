//
//  PodcastEndPoint.swift
//  iTunes
//
//  Created by Sonkar, Swapnil on 14/05/24.
//

import Foundation

enum PodcastApi {
    case searchEpisode(id: Int, media: String, entity: String, limit: Int)
}

extension PodcastApi: EndPointType {
    
    var environmentBaseURL: String {
        switch NetworkManager.environment {
        case .qa: return "https://itunes.apple.com"
        case .staging: return "https://itunes.apple.com"
        case .production: return "https://itunes.apple.com"
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
        case .searchEpisode(_, _, _, _): return "/lookup"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .searchEpisode(_, _, _, _):
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case let .searchEpisode(id, media, entity, limit):
            return .requestParameters(parameterEncoding: .urlEncoding,
                                      urlParameters: [
                                                        "id": id,
                                                        "media": media,
                                                        "entity": entity,
                                                        "limit": limit
                                                    ],
                                      bodyParameters: nil)
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .searchEpisode(_, _, _, _):
            return nil
        }
    }
    
    
}
