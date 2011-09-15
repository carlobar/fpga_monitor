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

module rot_button (
	input clk,
	input rst,
	input [1:0] rot,
	output reg event_,
	output reg right_

);

reg a,b, a_delay, b_delay;

always @(posedge clk) begin
	if (rst) begin
		a <= 1'b1;
		b <= 1'b1;
		a_delay <= 1'b1;
		b_delay <= 1'b1;
	end
	else begin
		a <= rot[0];
		b <= rot[1];
		a_delay <= a;
		b_delay <= b;
	end
end


parameter [3:0] idle = 0, s1 = 1, s2 = 2, s3 = 3, s4 = 4, s5 = 5, s6 = 6, s_notify_right = 7, s_notify_left = 8;
reg [3:0] state;
reg [3:0] next_state;


always @(posedge clk) begin
	if(rst) 
		state <= idle;
	else
		state <= next_state;
end

always @(*) begin
	next_state = state;
	case(state)
		idle: begin
			if((a & ~b) & (a_delay & b_delay))
				next_state = s1;
			else if (~a & b & (a_delay & b_delay))
				next_state = s4;
			else
				next_state = state;
		end
		


		//// right
		s1: begin
			if (~a & a_delay & ~b & ~b_delay)
				next_state = s2;
			else if (b & a)
				next_state = idle;
			else
				next_state = state;
		end
		s2: begin
			if (b & ~b_delay & ~a & ~a_delay)
				next_state = s3;
			else
				next_state = state;
		end
		s3: begin
			if (a & ~a_delay & b & b_delay)
				next_state = s_notify_right;
			else
				next_state = state;
		end

		s_notify_right: begin
			next_state = idle;
		end

		///// left
		s4: begin
			if (~b & b_delay & ~a & ~a_delay)
				next_state = s5;
			else if (a & b)
				next_state = idle;
			else
				next_state = state;
		end
		s5: begin
			if (a & ~a_delay & ~b & ~b_delay)
				next_state = s6;
			else
				next_state = state;
		end
		s6: begin
			if (b & ~b_delay & a & a_delay)
				next_state = s_notify_left;
			else
				next_state = state;
		end	
		s_notify_left: begin
			next_state = idle;
		end
	endcase
end



always @(*) begin
	case(state)
		idle: begin
			event_ = 1'b0;
			right_ = 1'b0;
		end
		s1: begin
			event_ = 1'b0;
			right_ = 1'b0;
		end
		s2: begin
			event_ = 1'b0;
			right_ = 1'b0;
		end
		s3: begin
			event_ = 1'b0;
			right_ = 1'b0;
		end
		s4: begin
			event_ = 1'b0;
			right_ = 1'b0;
		end
		s5: begin
			event_ = 1'b0;
			right_ = 1'b0;
		end
		s6: begin
			event_ = 1'b0;
			right_ = 1'b0;
		end
		s_notify_right: begin
			event_ = 1'b1;
			right_ = 1'b1;
		end
		s_notify_left: begin
			event_ = 1'b1;
			right_ = 1'b0;
		end
		default: begin
			event_ = 1'b0;
			right_ = 1'b0;

		end
	endcase
end




endmodule
