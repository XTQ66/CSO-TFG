module automatic tb_barret_sp_hanming();

parameter MAX_BW = 62;

logic                           clk, rst_n                      ;
logic                           valid, mode                     ;
logic       [2*MAX_BW-1:0]      xy                              ;
logic       [MAX_BW-1:0]        q                               ;
logic                           hamming_sign0, hamming_sign1    ;
logic       [7:0]               hamming_index0,hamming_index1   ;

logic           hamming_sign0_T     = 1 ;
logic  [7:0]    hamming_index0_T    =25 ;
logic           hamming_sign1_T     =0  ;
logic  [7:0]    hamming_index1_T    =20 ;
logic           hamming_sign2_T     =1  ;
logic  [7:0]    hamming_index2_T    =1  ;
logic           hamming_sign3_T     =1  ;
logic  [7:0]    hamming_index3_T    =1  ;


logic [99:0][2*MAX_BW-1:0] share_test_data ;

//------------------------DUT--------------------

wire        [2*MAX_BW-1:0]      o_res       ;
wire                            o_valid     ;

barret_sp_hanming
#(
    .MAX_BW            ( 62 )
)u_barret_sp(
    .clk               ( clk                ),
    .rst_n             ( rst_n              ),
    .i_valid           ( valid              ),
    .i_mode            ( mode               ),
    .i_xy              ( xy                 ),
    .i_q               ( q                  ),
    .i_hamming_sign0   ( hamming_sign0      ),
    .i_hamming_index0  ( hamming_index0     ),
    .i_hamming_sign1   ( hamming_sign1      ),
    .i_hamming_index1  ( hamming_index1     ),
    .i_hamming_sign0_T   ( hamming_sign0_T  ),
    .i_hamming_index0_T  ( hamming_index0_T ),
    .i_hamming_sign1_T   ( hamming_sign1_T  ),
    .i_hamming_index1_T  ( hamming_index1_T ),
    .i_hamming_sign2_T   ( hamming_sign2_T  ),
    .i_hamming_index2_T  ( hamming_index2_T ),
    .i_hamming_sign3_T   ( hamming_sign3_T  ),
    .i_hamming_index3_T  ( hamming_index3_T ),    
    .o_valid           ( o_valid            ),
    .o_res             ( o_res              )
);


//---------------------test bench-----------------

always #5 clk = ~clk;

initial
begin
    test_barret_normal();
end

logic    [MAX_BW-1:0]    l = 0 ;
logic    [2*MAX_BW-1:0]  t = 0 ;

logic    [MAX_BW-1:0]    x = 0 ;
logic    [MAX_BW-1:0]    y = 0 ;
logic    [MAX_BW-1:0]    z ;

logic    [2*MAX_BW-1:0]      res   = 0   ;
logic    [MAX_BW:0]          res_0 = 0   ;
logic    [MAX_BW:0]          res_1 = 0   ;
logic    [2*MAX_BW+2-1:0]    res_11  = 0 ;
logic    [MAX_BW:0]          res_mr  = 0 ;
logic    [2*MAX_BW:0]          test = 0  ;  
logic [MAX_BW:0] test10;
logic [MAX_BW:0] test11;

function automatic logic[MAX_BW:0] modmulti_test
(
    // input [MAX_BW-1:0] x,
    // input [MAX_BW-1:0] y
);

    // logic    [2*MAX_BW-1:0]    res   = 0 ;
    // logic    [MAX_BW:0]        res_0 = 0 ;
    // logic    [MAX_BW:0]        res_1 = 0 ;
    // logic    [2*MAX_BW+2-1:0]    res_11  = 0 ;
    // logic    [MAX_BW:0]    res_mr  = 0 ;
    
    test=(xy)%q;
    
    l=MAX_BW;
    res = res;

    res_0 = res[MAX_BW:0];

    res_1 = res>>(l-1);
    t=( 128'b1<<(2*l) )/q;
//    t = (128'b1<<( MAX_BW-1 )) - (128'b1<<hamming_index0) + (128'b1<<hamming_index1) - 1;
    //
//    res_11 = res_1 - res_1
//    //
    res_11 = res_1 * t[MAX_BW:0];
    res_1 = res_11>>(l+1);
    res_11 = res_1 * {1'b0,q};
    res_1 = res_11[MAX_BW:0];
    
    res_mr = res_0 - res_1;
    if($signed({1'b0,res_mr})-$signed({1'b0,q})>=0)
        return res_mr-q;
    else
        return res_mr;

endfunction


task test_barret_normal();
    fork
//         event monitor_start;
        begin:initial_process
            clk = 0;
            rst_n = 0;
            valid = 0;
            mode = 0;
            xy = 0;
            hamming_sign0 = 0;
            hamming_sign1 = 1;
            hamming_index0 = 23;
            hamming_index1 = 18;
            l = MAX_BW;
            q = (128'b1<<( MAX_BW-1 )) + (128'b1<<hamming_index0) - (128'b1<<hamming_index1) + 1;
            t=( 128'b1<<(2*l) )/q;
    //
//    res_11 = res_1 - res_1
    //
            test10 = t[MAX_BW:0];
            test11 = (128'b1<<( MAX_BW+1 )) - (128'b1<<25) + (128'b1<<20)- (128'b1<<1) - 2;
    
            
            t = (128'b1<<( MAX_BW-1 )) - (128'b1<<hamming_index0) + (128'b1<<hamming_index1) - 1;
        end

        begin:Simulation_data_process
            automatic logic [2*MAX_BW-1:0] temp = 0;
            #100;
            rst_n = 1;
            mode = 0;
            for(int i=0;i<100;i=i+1)
            begin
                //
                for(int j=0;j<100;j=j+1)
                begin
                    share_test_data[j] = $random% (q*q);
                end
                valid = 0;
                xy = 0;
                //
                for(int j=0;j<100;j=j+1)
                begin
                    @(posedge clk)
                    begin
                        #1;
                        valid = 1;
                        xy = share_test_data[j];
                    end
                end
                valid = 0;
                #1000;
//                ->monitor_start;
            end
            #1000;
            $finish;
        end

        begin:monitor
            begin
                logic [99:0][2*MAX_BW-1:0] share_test_data0 ;
                automatic int i = 0;
                automatic logic [2*MAX_BW-1:0] temp = 0;
                automatic logic [2*MAX_BW-1:0] temp1 = 0;
                forever
                begin
                    if(o_valid == 0)
                    begin
                        i = 0;
                        share_test_data0=share_test_data;
                    end
                    @(posedge clk)
                    begin
                        if(o_valid)
                        begin
                            res = share_test_data0[i];
                            temp = modmulti_test();
                            temp1 = xy %q;
                            $display("%d, %d",share_test_data0[i], q);
                            $display("%d, %d, %d, index = %d",o_res[MAX_BW-1:0], temp, temp1, i);
                            assert (o_res[MAX_BW-1:0] == temp)
                            else $fatal("Mismatch at index %d",i);
                            i = i + 1;
                        end
                    end
                end
            end
        end

    join
endtask


endmodule 