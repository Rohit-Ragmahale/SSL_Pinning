//
//  Pinning.swift
//  SSL-pinning-weather
//
//  Created by Rohit Ragmahale on 16/02/2023.
//

import Foundation

private let asnHeaderWithrsa22048:[UInt8] = [
    0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
    0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
]

private let localPublicKeys = ["axmGTWYycVN5oCjh3GJrxWVndLSZjypDO6evrHMwbXg="]
private let localCertificateNames = [
    "*.openweathermap.org",
    "*.google.co.in"
]

extension NetworkManager: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard NetworkConfiguration.isPinningAllow else {
            // Skip Pinning
            completionHandler(.performDefaultHandling, nil)
            return
        }

        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            
            let remoteCertificates = (0..<SecTrustGetCertificateCount(serverTrust)).compactMap{ SecTrustGetCertificateAtIndex(serverTrust, $0)}
            
            var isMatched = false
            switch NetworkConfiguration.pinningMethod {
            case .certificatePinning:
                isMatched = matchCertificate(remoteCertificates: remoteCertificates)
            case .publicKeyPinning:
                isMatched = matchPublicKay(remoteCertificates: remoteCertificates)
            case .publicKeyHash:
                isMatched = matchPublicKayHash(remoteCertificates: remoteCertificates)
            }

            let policies = [SecPolicyCreateSSL(true, (challenge.protectionSpace.host as CFString))]
            SecTrustSetPolicies(serverTrust, policies as CFTypeRef)
            let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
            
            if isMatched && isServerTrusted {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
            
        }
    }
}

extension NetworkManager {
    private func matchCertificate(remoteCertificates: [SecCertificate]) -> Bool {
        let localCerts = localCertificateNames.compactMap { getLocalCertificate(name: $0) }
        let localCertsData = localCerts.compactMap{ SecCertificateCopyData($0) as Data }
        let remoteCertsData = remoteCertificates.compactMap{ SecCertificateCopyData($0) as Data }
        return !Set(localCertsData).isDisjoint(with: remoteCertsData)
    }
    
    private func matchPublicKay(remoteCertificates: [SecCertificate]) -> Bool {
        let certToData: ((_ certificate: SecCertificate) -> Data?) = { (certificate: SecCertificate) -> Data? in
            guard let serverPublicKey = SecCertificateCopyKey(certificate), let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil) else {
                return nil
            }
            let data: Data = serverPublicKeyData as Data
            return data
        }
        
        let serverPublicKeysData: [Data] = remoteCertificates.compactMap {certToData($0)}
        let localCerts = localCertificateNames.compactMap { getLocalCertificate(name: $0) }
        let localCertsData: [Data] = localCerts.compactMap {certToData($0)}
        
        return !Set(serverPublicKeysData).isDisjoint(with: localCertsData)
    }
    
    private func matchPublicKayHash(remoteCertificates: [SecCertificate]) -> Bool {
        
        let serverPublicKeys: [String] = remoteCertificates.compactMap { certificate in
            
            guard let serverPublicKey = SecCertificateCopyKey(certificate), let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil) else {
                return nil
            }

            let data: Data = serverPublicKeyData as Data
            var keyWithHeader = Data(asnHeaderWithrsa22048)
            keyWithHeader.append(data)
            
            return HASHUtility.sha256(data: keyWithHeader).base64EncodedString()
        }
        return !Set(serverPublicKeys).isDisjoint(with: localPublicKeys)
    }

    private func getLocalCertificate(name: String) -> SecCertificate? {
        if let url = Bundle.main.url(forResource: name, withExtension: "cer"), let data = try? Data(contentsOf: url), let cert = SecCertificateCreateWithData(nil, data as CFData) {
            return cert
        }
        return nil
    }
}




