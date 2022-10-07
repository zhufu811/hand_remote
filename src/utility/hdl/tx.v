module		tx(
					input			clk_50	    		,
					input			rst_n			     	,
					input			tx_vld				,
					input	[ 7:0]	tx_data				,
					output	reg	    tx                  ,
					output  wire    tx_done             
);
		
		parameter					BPS_END	=	13'd868	;    //bsp_speed wei 57600 (per second tx 57600 )
		parameter					BIT_END	=	4'd10		;
		
		reg 			[ 7:0]		tx_data_temp				;
		reg						    tx_flag						;
		reg	     		[12:0]		bps_cnt						;
        wire						add_bps_cnt					;
        wire						end_bps_cnt					;
        reg			    [ 3:0]		bit_cnt						;
        wire						add_bit_cnt					;
        wire						end_bit_cnt					;
		
		always @(posedge clk_50 or negedge rst_n)begin
			if(rst_n==0)
				tx_data_temp	<=	0		;
			else if(tx_vld)
				tx_data_temp	<=	tx_data	;
		end 
		
		always @(posedge clk_50 or negedge rst_n)begin
			if(rst_n==0)
				tx_flag	<=	0		;
			else if(end_bit_cnt)
				tx_flag	<=	0		;
			else if(tx_vld)
				tx_flag	<=	1		;
		end
		
		always @(posedge clk_50 or negedge rst_n)begin
        	if(rst_n==0)
        		bps_cnt	<=	0		;
        	else if(add_bps_cnt)begin
        		if(end_bps_cnt)
        			bps_cnt	<=	0	;
        		else
        			bps_cnt	<=	bps_cnt + 1	;
        	end
        end
        assign		add_bps_cnt	=	tx_flag	;
        assign		end_bps_cnt	=	add_bps_cnt	&&	bps_cnt==BPS_END-1	;
        
        always @(posedge clk_50 or negedge rst_n)begin
        	if(rst_n==0)
        		bit_cnt	<=	0		;
        	else if(add_bit_cnt)begin
        		if(end_bit_cnt)
        			bit_cnt	<=	0	;
        		else
        			bit_cnt	<=	bit_cnt + 1	;
        	end
        end
        assign		add_bit_cnt	=	end_bps_cnt	;
        assign		end_bit_cnt	=	add_bit_cnt	&&	bit_cnt==BIT_END-1	;
		assign      tx_done     =   end_bit_cnt                          ;  
		
		always @(posedge clk_50 or negedge rst_n)begin
			if(rst_n==0)
				tx	<=	1		;
			else if(tx_flag)begin
				if(add_bit_cnt && bit_cnt!=8) begin
					if (bit_cnt == 9)
					    tx  <=      1   ;
					else
					    tx	<=		tx_data_temp[bit_cnt]	;
				end
				else if(bit_cnt==0)	
					tx	<=		0	;
				else if(bit_cnt == 9)
				    tx  <=      1   ;
			    else
				    tx  <=      tx   ;  
			end
			else 
					tx	<=		1	;
		end

/*test*/

		
endmodule
					