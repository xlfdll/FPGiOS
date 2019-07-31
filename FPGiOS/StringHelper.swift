//
//  StringHelper.swift
//  FPGiOS
//
//  Created by Xlfdll on 2019/07/25.
//  Copyright © 2019 Xlfdll Workstation. All rights reserved.
//

import Foundation

class StringHelper {
    static func getBytesString(data: Data) -> String {
        let format = "%02x"

        return data.map { String(format: format, $0) }.joined()
    }

    static func getHashString(hashAlgorithmName: String, text: String, encoding: String.Encoding) -> String {
        let textData = text.data(using: encoding)

        switch hashAlgorithmName {
        case "SHA-512":
            return StringHelper.getBytesString(data: (textData?.sha512())!)
        default:
            return ""
        }
    }
}
