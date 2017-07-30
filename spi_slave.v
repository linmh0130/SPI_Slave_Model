// 32位二段式状态机spi模块
module spi_slave(
	input wire clk,
	
	input wire CS,
	input wire SCK,
	input wire MOSI,
	output reg MISO,
	
	output reg busy,//spi给fpga其他模块，busy=1时，禁止FPGA读写
	input wire[31:0] data_to_out,
	output reg[31:0] data_had_receive);

reg [1:0] state;
parameter IDLE = 2'b00;
parameter TRANS = 2'b01;
parameter WAIT = 2'b10;

reg [1:0]CS_buf;
wire CS_falling_flag;
wire CS_rising_flag;
always@(posedge clk)
begin
	CS_buf[1] <= CS_buf[0];
	CS_buf[0] <= CS;
end
assign CS_falling_flag = CS_buf[1] &(~CS_buf[0]);
assign CS_rising_flag = (~CS_buf[1]) & CS_buf[0];

reg [1:0]SCK_buf;
wire SCK_falling_flag;
wire SCK_rising_flag;
always@(posedge clk)
begin  
     SCK_buf[1] <= SCK_buf[0];
	  SCK_buf[0] <= SCK;
end

assign SCK_falling_flag = SCK_buf[1]&(~SCK_buf[0]);
assign SCK_rising_flag = (~SCK_buf[1])&SCK_buf[0];

reg [5:0]count;
// state machine
always@(posedge clk)
begin
	case(state)
		IDLE:begin
				 if(CS_falling_flag==1) state <= TRANS;
			  end
		TRANS:begin
					if(count == 6'b100000) state <= WAIT; // 传完32个数
					else if (CS_rising_flag==1) state <= IDLE; // 意外结束
				end
		WAIT:begin
				 if (CS_rising_flag) state <= IDLE;
			  end
	endcase
end

// count
always@(posedge clk)
begin
	case(state)
		IDLE: count<=6'b0;
		TRANS:begin
					if(SCK_rising_flag == 1) count <= count + 6'b1;
				end
	endcase
end

// MISO
always@(posedge clk)
begin
	if ((state == TRANS)&&(SCK_falling_flag == 1))
	begin
		case(count)
			6'b000000: MISO <= data_to_out[31];
			6'b000001: MISO <= data_to_out[30];
			6'b000010: MISO <= data_to_out[29];
			6'b000011: MISO <= data_to_out[28];
			6'b000100: MISO <= data_to_out[27];
			6'b000101: MISO <= data_to_out[26];
			6'b000110: MISO <= data_to_out[25];
			6'b000111: MISO <= data_to_out[24];
			6'b001000: MISO <= data_to_out[23];
			6'b001001: MISO <= data_to_out[22];
			6'b001010: MISO <= data_to_out[21];
			6'b001011: MISO <= data_to_out[20];
			6'b001100: MISO <= data_to_out[19];
			6'b001101: MISO <= data_to_out[18];
			6'b001110: MISO <= data_to_out[17];
			6'b001111: MISO <= data_to_out[16];
			6'b010000: MISO <= data_to_out[15];
			6'b010001: MISO <= data_to_out[14];
			6'b010010: MISO <= data_to_out[13];
			6'b010011: MISO <= data_to_out[12];
			6'b010100: MISO <= data_to_out[11];
			6'b010101: MISO <= data_to_out[10];
			6'b010110: MISO <= data_to_out[9];
			6'b010111: MISO <= data_to_out[8];
			6'b011000: MISO <= data_to_out[7];
			6'b011001: MISO <= data_to_out[6];
			6'b011010: MISO <= data_to_out[5];
			6'b011011: MISO <= data_to_out[4];
			6'b011100: MISO <= data_to_out[3];
			6'b011101: MISO <= data_to_out[2];
			6'b011110: MISO <= data_to_out[1];
			6'b011111: MISO <= data_to_out[0];
		endcase
	end
end

// MOSI
always@(posedge clk)
begin
	if ((state == TRANS)&&(SCK_rising_flag == 1))
	begin
		case(count)
			6'b000000: data_had_receive[31] <= MOSI;
			6'b000001: data_had_receive[30] <= MOSI;
			6'b000010: data_had_receive[29] <= MOSI;
			6'b000011: data_had_receive[28] <= MOSI;
			6'b000100: data_had_receive[27] <= MOSI;
			6'b000101: data_had_receive[26] <= MOSI;
			6'b000110: data_had_receive[25] <= MOSI;
			6'b000111: data_had_receive[24] <= MOSI;
			6'b001000: data_had_receive[23] <= MOSI;
			6'b001001: data_had_receive[22] <= MOSI;
			6'b001010: data_had_receive[21] <= MOSI;
			6'b001011: data_had_receive[20] <= MOSI;
			6'b001100: data_had_receive[19] <= MOSI;
			6'b001101: data_had_receive[18] <= MOSI;
			6'b001110: data_had_receive[17] <= MOSI;
			6'b001111: data_had_receive[16] <= MOSI;
			6'b010000: data_had_receive[15] <= MOSI;
			6'b010001: data_had_receive[14] <= MOSI;
			6'b010010: data_had_receive[13] <= MOSI;
			6'b010011: data_had_receive[12] <= MOSI;
			6'b010100: data_had_receive[11] <= MOSI;
			6'b010101: data_had_receive[10] <= MOSI;
			6'b010110: data_had_receive[9] <= MOSI;
			6'b010111: data_had_receive[8] <= MOSI;
			6'b011000: data_had_receive[7] <= MOSI;
			6'b011001: data_had_receive[6] <= MOSI;
			6'b011010: data_had_receive[5] <= MOSI;
			6'b011011: data_had_receive[4] <= MOSI;
			6'b011100: data_had_receive[3] <= MOSI;
			6'b011101: data_had_receive[2] <= MOSI;
			6'b011110: data_had_receive[1] <= MOSI;
			6'b011111: data_had_receive[0] <= MOSI;
		endcase
	end
end

// busy
always@(posedge clk)
begin
	case(state)
		IDLE: busy <= 0;
		TRANS: busy <= 1;
		WAIT: busy <= 0;
	endcase
end

endmodule
