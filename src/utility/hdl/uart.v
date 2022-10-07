`timescale 1ns / 1ps
 
module uart(
	input	wire   clk_50	    		,
	input   wire	rst_n			    ,
	(*MARK_DEBUG="TRUE"*)
	output	wire	tx                      
);
(*MARK_DEBUG="TRUE"*)  
reg                tx_vld	     ;
(*MARK_DEBUG="TRUE"*)
reg   [7 : 0]      tx_data       ;
(*MARK_DEBUG="TRUE"*)
wire               tx_done       ;
wire               tx_1          ;
reg    [13 : 0]   cnt   ;
reg    [13 : 0]   cnt_delay      ;
(*MARK_DEBUG="TRUE"*)
reg               key            ;

assign    tx   =  tx_1           ;

always @(posedge clk_50 or negedge rst_n) begin
	if(!rst_n)
	   cnt <= 'd0 ;
	else if (cnt == 'd90)
	   cnt <=  'd0 ;
	else
	   cnt <= cnt + 1'd1 ;
end

always @(posedge clk_50 or negedge rst_n) begin
	if(!rst_n)
	   cnt_delay <= 'd0 ;
	else if (cnt_delay == 'd90)
	   cnt_delay <=  'd0 ;
	else if (cnt === 0)
	   cnt_delay <= cnt_delay + 1'd1 ;
	else 
	   cnt_delay <= cnt_delay ;
end

always @(posedge clk_50 or negedge rst_n) begin
	if(!rst_n)
	   key <= 'd1 ;
	else if (cnt_delay == 0 && cnt == 10)
	   key <= 1'd0 ;
	else
	   key <= 1'd1  ;
end

always @(posedge clk_50 or negedge rst_n) begin
	if(!rst_n)
	   tx_vld  <= 1'd0 ;
	else if (!key)
	   tx_vld  <= 1'd1 ;
	else if (tx_done)
	   tx_vld <= 1'd0  ;
    else
       tx_vld  <= tx_vld ;
end

always @(posedge clk_50 or negedge rst_n) begin
	if(!rst_n)
	   tx_data <= 'd1 ;
	else if (!key)
	   tx_data <= tx_data + 1'd1 ;
	else
	   tx_data <= tx_data  ;
end


tx  tx_tb(
	.clk_50		(clk_50)		 ,
	.rst_n		(rst_n)		     ,
	.tx_vld		(tx_vld)		 ,
	.tx_data	(tx_data)		 , 
	.tx         (tx_1)           ,
	.tx_done    (tx_done)
);

ila_0 ila_hc05 (
	.clk(clk_50), // input wire clk


	.probe0(tx_data), // input wire [7:0]  probe0    
	.probe1(tx), // input wire [0:0]  probe1 
	.probe2(key) // input wire [0:0]  probe2
);

endmodule