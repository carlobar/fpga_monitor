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

module DDR_in_buf #(
	parameter size = 16
)
(
	input [size-1:0] D,
	output [size-1:0] Q0,
	input C0,
	input C1,
	input CE,
	input R,
	input S,
	output [size-1:0] Q1
);


genvar i;
generate

	for(i = 0; i<size; i=i+1) begin: ddr_gen
DDR_in_reg ddr_reg(
	.D(D[i]),
	.Q0(Q0[i]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.R(R),
	.S(S),
	.Q1(Q1[i])
);
	end

endgenerate



endmodule
