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

module flip_flop_d (
	input D,
	input clk,
	input ce,
	input reset,
	input set,
	output reg Q
);

always @(posedge clk) begin
	if(reset)
		Q <= 1'b0;
	else if (set)
		Q <= 1'b1;
	else if (~reset & ~set & ce)
		Q <= D;
	else if (~reset & ~set & ~ce)
		Q <= Q;
	else
		Q <= Q;
end

endmodule
