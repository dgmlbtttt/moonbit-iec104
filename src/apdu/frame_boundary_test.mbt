///|
test "APDU parser rejects every short prefix length" {
  for length = 0; length < 6; length = length + 1 {
    let bytes : Array[Byte] = Array::make(length, b'\x00')
    assert_true(parse_apdu(bytes) is Err(_))
  }
}

///|
test "APDU parser rejects invalid length octets" {
  let lengths : Array[Byte] = [b'\x00', b'\x01', b'\x02', b'\x03', b'\xFF']
  for length in lengths {
    assert_true(
      parse_apdu([@types.START_BYTE, length, b'\x00', b'\x00', b'\x00', b'\x00'])
      is Err(_),
    )
  }
}

///|
test "APDU round trips sequence boundaries" {
  let sequences : Array[Int] = [0, 1, 127, 255, 1024, 16384, 32767]
  for sequence in sequences {
    match parse_apdu(encode_apdu(APDU::make_s(sequence))) {
      Ok(SFormat(value)) => assert_eq(value, sequence)
      _ => fail("S-frame sequence did not round trip")
    }
  }
}

///|
test "stream decoder preserves pending bytes through every split point" {
  let source = encode_apdu(APDU::make_i(7, 8, [b'\x01', b'\x02', b'\x03']))
  for split = 1; split < source.length(); split = split + 1 {
    let decoder = APDUStreamDecoder::new()
    let first : Array[Byte] = []
    let second : Array[Byte] = []
    for i = 0; i < split; i = i + 1 {
      first.push(source[i])
    }
    for i = split; i < source.length(); i = i + 1 {
      second.push(source[i])
    }
    assert_true(decoder.push(first).unwrap().length() == 0)
    assert_eq(decoder.push(second).unwrap().length(), 1)
  }
}
