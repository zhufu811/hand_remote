module ad7606 #(
    parameter  SAMPLE_SPEED	     =   3'b000 ,
    parameter  AREG_RANG         =   0      
)
(
    input      wire               clk_50       ,
    input      wire               rst_n        ,
   
    output     wire               rst_ad7606   ,    //ad的复位，建议在工作之前线复位下ad 持续时间最少50ns
    output     wire               cva          ,
    output     reg                cvb          ,    //通道选择，本工程用到5个通道所以可以直接将cva、cvb连接在一起
    output     wire               cs_n         ,
    output     reg                rd_n         ,    //下降沿输出，可以上升沿的时候读取数据，在8080、spi两种通信总线下各有不同。8080情况下当busy信号变低时由该信号控制通道数据输出，持续时间为21ns
    output     wire               areg         ,
   
    output     wire   [2  : 0]    os           ,    //倍数
       
    input      wire               busy         ,    //当收到cvb低信号时，busy信号变为高电平开始装载数据，有两种方式读取，本工程用低信号读取。
    input      wire   [15 : 0]    data         ,


    output     reg                led_kai        ,
    output     reg                led_guan       ,
    input      wire               key_kai        ,
    input      wire               key_guan       ,
    output	   wire          	  tx   
);
    
parameter    chushi = 3'b001    , channel_choose = 3'b010  , read_data = 3'b100  ;
localparam   TIME_100MS  = 128_00;      //采集张、手闭合信号
localparam   TIME_20MS   = 1_000_000;   //按键去抖动
localparam   TIME_10MS   = 128_0       ;  //采集ad信号后做均匀   
//localparam   TIME_20MS  = 1_000     ;       // just for test
//localparam   TIME_100MS = 32        ;
//localparam   TIME_10MS   = 12        ;



reg     [4 : 0]   channel_cnt      ;
reg     [9 : 0]   ad_rst_cnt       ;
reg     [4 : 0]   rd_cnt           ;
reg     [4 : 0]   rd_bit_cnt       ;

reg     [15 : 0]  data_r [7 : 0]   ;
reg     [2  : 0]  state            ;
reg               rd_en            ;
     
reg               rst_ad7606_1     ;
wire              rst_ad7606_nd    ;
reg               busy_1           ; 
wire              busy_nd          ;
reg               busy_2           ; 
wire              busy_1nd         ;
reg               rd_n_1           ;
wire              rd_n_pd          ;

reg   [20 : 0]   key_cnt           ;
reg              key_cnt_en        ; 
reg              key_kai_1         ;
reg              key_kai_2         ;
reg              key_guan_1        ;
reg              key_guan_2        ;

reg              jiance_en         ;
reg   [5 : 0]    jiance_cnt        ;
reg   [22 : 0]   jiance_delay      ;

reg   [2 : 0]    jiance_state      ;

reg   [19 : 0]   jiance_data    [4 : 0]     ;
(*MARK_DEBUG="TRUE"*)
reg   [19 : 0]   data_ave_zhang [4 : 0]     ;
(*MARK_DEBUG="TRUE"*)
reg   [19 : 0]   data_ave_guan  [4 : 0]     ;

wire              key_kai_1nd      ;
wire              key_guan_1nd     ;

wire              tx_1             ;


assign  tx         = tx_1                ;
assign  cs_n       = 0                   ;
assign  os         = SAMPLE_SPEED        ;
assign  areg       = AREG_RANG           ;
assign  cva        = cvb                 ;
assign  rst_ad7606 = (ad_rst_cnt >= 10'd350) && (ad_rst_cnt <= 10'd360) ? 1'd1 : 1'd0  ;
assign  rst_ad7606_nd = ~rst_ad7606 && rst_ad7606_1  ;
assign  busy_nd       = ~busy && busy_1   ;
assign  busy_1nd      = ~busy_1 && busy_2   ;
assign  rd_n_pd    =   ~rd_n_1 && rd_n   ;

assign  key_kai_1nd  =  ~key_kai_1  && key_kai_2   ;
assign  key_guan_1nd =  ~key_guan_1 && key_guan_2  ;

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n) begin
        rst_ad7606_1 <= 1'd0     ;
        busy_1       <=  'd0     ;
        busy_2       <=  'd0     ;
        rd_n_1       <=  'd0     ;
        key_kai_1    <= 1'd1     ;
        key_kai_2    <= 1'd1     ;
        key_guan_1   <= 1'd1     ;
        key_guan_2   <= 1'd1     ;    
    end 
    else begin    
        rst_ad7606_1 <= rst_ad7606      ;
        busy_1       <= busy            ;
        busy_2       <= busy_1          ;       
        rd_n_1       <= rd_n            ;
        key_kai_1    <= key_kai         ;
        key_kai_2    <= key_kai_1       ;
        key_guan_1    <= key_guan         ;
        key_guan_2    <= key_guan_1       ;
    end    
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n)
        channel_cnt <= 'd0 ;
    else if(state == channel_choose)
        channel_cnt <= channel_cnt + 1'd1 ;
    else 
        channel_cnt <= 'd0 ;        
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n)
        ad_rst_cnt <= 'd0 ;
    else if(ad_rst_cnt == 499)
        ad_rst_cnt <= ad_rst_cnt ;
    else 
        ad_rst_cnt <= ad_rst_cnt + 1'd1  ;        
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n)
        rd_cnt <= 'd0 ;
    else if(rd_cnt == 19)
        rd_cnt <= 'd0  ;
    else if (rd_en)
        rd_cnt <= rd_cnt + 1'd1  ;
    else 
        rd_cnt <= 'd0   ;        
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n)
        rd_bit_cnt <= 'd0 ;
    else if (rd_en) begin
        if(rd_cnt == 19)
            rd_bit_cnt <= rd_bit_cnt + 1'd1 ;
        else
            rd_bit_cnt <= rd_bit_cnt   ;
    end
    else 
        rd_bit_cnt <=  'd0  ;        
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n)
        rd_n <= 1'd1 ;
    else if (rd_en) begin
        if(rd_cnt <= 9)
            rd_n <= 1'd1 ;
        else
            rd_n <= 1'd0 ; 
    end
    else 
        rd_n <=  1'd1  ;        
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n) begin
        state <= chushi    ;
        cvb   <= 'd1       ; 
        rd_en <= 1'd0      ;
    end
    else begin
        case (state)
            chushi         : begin
                cvb  <= 1'd1   ;
                if(ad_rst_cnt == 'd499)
                    state <= channel_choose  ;
                else
                    state <= chushi          ; 
            end
            channel_choose : begin
                if(channel_cnt == 19) begin
                    cvb <= 1'd1         ;
                    state <= read_data  ;
                end
                else begin
                    rd_en <= 0 ;
                    cvb <= 1'd0 ;
                    state <= channel_choose ; 
                end
            end 
            read_data      : begin
                if(busy_1nd) 
                    rd_en <= 1'd1 ;    
                else begin
                    rd_en <= rd_en ; 
                    if(rd_bit_cnt == 8 && rd_cnt == 8)
                        state <= channel_choose ;
                    else
                        state <= state ;
                end
            end      
        endcase
    end
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n) begin
        data_r[0] <= 'd0 ;
        data_r[1] <= 'd0 ;
        data_r[2] <= 'd0 ;
        data_r[3] <= 'd0 ;
        data_r[4] <= 'd0 ;
        data_r[5] <= 'd0 ;
        data_r[6] <= 'd0 ;
        data_r[7] <= 'd0 ;
    end
    else if (rd_en)
        if (rd_n_pd)
           data_r[rd_bit_cnt - 1] <= data ;
    else begin
        data_r[0] <= data_r[0] ;
        data_r[1] <= data_r[1] ;
        data_r[2] <= data_r[2] ;
        data_r[3] <= data_r[3] ;
        data_r[4] <= data_r[4] ;
        data_r[5] <= data_r[5] ;
        data_r[6] <= data_r[6] ;
        data_r[7] <= data_r[7] ;
    end
end

/*采集手掌张开、手掌闭合时的数据*/

reg       kai_flag  ;
reg       guan_flag ;





parameter   jiance_chushi = 3'b001  ,  jiance_100ms = 3'b010  , jiance_caiji = 3'b100  ;

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n)
        key_cnt_en  <=  1'd0  ;
    else if (key_cnt == 0 && (key_kai_1nd == 1 || key_guan_1nd == 1))
        key_cnt_en  <=  1'd1  ;
    else if (key_cnt == TIME_20MS)
        key_cnt_en  <=  1'd0  ;
    else
        key_cnt_en  <=  key_cnt_en  ;
end


always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n)
        key_cnt   <=  1'd0  ;
    else if (key_cnt_en)
        key_cnt   <= key_cnt + 1'd1  ;
    else 
        key_cnt   <=  'd0   ;
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n) begin
        kai_flag    <= 1'd0   ;
        guan_flag   <= 1'd0   ;
        jiance_en   <=  1'd0  ;
    end
    else if ((key_kai_1 == 0 || key_guan_1 == 0) && key_cnt == TIME_20MS) begin
        jiance_en   <=  1'd1  ;
        if (key_kai_1 == 0)
            kai_flag  <= 1 ;
        else if (key_guan_1 == 0)
            guan_flag <= 1 ;
    end  
    else if (jiance_cnt == 31 && rd_n_pd && rd_bit_cnt == 6) begin
        jiance_en   <=  'd0   ;
        kai_flag    <= 1'd0   ;
        guan_flag   <= 1'd0   ;        
    end
    else begin
        jiance_en   <=  jiance_en   ;
        kai_flag    <=  kai_flag    ;
        guan_flag   <=  guan_flag   ;
    end
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n) begin
        jiance_state <= jiance_chushi  ;
        jiance_delay <= 'd0            ;
        jiance_data [0]  <= 'd0            ;
        jiance_data [1]  <= 'd0            ;
        jiance_data [2]  <= 'd0            ;
        jiance_data [3]  <= 'd0            ;
        jiance_data [4]  <= 'd0            ;
        jiance_cnt   <= 'd0            ; 
    end            
    else
        case (jiance_state)
           jiance_chushi   : begin
                jiance_data [0]  <= 'd0            ;
                jiance_data [1]  <= 'd0            ;
                jiance_data [2]  <= 'd0            ;
                jiance_data [3]  <= 'd0            ;
                jiance_data [4]  <= 'd0            ;               
                jiance_cnt <= 'd0 ;
                if (jiance_en)
                    jiance_state <= jiance_100ms    ;
                else
                    jiance_state <= jiance_chushi   ;         
           end
           jiance_100ms : begin
                if (rd_n_pd && rd_bit_cnt == 8)
                    jiance_delay <= jiance_delay + 1'd1 ;
                else if (jiance_delay == TIME_100MS) 
                    jiance_state <= jiance_caiji  ;
                else 
                    jiance_delay <= jiance_delay  ;  
           end
           jiance_caiji : begin
                jiance_delay <= 'd0  ;
                if(rd_n_pd) begin
                    if (rd_bit_cnt <= 5)
                        jiance_data [rd_bit_cnt - 1] = jiance_data [rd_bit_cnt - 1] + data   ;
                    else begin
                        jiance_cnt <= jiance_cnt + 1'd1 ;
                        if (jiance_cnt == 31) 
                            jiance_state <= jiance_chushi ;
                        else
                            jiance_state <= jiance_100ms    ;  
                    end
                end
                else
                    jiance_data [rd_bit_cnt - 1] = jiance_data [rd_bit_cnt - 1]          ;
           end 
        endcase
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n) begin
        data_ave_zhang [4] <= 'd0    ;
        data_ave_zhang [3] <= 'd0    ;
        data_ave_zhang [2] <= 'd0    ;
        data_ave_zhang [1] <= 'd0    ;
        data_ave_zhang [0] <= 'd0    ;
        data_ave_guan  [4] <= 'd0    ;
        data_ave_guan  [3] <= 'd0    ;
        data_ave_guan  [2] <= 'd0    ;
        data_ave_guan  [1] <= 'd0    ;
        data_ave_guan  [0] <= 'd0    ;
    end
    else if (jiance_cnt == 31 && (kai_flag == 1 || guan_flag == 1))
        if (kai_flag == 1) begin
            data_ave_zhang [4] <= jiance_data [4] >> 5    ;
            data_ave_zhang [3] <= jiance_data [3] >> 5    ;
            data_ave_zhang [2] <= jiance_data [2] >> 5    ;
            data_ave_zhang [1] <= jiance_data [1] >> 5    ;
            data_ave_zhang [0] <= jiance_data [0] >> 5    ;
        end
        else if (guan_flag == 1) begin
            data_ave_guan  [4] <= jiance_data [4] >> 5    ;
            data_ave_guan  [3] <= jiance_data [3] >> 5    ;
            data_ave_guan  [2] <= jiance_data [2] >> 5    ;
            data_ave_guan  [1] <= jiance_data [1] >> 5    ;
            data_ave_guan  [0] <= jiance_data [0] >> 5    ;
        end        
    else begin
        data_ave_zhang [4] <= data_ave_zhang [4]    ;
        data_ave_zhang [3] <= data_ave_zhang [3]    ;
        data_ave_zhang [2] <= data_ave_zhang [2]    ;
        data_ave_zhang [1] <= data_ave_zhang [1]    ;
        data_ave_zhang [0] <= data_ave_zhang [0]    ;
        data_ave_guan  [4] <= data_ave_guan  [4]    ;
        data_ave_guan  [3] <= data_ave_guan  [3]    ;
        data_ave_guan  [2] <= data_ave_guan  [2]    ;
        data_ave_guan  [1] <= data_ave_guan  [1]    ;
        data_ave_guan  [0] <= data_ave_guan  [0]    ;
    end
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n) begin
        led_guan <= 1'd1  ;
        led_kai  <= 1'd1  ;
    end
    else if (jiance_cnt == 31 && (kai_flag == 1 || guan_flag == 1))
        if (kai_flag == 1) begin
            led_kai <= 1'd0 ;
        end
        else if (guan_flag == 1) begin
            led_guan <= 1'd0 ;
        end        
    else begin
        led_guan <= led_guan  ;
        led_kai  <= led_kai  ;
    end
end


/*检测手掌状态*/

wire       control_en    ;

reg   [13 : 0]  data_cha     [4 : 0]    ;
reg   [19 : 0]  data_bianhua [4 : 0]    ;
(*MARK_DEBUG="TRUE"*)
reg   [15 : 0]  data_result  [4 : 0]    ;
reg   [14 : 0]  A [4 : 0]               ;

reg   [7 : 0]  yunsuan_state           ;
reg   [6 : 0]  leijia_cnt              ;
reg   [11 : 0]  ys_delay_cnt            ;

wire  [25 : 0] p [4 : 0]               ; 
wire           data_bianhua_en         ;

wire           tx_done                 ;
wire  [7 : 0]  tx_data                 ;
reg            tx_vld                  ;
reg   [4 : 0]  send_cnt                ;
wire  [175 : 0] send_data              ;

parameter    ys_kong    = 8'b0000_0000 ,
             ys_chushi  = 8'b0000_0001 , 
             ys_delay   = 8'b0000_0010 , 
             ys_leijia  = 8'b0000_0100 , 
             ys_pingjun = 8'b0000_1000 , 
             ys_cheng   = 8'b0001_0000 , 
             ys_result  = 8'b0010_0000 ,
             ys_send    = 8'b0100_0000 ;


assign     control_en  =  ~led_kai && ~led_guan  ;
assign     data_bianhua_en  =  control_en && rd_bit_cnt == 8 && rd_cnt == 3 ;
assign     send_data   = { 8'h55 , 8'h55 , 8'h14 , 8'h03 , 8'h05 , 8'h2c , 8'h01 , 8'h01 , data_result[0][7 : 0] , data_result[0][15 : 8] , 8'h02 , data_result[1][7 : 0] , data_result[1][15 : 8] , 8'h03 , data_result[2][7 : 0] , data_result[2][15 : 8] , 8'h04 , data_result[3][7 : 0] , data_result[3][15 : 8] , 8'h05 , data_result[4][7 : 0] , data_result[4][15 : 8] }  ;
assign     tx_data     = send_data [(175-send_cnt*8) -: 8]   ;

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n) begin
        data_cha [0] <= 'd0  ;
        data_cha [1] <= 'd0  ;
        data_cha [2] <= 'd0  ;
        data_cha [3] <= 'd0  ;
        data_cha [4] <= 'd0  ;
    end  
    else if (control_en) begin
        data_cha [0] <=  data_ave_zhang [0] - data_ave_guan [0]  ; 
        data_cha [1] <=  data_ave_zhang [1] - data_ave_guan [1]  ;
        data_cha [2] <=  data_ave_zhang [2] - data_ave_guan [2]  ;
        data_cha [3] <=  data_ave_zhang [3] - data_ave_guan [3]  ;
        data_cha [4] <=  data_ave_zhang [4] - data_ave_guan [4]  ;
    end
    else begin
        data_cha [0] <= data_cha [0]  ;
        data_cha [1] <= data_cha [1]  ;
        data_cha [2] <= data_cha [2]  ;
        data_cha [3] <= data_cha [3]  ;
        data_cha [4] <= data_cha [4]  ;  
    end    
end

always @(posedge clk_50 or negedge rst_n ) begin
    if(!rst_n) begin
        yunsuan_state <= ys_chushi  ; 
        leijia_cnt    <= 'd0        ;
        ys_delay_cnt  <= 'd0        ;
        tx_vld        <= 'd0        ;
        send_cnt      <= 'd0        ;
        data_bianhua [0] <= 'd0  ;
        data_bianhua [1] <= 'd0  ;
        data_bianhua [2] <= 'd0  ;
        data_bianhua [3] <= 'd0  ;
        data_bianhua [4] <= 'd0  ;
        data_result [0]  <= 'd0  ;
        data_result [1]  <= 'd0  ;
        data_result [2]  <= 'd0  ;
        data_result [3]  <= 'd0  ;
        data_result [4]  <= 'd0  ;
        A[0] <=   'd0  ;
        A[1] <=   'd0  ;
        A[2] <=   'd0  ;
        A[3] <=   'd0  ;
        A[4] <=   'd0  ;
    end
    else
       case (yunsuan_state)
        ys_chushi  : begin
            data_bianhua [0] <= 'd0  ;
            data_bianhua [1] <= 'd0  ;
            data_bianhua [2] <= 'd0  ;
            data_bianhua [3] <= 'd0  ;
            data_bianhua [4] <= 'd0  ;
            if (control_en)
                yunsuan_state <= ys_delay  ;
            else 
                yunsuan_state <= yunsuan_state  ;
        end
        ys_delay   : begin
            if (rd_n_pd && rd_bit_cnt == 8)
                ys_delay_cnt <= ys_delay_cnt + 1'd1 ;
            else if (ys_delay_cnt == TIME_10MS)
                ys_delay_cnt <= 'd0 ;
            else  
                ys_delay_cnt <= ys_delay_cnt   ;
            if (ys_delay_cnt == TIME_10MS) 
                yunsuan_state <= ys_leijia  ;
            else 
                yunsuan_state <= ys_delay   ;              
        end
        ys_leijia  : begin  
            if (data_bianhua_en) begin
                data_bianhua [0] <= data_bianhua [0] + data_r [0] - data_ave_guan [0]   ; 
                data_bianhua [1] <= data_bianhua [1] + data_r [1] - data_ave_guan [1]   ;
                data_bianhua [2] <= data_bianhua [2] + data_r [2] - data_ave_guan [2]   ;
                data_bianhua [3] <= data_bianhua [3] + data_r [3] - data_ave_guan [3]   ;
                data_bianhua [4] <= data_bianhua [4] + data_r [4] - data_ave_guan [4]   ; 
                leijia_cnt <= leijia_cnt + 1'd1  ;               
            end
            else if (leijia_cnt == 32)
                yunsuan_state <= ys_pingjun  ;
            else
                yunsuan_state <= ys_delay    ;
        end
        ys_pingjun  : begin
            leijia_cnt       <= 'd0                    ;
            data_bianhua [0] <= data_bianhua [0] >> 5  ;
            data_bianhua [1] <= data_bianhua [1] >> 5  ;
            data_bianhua [2] <= data_bianhua [2] >> 5  ;
            data_bianhua [3] <= data_bianhua [3] >> 5  ;
            data_bianhua [4] <= data_bianhua [4] >> 5  ;
            yunsuan_state    <= ys_cheng   ;
        end
        ys_cheng  : begin
            A[0] <= data_bianhua [0]  ;
            A[1] <= data_bianhua [1]  ;
            A[2] <= data_bianhua [2]  ;
            A[3] <= data_bianhua [3]  ;
            A[4] <= data_bianhua [4]  ;
            yunsuan_state <= ys_kong   ;
        end
        ys_kong  :
            yunsuan_state <= ys_result  ;
        ys_result   : begin
            data_result [0]  <=  2000 - p [0]/data_cha [0] ;     
            data_result [1]  <=  p [1]/data_cha [1]+ 800 ;   
            data_result [2]  <=  p [2]/data_cha [2]+ 800 ;   
            data_result [3]  <=  p [3]/data_cha [3]+ 800 ;   
            data_result [4]  <=  p [4]/data_cha [4]+ 800 ;
            yunsuan_state    <=  ys_send  ;   
        end
        ys_send : begin
            if (tx_done) begin
                send_cnt  <= send_cnt + 1'd1  ;
                tx_vld    <= 1'd0       ; 
            end
            else if (send_cnt == 22) begin
                yunsuan_state <= ys_chushi  ;
                send_cnt     <= 'd0  ;
            end
            else begin
                tx_vld    <=  1'd1     ;
                send_cnt  <= send_cnt  ;
            end
        end
 //       default: 
       endcase
end
mult_gen_0 mult_0 (
  .CLK(clk_50),  // input wire CLK
  .A(A[0]),      // input wire [14 : 0] A
  .P(p[0])      // output wire [25 : 0] P
);
mult_gen_1 mult_1 (
  .CLK(clk_50),  // input wire CLK
  .A(A[1]),      // input wire [14 : 0] A
  .P(p[1])      // output wire [25 : 0] P
);
mult_gen_2 mult_2 (
  .CLK(clk_50),  // input wire CLK
  .A(A[2]),      // input wire [14 : 0] A
  .P(p[2])      // output wire [25 : 0] P
);
mult_gen_3 mult_3 (
  .CLK(clk_50),  // input wire CLK
  .A(A[3]),      // input wire [14 : 0] A
  .P(p[3])      // output wire [25 : 0] P
);
mult_gen_4 mult_4 (
  .CLK(clk_50),  // input wire CLK
  .A(A[4]),      // input wire [14 : 0] A
  .P(p[4])      // output wire [25 : 0] P
);


tx tx_init(
	.clk_50	    (clk_50)    		,
	.rst_n		(rst_n)	         	,
	.tx_vld		(tx_vld)    		,
	.tx_data	(tx_data)    			,
	.tx         (tx_1)             ,
	.tx_done    (tx_done)             
);

ila_0 ila_init (
	.clk(clk_50), // input wire clk


	.probe0(data_result[0]), // input wire [15:0]  probe0  
	.probe1(data_result[1]), // input wire [15:0]  probe1 
	.probe2(data_ave_zhang[0]), // input wire [19:0]  probe2 
	.probe3(data_ave_guan[0]) // input wire [19:0]  probe3
);

endmodule



















 