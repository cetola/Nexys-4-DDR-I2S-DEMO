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
// Description: Very simple distortion effect.
//              Based on work by Geoff Wallace
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module swap #(
    parameter DATA_WIDTH = 24
) (
    input wire clk,
    input wire swap_sw,
    input  wire [DATA_WIDTH-1:0] rx_data,
    output reg [DATA_WIDTH-1:0] tx_data
);

    always@(posedge clk) begin
        if (swap_sw && rx_data[DATA_WIDTH-1] === 1'b1)
            tx_data <= {1, rx_data[15:0], rx_data[22:16]};
        else if(swap_sw)
            tx_data <= {0, rx_data[15:0], rx_data[22:16]};
        else
            tx_data <= rx_data;
    end
endmodule
