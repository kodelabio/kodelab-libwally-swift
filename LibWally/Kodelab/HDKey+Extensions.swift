//
//  HDKey+Extensions.swift
//  HDKey+Extensions
//
//  Created by Aden Eley on 24/06/2025.
//  Copyright © 2025 Sjors Provoost. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

extension HDKey {
    /// Convenience: directly return WIF for a BIP-32 path.
    /// Throws if the path can’t be derived or the key is neutered.
    /// Example: `HDKey(mnemonic.seedHex(), .testnet).wif(at: "m/86'/1'/0'/0/0")`
    public func wif(at path: String) throws -> String {
        let child = try derive(path)
        guard let wif = child.privKey?.wif else {
            throw BIP32Error.derivationFailed
        }
        return wif
    }
}
