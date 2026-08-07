// MoonBit IEC 104 - Substation Point Database (Tele-signals & Telemetry)

///|
pub struct PointDatabase {
  single_points : Map[Int, Bool]
  double_points : Map[Int, Int]
  telemetry_norm : Map[Int, Int]
  telemetry_float : Map[Int, Double]
  energy_counters : Map[Int, Int64]
} derive(Debug, Eq)

///|
pub fn PointDatabase::new() -> PointDatabase {
  {
    single_points: Map([]),
    double_points: Map([]),
    telemetry_norm: Map([]),
    telemetry_float: Map([]),
    energy_counters: Map([]),
  }
}

///|
pub fn PointDatabase::set_single_point(
  self : PointDatabase,
  ioa : Int,
  val : Bool,
) -> Unit {
  self.single_points.set(ioa, val)
}

///|
pub fn PointDatabase::get_single_point(
  self : PointDatabase,
  ioa : Int,
) -> Bool? {
  self.single_points.get(ioa)
}

///|
pub fn PointDatabase::set_double_point(
  self : PointDatabase,
  ioa : Int,
  dpi_val : Int,
) -> Unit {
  self.double_points.set(ioa, dpi_val)
}

///|
pub fn PointDatabase::get_double_point(self : PointDatabase, ioa : Int) -> Int? {
  self.double_points.get(ioa)
}

///|
pub fn PointDatabase::set_telemetry_norm(
  self : PointDatabase,
  ioa : Int,
  val : Int,
) -> Unit {
  self.telemetry_norm.set(ioa, val)
}

///|
pub fn PointDatabase::get_telemetry_norm(
  self : PointDatabase,
  ioa : Int,
) -> Int? {
  self.telemetry_norm.get(ioa)
}

///|
pub fn PointDatabase::set_telemetry_float(
  self : PointDatabase,
  ioa : Int,
  val : Double,
) -> Unit {
  self.telemetry_float.set(ioa, val)
}

///|
pub fn PointDatabase::get_telemetry_float(
  self : PointDatabase,
  ioa : Int,
) -> Double? {
  self.telemetry_float.get(ioa)
}

///|
pub fn PointDatabase::set_energy_counter(
  self : PointDatabase,
  ioa : Int,
  val : Int64,
) -> Unit {
  self.energy_counters.set(ioa, val)
}

///|
pub fn PointDatabase::get_energy_counter(
  self : PointDatabase,
  ioa : Int,
) -> Int64? {
  self.energy_counters.get(ioa)
}

///|
pub fn PointDatabase::build_gi_asdus(
  self : PointDatabase,
  casdu : @types.CASDU,
) -> Array[@asdu.ASDU] {
  let asdus : Array[@asdu.ASDU] = []

  // 1. Single point tele-signals
  let sp_elems : Array[@asdu.InformationElement] = []
  self.single_points.each(fn(ioa_val, sp_val) {
    let ioa = @types.IOA::new(ioa_val)
    let siq = @types.SIQ::create(value=sp_val, invalid=false)
    sp_elems.push(@asdu.InformationElement::single_point(ioa, siq))
  })
  if sp_elems.length() > 0 {
    let hdr = @asdu.ASDUHeader::create(
      type_id=@types.TYPE_M_SP_NA_1,
      num_objects=sp_elems.length(),
      cot=@types.COT_INTERROGATED_STATION,
      casdu~,
    )
    asdus.push(@asdu.ASDU::create(hdr, sp_elems))
  }

  // 2. Double point tele-signals
  let dp_elems : Array[@asdu.InformationElement] = []
  self.double_points.each(fn(ioa_val, dpi_val) {
    let ioa = @types.IOA::new(ioa_val)
    let diq = @types.DIQ::create(dpi=dpi_val, invalid=false)
    dp_elems.push(@asdu.InformationElement::double_point(ioa, diq))
  })
  if dp_elems.length() > 0 {
    let hdr = @asdu.ASDUHeader::create(
      type_id=@types.TYPE_M_DP_NA_1,
      num_objects=dp_elems.length(),
      cot=@types.COT_INTERROGATED_STATION,
      casdu~,
    )
    asdus.push(@asdu.ASDU::create(hdr, dp_elems))
  }

  // 3. Short float telemetries
  let float_elems : Array[@asdu.InformationElement] = []
  self.telemetry_float.each(fn(ioa_val, f_val) {
    let ioa = @types.IOA::new(ioa_val)
    let qds = @types.QDS::default()
    float_elems.push(
      @asdu.InformationElement::short_float_telemetry(ioa, f_val, qds),
    )
  })
  if float_elems.length() > 0 {
    let hdr = @asdu.ASDUHeader::create(
      type_id=@types.TYPE_M_ME_NC_1,
      num_objects=float_elems.length(),
      cot=@types.COT_INTERROGATED_STATION,
      casdu~,
    )
    asdus.push(@asdu.ASDU::create(hdr, float_elems))
  }

  asdus
}
