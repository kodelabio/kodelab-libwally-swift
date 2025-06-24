//
//  UTXO.swift
//  UTXO
//
//  Created by Aden Eley on 24/06/2025 for Kodelab.
//  Copyright © 2025 Sjors Provoost. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation

/// Minimal UTXO model used by the selection engine.
public struct UTXO: Equatable {
    public let txid: String  // big-endian hex
    public let vout: UInt32  // output index
    public let value: UInt64  // satoshis
    public let scriptPubKey: ScriptPubKey

    public init(
        txid: String, vout: UInt32, value: UInt64, scriptPubKey: ScriptPubKey
    ) {
        self.txid = txid
        self.vout = vout
        self.value = value
        self.scriptPubKey = scriptPubKey
    }
}

/// Virtual-byte size constants for *one* input or output plus tx overhead.
/// Create a custom instance when you want a different script template.
public struct VSizeModel: Equatable {
    public let input: UInt64  // vbytes per input
    public let output: UInt64  // vbytes per output
    public let txOverhead: UInt64  // version + locktime etc.

    public init(input: UInt64, output: UInt64, txOverhead: UInt64) {
        self.input = input
        self.output = output
        self.txOverhead = txOverhead
    }
    /// Default values for native SegWit P2WPKH.
    public static let p2wpkh = VSizeModel(input: 68, output: 31, txOverhead: 12)
}

/// Errors thrown by the selector.
public enum UTXOSelectorError: Error {
    case insufficientFunds(required: UInt64, available: UInt64)
}

public enum UTXOSelector {

    /// Simple “smallest-first” algorithm (a.k.a. “accumulative” in BitcoinJS).
    ///
    /// - Parameters:
    ///   - utxos:   Spendable UTXOs.
    ///   - target:  Desired payment amount in satoshis (does **not** include fee).
    ///   - feeRate: Fee rate in sat/vByte.
    ///   - sizeModel: VSizeModel, Virtual-byte size constants for *one* input or output plus tx overhead.
    ///
    /// - Returns: `(inputs, change, fee)`
    ///   * `inputs`  – the chosen UTXOs
    ///   * `change`  – change amount in sats (0 if none created)
    ///   * `fee`     – miner fee in sats, based on a coarse size model
    ///
    /// - Throws: `UTXOSelectorError.insufficientFunds`
    ///
    public static func smallestFirst(
        utxos: [UTXO],
        targetAmount: UInt64,
        feeRateInSatsPerVByte: UInt64,
        sizeModel: VSizeModel = .p2wpkh
    ) throws -> (selectedUTXOs: [UTXO], changeAmount: UInt64, feeAmount: UInt64) {

        func estimateFee(vInputCount: Int, vOutputCount: Int) -> UInt64 {
            let totalVBytes =
                UInt64(vInputCount) * sizeModel.input +
                UInt64(vOutputCount) * sizeModel.output +
                sizeModel.txOverhead
            return totalVBytes * feeRateInSatsPerVByte
        }

        let sortedUTXOs = utxos.sorted { $0.value < $1.value }
        var selectedUTXOs: [UTXO] = []
        var accumulatedValue: UInt64 = 0

        for utxo in sortedUTXOs {
            selectedUTXOs.append(utxo)
            accumulatedValue += utxo.value

            let estimatedFee = estimateFee(
                vInputCount: selectedUTXOs.count,
                vOutputCount: 2  // assume recipient + change
            )

            if accumulatedValue >= targetAmount + estimatedFee {
                let changeAmount = accumulatedValue - targetAmount - estimatedFee
                return (selectedUTXOs, changeAmount, estimatedFee)
            }
        }

        let totalAvailableValue = utxos.reduce(0) { $0 + $1.value }

        throw UTXOSelectorError.insufficientFunds(
            required: targetAmount,
            available: totalAvailableValue
        )
    }
}
