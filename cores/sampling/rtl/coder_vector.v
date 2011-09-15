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

module coder_vector #(
	parameter size = 16,
	parameter data_a = 16'habad,
	parameter data_b = 16'hface
)(
	input [size-1:0] data,
	output reg [1:0] out
);




always @(*) begin
	case(data)
		{size{1'b0}}:
			out = 2'b00;
		data_a:
			out = 2'b01;
		data_b:	
			out = 2'b10;
		default:
			out = 2'b11;
	endcase
end


endmodule
