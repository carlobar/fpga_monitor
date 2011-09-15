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


module pixel_vector #(
	parameter bx = 11'd10,
	parameter by = 10'd10,
	parameter px = 11'd10,
	parameter py = 10'd10
)(
//	input clk,
	input rst,
	input [10:0] x,
	input [9:0] y,
	input [1:0] state,
	output reg [2:0] rgb,
	input change
);

reg active;
/*
assign b_x_ = bx;
assign p_x_ = px;


wire [9:0] b_y_, p_y_;
assign b_y_ = by;
assign p_y_ = py;

*/

always @(*) begin
	if((y == py) & (x > px) & (x < (px+bx)) & ((state == 2'b01) | (state == 2'b10)))
		active <= 1'b1;
	else if ((y < (py+by)) & (y > py) & change)
		active <= 1'b1;
	else if ((y < (py+by)) & (y > py) & (x > px) & (x < (px+bx)) & ((state == 2'b01) | (state == 2'b10)) )
		active <= 1'b1;
	else if ((y == (py+by)) & (x > px) & (x <= (px+bx)) & (state == 2'b00))
		active <= 1'b1;
	else if ((y == py+by/2) & (x < (px+bx)) & (x > px) & ((state == 2'b11) | (state == 2'b11)))
		active <= 1'b1;
	else
		active <= 1'b0;
end




always @(*) begin
	if (rst)
		rgb <= 3'b000;
	else begin
		if ((state == 2'b00) & active)
			rgb <= {1'b0,1'b1,1'b0};		// green
		else if (state == 2'b01 & active)
			rgb <= {1'b0, 1'b0, 1'b1};	// blue
		else if (state == 2'b10 & active)
			rgb <= {1'b1, 1'b0, 1'b1};	// magenta
		else if (active)
			rgb <= {1'b1, 1'b0, 1'b0};	// red
		else
			rgb <= 3'b0;
	end	
end


endmodule
