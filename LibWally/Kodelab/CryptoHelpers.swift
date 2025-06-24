//
//  CryptoHelpers.swift
//  CryptoHelpers
//
//  Created by Aden Eley on 24/06/2025.
//  Copyright © 2025 Sjors Provoost. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import CryptoKit

// MARK: - Hashing

public extension Data {
    /// RIPEMD160(SHA256(self))
    var hash160: Data {
        let sha = SHA256.hash(data: self)
        return RIPEMD160.hash(data: Data(sha))
    }
}

// MARK: - Keys

public extension Key {
    /// Native SegWit (P2WPKH) Bech32 address for this private key.
    /// Works for both mainnet and testnet depending on `self.network`.
    func p2wpkhAddress() -> Address {
        // hash160 of compressed pubkey
        let pkHash = pubKey.data.hash160
        
        // build witness program: 0 <20-byte-hash>
        var wp = Data([0x00, 0x14])
        wp.append(pkHash)
        
        let spk  = ScriptPubKey(wp.hexString)!           // cannot fail
        return Address(spk, network)!                    // cannot fail
    }
}
