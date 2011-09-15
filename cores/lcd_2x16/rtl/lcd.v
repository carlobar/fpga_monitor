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

module lcd #(
	parameter	width_timer  =	18,
	parameter	timer_135k   =	7,
	parameter	timer_40ms   =	750000,	// 15ms
	parameter	timer_37us   =	10,
	parameter	timer_100us   =	27,
	parameter	timer_1_52ms =	411,
	parameter	timer_1us    =  1,
	parameter	timer_4_1ms    =  1094,
	parameter	timer_500ms  = 135136

)  (
	input	sf_byte,
	input 	[31:0]	buffer_data,
	input 	[31:0]	buffer_data_b,
	input 	rst,
	input 	clkin,
	output	reg	e,
	output	reg	rs,
	output	reg	rw,
	inout	[3:0]	data_io // in out?????? reg[3:0]

);



BUFG lcd_clk(
	.I(clkin),
	.O(clk)
);



reg [7:0] load_data;
reg [3:0] load_data_raw;

reg rs_, rw_;

reg enable_check;

reg [3:0] data;
reg [7:0] busy_data;

reg	[7:0]	data_bus;

parameter [1:0] idle = 0, upper_data = 1, lower_data = 2, delay =3;
reg 	[1:0] state_instr;
reg 	[1:0] next_state_instr;

parameter [7:0] null_ = 0, start = 1, function_set_1 = 2, function_set_2 = 3, function_set_3 = 4, display_on_off = 5, display_clear = 6, entry_mode = 7,  start_write = 8, check_busy = 9, return_home = 10, write_data = 11, wait_37us = 12,  wait_1_52ms = 13,   wait_refresh = 14, busy_delay_1 = 15, busy_delay_2 = 16,  function_set_1_a = 17,  function_set_1_b = 18, wait_4_1ms = 19, wait_100us = 20, change_addr = 21; 

//parameter [7:0]  , set_addr = 2, write = 3, read_data = 4, function_set = 5,  ;

reg	[7:0]	state, next_state, jump_state, jmp_state;

reg [width_timer-1:0] count_e;

reg [width_timer-1:0] count_clk_270k;
reg	clk_270k;

reg [width_timer-1:0] count_40ms;
reg	_40ms_done;

reg [width_timer-1:0] count_1_52ms;
reg	_1_52ms_done;

reg [width_timer-1:0] count_37us;
reg	_37us_done;

reg [width_timer-1:0] count_100us;
reg	_100us_done;

reg [width_timer-1:0] count_500ms;
reg	_500ms_done;

reg [width_timer-1:0] count_4_1ms;
reg	_4_1ms_done;

reg enable_instr;

reg	enable_timer_40ms;
reg	enable_timer_37us;
reg	enable_timer_100us;
reg	enable_timer_1_52ms;	
reg	enable_timer_500ms;
reg	enable_timer_4_1ms;



reg end_instr;

reg [6:0] addr_ddram;

initial begin
	addr_ddram = 0;	
end

/// impementar buffers

assign data_io = (enable_check) ?  4'bz : data;
/*
always @(*) begin
	if(enable_check)
		data_r = data_io;
	else
		data_r = 4'bZ;
end
*/

// relog a 270k
always @(posedge clk) begin
	if(rst) begin
		count_clk_270k <= 0;
		clk_270k <= 1;
	end
	else if(count_clk_270k == timer_135k) begin
		count_clk_270k <= 0;
		clk_270k <= ~clk_270k;
	end else begin
		count_clk_270k <= count_clk_270k + 1'b1;
		clk_270k <= clk_270k;
	end
end





// timer de 40ms
always @(posedge clk_270k) begin
	if(enable_timer_40ms) begin
		if(count_40ms == timer_40ms) begin
			_40ms_done <= 1;
			count_40ms <= 0;
		end else begin
			_40ms_done <= 0;
			count_40ms <= count_40ms+1'b1;
		end
	end else begin
		_40ms_done <= 0;
		count_40ms <= 0;
	end
end


// timer de 37us
always @(posedge clk_270k) begin
	if(enable_timer_37us) begin
		if(count_37us == timer_37us) begin
			_37us_done <= 1;
			count_37us <= 0;
		end else begin
			_37us_done <= 0;
			count_37us <= count_37us+1'b1;
		end
	end else begin
		_37us_done <= 0;
		count_37us <= 0;
	end
end


// timer de 100us
always @(posedge clk_270k) begin
	if(enable_timer_100us) begin
		if(count_100us == timer_100us) begin
			_100us_done <= 1;
			count_100us <= 0;
		end else begin
			_100us_done <= 0;
			count_100us <= count_100us+1'b1;
		end
	end else begin
		_100us_done <= 0;
		count_100us <= 0;
	end
end


// timer 1,52ms
always @(posedge clk_270k) begin
	if(enable_timer_1_52ms) begin
		if(count_1_52ms == timer_1_52ms) begin
			_1_52ms_done <= 1;
			count_1_52ms <= 0;
		end else begin
			_1_52ms_done <= 0;
			count_1_52ms <= count_1_52ms+1'b1;
		end
	end else begin
		_1_52ms_done <= 0;
		count_1_52ms <= 0;
	end
end

// timer 500ms
always @(posedge clk_270k) begin
	if(enable_timer_500ms) begin
		if(count_500ms == timer_500ms) begin
			_500ms_done <= 1;
			count_500ms <= 0;
		end else begin
			_500ms_done <= 0;
			count_500ms <= count_500ms+1'b1;
		end
	end else begin
		_500ms_done <= 0;
		count_500ms <= 0;
	end
end

// timer 4.1ms
always @(posedge clk_270k) begin
	if(enable_timer_4_1ms) begin
		if(count_4_1ms == timer_4_1ms) begin
			_4_1ms_done <= 1;
			count_4_1ms <= 0;
		end else begin
			_4_1ms_done <= 0;
			count_4_1ms <= count_4_1ms+1'b1;
		end
	end else begin
		_4_1ms_done <= 0;
		count_4_1ms <= 0;
	end
end


always @(posedge clk_270k) begin
	if(rst)	begin
		state <= null_;
		jmp_state <= null_;
	end
	else	begin
		state <= next_state;
		jmp_state <= jump_state;
	end	
end


always @(posedge clk_270k) begin
		if(rst)	begin

		state_instr <= idle;

	end
	else	begin

		state_instr <= next_state_instr;

	end
end



// decide next state
always @(*) begin
	next_state = state;
	case(state)
		null_: begin
			jump_state = jmp_state;
			next_state = start;
		end
			
		start: begin		// 40ms delay
			jump_state = jmp_state;
			if(_40ms_done)
				next_state = function_set_1;
			else
				next_state = start;
		end

		function_set_1: begin
			if(state_instr == upper_data) begin //state_instr == upper_data
				next_state = wait_4_1ms;//wait_4_1ms
				jump_state = function_set_1_a;
			end else begin
				next_state = function_set_1;
				jump_state = jmp_state;
			end
		end
		function_set_1_a: begin
			if(state_instr == upper_data) begin
				next_state = wait_100us;
				jump_state = function_set_1_b;
			end else begin
				next_state = function_set_1_a;
				jump_state = jmp_state;
			end
		end
		function_set_1_b: begin
			if(state_instr == upper_data) begin
				next_state = wait_37us;//wait_37us
				jump_state = function_set_2;
			end else begin
				next_state = function_set_1_b;
				jump_state = jmp_state;
			end
		end
		function_set_2: begin
			if(state_instr == upper_data) begin //state_instr == upper_data
				next_state = wait_37us;//wait_37us
				jump_state = function_set_3;
			end else begin
				next_state = function_set_2;
				jump_state = jmp_state;
			end
		end

		function_set_3: begin
			if(end_instr) begin
				next_state = wait_37us;//wait_37us
				jump_state = display_on_off;
			end else begin
				next_state = function_set_3;
				jump_state = jmp_state;
			end
		end
		display_on_off: begin
			if(end_instr) begin
				next_state = wait_37us;//wait_37us
				jump_state = display_clear;
			end else begin
				next_state = display_on_off;
				jump_state = jmp_state;			
			end
		end

		display_clear: begin
			if(end_instr) begin
				next_state = wait_1_52ms;//wait_1_52ms
				jump_state = entry_mode;
			end else begin
				next_state = display_clear;
				jump_state = jmp_state;
			end
		end
		
		entry_mode: begin
			if(end_instr) begin
				next_state = wait_37us;
				jump_state = start_write;
			end else begin
				next_state = entry_mode;
				jump_state = jmp_state;
			end
		end


// write process:
		start_write: begin
			
			if((addr_ddram > 7'h9) && (addr_ddram < 7'hb)) begin// & (addr_ddram < 7'h39)
				next_state = busy_delay_1;
				jump_state = change_addr;
			end
			else if((addr_ddram > 7'h49)) begin
				jump_state = write_data;
				next_state = wait_refresh;
			end
			else begin
				jump_state = write_data;
				next_state = busy_delay_1;//check_busy
			end

		end

		
		return_home: begin
			if(end_instr) begin
				next_state = wait_1_52ms;
				jump_state = jmp_state;
			end else begin
				next_state = return_home;
				jump_state = jmp_state;
			end
		end

		busy_delay_1: begin
			jump_state = jmp_state;
			if(_37us_done)
				next_state = busy_delay_2;
			else
				next_state = busy_delay_1;
		end

		busy_delay_2: begin
			jump_state = jmp_state;
			if(_37us_done)
				next_state = check_busy;
			else
				next_state = busy_delay_2;
		end

		check_busy: begin
			if(end_instr) begin
				if(busy_data[7] != 1'b1) begin	//busy_data[7] != 1'b1
					jump_state = jmp_state;
					next_state = wait_37us;
				end
				else begin
					next_state = busy_delay_1;
					jump_state = jmp_state;
				end
			end else begin
				next_state = check_busy;
				jump_state = jmp_state;			
			end
		end


		write_data:begin
			if(end_instr) begin
				next_state = wait_37us;
				jump_state = start_write;
			end else begin
				next_state = write_data;
				jump_state = jmp_state;
			end			
		end 
		
		change_addr: begin
			jump_state = start_write;
			if(end_instr) begin
				next_state = wait_37us;
			end else begin
				next_state = change_addr;
			end
		end

			
		wait_refresh: begin
			jump_state = start_write;
			if(_500ms_done)
				next_state = return_home;
			else
				next_state = wait_refresh;
		end
		
		wait_37us: begin
			jump_state = jmp_state;
			if(_37us_done)
				next_state = jmp_state;
			else
				next_state = wait_37us;
		end

		wait_100us: begin
			jump_state = jmp_state;
			if(_100us_done)
				next_state = jmp_state;
			else
				next_state = wait_100us;
		end

		wait_1_52ms: begin
			jump_state = jmp_state;
			if(_1_52ms_done)
				next_state = jmp_state;
			else
				next_state = wait_1_52ms;
		end

		wait_4_1ms: begin
			jump_state = jmp_state;
			if(_4_1ms_done)
				next_state = jmp_state;
			else
				next_state = wait_4_1ms;
		end
		

	endcase
end



// outputs in each state
always @(*) begin
	case(state)
		null_: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 0;
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;	
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b0 && ~sf_byte;		
		end
		start: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 0;
			enable_timer_40ms = 1'b1;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b0 && ~sf_byte;		
		end
		function_set_1: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 8'b00110011;//8'b00110011
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b1 && ~sf_byte;
		end

		function_set_1_a: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 8'b00110011;
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b1 && ~sf_byte;
		end

		function_set_1_b: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 8'b00110011;
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b1 && ~sf_byte;
		end


		function_set_2: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 8'b00101000;		// select 2 lines and 5x8 dots
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b1 && ~sf_byte;
		end
		function_set_3: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 8'b00101000;		// select 2 lines and 5x8 dots
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b1 && ~sf_byte;
		end
		display_on_off: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 8'b00001111;		// display on, cursor and cursor position off
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b1 && ~sf_byte;
		end

		display_clear: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 8'b00000001;		
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b1 && ~sf_byte;
		end
		
		entry_mode: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 8'b00000110;		//auto increment
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b1 && ~sf_byte;
		end
		start_write: begin		// null outputs
			rs_ = 0;
			rw_ = 0;
			data_bus = 0;
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;	
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b0 && ~sf_byte;	
		end
		write_data: begin
			rs_ = 1;
			rw_ = 0;
			data_bus = load_data;		
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b1 && ~sf_byte;			
		end

		return_home: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 8'b00000010;		
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b1 && ~sf_byte;			
		end
		

		change_addr: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 8'b11000000;
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b1 && ~sf_byte;
		end

		check_busy: begin
			rs_ = 0;
			rw_ = 1;
			data_bus = 8'b0;
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b1 && ~sf_byte;			
		end

		busy_delay_1: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 0;
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b1;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b0 && ~sf_byte;		
		end

		busy_delay_2: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 0;
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b1;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b0 && ~sf_byte;		
		end

		wait_37us: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 0;
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b1;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b0 && ~sf_byte;		
		end

		wait_100us: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 0;
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b1;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b0 && ~sf_byte;		
		end

		wait_1_52ms: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 0;
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b1;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b0 && ~sf_byte;		
		end
		wait_4_1ms: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 0;
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b1;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b0 && ~sf_byte;		
		end


		wait_refresh: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 0;
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b1;
			enable_instr = 1'b0 && ~sf_byte;		
		end
		default: begin
			rs_ = 0;
			rw_ = 0;
			data_bus = 0;
			enable_timer_40ms = 1'b0;
			enable_timer_37us = 1'b0;
			enable_timer_100us = 1'b0;
			enable_timer_1_52ms = 1'b0;
			enable_timer_4_1ms = 1'b0;
			enable_timer_500ms = 1'b0;
			enable_instr = 1'b0 && ~sf_byte;	
		end

	endcase
end


always @(*) begin
	if(enable_instr) begin
		case(state_instr)
			idle: begin
				next_state_instr = upper_data;
			end
			upper_data: begin	
				next_state_instr = delay;//delay;
			end
			delay: begin	
				next_state_instr = lower_data;
			end
			lower_data: begin
				next_state_instr = idle;
			end
			default: begin
				next_state_instr = idle;
			end
		endcase
	end else
		next_state_instr = idle;
end


always @(posedge clk) begin

	if(enable_instr) begin
	case(state_instr)
		idle: begin
//			e <= 0
			rs <= 0;
			rw <= 0;
			data <= 4'b0;
			busy_data <= 8'b0;
			end_instr <= 1'b0;
		end
		upper_data: begin
//			e <= 1;
			rs <= rs_;
			rw <= rw_;
			data <= data_bus[7:4];
			busy_data <= {data_io,{4{1'b0}}};
			end_instr <= 1'b0;
		end
		delay: begin
//			e <= 0;
			rs <= rs_;
			rw <= rw_;
			data <= data;
			busy_data <= busy_data;
			end_instr <= 1'b0;
		end
		lower_data: begin
//			e <= 1;
			rs <= rs_;
			rw <= rw_;
			data <= data_bus[3:0];
			busy_data <= {busy_data[7:4],data_io};
			end_instr <= 1'b1;
		end
		default: begin
			data <= 4'b0;
			rs <= 0;
			rw <= 0;
			busy_data <= 8'b0;
			end_instr <= 0;
		end
	endcase
	end else begin
			data <= 4'b0;
			rs <= 0;
			rw <= 0;
			busy_data <= 8'b0;
			end_instr <= 0;
	end
		
end
/*
always @(posedge clk) begin
	e <= | count_e;
	if(((state_instr == upper_data) || (state_instr == lower_data)) && enable_instr && ~sf_byte ) begin
		if((count_clk_270k==timer_1us/2) && (count_e == 0) && clk_270k) begin
			count_e <= 1;
		end1111
		else if(count_e == (2*timer_135k-timer_1us)) begin
			count_e <= 0;
		end
		else if(count_e >= 1) begin
			count_e <= count_e + 1'b1;
		end
		else begin
			count_e <= count_e;
		end
	end
	else
		count_e <= 0;
end
*/

always @(posedge clk) begin
	e <= | count_e;
	if(((state_instr == upper_data) || (state_instr == lower_data)) && enable_instr && ~sf_byte ) begin
		if((count_clk_270k==2) && (count_e == 0) && clk_270k) begin
			count_e <= 1;
		end
		else if(count_e == 13) begin
			count_e <= 0;
		end
		else if(count_e >= 1) begin
			count_e <= count_e + 1'b1;
		end
		else begin
			count_e <= count_e;
		end
	end
	else
		count_e <= 0;
end

always @(*) begin
	case(state)
		check_busy: begin
			enable_check = 1'b1;
		end
		default: begin
			enable_check = 1'b0;
		end
		
	endcase
end


always @(posedge clk_270k) begin

	if((state == write_data) && (state_instr == lower_data)) begin
		addr_ddram <= addr_ddram+1'b1;
	end
	else if (state == change_addr)
		addr_ddram <= 7'h40;
	else if (state == wait_refresh)
		addr_ddram <= 0;
	else
		addr_ddram <= addr_ddram;
	
end

// conversion de datos
always @(*) begin
	if(addr_ddram < 7'h2) begin
	case(addr_ddram)
		7'h0: begin
			load_data = 8'b00110000;
		end
		7'h1: begin
			load_data = 8'b01111000;			
		end
		default:
			load_data = 8'b00000000;			
	endcase
	end

	else if((addr_ddram > 7'h39) & (addr_ddram < 7'h42)) begin
	case(addr_ddram)
		7'h40: begin
			load_data = 8'b00110000;
		end
		7'h41: begin
			load_data = 8'b01111000;			
		end
		default:
			load_data = 8'b00000000;			
	endcase
	end

	else begin
		if(load_data_raw >= 10)
			load_data = {4'b0100,(load_data_raw-4'b1001)};
		else
			load_data = {4'b0011,load_data_raw};
	end
end


always @(posedge clk_270k) begin
	case(addr_ddram)
/*		6'h0: begin
			load_data_raw <= 8'b00110000;
		end
		6'h1: begin
			load_data_raw <= 8'b01111000;			
		end
*/		7'h2: begin
			load_data_raw <= buffer_data[31:28];
		end
		7'h3: begin
			load_data_raw <= buffer_data[27:24];
		end
		7'h4: begin
			load_data_raw <= buffer_data[23:20];
		end
		7'h5: begin
			load_data_raw <= buffer_data[19:16];
		end
		7'h6: begin
			load_data_raw <= buffer_data[15:12];
		end
		7'h7: begin
			load_data_raw <= buffer_data[11:8];
		end
		7'h8: begin
			load_data_raw <= buffer_data[7:4];
		end
		7'h9: begin
			load_data_raw <= buffer_data[3:0];
		end

// segunda linea
		7'h42: begin
			load_data_raw <= buffer_data_b[31:28];
		end
		7'h43: begin
			load_data_raw <= buffer_data_b[27:24];
		end
		7'h44: begin
			load_data_raw <= buffer_data_b[23:20];
		end
		7'h45: begin
			load_data_raw <= buffer_data_b[19:16];
		end
		7'h46: begin
			load_data_raw <= buffer_data_b[15:12];
		end
		7'h47: begin
			load_data_raw <= buffer_data_b[11:8];
		end
		7'h48: begin
			load_data_raw <= buffer_data_b[7:4];
		end
		7'h49: begin
			load_data_raw <= buffer_data_b[3:0];
		end




		default:
			load_data_raw <= 8'b0;
//load_data_raw <= buffer_data[31]

	endcase
end


endmodule

