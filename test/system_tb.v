/*
    Copyright 2011 Carlos Barreto	

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

`timescale 1ns/1ps

module system_tb();


 initial begin
     $dumpfile("system_tb.vcd");
     $dumpvars(0,system_tb);
     #1200000 $finish;

  end


reg sys_clk;
reg resetin;

wire hsync,vsync;
wire [2:0] rgb_final;

initial sys_clk = 1'b0;
always #10 sys_clk = ~sys_clk;

initial begin
	resetin = 1'b1;
	#20 resetin = 1'b0;  
end

reg sw;
initial begin
	sw = 4'd1;
//	#600 
//	sw = 4'd0;
end


system system (
	.clk_in(sys_clk),
	.reset_in(resetin),
		// VGA
	.vga_hsync(hsync),
	.vga_vsync(vsync),
	.rgb(rgb_final),
	.sw(sw)
	// GPIO
	//.btn    // 3
);


endmodule
