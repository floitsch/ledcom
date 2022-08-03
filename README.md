# LED Communication

Small demo project to show to send data with the flashlight of a phone to an ESP32 running [Toit](toitlang.org).

The project uses a normal LED (instead of a photodiode) to receive the data. The LED is connected as usual (with a
current-limiting resistor) and is fully functional. When receiving, the direction of the pin is switched from output
to input and with the ESP32's ADC we measure the voltage.

The code is just a proof of concept and not production ready.


https://user-images.githubusercontent.com/1731210/182683026-0ba1cbc4-50e4-4302-b90c-e2b410439632.mp4

