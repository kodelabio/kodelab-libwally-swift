//
//  RIPEMD160+Hash.swift
//
//  Created by Aden Eley on 18/06/2025.
//

extension RIPEMD160 {
    public static func hash(data: Data) -> Data {
        var md = Self()
        md.update(data: data)
        return md.finalize()
    }
}
