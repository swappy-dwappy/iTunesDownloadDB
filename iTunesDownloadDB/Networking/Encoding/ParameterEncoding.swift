//
//  ParameterEncoding.swift
//  Acharya Prashant
//
//  Created by Sonkar, Swapnil on 12/05/24.
//

import Foundation

enum ParameterEncoding {
    
    case urlEncoding
    case jsonEncoding
    case urlAndJsonEncoding
    
    func encode(urlRequest: inout URLRequest,
                urlParameters: Parameters?,
                bodyParameters: Parameters?) throws {
        
        switch self {
        case .urlEncoding:
            guard let urlParameters = urlParameters else { return }
            try URLParameterEncoder().encode(urlRequest: &urlRequest, parameters: urlParameters)
            
        case .jsonEncoding:
            guard let bodyParameters = bodyParameters else { return }
            try JSONParameterEncoder().encode(urlRequest: &urlRequest, parameters: bodyParameters)
            
        case .urlAndJsonEncoding:
            if let urlParameters = urlParameters {
                try URLParameterEncoder().encode(urlRequest: &urlRequest, parameters: urlParameters)
            }
            if let bodyParameters = bodyParameters {
                try JSONParameterEncoder().encode(urlRequest: &urlRequest, parameters: bodyParameters)
            }
        }
    }
}
