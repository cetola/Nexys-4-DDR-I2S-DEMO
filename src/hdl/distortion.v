`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: PSU
// Engineer: Stephano Cetola
// 
// Create Date: 11/30/2018 02:37:45 PM
// Design Name: 
// Module Name: distortion
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module distortion#(
    parameter DATA_WIDTH = 24
) (
    input wire clk,
    input wire distort_sw,
    input  wire [DATA_WIDTH-1:0] rx_data,
    output reg [DATA_WIDTH-1:0] tx_data = 1'b0
);
    reg [DATA_WIDTH-1:0] data [1:0];

    //TODO: this is gross. use the debounce module instead.
    reg d_sw_sync_r [2:0];
    wire d_sw_sync = d_sw_sync_r[2];
    
    always@(posedge clk) begin
        //TODO: OMG, seriously, it's gross.
        d_sw_sync_r[2] <= d_sw_sync_r[1];
        d_sw_sync_r[1] <= d_sw_sync_r[0];
        d_sw_sync_r[0] <= distort_sw;
    end
    
    always@(posedge clk) begin
        if (d_sw_sync && rx_data[DATA_WIDTH-1] === 1'b1)
            tx_data <= ~rx_data;
        else
            tx_data <= rx_data;
    end
endmodule
