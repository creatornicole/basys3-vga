`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Hochschule Mittweida
// Engineer: Nicole Gottschall, Fabian Schröer
// 
// Create Date: 19.12.2022 14:29:27
// Design Name: 
// Module Name: vga
// Project Name: VGA_Pikachu 
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


module vga(
    input clk,
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
    reg [10:0]pixelcounter; //max.: 800
    reg [10:0]zeilencounter; //max.: 525
    
    ///////// Display and produce different colors /////////
    wire display_ok, red_ok, blue_ok, green_ok, yellow_ok, white_ok;
    
    //reference pixel (is top most left pixel of Pikachu) 
    reg zeile = 9'd120; //9 Bit to display maximum needed number 340
    reg pixel = 9'd250; //9 Bit to display maximum needed number 500
    
    //Reg fuer Verschiebung nach rechts und links (einfach zu zeile hinzu addieren)
    
    //display_ok = visible area
    assign display_ok = (zeilencounter >= 45) && (pixelcounter > 160); //Pixel == Columns
    
    //yellow_ok has to be assigned to red and green (are the colors that are needed to generate yellow color)
    assign yellow_ok = ((zeilencounter >= zeile) && (zeilencounter <= (zeile+20))) 
            && (((pixelcounter >= pixel && (pixelcounter <= (pixel+20))) 
            || (pixelcounter >= (pixel+260)) && (pixelcounter <= (pixel+280)))) //Area 1
        || ((zeilencounter >= (zeile+10) && (zeilencounter <= (zeile+50)) 
            && (((pixelcounter >= (pixel+20)) && (pixelcounter <= (pixel+40))) 
            || (pixelcounter >= (pixel+240)) && (pixelcounter <= (pixel+260)))) //Area 2
        || ((zeilencounter >= (zeile+30)) && (zeilencounter <= (zeile+50)) 
            && (((pixelcounter >= (pixel+40)) && (pixelcounter <= (pixel+60))) 
            || (pixelcounter >= (pixel+220)) && (pixelcounter <= (pixel+270)))) //Area 3
        || ((zeilencounter >= (zeile+40)) && (zeilencounter <= (zeile+50)) 
            && (((pixelcounter >= (pixel+20)) && (pixelcounter <= (pixel+100))) 
            || ((pixelcounter >= (pixel+120)) && (pixelcounter <= (pixel+160))) 
            || ((pixelcounter >= (pixel+180)) && (pixelcounter <= (pixel+260))))) //Area 4
        || ((zeilencounter >= (zeile+50)) && (zeilencounter <= (zeile+70)) 
            && ((pixelcounter >= (pixel+20)) && (pixelcounter <= (pixel+260)))) //Area 5
        || ((zeilencounter >= 190) && (zeilencounter <= 210) 
            && ((pixelcounter >= (pixel+40)) && (pixelcounter <= (pixel+240)))) //Area 6
        || ((zeilencounter >= (zeile+90)) && (zeilencounter <= (zeile+110)) 
            && ((pixelcounter >= (pixel+60)) && (pixelcounter <= (pixel+230)))) //Area 12
        || ((zeilencounter >= (zeile+110)) && (zeilencounter <= (zeile+120)) 
            && (((pixelcounter >= (pixel+40)) && (pixelcounter <= (pixel+80))) 
            || ((pixelcounter >= (pixel+100)) && (pixelcounter <= (pixel+180))) 
            || ((pixelcounter >= (pixel+200)) && (pixelcounter <= (pixel+240))))) //Area 13
        || ((zeilencounter >= (zeile+120)) && (zeilencounter <= (zeile+140)) 
            && (((pixelcounter >= (pixel+40)) && (pixelcounter <= (pixel+70)))
            || ((pixelcounter >= (pixel+110)) && (pixelcounter <= (pixel+170)))
            || ((pixelcounter >= (pixel+210)) && (pixelcounter <= (pixel+240))))) //Area 14
        || ((zeilencounter >= (zeile+140)) && (zeilencounter <= (zeile+150)) 
            && (((pixelcounter >= (pixel+40)) && (pixelcounter <= (pixel+80))) 
            || ((pixelcounter >= (pixel+100)) && (pixelcounter <= (pixel+130))) 
            || ((pixelcounter >= (pixel+150)) && (pixelcounter <= (pixel+180))) 
            || ((pixelcounter >= (pixel+200)) && (pixelcounter <= (pixel+240))))) //Area 15
        || ((zeilencounter >= (zeile+150)) && (zeilencounter <= (zeile+160)) 
            && (((pixelcounter >= (pixel+30)) && (pixelcounter <= (pixel+60))) 
            || ((pixelcounter >= (pixel+80)) && (pixelcounter <= (pixel+200))) 
            || ((pixelcounter >= (pixel+220)) && (pixelcounter <= (pixel+250))))) //Area 16
        || ((zeilencounter >= (zeile+160)) && (zeilencounter <= (zeile+170)) 
            && (((pixelcounter >= (pixel+30)) && (pixelcounter <= (pixel+250))) 
            || ((pixelcounter >= (pixel+90)) && (pixelcounter <= (pixel+110))) 
            || ((pixelcounter >= (pixel+120)) && (pixelcounter <= (pixel+130))) 
            || ((pixelcounter >= (pixel+150)) && (pixelcounter <= (pixel+160))) 
            || ((pixelcounter >= (pixel+170)) && (pixelcounter <= (pixel+190))) 
            || ((pixelcounter >= (pixel+230)) && (pixelcounter <= (pixel+250))))) //Area 17
        || ((zeilencounter >= (zeile+170)) && (zeilencounter <= (zeile+180)) 
            && (((pixelcounter >= (pixel+30)) && (pixelcounter <= (pixel+50))) 
            || ((pixelcounter >= (pixel+90)) && (pixelcounter <= (pixel+120))) 
            || ((pixelcounter >= (pixel+160)) && (pixelcounter <= (pixel+190))) 
            || ((pixelcounter >= (pixel+230)) && (pixelcounter <= (pixel+250))))) //Area 18
        || ((zeilencounter >= (zeile+180)) && (zeilencounter <= (zeile+190)) 
            && (((pixelcounter >= (pixel+40)) && (pixelcounter <= (pixel+60))) 
            || ((pixelcounter >= (pixel+80)) && (pixelcounter <= (pixel+120))) 
            || ((pixelcounter >= (pixel+160)) && (pixelcounter <= (pixel+200))) 
            || ((pixelcounter >= (pixel+220)) && (pixelcounter <= (pixel+240))))) //Area 19
        || ((zeilencounter >= (zeile+190)) && (zeilencounter <= (zeile+200)) 
            && (((pixelcounter >= (pixel+50)) && (pixelcounter <= (pixel+120))) 
            || ((pixelcounter >= (pixel+160)) && (pixelcounter <= (pixel+230))))) //Area 20
        || ((zeilencounter >= (zeile+200)) && (zeilencounter <= (zeile+210)) 
            && (((pixelcounter >= (pixel+60)) && (pixelcounter <= (pixel+130))) 
            || ((pixelcounter >= (pixel+150)) && (pixelcounter <= (pixel+220))))) //Area 21
        || ((zeilencounter >= (zeile+210)) && (zeilencounter <= (zeile+220)) 
            && (((pixelcounter >= (pixel+80)) && (pixelcounter <= (pixel+200)))))); //Area 22
    
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
            || ((pixelcounter >= 450) && (pixelcounter <= 470)))); //Red Area of Area 19
    
    //TODO: | or ||?
    assign vgaRed = 4'b1111 & {4{display_ok}} & ({4{red_ok}} | {4{yellow_ok}} | {4{white_ok}}); //show red color if display is ok and if red or yellow color is wanted
    assign vgaGreen = 4'b1111 & {4{display_ok}} & ({4{green_ok}} | {4{yellow_ok}} | {4{white_ok}}); //show green color if display is ok and if green or yellow color is wanted
    assign vgaBlue = 4'b1111 & {4{display_ok}} & ({4{blue_ok}} | {4{white_ok}}); ////show blue color if display is ok and if blue or yellow color is wanted
    
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
        //runs with 25 MHz = 1 beat per pixel
        //1 beat = 1 pixel
        
        pixelcounter = pixelcounter + 1; //increment pixelcounter
        
        //HSync Impuls (Line Synchronisation)
        if(pixelcounter == 17)  HsyncPuls <= 1; //Sync
        if(pixelcounter == 113) HsyncPuls <= 0; //Back Porch
        
        //Vsync Impuls (Frame Synchronisation)
        if(zeilencounter == 11) VsyncPuls <= 1; //Sync
        if(zeilencounter == 13) VsyncPuls <= 0; //Back Porch
        
        //Reset pixelcounter
        if(pixelcounter == 800)
        begin
            pixelcounter = 0; //reset
            zeilencounter = zeilencounter + 1; //new line
        end
        
        //Reset zeilencounter
        if(zeilencounter == 525) zeilencounter = 0;
    end
    
    ///////// Connect registers for synchronisation /////////
    assign Hsync = HsyncPuls;
    assign Vsync = VsyncPuls;
    
endmodule
