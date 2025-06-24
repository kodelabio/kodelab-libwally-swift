//
//  CryptoHelpers.swift
//  CryptoHelpers
//
//  Created by Aden Eley on 24/06/2025 for Kodelab.
//  Copyright © 2025 Sjors Provoost. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import CryptoKit

// MARK: - Hashing

extension Data {
    /// RIPEMD160(SHA256(self))
    public var hash160: Data {
        let sha = SHA256.hash(data: self)
        return RIPEMD160.hash(data: Data(sha))
    }
}

// MARK: - Keys

extension Key {
    /// Native SegWit (P2WPKH) Bech32 address for this private key.
    /// Works for both mainnet and testnet depending on `self.network`.
    public func p2wpkhAddress() -> Address {
        // hash160 of compressed pubkey
        let pkHash = pubKey.data.hash160

        // build witness program: 0 <20-byte-hash>
        var wp = Data([0x00, 0x14])
        wp.append(pkHash)

        let spk = ScriptPubKey(wp.hexString)!
        return Address(spk, network)!
    }
}

// MARK: - SAT↔BTC
extension UInt64 {
    public init(btc: Double) { self = UInt64(btc * 100_000_000) }
}
extension Double {
    public init(sats: UInt64) { self = Double(sats) / 100_000_000 }
}
