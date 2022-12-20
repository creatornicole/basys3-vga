`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Hochschule Mittweida
// Engineer: Nicole Gottschall, Fabian Schröer
// 
// Create Date: 19.12.2022 14:29:27
// Design Name: 
// Module Name: vga_pikachu
// Project Name: VGAAbgabe
// Target Devices: Basys3
// Tool Versions: 
// Description: Module displays Pikachu on Monitor using VGA Port of Basys3.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Commented 'Areas' for color wires correspond to created areas for color process. (see extra picture)
// 
//////////////////////////////////////////////////////////////////////////////////
// https://www.kampis-elektroecke.de/fpga/vga-im-fpga-der-vga-controller/

//////////////////////////////////////////////////////////////////////////////////
//Displays Pikachu
//HW_switch[0] flicker mode 
//HW_switch[1] changes background color to blue
//////////////////////////////////////////////////////////////////////////////////

module vga(
    input clk,
    input [1:0]HW_switch, //to manage transition (turn off/on)
    output [3:0]vgaRed, //to display red color
    output [3:0]vgaGreen, //to display green color
    output [3:0]vgaBlue, //to display blue color
    output Vsync, //for vertical synchronisation (Frame Synchronisation)
    output Hsync //for horizontal synchronisation (Line Synchronisation)
    );
    
    ///////// Different Registers to process Synchronisation /////////
    reg VsyncPuls; //for Frame Synchronisation
    reg HsyncPuls; //for Line Synchronisation
    reg [31:0]tick;
    reg [10:0]pixelcounter; //max. needed: 800
    reg [10:0]zeilencounter; //max. needed: 525
    
    ///////// Display and produce different colors /////////
    reg [7:0]durchlauf; //for color transition, max. number: 255
    wire display_ok, red_ok, blue_ok, yellow_ok;
    
    //display_ok = visible area
    assign display_ok = (zeilencounter >= 45) && (pixelcounter > 120); //Pixel == Columns
    
    //yellow_ok has to be assigned to red and green (are the colors that are needed to generate yellow color)
    assign yellow_ok = ((zeilencounter >= 120) && (zeilencounter <= 160) 
            && (((pixelcounter >= 250) && (pixelcounter <= 270)) 
            || (pixelcounter >= 510) && (pixelcounter <= 530))) //Area 1
        || ((zeilencounter >= 130) && (zeilencounter <= 170) 
            && (((pixelcounter >= 270) && (pixelcounter <= 290)) 
            || (pixelcounter >= 490) && (pixelcounter <= 510))) //Area 2
        || ((zeilencounter >= 150) && (zeilencounter <= 170) 
            && (((pixelcounter >= 290) && (pixelcounter <= 310)) 
            || (pixelcounter >= 470) && (pixelcounter <= 490))) //Area 3
        || ((zeilencounter >= 160) && (zeilencounter <= 170) 
            && (((pixelcounter >= 270) && (pixelcounter <= 350)) 
            || ((pixelcounter >= 370) && (pixelcounter <= 410)) 
            || ((pixelcounter >= 430) && (pixelcounter <= 510)))) //Area 4
        || ((zeilencounter >= 170) && (zeilencounter <= 190) 
            && ((pixelcounter >= 270) && (pixelcounter <= 510))) //Area 5
        || ((zeilencounter >= 190) && (zeilencounter <= 210) 
            && ((pixelcounter >= 290) && (pixelcounter <= 490))) //Area 6
        || ((zeilencounter >= 210) && (zeilencounter <= 230) 
            && ((pixelcounter >= 300) && (pixelcounter <= 480))) //Area 12
        || ((zeilencounter >= 230) && (zeilencounter <= 240) 
            && (((pixelcounter >= 290) && (pixelcounter <= 330)) 
            || ((pixelcounter >= 350) && (pixelcounter <= 430)) 
            || ((pixelcounter >= 450) && (pixelcounter <= 490)))) //Area 13
        || ((zeilencounter >= 240) && (zeilencounter <= 260) 
            && (((pixelcounter >= 290) && (pixelcounter <= 320))
            || ((pixelcounter >= 360) && (pixelcounter <= 420))
            || ((pixelcounter >= 460) && (pixelcounter <= 490)))) //Area 14
        || ((zeilencounter >= 260) && (zeilencounter <= 270) 
            && (((pixelcounter >= 290) && (pixelcounter <= 330)) 
            || ((pixelcounter >= 350) && (pixelcounter <= 380)) 
            || ((pixelcounter >= 400) && (pixelcounter <= 430)) 
            || ((pixelcounter >= 450) && (pixelcounter <= 490)))) //Area 15
        || ((zeilencounter >= 270) && (zeilencounter <= 280) 
            && (((pixelcounter >= 280) && (pixelcounter <= 310)) 
            || ((pixelcounter >= 330) && (pixelcounter <= 450)) 
            || ((pixelcounter >= 470) && (pixelcounter <= 500)))) //Area 16
        || ((zeilencounter >= 280) && (zeilencounter <= 290) 
            && (((pixelcounter >= 280) && (pixelcounter <= 300)) 
            || ((pixelcounter >= 340) && (pixelcounter <= 360)) 
            || ((pixelcounter >= 370) && (pixelcounter <= 380)) 
            || ((pixelcounter >= 400) && (pixelcounter <= 410)) 
            || ((pixelcounter >= 420) && (pixelcounter <= 440)) 
            || ((pixelcounter >= 480) && (pixelcounter <= 500)))) //Area 17
        || ((zeilencounter >= 290) && (zeilencounter <= 300) 
            && (((pixelcounter >= 280) && (pixelcounter <= 300)) 
            || ((pixelcounter >= 340) && (pixelcounter <= 370)) 
            || ((pixelcounter >= 410) && (pixelcounter <= 440)) 
            || ((pixelcounter >= 480) && (pixelcounter <= 500)))) //Area 18
        || ((zeilencounter >= 300) && (zeilencounter <= 310) 
            && (((pixelcounter >= 290) && (pixelcounter <= 310)) 
            || ((pixelcounter >= 330) && (pixelcounter <= 370)) 
            || ((pixelcounter >= 410) && (pixelcounter <= 450)) 
            || ((pixelcounter >= 470) && (pixelcounter <= 490)))) //Area 19
        || ((zeilencounter >= 310) && (zeilencounter <= 320) 
            && (((pixelcounter >= 300) && (pixelcounter <= 370)) 
            || ((pixelcounter >= 410) && (pixelcounter <= 480)))) //Area 20
        || ((zeilencounter >= 320) && (zeilencounter <= 330) 
            && (((pixelcounter >= 310) && (pixelcounter <= 380)) 
            || ((pixelcounter >= 400) && (pixelcounter <= 470)))) //Area 21
        || ((zeilencounter >= 330) && (zeilencounter <= 340) 
            && (((pixelcounter >= 330) && (pixelcounter <= 450)))); //Area 22
    
    //white_ok has to be assigned to red, green and blue (are the colors that are needed to generate white color)
    //white for Pikachu's eyes
    assign white_ok = ((zeilencounter >= 240) && (zeilencounter <= 250) 
            && (((pixelcounter >= 340) && (pixelcounter <= 350))
            || ((pixelcounter >= 440) && (pixelcounter <= 450))));
    
    //red for Pikachu's cheeks
    assign red_ok = ((zeilencounter >= 270) && (zeilencounter <= 280) 
            && (((pixelcounter >= 310) && (pixelcounter <= 330)) 
            || ((pixelcounter >= 450) && (pixelcounter <= 470)))) //Red Area of Area 16
        || ((zeilencounter >= 280) && (zeilencounter <= 300) 
            && (((pixelcounter >= 300) && (pixelcounter <= 340)) 
            || ((pixelcounter >= 440) && (pixelcounter <= 480)))) //Red Area of Area 17 and Area 18
        || ((zeilencounter >= 300) && (zeilencounter <= 310) 
            && (((pixelcounter >= 310) && (pixelcounter <= 330)) 
            || ((pixelcounter >= 450) && (pixelcounter <= 470)) //Red Area of Area 19
            || ((pixelcounter >= 380) && (pixelcounter <= 400)))) //Mouth Area 19
        || ((zeilencounter >= 310) && (zeilencounter <= 330)  
            && ((pixelcounter >= 380) && (pixelcounter <= 400))); //Mouth Area 20
        
    //background color if HW_switch[1] is turned on
    assign blue_ok = (zeilencounter >= 46) && (pixelcounter >= 161);
    
    reg [3:0]red;
    reg [3:0]green;
    reg [3:0]blue;
    
    assign vgaRed = red & {4{display_ok}} & ({4{red_ok}} | {4{yellow_ok}} | {4{white_ok}}); //show red color if display is ok and if red or yellow, white color is wanted
    assign vgaGreen = green & {4{display_ok}} & {4{yellow_ok}} | {4{white_ok}}; //show green color if display is ok and if yellow, white color is wanted
    assign vgaBlue = blue & {4{display_ok}} & ({4{blue_ok}} | {4{white_ok}}); ////show blue color if display is ok and if blue or yellow, white color is wanted
    
    ///////// Initialization /////////
    initial
    begin
        VsyncPuls = 0;
        HsyncPuls = 0;
    end
    
    ///////// Generation of Picture /////////
    always@(posedge clk)
    begin
        tick = tick + 1;
    end
    
    always@(posedge tick[1])
    begin
        
        red = (HW_switch[0] && ((durchlauf > 63) && (durchlauf <= 126))) ? 4'b0000 : 4'b1111; //only turn off red color to change appearance of Pikachu if color transition is turned on
        green = (HW_switch[0] && ((durchlauf > 126) && (durchlauf <= 189))) ? 4'b0000 : 4'b1111; //only turn off green color to change appearance of Pikachu if color transition is turned on
        blue = (HW_switch[1]) ? 4'b1111 : 4'b0000;
            
        //runs with 25 MHz = 1 beat per pixel
        //1 beat = 1 pixel
        
        //increment zeilencounter if unequal 525
        if(pixelcounter == 810)
        begin
            zeilencounter = (zeilencounter == 525) ? 0 : zeilencounter + 1;
        end
        
        //increment pixelcounter if unequal 810
        pixelcounter = (pixelcounter == 810) ? 0 : pixelcounter + 1;
        
        //HSync Impuls (Line Synchronisation) (includes Back Porch)
        HsyncPuls <= ((pixelcounter >= 17) && (pixelcounter < 120)) ? 1 : 0; //Sync (with ternary operator, is shorthand for if statement)
        //Vsync Impuls (Frame Synchronisation) (includes Back Porch)
        VsyncPuls <= ((zeilencounter >= 11) && (zeilencounter < 13)) ? 1 : 0; //Sync (with ternary operator, is shorthand for if statement)
        
        //Increment durchlauf if zeilencounter == 525
        if(zeilencounter == 525) if(HW_switch[0]) durchlauf = (durchlauf > 189) ? 0 : durchlauf + 1; //transistion starts where it ended
    end
    
    ///////// Connect registers for synchronisation impuls/////////
    assign Hsync = HsyncPuls;
    assign Vsync = VsyncPuls;
    
endmodule
