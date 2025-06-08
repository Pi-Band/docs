# Pimoroni Blinkt! via Remote GPIO

This folder contains:

- Pimoroni's blinkt module refactored to use gpiozero (instead of RPi.GPIO), for controlling GPIO pins on a remote Pi (remote_blink/blinkt.py)
- Examples (1d_tetris.py, binary_clock_meld.py, keystroke.py, kitt.py, rainbow.py)

<br />

## Requirements

- Raspberry Pi set up as [remote GPIO device](https://github.com/Pi-Band/docs/wiki/Do:-Remote-GPIO#set-up-raspberry-pi) and with [Primoroni Blinkt! attached](https://github.com/Pi-Band/docs/wiki/HATs:-Pimoroni-Blinkt!#installation-of-pimoroni-blinkt). No need to have Pimoroni's Blinkt library installed.
- A computer set up as [controller computer](https://github.com/Pi-Band/docs/wiki/Do:-Remote-GPIO#set-up-the-controller-computer).


<br />

## Installation

**On the controller computer:**

1. Create a new project directory and set up a Python virtual environment in the directory e.g.

   ```
   mkdir my-blinkt-project && cd my-blinkt-project
   python3 -m venv --system-site-packages .virtualenv
   ```

   Feel free to skip this step if you already have a project directory you want to use and have a Python virtual envrionment set up in the directory.

1. Install **gpiozero** and **pigpio** in the virtual environment e.g.

   ```
   .virtualenv/bin/pip install gpiozero pigpio
   ```

1. Download this **blinkt** folder to the root of your project directory e.g.

   ```
   my-blinkt-project
   ├── .virtualenv
   └── blinkt
      ├── 1d_tetris.py
      ├── binary_clock_meld.py
      ├── keystroke.py
      ├── kitt.py
      ├── rainbow.py
      ├── README.md
      └── remote_blinkt
          ├── blinkt.py
          └── __init__.py
   ```

<br />

## Running examples

A few examples are included in the **blinkt** folder. Note that some examples may require additional packages to be installed, and in which case, you will see an error message with instructions in your terminal window.

**On the controller computer:**

1. Verify that your Raspberry Pi with Pimoroni Blinkt! attached is accessbile.

   ```
   ping YOUR_BLINKT_PI_HOSTNAME.local
   ```

   `YOUR_BLINKT_PI_HOSTNAME` should be replaced with the hostname of your Raspberry Pi with Pimoroni Blinkt! attached.

   For example, with the hostname **blinkitteh**:

   ```
   ping blinkitteh.local
   ```

   You should see an output like this:

   ```
   PING blinkitteh.local (10.42.0.20) 56(84) bytes of data.
   64 bytes from 10.42.0.20 (10.42.0.20): icmp_seq=1 ttl=64 time=0.238 ms
   64 bytes from 10.42.0.20 (10.42.0.20): icmp_seq=2 ttl=64 time=0.387 ms
   ...
   ```

1. Activate the virtual environment in your project directory e.g.

   ```
   source .virtualenv/bin/activate
   ```

1. Run an example.

   In order for the examples to connect to your Raspberry Pi with Pimoroni Blinkt! attached, you will need to specify the hostname or IP address of the Pi by setting an envrionment variable called **PIGPIO_ADDR** like this:

   ```
   PIGPIO_ADDR=YOUR_BLINKT_PI_ADDRESS python EXAMPLE.py
   ```

   `EXAMPLE` should be replaced by the filename of the example you wish to run, and `YOUR_BLINKT_PI_ADDRESS` should be replaced with the hostname or IP address of your Raspberry Pi with Pimoroni Blinkt! attached e.g.

   To run the rainbow example using hostname:

   ```
   PIGPIO_ADDR=blinkitteh.local python rainbow.py
   ```

   Or using IP address:

   ```
   PIGPIO_ADDR=10.42.0.20 python rainbow.py
   ```

<br />

## Running Pimoroni's Blinkt! examples

To run [the examples provided in Pimoroni's Blinkt repository](https://github.com/pimoroni/blinkt/tree/master/examples), you will need to make one small adjustment.

**On the controller computer:**

1. Download/copy the example(s) you want to run to the root of your project directory alongside the examples provided in this **blinkt** folder e.g.

   ```
   my-blinkt-project
   ├── .virtualenv
   └── blinkt
      ├── 1d_tetris.py
      ├── binary_clock_meld.py
      ├── keystroke.py
      ├── kitt.py
      ├── morse_code.py             <-- downloaded
      ├── rainbow.py
      ├── random_blink_colours.py   <-- downloaded
      ├── README.md
      └── remote_blinkt
          ├── blinkt.py
          └── __init__.py
   ```

1. Open each of the downloaded example file(s) in a code or plain text editor, and replace the line:

   ```
   import blinkt
   ```
   
   with:
   
   ```
   from remote_blinkt import blinkt
   ```

1. Run the example(s) following the guide in [Running examples](#running-examples) section above.
