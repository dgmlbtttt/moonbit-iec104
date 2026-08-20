// Fixed-capacity byte ring for transport adapters and diagnostic traces.

///|
pub struct ByteRingBuffer {
  capacity : Int
  data : Array[Byte]
  mut head : Int
  mut count : Int
} derive(Debug, Eq)

///|
pub fn ByteRingBuffer::new(capacity : Int) -> ByteRingBuffer {
  let size = if capacity < 1 { 1 } else { capacity }
  { capacity: size, data: Array::make(size, b'\x00'), head: 0, count: 0 }
}

///|
pub fn ByteRingBuffer::capacity(self : ByteRingBuffer) -> Int {
  self.capacity
}

///|
pub fn ByteRingBuffer::len(self : ByteRingBuffer) -> Int {
  self.count
}

///|
pub fn ByteRingBuffer::is_full(self : ByteRingBuffer) -> Bool {
  self.count == self.capacity
}

///|
pub fn ByteRingBuffer::push(self : ByteRingBuffer, value : Byte) -> Bool {
  if self.is_full() {
    return false
  }
  let index = (self.head + self.count) % self.capacity
  self.data[index] = value
  self.count += 1
  true
}

///|
pub fn ByteRingBuffer::pop(self : ByteRingBuffer) -> Byte? {
  if self.count == 0 {
    return None
  }
  let value = self.data[self.head]
  self.head = (self.head + 1) % self.capacity
  self.count -= 1
  Some(value)
}

///|
pub fn ByteRingBuffer::to_array(self : ByteRingBuffer) -> Array[Byte] {
  let result : Array[Byte] = []
  for i = 0; i < self.count; i = i + 1 {
    result.push(self.data[(self.head + i) % self.capacity])
  }
  result
}

///|
pub fn ByteRingBuffer::clear(self : ByteRingBuffer) -> Unit {
  self.head = 0
  self.count = 0
}
