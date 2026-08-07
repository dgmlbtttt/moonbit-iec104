// MoonBit IEC 104 - File Transfer Unit Tests

///|
test "File descriptor creation and properties" {
  let fd = FileDescriptor::create(
    filename_id=101,
    file_size_bytes=4096,
    is_directory=false,
  )
  assert_eq(fd.filename_id(), 101)
  assert_eq(fd.file_size_bytes(), 4096)
  assert_false(fd.is_directory())
}

///|
test "File segment checksum verification" {
  let data : Array[Byte] = [b'\x01', b'\x02', b'\x03', b'\x04', b'\x05']
  let seg = FileSegment::create(
    filename_id=1,
    section_number=1,
    segment_offset=0,
    data~,
  )
  assert_true(seg.verify_checksum())
}

///|
test "Fault waveform buffer sampling and byte serialization" {
  let buf = FaultWaveformBuffer::new(2001, 1000)
  buf.add_sample(110.5, 120.0)
  buf.add_sample(109.8, 122.5)

  assert_eq(buf.samples_count(), 2)
  let bytes = buf.to_bytes()
  assert_true(bytes.length() >= 22)
}
