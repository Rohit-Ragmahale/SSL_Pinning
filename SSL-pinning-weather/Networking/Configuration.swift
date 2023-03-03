//
//  Configuration.swift
//  SSL-pinning-weather
//
//  Created by Rohit Ragmahale on 16/02/2023.
//

import Foundation


struct NetworkConfiguration {
    static let isPinningAllow: Bool = true
    static let pinningMethod: PinningMethod = .publicKeyPinning
}

enum PinningMethod {
    case certificatePinning
    case publicKeyPinning
    case publicKeyHash
}
