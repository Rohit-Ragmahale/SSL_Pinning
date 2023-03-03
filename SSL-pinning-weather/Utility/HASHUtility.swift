//
//  HASHUtility.swift
//  SSL-pinning-weather
//
//  Created by Rohit Ragmahale on 16/02/2023.
//

import Foundation
import CommonCrypto

class HASHUtility {
    static func sha256(data: Data) -> Data {
        var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        digestData.withUnsafeMutableBytes { (digestBytes: UnsafeMutableRawBufferPointer) -> Void in
            data.withUnsafeBytes { (messageBytes: UnsafeRawBufferPointer) -> Void in
                CC_SHA256(messageBytes.baseAddress, CC_LONG(data.count), digestBytes.bindMemory(to: UInt8.self).baseAddress)
            }
        }
        return digestData
    }
}
