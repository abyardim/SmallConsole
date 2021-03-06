# SmallConsole
Simple synthesizable console with a custom CPU, designed for the BASYS 3 board. It has tiled VGA output and is controlled by a classic NES controller connected through the PMOD pins.

A [video](https://www.youtube.com/watch?v=EfJV1adBH6E) describing the project.

## The processor
The device has a 16-bit processor designed specifically for it, with a custom straightforward instruction set.

## The controller
The device can be controlled by a NES controller, the output being mapped to a memory address. The current state of the controller can be obtained through a memory read.

## Graphics
The device has a simplistic graphics processor, which tiles the screen into 32x32 parts. Each part can be assigned a tile from the tile palette in memory.

## The assembler
There is a basic assembler written in Java which generates bit values from a file that contains proper assembly code, simplifying the development process of games.

## Extensibility
The processor uses a memory mapped IO model for communication with sceondary parts, so custom graphics modules and IO devices can be implemented by simply writing memory mappers. 

