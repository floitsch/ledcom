import gpio
import gpio.adc

main:
  pin := gpio.Pin --output 32
  adc_pin := adc.Adc pin --max_voltage=2.0

  while true:
    voltage := adc_pin.get
    if voltage > 1.0: break
    sleep --ms=50

  print "detected high"
  while true:
    voltage := adc_pin.get --samples=1
    if voltage < 1.0: break

  print "start"
  measurements := List 100
  index := 0
  while true:
    count := 0
    while (adc_pin.get --samples=1) < 1.0 and count < 1000:
      count++
    if count >= 1000: break
    measurements[index++] = count

    count = 0
    while (adc_pin.get --samples=1) > 1.0 and count < 1000:
      count++
    if count >= 1000: break
    measurements[index++] = count

  print measurements

  // Compute the threshold.
  // The first byte is 0x55 consisting of alternating bits. This gives us a good way to
  // determine the threshold.
  sum := 0
  8.repeat:
    sum += measurements[1 + it * 2]
  threshold := sum / 8
  print "threshold: $threshold"

  index = 1 + 8 * 2
  result := #[]
  done := false
  while not done:
    c := 0
    mask := 0x01
    for i := 0; i < 8; i++:
      measurement := measurements[index]
      index += 2
      if not measurement:
        measurement = 0
        done = true
      if measurement > threshold:
        c |= mask
      mask <<= 1
    result += #[c]
  print result
  print result.to_string_non_throwing

  adc_pin.close
  pin.close
