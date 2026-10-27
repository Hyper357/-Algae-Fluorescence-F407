# Board pin map

The user-provided photo identifies the board family as 正点原子探索者 STM32F4; its revision and exact chip remain unconfirmed. Do not use ESP32 GPIO numbers from the separate V2 project as F407 pin assignments.

| Function | Attached board assignment | Status |
| --- | --- | --- |
| Existing CH340 serial | COM8 on host; MCU UART and full routing unknown | Receives existing diagnostic text at 115200 8N1; photo shows a USART1 jumper area marked `PA10(RX)`, but the connection to CH340 has not been traced |
| Board LEDs | Unknown | Pending board-specific schematic and marking |
| ADS1115 I2C SDA / SCL | Not yet wired or verified | Photo labels `I2C1 PB8/PB9`; the F407 datasheet assigns I2C1 SCL to PB8 and SDA to PB9 when configured in the appropriate alternate function. Actual board routing, conflicts and module wiring remain unverified. |
| ADS1115 supply / address / pull-ups | Unknown | Pending inspection |
| SWD / boot mode | Unknown | No ST-Link detected in the current USB inventory |

ADC supply range, I2C pull-up voltage, common ground, and actual ADC input voltage must be checked against the hardware and datasheet before physical connection or measurement.

Source for the candidate chip's alternate functions: [ST STM32F405/F407 datasheet, pin description](https://www.st.com/resource/en/datasheet/stm32f407zg.pdf). The supplied photograph is not a complete board schematic.
