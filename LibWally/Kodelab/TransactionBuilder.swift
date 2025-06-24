//
//  TransactionBuilder.swift
//  TransactionBuilder
//
//  Created by Aden Eley on 24/06/2025 for Kodelab.
//  Copyright © 2025 Sjors Provoost. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation

// MARK: - TransactionBuilder

public struct TransactionBuilder {

    // ------------------------------------------------------------------
    // Output
    // ------------------------------------------------------------------
    public var rawHex: String? { transaction?.description }
    public var feePaid: UInt64? { fee }
    public var changeAmount: UInt64? { change }

    // ------------------------------------------------------------------
    // Internal state
    // ------------------------------------------------------------------
    private let network: Network
    private let feeRate: UInt64
    private let sizeModel: VSizeModel

    private var targetAmount: UInt64 = 0

    private var inputs: [UTXO]? = nil
    private var outputs: [TxOutput]? = nil
    private var change: UInt64? = nil
    private var fee: UInt64? = nil
    private var transaction: Transaction? = nil

    // ------------------------------------------------------------------
    public enum BuilderError: Error {
        case fundStepMissing
        case buildStepMissing
        case cannotParsePrevTx
        case cannotCreateInput
        case signFailed
        case outputsMissing
    }

    // ------------------------------------------------------------------
    // Initialisation
    // ------------------------------------------------------------------
    public init(
        network: Network,
        feeRate: UInt64,  // sats / vByte
        sizeModel: VSizeModel = .p2wpkh
    ) {
        self.network = network
        self.feeRate = feeRate
        self.sizeModel = sizeModel
    }

    // ------------------------------------------------------------------
    // 1.  Input / fee selection
    // ------------------------------------------------------------------
    public mutating func fund(
        with utxos: [UTXO],
        targetAmount: UInt64  // sats to recipient
    ) throws {
        (inputs, change, fee) = try UTXOSelector.smallestFirst(
            utxos: utxos,
            targetAmount: targetAmount,
            feeRateInSatsPerVByte: feeRate,
            sizeModel: sizeModel
        )
        self.targetAmount = targetAmount
    }

    // ------------------------------------------------------------------
    // 2.  Output construction
    // ------------------------------------------------------------------
    public mutating func buildOutputs(
        recipient: Address,
        changeAddress: Address?
    ) throws {
        guard inputs != nil else {
            throw BuilderError.fundStepMissing
        }

        outputs = [
            TxOutput(
                recipient.scriptPubKey,
                targetAmount,
                network)
        ]

        if let chg = change, chg > 546, let changeAddr = changeAddress {
            outputs!.append(
                TxOutput(changeAddr.scriptPubKey, chg, network)
            )
        }
    }

    // ------------------------------------------------------------------
    // 3.  Sign all inputs (P2WPKH v1)
    // ------------------------------------------------------------------
    public mutating func sign(
        with key: Key,
        fetchTxHex: (String) async throws -> String
    ) async throws {

        guard let outs = outputs,
            let ins = inputs
        else {
            throw BuilderError.buildStepMissing
        }

        var signedInputs: [TxInput] = []

        // Loop through the UTXOs, fetch their previous transaction hex,
        // create TxInput objects and collect them.
        for utxo in ins {
            let prevHex = try await fetchTxHex(utxo.txid)
            guard let prevTx = Transaction(prevHex) else {
                throw BuilderError.cannotParsePrevTx
            }

            let witness = Witness(.payToWitnessPubKeyHash(key.pubKey))

            guard
                let txIn = TxInput(
                    prevTx,
                    utxo.vout,
                    Satoshi(utxo.value),
                    nil,
                    witness,
                    utxo.scriptPubKey)
            else {
                throw BuilderError.cannotCreateInput
            }
            signedInputs.append(txIn)
        }

        var txn = Transaction(signedInputs, outs)

        guard txn.sign(Array(repeating: key, count: signedInputs.count))
        else { throw BuilderError.signFailed }

        self.transaction = txn // expose transaction to caller
        fee = txn.fee // set real fee
    }
}
