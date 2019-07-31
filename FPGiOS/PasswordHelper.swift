//
//  PasswordHelper.swift
//  FPGiOS
//
//  Created by Xlfdll on 2019/07/25.
//  Copyright © 2019 Xlfdll Workstation. All rights reserved.
//

import Foundation

import CryptoSwift

class PasswordHelper {
    static let RandomSaltLength = 64
    static let RandomSaltBackupDataFileName = "FPG_Salt.dat"

    static func generatePassword(keyword: String, salt: String, length: Int) -> String {
        var input = ""

        input.append(keyword)
        input.append(UserDefaults.standard.string(forKey: AppDataKeys.RandomSaltKey)!)
        input.append(salt)

        let hash = StringHelper.getHashString(hashAlgorithmName: "SHA-512",
            text: input,
            encoding: String.Encoding.utf16BigEndian)

        var result = ""

        var i = 0
        var j = length

        while i < length {
            if (j + i) == hash.count {
                j = 0
            }

            let ch = hash[hash.index(hash.startIndex, offsetBy: j + i)]

            if i % 2 == 0 {
                result.append(ch.uppercased())
            } else {
                result.append(ch)
            }

            i += 1
            j += 1
        }

        return result
    }

    static func generateSalt(length: Int) -> String {
        let basicCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_[]{}<>~`+=,.;:/?|"

        var salt = ""

        for _ in 0...length {
            let index = Int.random(in: 0 ... (basicCharacters.count - 1))
            salt.append(basicCharacters[basicCharacters.index(basicCharacters.startIndex, offsetBy: index)])
        }

        return salt
    }

    static func getRandomSaltFileURL() -> URL? {
        do {
            return try FileManager().url(for: FileManager.SearchPathDirectory.documentDirectory,
                in: FileManager.SearchPathDomainMask.userDomainMask,
                appropriateFor: nil,
                create: true)
                .appendingPathComponent(PasswordHelper.RandomSaltBackupDataFileName)
        }
        catch {
            return nil
        }
    }

    static func loadRandomSalt() -> String? {
        let url = PasswordHelper.getRandomSaltFileURL()

        if url != nil && FileManager().fileExists(atPath: url!.path) {
            do {
                return try String(contentsOf: url!, encoding: String.Encoding.utf8)
            }
            catch {
                print(error.localizedDescription)

                return nil
            }
        }

        return nil
    }

    static func saveRandomSalt(_ randomSalt: String) {
        let url = PasswordHelper.getRandomSaltFileURL()

        if url != nil {
            do {
                try randomSalt.write(to: url!, atomically: true, encoding: String.Encoding.utf8)
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
}
