//
//  ParameterEncoderType.swift
//  Acharya Prashant
//
//  Created by Sonkar, Swapnil on 12/05/24.
//

import Foundation

typealias Parameters = [String: Any]

protocol ParameterEncoderType {
    func encode(urlRequest: inout URLRequest, parameters: Parameters) throws
}
