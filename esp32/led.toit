import gpio
import gpio.adc

THRESHOLD_US ::= 100_000

wait_for pin/adc.Adc [block] -> int?:
  start := Time.monotonic_us
  while true:
    val := pin.get --samples=1
    now := Time.monotonic_us
    if block.call (pin.get --samples=1): return now - start
    if now - start > THRESHOLD_US: return null

main:
  pin := gpio.Pin --output 32

  pin.set 1
  sleep --ms=1_500
  pin.set 0

  adc_pin := adc.Adc pin --max_voltage=2.0

  print "Waiting for light."
  while true:
    voltage := adc_pin.get
    if voltage > 1.0: break
    sleep --ms=50

  print "Receiving"
  while true:
    voltage := adc_pin.get --samples=1
    if voltage < 1.0: break

  measurements := []
  wait_for_raising := true
  while true:
    duration_us := wait_for adc_pin:
      wait_for_raising ? it > 1.0 : it < 1.0
    if not duration_us: break
    measurements. add duration_us
    wait_for_raising = not wait_for_raising

  // Compute the threshold.
  // The first byte is 0x55 consisting of alternating bits. This gives us a good way to
  // determine the threshold.
  sum := 0
  8.repeat:
    sum += measurements[1 + it * 2]
  threshold := sum / 8

  index := 1 + 8 * 2
  result := #[]
  done := false
  while index < measurements.size:
    c := 0
    mask := 0x01
    for i := 0; i < 8; i++:
      measurement := index < measurements.size ? measurements[index] : 0
      index += 2
      if measurement > threshold:
        c |= mask
      mask <<= 1
    result += #[c]
  print "Received: $result = $(result.to_string_non_throwing)"

  adc_pin.close
  pin.close
