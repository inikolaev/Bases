//
//  Base32.swift
//  Bases
//
//  Created by Matt Rubin on 3/29/15.
//  Copyright (c) 2015 Matt Rubin. All rights reserved.
//

private let quantumSize = 5

public func base32<S: SequenceType where S.Generator.Element == UInt8>(bytes: S) -> String? {
    return encode(ArraySlice(bytes))
}

private func encode(bytes: ArraySlice<UInt8>) -> String? {
    if let s = encodeQuantum(bytes) {
        if bytes.count <= quantumSize {
            return s
        } else {
            // There's more data to encode
            let remainingBytes = bytes[(bytes.startIndex + quantumSize)..<(bytes.endIndex)]
            if let restOfString = encode(remainingBytes) {
                return s + restOfString
            }
        }
    }

    // Something failed
    return nil
}

private func encodeQuantum(bytes: ArraySlice<UInt8>) -> String? {
    // Special processing is performed if fewer than 40 bits are available
    // at the end of the data being encoded.  A full encoding quantum is
    // always completed at the end of a body.  When fewer than 40 input bits
    // are available in an input group, bits with value zero are added (on
    // the right) to form an integral number of 5-bit groups.  Padding at
    // the end of the data is performed using the "=" character.  Since all
    // base 32 input is an integral number of octets, only the following
    // cases can arise:
    switch bytes.count {
    case 0:
        return ""
    case 1:
        // The final quantum of encoding input is exactly 8 bits; here, the
        // final unit of encoded output will be two characters followed by
        // six "=" padding characters.
        if let c = charactersForBytes(bytes[0], nil, nil, nil, nil) {
            return String([c.0, c.1, c.2, c.3, c.4, c.5, c.6, c.7])
        }
    case 2:
        // The final quantum of encoding input is exactly 16 bits; here, the
        // final unit of encoded output will be four characters followed by
        // four "=" padding characters.
        if let c = charactersForBytes(bytes[0], bytes[1], nil, nil, nil) {
            return String([c.0, c.1, c.2, c.3, c.4, c.5, c.6, c.7])
        }
    case 3:
        // The final quantum of encoding input is exactly 24 bits; here, the
        // final unit of encoded output will be five characters followed by
        // three "=" padding characters.
        if let c = charactersForBytes(bytes[0], bytes[1], bytes[2], nil, nil) {
            return String([c.0, c.1, c.2, c.3, c.4, c.5, c.6, c.7])
        }
    case 4:
        // The final quantum of encoding input is exactly 32 bits; here, the
        // final unit of encoded output will be seven characters followed by
        // one "=" padding character.
        if let c = charactersForBytes(bytes[0], bytes[1], bytes[2], bytes[3], nil) {
            return String([c.0, c.1, c.2, c.3, c.4, c.5, c.6, c.7])
        }
    default:
        // The final quantum of encoding input is an integral multiple of 40
        // bits; here, the final unit of encoded output will be an integral
        // multiple of 8 characters with no "=" padding.
        if let c = charactersForBytes(bytes[0], bytes[1], bytes[2], bytes[3], bytes[4]) {
            return String([c.0, c.1, c.2, c.3, c.4, c.5, c.6, c.7])
        }
    }

    // Something failed
    return nil
}


private func charactersForBytes(b0: UInt8, b1: UInt8?, b2: UInt8?, b3: UInt8?, b4: UInt8?)
    -> (Character, Character, Character, Character, Character, Character, Character, Character)?
{
    let q = quintets(b0, b1, b2, b3, b4)
    if let
        c0 = characterForValue(q.0),
        c1 = characterForValue(q.1),
        c2 = characterOrPaddingForValue(q.2),
        c3 = characterOrPaddingForValue(q.3),
        c4 = characterOrPaddingForValue(q.4),
        c5 = characterOrPaddingForValue(q.5),
        c6 = characterOrPaddingForValue(q.6),
        c7 = characterOrPaddingForValue(q.7)
    {
        return (c0, c1, c2, c3, c4, c5, c6, c7)
    } else {
        return nil
    }
}

private func characterOrPaddingForValue(value: UInt8?) -> Character? {
    if let value = value {
        return characterForValue(value)
    } else {
        return pad
    }
}
