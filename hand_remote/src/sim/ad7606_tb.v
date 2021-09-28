`timescale 1ns / 1ps
 
module ad7606_tb();
 
 
    reg                clk_50        ;
    reg                rst_n         ;
   
    wire               rst_ad7606    ;  
    wire               cva           ;
    wire               cvb           ;  
    wire               cs_n          ;
    wire               rd_n          ;  
    wire               areg          ;
   
    wire   [2  : 0]    os            ;  
    
    reg                busy          ;  
    reg   [15 : 0]     data          ;

    wire               led_kai       ;
    wire               led_guan      ;
    wire               key_kai       ;
    wire               key_guan      ;
   
    wire                tx            ;


reg   [4 : 0]  busy_cnt         ;
reg   [9 : 0]  busy_bit_cnt     ;

reg            cvb_1   ;
wire           cvb_pd  ;
reg            rd_n_1  ;
wire           rd_n_nd ;

reg            led_kai_1  ;

reg   [10 : 0] key_kai_cnt  ;
reg            key_kai_cnt_en ;
reg   [10 : 0] key_guan_cnt  ;
reg            key_guan_cnt_en ;
reg   [19 : 0] key_delay     ;

wire           led_nd    ; 

localparam   delay_20MS = 1_000_000       ;


assign  cvb_pd  =  ~cvb_1  && cvb  ;
assign  rd_n_nd =  ~rd_n && rd_n_1  ;
assign  key_kai =  ~key_kai_cnt_en      ;
assign  led_nd  =  ~led_kai && led_kai_1  ;
assign  key_guan = ~key_guan_cnt_en  ;

initial
begin
    rst_n    =   1'b0                ;
    clk_50    =   1'b0               ;
    #1000                            ;
    rst_n    =   1'b1                ;
end

always   #10 clk_50 = ~clk_50   ;

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n) begin
        cvb_1 <= 1'd1 ;
        rd_n_1 <= 1'd0 ;
        led_kai_1 <= 1'd1 ;
    end 
    else begin    
        cvb_1 <= cvb  ;
        rd_n_1 <= rd_n   ;
        led_kai_1 <= led_kai  ;
    end    
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n)
        busy_cnt <= 'd0 ;
    else if (cvb) begin
        if(busy_cnt == 19)
            busy_cnt <= 'd0  ;
        else
            busy_cnt <= busy_cnt + 1'd1 ;
    end
    else
        busy_cnt <= 'd0 ;
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n)
        busy_bit_cnt <= 'd0 ;
    else if (cvb) begin
        if (busy_cnt == 19)
            busy_bit_cnt <= busy_bit_cnt + 1'd1 ;
        else 
            busy_bit_cnt <= busy_bit_cnt  ; 
    end
    else
        busy_bit_cnt <= 'd0 ;
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n) 
        key_kai_cnt <= 'd0  ;
    else if (key_kai_cnt_en || key_guan_cnt_en)
        key_kai_cnt <= key_kai_cnt + 1'd1 ;
    else
        key_kai_cnt <= 'd0 ;
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n) 
        key_kai_cnt_en <= 1'd0  ;
    else if (data == 100)
        key_kai_cnt_en <= 1'd1  ;
    else if (key_kai_cnt == 2000) 
        key_kai_cnt_en <= 1'd0 ;
    else
        key_kai_cnt_en <= key_kai_cnt_en ;
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n)
        busy <= 0 ;
    else if (cvb_pd)
        busy <= 1'd1 ;
    else if (busy_bit_cnt == 200)
        busy <= 'd0 ;
    else
        busy <= busy   ;    
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n)
        data <= 0 ;
    else if (rd_n_nd)
        data <= data + 1'd1 ;
    else
        data <= data   ;    
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n)
        key_delay <= 'd0 ;
    else if (!led_kai && key_delay <= delay_20MS) 
        key_delay <= key_delay + 1'd1 ;
    else 
        key_delay <= key_delay  ;    
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n) 
        key_guan_cnt_en <= 1'd0  ;
    else if (key_delay == delay_20MS - 1 )
        key_guan_cnt_en <= 1'd1  ;
    else if (key_kai_cnt == 2000) 
        key_guan_cnt_en <= 1'd0 ;
    else
        key_guan_cnt_en <= key_guan_cnt_en ;
end

ad7606 ad7606_tb 
(
    .clk_50      ( clk_50  )         ,
    .rst_n       ( rst_n  )          ,
    
    .rst_ad7606  ( rst_ad7606  )     , 
    .cva         ( cva  )            , 
    .cvb         ( cvb  )            , 
    .cs_n        ( cs_n  )           , 
    .rd_n        ( rd_n  )           , 
    .areg        ( areg  )           , 
    
    .os          ( os  )             , 
    
    .busy        ( busy  )           , 
    .data        ( data  )           ,
    .led_kai     ( led_kai )         ,
    .led_guan    ( led_guan)         ,
    .key_kai     ( key_kai)          ,
    .key_guan    ( key_guan )        ,
    .tx          ( tx   )
);



endmodule