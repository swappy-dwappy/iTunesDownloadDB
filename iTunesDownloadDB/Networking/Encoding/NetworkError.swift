//
//  NetworkError.swift
//  Acharya Prashant
//
//  Created by Sonkar, Swapnil on 12/05/24.
//

import Foundation

enum NetworkError: LocalizedError {
    case parametersNil
    case encodingFailed
    case missingURL
    case uploadFileMissing
    case uploadDataNil
    
    var errorDescription: String? {
        switch self {
        case .parametersNil:
            return "Parameters were nil."
        case .encodingFailed:
            return "Parameter encoding failed."
        case .missingURL:
            return "URL is nil."
        case .uploadFileMissing:
            return "Upload file is missing."
        case .uploadDataNil:
            return "No data to upload."
        }
    }
}
