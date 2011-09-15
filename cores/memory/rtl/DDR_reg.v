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

module DDR_reg (
	input D0,
	input D1,
	input C0,
	input C1,
	input CE,
	input R,
	input S,
	output reg Q
);

wire Q1, Q0;



///////////////////////////////////////////////

flip_flop_d ffD0(
	.D(D0),
	.clk(C0),
	.ce(CE),
	.reset(R),
	.set(S),
	.Q(Q0)
);


flip_flop_d ffD1(
	.D(D1),
	.clk(C1),
	.ce(CE),
	.reset(R),
	.set(S),
	.Q(Q1)
);

//////////////////////////////////////////////////////

wire q_1, q_2, sel;

flip_flop_d reg_1(
	.D(~q_2),
	.clk(C0),
	.ce(CE),
	.reset(R),
	.set(S),
	.Q(q_1)
);


flip_flop_d reg_2(
	.D(q_1),
	.clk(C1),
	.ce(CE),
	.reset(R),
	.set(S),
	.Q(q_2)
);


assign sel = q_1 ~^ q_2;
/////////////////////////////////////////////////


always @(*) begin
	case (sel)
		1'b0:
			Q = Q0;
		1'b1:
			Q = Q1;
	endcase
end



endmodule
