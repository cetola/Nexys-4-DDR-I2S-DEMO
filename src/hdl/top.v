`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: PSU
// Engineer: Stephano Cetola
// 
// Create Date: 11/24/2018 06:36:30 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: Nexys 4 DDR
// Tool Versions: 
// Description: Simple I2S2 Test
// Based on Digilent's demo.
// Implements a volume control stream from Line In to Line Out of a Pmod I2S2 on port JA
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top #(
	parameter NUMBER_OF_VOL_SWITCHES = 4,
	parameter RESET_POLARITY = 0
) (
    input wire          clk,
    input wire          [15:0] sw,
    input wire          BTNU, BTND, BTNL, BTNC, BTNR,
    input wire          reset,
    
    output wire tx_mclk,
    output wire tx_lrck,
    output wire tx_sclk,
    output wire tx_data,
    output wire rx_mclk,
    output wire rx_lrck,
    output wire rx_sclk,
    input  wire rx_data
);
    wire axis_clk;
    wire clk_out50;
    wire clk_out100;
    
    wire [23:0] axis_tx_data;
    wire axis_tx_valid;
    wire axis_tx_ready;
    wire axis_tx_last;
    
    wire [23:0] axis_rx_data;
    wire axis_rx_valid;
    wire axis_rx_ready;
    wire axis_rx_last;
    
    wire [23:0] volume_data;
    wire [23:0] distort_data;
    wire [23:0] swap_data;

	wire resetn = (reset == RESET_POLARITY) ? 1'b0 : 1'b1;
	
	wire [5:0] btn_db;
    wire [15:0] sw_db;
    
    clk_wiz_0 m_clk (
        .clk_in1(clk),
        .axis_clk(axis_clk),
        .clk_out100(clk_out100),
        .clk_out50(clk_out50)
    );
    
    debounce debounce(
        .clk(clk_out50),
        .pbtn_in({resetn,BTNU,BTND,BTNL,BTNC,BTNR}),
        .switch_in(sw),
        .pbtn_db(btn_db),
        .swtch_db(sw_db));


    axis_i2s2 m_i2s2 (
        .axis_clk(axis_clk),
        .axis_resetn(resetn),
    
        .tx_axis_s_data(axis_tx_data),
        .tx_axis_s_valid(axis_tx_valid),
        .tx_axis_s_ready(axis_tx_ready),
        .tx_axis_s_last(axis_tx_last),
    
        .rx_axis_m_data(axis_rx_data),
        .rx_axis_m_valid(axis_rx_valid),
        .rx_axis_m_ready(axis_rx_ready),
        .rx_axis_m_last(axis_rx_last),
        
        .tx_mclk(tx_mclk),
        .tx_lrck(tx_lrck),
        .tx_sclk(tx_sclk),
        .tx_sdout(tx_data),
        .rx_mclk(rx_mclk),
        .rx_lrck(rx_lrck),
        .rx_sclk(rx_sclk),
        .rx_sdin(rx_data)
    );
    
    axis_volume_controller #(
		.SWITCH_WIDTH(NUMBER_OF_VOL_SWITCHES),
		.DATA_WIDTH(24)
	) m_vc (
        .clk(axis_clk),
        .sw(sw_db[NUMBER_OF_VOL_SWITCHES-1:0]),
        
        .s_axis_data(axis_rx_data),
        .s_axis_valid(axis_rx_valid),
        .s_axis_ready(axis_rx_ready),
        .s_axis_last(axis_rx_last),
        
        .m_axis_data(volume_data),
        .m_axis_valid(axis_tx_valid),
        .m_axis_ready(axis_tx_ready),
        .m_axis_last(axis_tx_last)
    );
    
    distortion #(
        .DATA_WIDTH(24)
    ) m_dist (
        .clk(clk_out50),
        .distort_sw(sw_db[15]),
        .rx_data(volume_data),
        .tx_data(distort_data)
    );
        
    swap #(
        .DATA_WIDTH(24)
    ) m_swap (
        .clk(clk_out50),
        .swap_sw(sw_db[14]),
        .rx_data(distort_data),
        .tx_data(swap_data)
    );
    
   tremolo #(
        .DATA_WIDTH(24)
    ) m_tremelo (
        .clk(clk_out50),
        .tremolo_sw(sw_db[13]),
        .rx_data(swap_data),
        .tx_data(axis_tx_data)
    );

endmodule
