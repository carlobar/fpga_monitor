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

module graph#(
	parameter samples = 15,
	parameter height = 10'd10,
	parameter data_width = 14
) (
	input clk,
	input  rst,
	input [10:0] x,
	input [9:0] y,
	input [data_width-1:0] state,
	input [data_width-1:0] buf_data,
	output [2:0] rgb_out
);


//reg print;
wire [2:0] rgb_a, rgb_b, rgb_c, rgb_d, rgb_e;


wire change_a, change_b, change_c, change_d, change_e;


assign change_a = |(state[9:8] ^ buf_data[9:8]) ;
assign change_b = |(state[7:6] ^ buf_data[7:6]) ;
assign change_c = |(state[5:4] ^ buf_data[5:4]) ;
assign change_d = |(state[3:2] ^ buf_data[3:2]) ;
assign change_e = |(state[1:0] ^ buf_data[1:0]) ;


// sample clk
	pixel #(
	.bx(1280),
	.by(height),
	.px(0),
	.py(10)
	) pixel_a(
	////.clk(clk),
	.rst(rst),
	.x(x),
	.y(y),
	.state(state[9:8]),
	.change(change_a),
	.rgb(rgb_a)
	);

// clk
//	for(i = 0; i<samples+1; i=i+1) begin: pixel_gen
	pixel #(
	.bx(1280),
	.by(height),
	.px(0),
	.py(40)
	) pixel_b(
	////.clk(clk),
	.rst(rst),
	.x(x),
	.y(y),
	.state(state[7:6]),
	.change(change_b),
	.rgb(rgb_b)
	);
//	end

///endgenerate


// stb
	pixel #(
	.bx(1280),
	.by(height),
	.px(0),
	.py(70)
	) pixel_c(
	//.clk(clk),
	.rst(rst),
	.x(x),
	.y(y),
	.state(state[5:4]),
	.change(change_c),
	.rgb(rgb_c)
	);

// we
	pixel #(
	.bx(1280),
	.by(height),
	.px(0),
	.py(100)
	) pixel_d(
	////.clk(clk),
	.rst(rst),
	.x(x),
	.y(y),
	.state(state[3:2]),
	.change(change_d),
	.rgb(rgb_d)
	);


// dqs
	pixel_vector #(
	.bx(1280),
	.by(height),
	.px(0),
	.py(130)
	) pixel_e(
	////.clk(clk),
	.rst(rst),
	.x(x),
	.y(y),
	.state(state[1:0]),
	.change(change_e),
	.rgb(rgb_e)
	);




assign rgb_out = rgb_a | rgb_b | rgb_c | rgb_d | rgb_e ;

endmodule
