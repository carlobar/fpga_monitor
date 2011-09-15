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


module sampling
#(
	parameter data_size = 18,	// total data bits (sum of signal bits)
	parameter state_size = 20,	// number of signals
	parameter mem_width = 5,	// memory depth
	parameter samples = 10		// samples shown in monitor
)
(
	input	in_dcm,			// Digital Clock Multiplier (DCM) Input clock
	input sys_rst,			// Reset Button
	input rst_in,			// System Reset

	input [1:0] rot,		// Rotatory Button

	input start_stop,		// Start/stop samplig signal

	// sampling signals
	input clk,
	input bit_0,
	input bit_1,
	input bit_2,
	input [2:0] vector_a,
	output [state_size-1:0] state,
	output reg [state_size-1:0] buf_graph,


	output [31:0] phase_counter,	// Counter of phase 

	input [10:0] x_in		// Monitor x position


);

////////////////////////////////////////////////////////////////////
////////////////////////////////  DCM  /////////////////////////////

// Clock signals intended to sample on rissing or falling edges.
wire sample_clk_dcm, sample_clk_dcm_n, sample_clk, sample_clk_n;


// Phase control signals
wire psen, psincdec,psdone, locked, psclk;

reg [10:0] x;
reg dcm_rst;


DCM_SP #(
	.CLKDV_DIVIDE(2.0), 	// 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
	.CLKFX_DIVIDE(2), 	// 1 to 32
	.CLKFX_MULTIPLY(4), 	// 2 to 32

	.CLKIN_DIVIDE_BY_2("FALSE"),
	.CLKIN_PERIOD(25.0),
	.CLKOUT_PHASE_SHIFT("VARIABLE"),
	.CLK_FEEDBACK("2X"),
	.DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"),
	.DFS_FREQUENCY_MODE("LOW"),
	.DLL_FREQUENCY_MODE("LOW"),
	.DUTY_CYCLE_CORRECTION("TRUE"),
	.PHASE_SHIFT(0),
	.STARTUP_WAIT("TRUE")
) clkgen_sample (
	.CLK0(),
	.CLK90(),
	.CLK180(),
	.CLK270(),

	.CLK2X(sample_clk_dcm),
	.CLK2X180(sample_clk_dcm_n),

	.CLKDV(),
	.CLKFX(),
	.CLKFX180(),//sample_clk_dcm_n
	.LOCKED(locked),
	.CLKFB(sample_clk),//
	.CLKIN(in_dcm),
	.RST(dcm_rst),//dcm_rst

	.PSEN(psen),
	.PSINCDEC(psincdec),
	.PSDONE(psdone),
	.PSCLK(psclk)
);

// Clock Buffers
BUFG b_sample(
	.I(sample_clk_dcm),
	.O(sample_clk)
);

BUFG b_sample_n(
	.I(sample_clk_dcm_n),
	.O(sample_clk_n)
);



//-------------------------------------------------
//-------------------- reset --------------------


reg [19:0] rst_cnt;

initial rst_cnt <= 20'h0000a;
always @(posedge in_dcm) begin
	if(rst_in)
		rst_cnt <= 20'h0000a;
	else if(rst_cnt != 20'd0)
		rst_cnt <= rst_cnt - 20'd1;
	dcm_rst <= (rst_cnt < 20'd4) & (rst_cnt != 20'd0);
end




// ----------------------------------------------------------
// ---------------   phase control ------------------------

phase_ctl phase_ctl(
	.clk(sample_clk),
	.rst(sys_rst),
	.rot(rot),
	.locked(locked),
	.psen(psen),
	.psincdec(psincdec),
	.psdone(psdone),
	.psclk(psclk),
	.counter(phase_counter)
);



//---------------------------------------------------
// 		Sample sample_clk
wire sample_delay;

DDR_reg clock_sample (
	.Q(sample_delay),
	.C0(sample_clk),
	.C1(sample_clk_n),
	.CE(1'b1),
	.D0(1'b1),
	.D1(1'b0),
	.R(sys_rst),
	.S(1'b0)
);



//-----------------------------------------------------
// 		Input Buffer

wire [data_size-1:0] mem_dat_r_p, mem_dat_r_n, data_input, mem_dat_r;

wire [data_size-1:0] mem_dat_w_a, mem_dat_w_b;


assign data_input = {clk, bit_0, bit_1, bit_2, vector_a};

DDR_in_buf #(
	.size(data_size)
)
DDR_buffer
(
	.D(data_input),
	.Q0(mem_dat_w_a),
	.C0(sample_clk),
	.C1(sample_clk_n),
	.CE(1'b1),
	.R(sys_rst),
	.S(1'b0),
	.Q1(mem_dat_w_b)
);



always @(posedge sample_clk) begin
	if(sys_rst)
		x <= 11'b0;
	else
		x <= x_in;
end




wire clk_mem, bit_0_mem, bit_1_mem,  bit_2_mem;

wire [2:0] vector_a_mem;
//wire [15:0] dq_mem;
//wire [31:0] do_mem, di_mem, dr_fml_mem;


wire enable_sampling;


assign enable_sampling = start_stop;




//----------------------------------------------------
//		Coders

wire [1:0] clk_, bit_0_, bit_1_, bit_2_, vector_a_;

coder coder_clk(
	.data(clk_mem),
	.out(clk_)
);

coder coder_bit_1(
	.data(bit_1_mem),
	.out(bit_1_)
);


coder coder_bit_2(
	.data(bit_2_mem),
	.out(bit_2_)
);


coder coder_bit_0(
	.data(bit_0_mem),
	.out(bit_0_)
);



coder_vector #(
	.size(3),
	.data_a(3'd5),
	.data_b(3'd2)
)
coder_vector_a(
	.data(vector_a_mem),
	.out(vector_a_)
);

assign state = {clk_, bit_0_, bit_1_, bit_2_, vector_a_};


assign clk_mem	 		= mem_dat_r[6];
assign bit_0_mem 		= mem_dat_r[5];
assign bit_1_mem 		= mem_dat_r[4];
assign bit_2_mem 		= mem_dat_r[3];
assign vector_a_mem		= mem_dat_r[2:0];


always @(posedge sample_clk) begin
	if(sys_rst)
		buf_graph <= {state_size{1'b0}};
	else 
		buf_graph <= state;
end


/*

`ifndef SIMULATION_DDR

	assign ack_mem 		= mem_dat_r[118] ;
	assign dr_fml_mem 	= mem_dat_r[117:86] ;
	assign sample_delay_mem = mem_dat_r[85] ;
	assign clk_mem 		= mem_dat_r[84] ;
	assign stb_mem 		= mem_dat_r[83] ;
	assign we_mem 		= mem_dat_r[82] ;
	assign dqs_mem 		= mem_dat_r[81:80] ;
	assign dq_mem 		= mem_dat_r[79:64] ;
	assign do_mem 		= mem_dat_r[63:32] ;
	assign di_mem 		= mem_dat_r[31:0] ;

`else

	assign ack_mem 		= mem_dat_w_a[118] ;
	assign dr_fml_mem 	= mem_dat_w_a[117:86] ;
	assign sample_delay_mem = mem_dat_w_a[85] ;
	assign clk_mem 		= mem_dat_w_a[84] ;
	assign stb_mem 		= mem_dat_w_a[83] ;
	assign we_mem 		= mem_dat_w_a[82] ;
	assign dqs_mem 		= mem_dat_w_a[81:80] ;
	assign dq_mem 		= mem_dat_w_a[79:64] ;
	assign do_mem 		= mem_dat_w_a[63:32] ;
	assign di_mem 		= mem_dat_w_a[31:0] ;
`endif
*/

/*
`ifdef SIMULATION_DDR

wire clk_mem_w, stb_mem_w, we_mem_w,  ack_mem_w, sample_clk_mem_w;
wire [1:0] dqs_mem_w;
wire [15:0] dq_mem_w;
wire [31:0] do_mem_w, di_mem_w, dr_fml_mem_w;


	assign ack_mem_w 		= mem_dat_w_a[118] ;
	assign dr_fml_mem_w 		= mem_dat_w_a[117:86] ;
	assign sample_delay_mem_w 	= mem_dat_w_a[85] ;
	assign clk_mem_w 		= mem_dat_w_a[84] ;
	assign stb_mem_w 		= mem_dat_w_a[83] ;
	assign we_mem_w 		= mem_dat_w_a[82] ;
	assign dqs_mem_w 		= mem_dat_w_a[81:80] ;
	assign dq_mem_w 		= mem_dat_w_a[79:64] ;
	assign do_mem_w 		= mem_dat_w_a[63:32] ;
	assign di_mem_w 		= mem_dat_w_a[31:0] ;

`endif
*/



// ------------------------------------------------------------------
//		 Write/read address

reg [10:0] counter;
reg inc_addr_r;

wire half_period;

reg h_p_delay_1, h_p_delay_2;

reg mem_we;
reg [mem_width-1:0] mem_adr_w, mem_adr_r;

wire [mem_width-1:0] mem_adr;


reg valid_address_r, last_address_r, rst_address;
reg valid_address_w, last_address_w;

// flags used in memory operations
always @(posedge sample_clk) begin
	if(sys_rst) begin
		valid_address_w <= 0;
		last_address_w 	<= 0;
		valid_address_r <= 0;
		last_address_r 	<= 0;
		rst_address 	<= 0;		
	end else begin
		valid_address_r	<= (mem_adr_r < {mem_width-1{1'b1}});
		last_address_r 	<= (mem_adr_r == {mem_width-1{1'b1}});
		rst_address 	<=  (x == 11'd0) | (x > 11'd1280);
		valid_address_w <= (mem_adr_w < {mem_width-1{1'b1}});
		last_address_w 	<= (mem_adr_w == {mem_width-1{1'b1}});
	end
end

// manage adress for reading memory
always @(posedge sample_clk) begin
	if(sys_rst | rst_address)
		mem_adr_r <= {mem_width-1{1'b0}} + 1;
	else if(inc_addr_r & valid_address_r)
		mem_adr_r <= mem_adr_r + 1'b1;
	else if(inc_addr_r & last_address_r)
		mem_adr_r <= mem_adr_r ;
end

// manage adress for writing memory
always @(posedge sample_clk) begin
	if(sys_rst | rst_address) begin
		mem_we <= 1'b0;
		mem_adr_w <= {mem_width-1{1'b0}};
	end else if(enable_sampling) begin
		if (valid_address_w) begin
			mem_we <= 1'b1;
			mem_adr_w <= mem_adr_w + 1;
		end
		else if (last_address_w) begin
			mem_we <= 1'b1;
			mem_adr_w <= mem_adr_w + 1;
		end
		else begin
			mem_we <= 1'b1;
			mem_adr_w <= {mem_width-1{1'b0}}; 
		end
	end else begin
		mem_we <= 1'b0;
		mem_adr_w <= {mem_width-1{1'b0}}; 
	end
end

// counter that increment address on reads
always @(posedge sample_clk) begin
	if (sys_rst | rst_address) begin
		counter <= {11{1'b0}};
		inc_addr_r <= 1'b0;
	end else if(counter > 1280/samples) begin
		counter <= {11{1'b0}};
		inc_addr_r <= 1'b1;		
	end else begin
		counter <= counter+11'd1;
		inc_addr_r <= 1'b0;	end
end

assign half_period = counter <= 1280/samples/2;

always @(posedge sample_clk) begin
	if(sys_rst) begin
		h_p_delay_1 <=1'b0;
		h_p_delay_2 <=1'b0;
	end
	else begin
		h_p_delay_1 <= half_period;
		h_p_delay_2 <= h_p_delay_1;
	end
end

assign mem_adr = mem_we ? mem_adr_w: mem_adr_r;



//-------------------------------------------------------------
//--------------------- Memory---------------------------------

memory#(
	.width(mem_width),
	.mem_size(data_size)
) buffer_posedge(
	.clk(sample_clk),
	.mem_dat_i(mem_dat_w_a),
	.mem_dat_o(mem_dat_r_p),
	.mem_we(mem_we),
	.mem_adr(mem_adr)
);

memory#(
	.width(mem_width),
	.mem_size(data_size)
) buffer_negedge(
	.clk(sample_clk_n),
	.mem_dat_i(mem_dat_w_b),
	.mem_dat_o(mem_dat_r_n),
	.mem_we(mem_we),
	.mem_adr(mem_adr)
);


// delay for mem_dat_r_n signal
reg [data_size-1:0] mem_dat_r_n_delay;

always @(posedge sample_clk) begin
	mem_dat_r_n_delay <= mem_dat_r_n;
end


assign mem_dat_r = h_p_delay_2 ? mem_dat_r_p : mem_dat_r_n_delay;




endmodule


