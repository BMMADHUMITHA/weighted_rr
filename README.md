# weighted_rr
The weight of each master is defined as the grant time slice that the master can configure in the arbiter. If all the masters have the same amount of weight, each master will get an equal time. If master A requests 20 cycles and master B requests 10 cycles, master A will get grant 2 times longer than master B. One disadvantage of letting the masters configure the weight is that a master may configure a very large weight. To reduce this large weight problem, another global configurable maximum allowed weight is added. A master may request a very large weight value, but the arbiter will only grant up to the maximum allowed
weight if there are other masters waiting.

# weight decoder
Weight decoder decodes one-hot grant to decode the correct weight of the granted master. Weight of the masters are concatenated to form a weight bus, the width of the bus can be calculated by the width of a single weight and the total number of masters in the arbiter. Weight decoder takes the current grant as an one-hot input. The input grant is decoded to produce an index for correct bit slice positions of the weight bus. For example, if the grant is b ′0010, the index output is 1. Index of 1 stands for the master no. 1. The weight of master 1 is decoded as an output. If the grant is b ′0100, index output is 2. The weight of master 2 is decoded as an output.

<img width="132" alt="image" src="https://github.com/BMMADHUMITHA/weighted_rr/assets/134037700/cf43c9fe-b31c-4807-8434-17c879566bbe">

# Next Grant Precalculator
Next Grant PReCalculator(NGPRC) calculates the next possible grants mask based on the current grant. By precalculating the next possible grants, NGPRC dictates the Round Robin arbitration of the arbiter. For example, if all 4 masters in the arbiter are requesting and the current grant is master 1, the next possible grant is restricted to be in the order of master 2, master 3 and master 0. The arbiter cannot skip master 2 to grant master 3. It would violate the Round-robin scheme and it is not allowed. By giving the next possible grant priority to the Grant State-machine, it forces the grant to be in strict Round-robin order. . For example, if the current grant is b′0010, rotate left gives b ′0100. After inversion, the bits become b ′1011. After increment by 1, the next possible grant becomes b ′1100. It means the leftmost 2 bits are in line in priority.

# Grant State Machine
Grant state machine is the logic to calculate which master gets the grant and for how long based on the weight. The grant logic is based on the requests and next grant priority mask created by NGPRC. “Grant Process” state masks requests using a precalculated mask to grant the next requesting master. After the grant is decided, it moves to the “Get Weight” state to fetch the weight of the grant from Weight Decoder. After that, it moves to the “Count” state to count the clock cycles until the local counter reaches the desired weight.

<img width="347" alt="image" src="https://github.com/BMMADHUMITHA/weighted_rr/assets/134037700/11aa54b9-16f0-4aea-b54c-0f608ed4566b">

# Output
<img width="454" alt="image" src="https://github.com/BMMADHUMITHA/weighted_rr/assets/134037700/ad2f16fc-ab61-4563-8d7e-9e4ada4b05b9">

<img width="455" alt="image" src="https://github.com/BMMADHUMITHA/weighted_rr/assets/134037700/5f19ab18-81a5-4dea-a125-c83a00f39ff9">

# Coverage:

<img width="685" alt="image" src="https://github.com/BMMADHUMITHA/weighted_rr/assets/134037700/68ff1f33-8896-4809-8563-73835ce91a36">

# Prepared by:
B M Madhumitha


# References

Toe, Aung, "Design and Verification of a Round-Robin Arbiter" (2018). Thesis. Rochester Institute of Technology

# TM4C123 GPIO Switch and RGB LED Control

**Name:** B M Madhumitha  
**Course:** PhD ESE  
**SR No.:** 04-01-00-10-12-26-01-28178

## Overview

This project demonstrates GPIO programming on the Texas Instruments TM4C123GH6PM Tiva C Series microcontroller using the onboard switches and RGB LED connected to GPIO Port F.

The assignment contains two programs:

### Switch-Based RGB LED Control

- SW1 pressed - Blue LED
- SW2 pressed - Green LED
- Both switches pressed - White LED
- No switch pressed - Red LED

### RGB LED Blinking with Adjustable Speed and Colour

- SW1 changes the blinking speed.
- SW2 changes the blinking colour.
- The speed and colour values cycle through predefined arrays.
- Switch debouncing is implemented to prevent a single physical press from being detected multiple times using software.

# Hardware

The programs are designed for the TM4C123GH6PM Tiva C Series LaunchPad.

## GPIO Port F Connections

| Pin | Function | Description |
|---|---|---|
| PF0 | Switch input | SW2 |
| PF1 | LED output | Red LED |
| PF2 | LED output | Blue LED |
| PF3 | LED output | Green LED |
| PF4 | Switch input | SW1 |

The RGB LED uses three GPIO pins:

- PF1 - RED
- PF2 - BLUE
- PF3 - GREEN

The three LED outputs can also be activated together to produce white, therefore:

- RED = PF1
- BLUE = PF2
- GREEN = PF3
- WHITE = PF1 + PF2 + PF3

# Program 1 — Switch-Based RGB LED Control

## Objective

Write a program to:

- Light the Blue LED when SW1 is pressed.
- Light the Green LED when SW2 is pressed.
- Light the White LED when both switches are pressed.
- Light the Red LED when neither switch is pressed.

## Program Logic

The program continuously reads PF0 and PF4:

```c
switch_value = GPIO_PORTF_DATA_R & 0x11;
```

The mask 0x11 corresponds to: 0x11 = 00010001 so Pf4 and PF0

The switches use pull-up resistors. Therefore: Switch released is 1 and Switch pressed is 0

The four possible switch combinations are:

| PF4 | PF0 | Switch condition | LED |
|---|---|---|---|
| 1 | 1 | Neither pressed | Red |
| 0 | 1 | SW1 pressed | Blue |
| 1 | 0 | SW2 pressed | Green |
| 0 | 0 | Both pressed | White |

The RGB LED output values are:

```c
RED   = 0x02;
BLUE  = 0x04;
GREEN = 0x08;
WHITE = 0x0E;
```

## GPIO Configuration

### Enable Port F Clock

```c
SYSCTL_RCGC2_R |= 0x20;
```

This enables the clock to GPIO Port F.

### Unlock PF0

PF0 is a protected GPIO pin on the TM4C123. It must be unlocked before configuration:

```c
GPIO_PORTF_LOCK_R = 0x4C4F434B;
GPIO_PORTF_CR_R |= 0x01;
```

### Configure LED Pins as Outputs

```c
GPIO_PORTF_DIR_R |= 0x0E;
```

This configures PF1, PF2 and PF3 as outputs.

### Configure Switch Pins as Inputs

```c
GPIO_PORTF_DIR_R &= ~0x11;
```

This configures PF0 and PF4 as inputs.

### Enable Digital Function

```c
GPIO_PORTF_DEN_R |= 0x1F;
```

This enables the digital function on PF0–PF4.

### Enable Pull-Up Resistors

```c
GPIO_PORTF_PUR_R |= 0x11;
```

The pull-up resistors ensure that the switch inputs have a stable logic HIGH state when the switches are released.

# Program 2 — Adjustable Blinking Speed and Colour

## Objective

Develop a program where:

- SW1 changes the blinking rate.
- SW2 changes the blinking colour.

The blinking speed cycles through predefined values.

The LED colour cycles through predefined colours.

# Speed Settings

Three blinking intervals are defined:

```c
#define SLOW    500
#define MEDIUM  250
#define FAST    100
```

They are stored in the following array:

```c
const uint16_t speeds[3] =
{
    SLOW,
    MEDIUM,
    FAST
};
```

The speed sequence is:

**Slow -> Medium -> Fast -> Slow -> ...**

The variable:

```c
uint8_t speed = 0;
```

stores the current speed index.

When SW1 is pressed:

```c
speed++;
```

When the last speed is reached:

```c
if (speed >= 3)
{
    speed = 0;
}
```

the index returns to zero.

Therefore:

speed = 0 -> Slow  
speed = 1 -> Medium  
speed = 2 -> Fast  
speed = 0 -> Slow

# Colour Settings

Four colours are stored in the colours array:

```c
const uint8_t colours[4] =
{
    BLUE,
    RED,
    WHITE,
    GREEN
};
```

The colour sequence is:

**Blue -> Red -> White -> Green -> Blue -> ...**

The current colour is stored using:

```c
uint8_t colour = 0;
```

When SW2 is pressed:

```c
colour++;
```

When the end of the colour array is reached:

```c
if (colour >= 4)
{
    colour = 0;
}
```

the sequence returns to Blue.

Therefore:

colour = 0 -> Blue  
colour = 1 -> Red  
colour = 2 -> White  
colour = 3 -> Green  
colour = 0 -> Blue

# Blinking Operation

The program uses:

```c
uint16_t blink_counter = 0;
uint8_t led_state = 0;
```

The counter is incremented continuously:

```c
blink_counter++;
```

When the counter reaches the selected speed value:

```c
if (blink_counter >= speeds[speed])
```

the counter is reset:

```c
blink_counter = 0;
```

The LED state is then toggled.

If the LED is OFF:

```c
led_state = 1;
setLED(colours[colour]);
```

the selected colour is switched ON.

If the LED is ON:

```c
led_state = 0;
setLED(0);
```

the LED is switched OFF.

This produces the blinking effect.

# Switch Debouncing

Mechanical switches do not change cleanly from HIGH to LOW. When a button is pressed or released, the electrical signal can rapidly alternate between states for a short period. This is called switch bouncing.

Without debouncing, one physical button press could be interpreted as several button presses.

The program therefore uses debounce counters:

```c
uint8_t debounce_sw1 = 0;
uint8_t debounce_sw2 = 0;
```

A change in switch state must remain detected for approximately 20 iterations before it is accepted.

```c
if (debounce_sw1 < 20)
{
    debounce_sw1++;
}
else
{
    last_sw1 = sw1;
    debounce_sw1 = 0;
}
```

The same approach is used for SW2.

The purpose is to ensure that a single physical press produces only one logical button event.

# Switch State Variables

The program maintains several variables for each switch.

### Current State

```c
uint8_t sw1_state = 1;
uint8_t sw2_state = 1;
```

A value of 1 represents released, while 0 represents pressed.

### Previous/Debounced State

```c
uint8_t last_sw1 = 1;
uint8_t last_sw2 = 1;
```

These variables store the previously accepted switch readings.

### Debounce Counters

```c
uint8_t debounce_sw1 = 0;
uint8_t debounce_sw2 = 0;
```

These counters are used to filter out switch bounce.

# SW1 — Changing Blink Speed

When only SW1 is pressed:

```c
if (sw1_state == 0 && sw2_state == 1)
```

the speed index is incremented:

```c
speed++;
```

If the end of the speed array is reached, it returns to the first speed:

```c
if (speed >= 3)
{
    speed = 0;
}
```

The switch is then marked as already processed:

```c
sw1_state = 2;
```

This prevents the program from repeatedly changing the speed while the switch remains pressed.

Once SW1 is released:

```c
if (sw1 == 1)
{
    sw1_state = 1;
}
```

the program is ready to detect the next press.

# SW2 — Changing Blink Colour

When only SW2 is pressed:

```c
if (sw2_state == 0 && sw1_state == 1)
```

the colour index is incremented:

```c
colour++;
```

When the end of the colour array is reached:

```c
if (colour >= 4)
{
    colour = 0;
}
```

the colour returns to Blue.

The switch is then marked as processed:

```c
sw2_state = 2;
```

When SW2 is released:

```c
if (sw2 == 1)
{
    sw2_state = 1;
}
```

the next press can be detected.

# LED Control Function

The function:

```c
void setLED(uint8_t value)
```

controls the RGB LED.

```c
GPIO_PORTF_DATA_R =
    (GPIO_PORTF_DATA_R & ~0x0E) | value;
```

The operation first clears PF1–PF3 and then writes the new LED value.

This ensures that the previous colour is removed before the new colour is selected.

For example:

```c
setLED(BLUE)  -> PF2 ON
setLED(RED)   -> PF1 ON
setLED(GREEN) -> PF3 ON
setLED(WHITE) -> PF1 + PF2 + PF3 ON
setLED(0)     -> all RGB LEDs OFF
```

# 1 ms Delay Function

The program contains:

```c
void delay1ms(void)
{
    int j;

    for (j = 0; j < 3180; j++)
    {
    }
}
```

This empty loop provides an approximate delay of 1 ms because of 16MHz CPU clock

The delay is used to:

- Provide timing for the blinking counter.
- Slow down switch polling.
- Make the debounce mechanism practical.

# Both-Switch Operation

When both the switches are pressed then no change in speed or colour.

# Summary

## Program 1

| Switch Condition | LED Output |
|---|---|
| Neither switch pressed | RED |
| SW1 pressed | BLUE |
| SW2 pressed | GREEN |
| Both switches pressed | WHITE |

## Program 2

| Switch | Function |
|---|---|
| SW1 | Change blinking speed |
| SW2 | Change blinking colour |
| Both switches | No speed/colour change |

### Blinking Speeds

Slow -> Medium -> Fast -> Slow -> ...

### Blinking Colours

Blue -> Red -> White -> Green -> Blue -> ...

# Conclusion

The two programs demonstrate how the TM4C123GH6PM microcontroller can interact with physical switches and an RGB LED using direct register-level GPIO programming.


