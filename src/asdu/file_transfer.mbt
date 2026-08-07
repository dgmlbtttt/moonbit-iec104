// MoonBit IEC 104 - File Transfer Protocol Structures and Codecs (IEC 60870-5-104 Section 7.4)

///|
pub struct FileDescriptor {
  filename_id : Int
  file_size_bytes : Int
  is_directory : Bool
  timestamp : @types.CP56Time2a
} derive(Debug, Eq)

///|
pub fn FileDescriptor::create(
  filename_id~ : Int,
  file_size_bytes~ : Int,
  is_directory? : Bool = false,
  timestamp? : @types.CP56Time2a = @types.CP56Time2a::default(),
) -> FileDescriptor {
  { filename_id, file_size_bytes, is_directory, timestamp }
}

///|
pub fn FileDescriptor::filename_id(self : FileDescriptor) -> Int {
  self.filename_id
}

///|
pub fn FileDescriptor::file_size_bytes(self : FileDescriptor) -> Int {
  self.file_size_bytes
}

///|
pub fn FileDescriptor::is_directory(self : FileDescriptor) -> Bool {
  self.is_directory
}

///|
pub fn FileDescriptor::timestamp(self : FileDescriptor) -> @types.CP56Time2a {
  self.timestamp
}

///|
pub struct FileSegment {
  filename_id : Int
  section_number : Int
  segment_offset : Int
  data : Array[Byte]
  checksum : Byte
} derive(Debug, Eq)

///|
pub fn FileSegment::create(
  filename_id~ : Int,
  section_number~ : Int,
  segment_offset~ : Int,
  data~ : Array[Byte],
) -> FileSegment {
  let lrc = @utils.calculate_lrc(data)
  { filename_id, section_number, segment_offset, data, checksum: lrc }
}

///|
pub fn FileSegment::filename_id(self : FileSegment) -> Int {
  self.filename_id
}

///|
pub fn FileSegment::section_number(self : FileSegment) -> Int {
  self.section_number
}

///|
pub fn FileSegment::segment_offset(self : FileSegment) -> Int {
  self.segment_offset
}

///|
pub fn FileSegment::data(self : FileSegment) -> Array[Byte] {
  self.data
}

///|
pub fn FileSegment::checksum(self : FileSegment) -> Byte {
  self.checksum
}

///|
pub fn FileSegment::verify_checksum(self : FileSegment) -> Bool {
  let lrc = @utils.calculate_lrc(self.data)
  lrc == self.checksum
}

///|
pub struct FaultWaveformBuffer {
  record_id : Int
  sampling_rate_hz : Int
  voltage_samples : Array[Double]
  current_samples : Array[Double]
} derive(Debug, Eq)

///|
pub fn FaultWaveformBuffer::new(
  record_id : Int,
  sampling_rate_hz : Int,
) -> FaultWaveformBuffer {
  { record_id, sampling_rate_hz, voltage_samples: [], current_samples: [] }
}

///|
pub fn FaultWaveformBuffer::add_sample(
  self : FaultWaveformBuffer,
  v : Double,
  i : Double,
) -> Unit {
  self.voltage_samples.push(v)
  self.current_samples.push(i)
}

///|
pub fn FaultWaveformBuffer::samples_count(self : FaultWaveformBuffer) -> Int {
  self.voltage_samples.length()
}

///|
pub fn FaultWaveformBuffer::to_bytes(self : FaultWaveformBuffer) -> Array[Byte] {
  let buf = @utils.ByteBuffer::new(128)
  buf.write_uint16_le(self.record_id)
  buf.write_uint16_le(self.sampling_rate_hz)
  buf.write_uint16_le(self.voltage_samples.length())

  for i = 0; i < self.voltage_samples.length(); i = i + 1 {
    buf.write_float32_le(self.voltage_samples[i])
    buf.write_float32_le(self.current_samples[i])
  }
  buf.to_array()
}
