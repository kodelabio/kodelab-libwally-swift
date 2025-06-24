//
//  TransactionBuilder+Factory.swift
//  TransactionBuilder+Factory
//
//  Created by Aden Eley on 24/06/2025.
//  Copyright © 2025 Sjors Provoost. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

/// Convinience factory for Transaction Builder.
/// One-shot init rather than multi-step.
extension TransactionBuilder {
    static func buildAndSign(
        utxos: [UTXO],
        target: UInt64,
        feeRate: UInt64,
        recipient: Address,
        changeAddr: Address,
        key: Key,
        network: Network,
        fetchTxHex: (String) async throws -> String
    ) async throws -> String {

        var b = TransactionBuilder(network: network, feeRate: feeRate)
        try b.fund(with: utxos, targetAmount: target)
        try b.buildOutputs(recipient: recipient, changeAddress: changeAddr)
        try await b.sign(with: key, fetchTxHex: fetchTxHex)
        return b.rawHex!
    }
}
