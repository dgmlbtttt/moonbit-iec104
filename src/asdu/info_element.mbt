// MoonBit IEC 104 - Information Element Enums and Structures

///|
pub enum InformationElement {
  SinglePointElem(
    @types.IOA,
    @types.SIQ,
    @types.CP24Time2a?,
    @types.CP56Time2a?
  )
  DoublePointElem(
    @types.IOA,
    @types.DIQ,
    @types.CP24Time2a?,
    @types.CP56Time2a?
  )
  StepPositionElem(@types.IOA, Int, @types.QDS, @types.CP56Time2a?) // IOA, VTI value, QDS, CP56Time2a
  NormalizedTelemetryElem(
    @types.IOA,
    Int,
    @types.QDS,
    @types.CP24Time2a?,
    @types.CP56Time2a?
  )
  ScaledTelemetryElem(
    @types.IOA,
    Int,
    @types.QDS,
    @types.CP24Time2a?,
    @types.CP56Time2a?
  )
  ShortFloatTelemetryElem(
    @types.IOA,
    Double,
    @types.QDS,
    @types.CP24Time2a?,
    @types.CP56Time2a?
  )
  IntegratedTotalsElem(
    @types.IOA,
    Int64,
    Int,
    Bool,
    Bool,
    Bool,
    @types.CP56Time2a?
  ) // IOA, val, seq, invalid, adjusted, overflow, time
  SingleCommandElem(@types.IOA, @types.CommandQualifier)
  DoubleCommandElem(@types.IOA, @types.CommandQualifier)
  SetPointNormalizedElem(@types.IOA, Int, @types.CommandQualifier)
  SetPointScaledElem(@types.IOA, Int, @types.CommandQualifier)
  SetPointFloatElem(@types.IOA, Double, @types.CommandQualifier)
  InterrogationCommandElem(@types.IOA, Byte)
  CounterInterrogationElem(@types.IOA, Byte)
  ClockSyncElem(@types.IOA, @types.CP56Time2a)
  ResetProcessElem(@types.IOA, Byte)
} derive(Debug, Eq)

///|
pub fn InformationElement::single_point(
  ioa : @types.IOA,
  siq : @types.SIQ,
  time24? : @types.CP24Time2a? = None,
  time56? : @types.CP56Time2a? = None,
) -> InformationElement {
  SinglePointElem(ioa, siq, time24, time56)
}

///|
pub fn InformationElement::double_point(
  ioa : @types.IOA,
  diq : @types.DIQ,
  time24? : @types.CP24Time2a? = None,
  time56? : @types.CP56Time2a? = None,
) -> InformationElement {
  DoublePointElem(ioa, diq, time24, time56)
}

///|
pub fn InformationElement::step_position(
  ioa : @types.IOA,
  vti : Int,
  qds : @types.QDS,
  time56? : @types.CP56Time2a? = None,
) -> InformationElement {
  StepPositionElem(ioa, vti, qds, time56)
}

///|
pub fn InformationElement::normalized_telemetry(
  ioa : @types.IOA,
  value : Int,
  qds : @types.QDS,
  time24? : @types.CP24Time2a? = None,
  time56? : @types.CP56Time2a? = None,
) -> InformationElement {
  NormalizedTelemetryElem(ioa, value, qds, time24, time56)
}

///|
pub fn InformationElement::scaled_telemetry(
  ioa : @types.IOA,
  value : Int,
  qds : @types.QDS,
  time24? : @types.CP24Time2a? = None,
  time56? : @types.CP56Time2a? = None,
) -> InformationElement {
  ScaledTelemetryElem(ioa, value, qds, time24, time56)
}

///|
pub fn InformationElement::short_float_telemetry(
  ioa : @types.IOA,
  value : Double,
  qds : @types.QDS,
  time24? : @types.CP24Time2a? = None,
  time56? : @types.CP56Time2a? = None,
) -> InformationElement {
  ShortFloatTelemetryElem(ioa, value, qds, time24, time56)
}

///|
pub fn InformationElement::integrated_totals(
  ioa : @types.IOA,
  counter_val : Int64,
  seq : Int,
  invalid : Bool,
  adjusted : Bool,
  overflow : Bool,
  time56? : @types.CP56Time2a? = None,
) -> InformationElement {
  IntegratedTotalsElem(
    ioa, counter_val, seq, invalid, adjusted, overflow, time56,
  )
}

///|
pub fn InformationElement::single_command(
  ioa : @types.IOA,
  cmd_qual : @types.CommandQualifier,
) -> InformationElement {
  SingleCommandElem(ioa, cmd_qual)
}

///|
pub fn InformationElement::double_command(
  ioa : @types.IOA,
  cmd_qual : @types.CommandQualifier,
) -> InformationElement {
  DoubleCommandElem(ioa, cmd_qual)
}

///|
pub fn InformationElement::set_point_normalized(
  ioa : @types.IOA,
  val : Int,
  cmd_qual : @types.CommandQualifier,
) -> InformationElement {
  SetPointNormalizedElem(ioa, val, cmd_qual)
}

///|
pub fn InformationElement::set_point_scaled(
  ioa : @types.IOA,
  val : Int,
  cmd_qual : @types.CommandQualifier,
) -> InformationElement {
  SetPointScaledElem(ioa, val, cmd_qual)
}

///|
pub fn InformationElement::set_point_float(
  ioa : @types.IOA,
  val : Double,
  cmd_qual : @types.CommandQualifier,
) -> InformationElement {
  SetPointFloatElem(ioa, val, cmd_qual)
}

///|
pub fn InformationElement::interrogation_command(
  ioa : @types.IOA,
  qoi : Byte,
) -> InformationElement {
  InterrogationCommandElem(ioa, qoi)
}

///|
pub fn InformationElement::counter_interrogation(
  ioa : @types.IOA,
  qcc : Byte,
) -> InformationElement {
  CounterInterrogationElem(ioa, qcc)
}

///|
pub fn InformationElement::clock_sync(
  ioa : @types.IOA,
  time : @types.CP56Time2a,
) -> InformationElement {
  ClockSyncElem(ioa, time)
}

///|
pub fn InformationElement::reset_process(
  ioa : @types.IOA,
  qrp : Byte,
) -> InformationElement {
  ResetProcessElem(ioa, qrp)
}
