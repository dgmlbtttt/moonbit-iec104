// Bounded ASDU builder for GI and event batches.

///|
pub struct ASDUBatchBuilder {
  type_id : Byte
  cot : Int
  casdu : @types.CASDU
  max_objects : Int
  mut elements : Array[InformationElement]
} derive(Debug, Eq)

///|
pub fn ASDUBatchBuilder::new(
  type_id~ : Byte,
  cot~ : Int,
  casdu~ : @types.CASDU,
  max_objects~ : Int,
) -> ASDUBatchBuilder {
  {
    type_id,
    cot,
    casdu,
    max_objects: if max_objects < 1 || max_objects > 127 {
      127
    } else {
      max_objects
    },
    elements: [],
  }
}

///|
pub fn ASDUBatchBuilder::pending(self : ASDUBatchBuilder) -> Int {
  self.elements.length()
}

///|
pub fn ASDUBatchBuilder::capacity(self : ASDUBatchBuilder) -> Int {
  self.max_objects
}

///|
fn ASDUBatchBuilder::build(self : ASDUBatchBuilder) -> ASDU {
  let header = ASDUHeader::create(
    type_id=self.type_id,
    num_objects=self.elements.length(),
    cot=self.cot,
    casdu=self.casdu,
  )
  ASDU::create(header, self.elements)
}

///|
pub fn ASDUBatchBuilder::add(
  self : ASDUBatchBuilder,
  element : InformationElement,
) -> Result[ASDU?, String] {
  let candidate = ASDU::create(
    ASDUHeader::create(
      type_id=self.type_id,
      num_objects=1,
      cot=self.cot,
      casdu=self.casdu,
    ),
    [element],
  )
  match candidate.validate() {
    Err(e) => Err(e)
    Ok(_) => {
      self.elements.push(element)
      if self.elements.length() >= self.max_objects {
        let flushed = self.build()
        self.elements = []
        Ok(Some(flushed))
      } else {
        Ok(None)
      }
    }
  }
}

///|
pub fn ASDUBatchBuilder::flush(self : ASDUBatchBuilder) -> ASDU? {
  if self.elements.length() == 0 {
    None
  } else {
    let result = self.build()
    self.elements = []
    Some(result)
  }
}
