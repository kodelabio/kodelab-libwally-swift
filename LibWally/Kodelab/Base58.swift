//
//  Base58.swift
//  Base58
//
//  Created by Aden Eley on 24/06/2025 for Kodelab.
//  Copyright © 2025 Sjors Provoost. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

private struct Base58 {
    static let base58Alphabet =
        "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

    // Encode
    static func base58FromBytes(_ bytes: [UInt8]) -> String {
        var bytes = bytes
        var zerosCount = 0
        var length = 0

        for b in bytes {
            if b != 0 { break }
            zerosCount += 1
        }

        bytes.removeFirst(zerosCount)

        let size = bytes.count * 138 / 100 + 1

        var base58: [UInt8] = Array(repeating: 0, count: size)
        for b in bytes {
            var carry = Int(b)
            var i = 0

            for j in 0...base58.count - 1 where carry != 0 || i < length {
                carry += 256 * Int(base58[base58.count - j - 1])
                base58[base58.count - j - 1] = UInt8(carry % 58)
                carry /= 58
                i += 1
            }

            assert(carry == 0)

            length = i
        }

        // skip leading zeros
        var zerosToRemove = 0
        var str = ""
        for b in base58 {
            if b != 0 { break }
            zerosToRemove += 1
        }
        base58.removeFirst(zerosToRemove)

        while 0 < zerosCount {
            str = "\(str)1"
            zerosCount -= 1
        }

        for b in base58 {
            str =
                "\(str)\(base58Alphabet[String.Index(utf16Offset: Int(b), in: base58Alphabet)])"
        }

        return str
    }

    // Decode
    static func bytesFromBase58(_ base58: String) -> [UInt8] {
        // remove leading and trailing whitespaces
        let string = base58.trimmingCharacters(in: CharacterSet.whitespaces)
        guard !string.isEmpty else { return [] }

        // count leading ASCII "1"'s [decodes directly to binary zero bytes]
        var leadingZeros = 0
        for c in string {
            if c != "1" { break }
            leadingZeros += 1
        }

        // calculate the size of the decoded output, rounded up
        let size =
            (string.lengthOfBytes(using: String.Encoding.utf8) - leadingZeros)
            * 733 / 1000 + 1

        // allocate a buffer large enough for the decoded output
        var base58: [UInt8] = Array(repeating: 0, count: size + leadingZeros)

        // decode what remains of the data
        var length = 0
        for c in string where c != " " {
            // search for base58 character
            guard let base58Index = base58Alphabet.firstIndex(of: c) else {
                return []
            }

            var carry = base58Index.utf16Offset(in: base58Alphabet)
            var i = 0
            for j in 0...base58.count where carry != 0 || i < length {
                carry += 58 * Int(base58[base58.count - j - 1])
                base58[base58.count - j - 1] = UInt8(carry % 256)
                carry /= 256
                i += 1
            }

            assert(carry == 0)
            length = i
        }

        // calculate how many leading zero bytes we have
        var totalZeros = 0
        for b in base58 {
            if b != 0 { break }
            totalZeros += 1
        }
        // remove the excess zero bytes
        base58.removeFirst(totalZeros - leadingZeros)

        return base58
    }
}
