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

module memory#(
	// memoria
	parameter width = 11,
	parameter mem_size = 32, // Memory limit is 16 signals
	parameter mem_depth = (1 << width)
)(
	input clk,
	input [mem_size-1:0] mem_dat_i,
	output reg [mem_size-1:0] mem_dat_o,
	input mem_we,
	input [width-1:0] mem_adr
	
);

reg [mem_size-1:0] mem_a [0:mem_depth-1];

always @(posedge clk) begin
	if (mem_we) begin
		mem_a[mem_adr] <= mem_dat_i;
		
	end
	else begin
		mem_dat_o   <= mem_a[mem_adr];
		
	end
end


endmodule
