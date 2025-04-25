
module FOF_TFG_Ctrl
#(
    parameter PIPELINE_CC = 8,
    parameter n = 16
)
(
    input                                   clk                 ,
    input                                   rst                 ,
    //上游模块配置信号
    input                                   i_valid             ,//pulse
    input        [3:0]                      i_log2N             ,
    //MUX控制信号
    output       [n-1:0]                    o_input_ff_mux      ,//n个二选一mux
    output                                  o_output_ff_initial ,//STF初始�?
    output       [n-1:0]                    o_output_ff_mux     ,//n个二选一mux
    output       [$clog2(n):0]              o_tfseed_mux        ,//�?�?(n+1)选一mux�?0表示选择1，其他为按顺序n个tfseed   
    //
    output                                  o_po_en             ,
    output       [PIPELIEN_CC_PO-1:0]       o_po_ff_mux         ,
    output       [$clog2(PIPELIEN_CC_PO):0] o_poseed_mux        ,
    //
    output                                  o_valid            //�?始正式输出TFG
);

    localparam PIPELIEN_CC_PO = PIPELINE_CC + 1;

    assign o_input_ff_mux = input_ff_mux          ;
    assign o_output_ff_initial = output_ff_initial;
    assign o_po_en = (cur_stage == TF_GEN)        ;
    assign o_po_ff_mux = po_ff_mux                ;
    assign o_poseed_mux = po_seed_mux             ;
    
    genvar p;
    generate
        for(p=0;p<n;p=p+1)
        begin
            assign o_output_ff_mux[p] = output_ff_mux[n-1-p];
        end
    endgenerate
    assign o_tfseed_mux = tf_seed_mux;
    
    reg [3:0] valid_delay;
    always@(*)
    begin
        if(PO_flag)
        case(PO_cnt1_end)
            0:valid_delay = 4;
            2:valid_delay = 6;
            6:valid_delay = 7;
        endcase
        else
            valid_delay = 7;
    end
    
//    reg valid;
//    always@(*)
//    begin
//        if(!rst)
//            valid = 0;
//         else if(PO_flag)
//            begin
//                case(PO_cnt1_end)
//                    0: valid = (cnt_gen >= PIPELINE_CC - 4);
//                endcase
//            end
//         else
//            valid = (cnt_gen >= 0);
//    end
    wire valid;
    assign valid = (cur_stage == TF_GEN && cnt_gen >= valid_delay);
    reg valid_d1, valid_d2;
    always@(posedge clk or negedge rst)
    begin
        if(!rst)
            {valid_d2,valid_d1}<=0;
        else 
            {valid_d2,valid_d1}<={valid_d1,valid};
    end

    assign o_valid = valid_d1;

    //状�?�机
    reg [2:0] cur_stage, cur_stage_d1 ,cur_stage_d2, next_stage;
    parameter IDLE = 0; parameter GTF = 1; parameter PO = 2; parameter STF = 3; parameter TF_GEN = 4;

    //NTT的stage计数�?
    reg [4:0] cnt_stage;

    //GTF或STF阶段刷新寄存器次数的计数�?
    reg [7:0] cnt0, cnt1;

    wire [7:0] cnt0_end;
    reg  [7:0] cnt1_end;
    reg  [7:0] PO_cnt1_end;
    
    reg PO_flag;

    always@(posedge clk or negedge rst)
    begin
        if(!rst)
            PO_flag <= 0;
        else if(cur_stage == TF_GEN && gen_end)
            PO_flag <= 0;
        else if(cur_stage == PO && cnt_stage< $clog2(n)+$clog2(PIPELIEN_CC_PO) && log2N>$clog2(n) && cnt_stage != log2N )
            PO_flag <= 1;
        else 
            PO_flag <= PO_flag;
    end


    wire update_end;
    assign update_end = ((cnt0 == cnt0_end) && (cnt1 == cnt1_end)) || no_STF_update_end;
    
    reg no_STF_update_end = 0;
    always@(posedge clk or negedge rst)
    begin
        if(!rst)
            no_STF_update_end<=0;
        else if(cur_stage == STF && output_ff_initial)
            if(log2N<=$clog2(n) && cnt_stage == log2N)
                no_STF_update_end<=1;
            else if(cnt_stage >= $clog2(n))
                no_STF_update_end<=1;
            else
                no_STF_update_end<=0;
        else
            no_STF_update_end<=0;
    end

    //TF_GEN阶段刷新寄存器次数的计数�?
    reg [15:0] cnt_gen, cnt_gen_1;
    wire gen_end;
    assign gen_end = (cur_stage == TF_GEN && cnt_gen == (cnt_gen_end_num + valid_delay)) ;
    
    reg [15:0] cnt_gen_end_num;
    always@(posedge clk or negedge rst)
    begin
        if(!rst)    
            cnt_gen_end_num <= 0;
        else if(  (20'b1<<<(log2N+1))>>>($clog2(n)+1) > 0  )   
            cnt_gen_end_num <= ( (20'b1<<<(log2N+1))>>>($clog2(n)+1) )-1;
        else
            cnt_gen_end_num <= 0;
    end

    always@(posedge clk or negedge rst)
    begin
        if(!rst)
            cur_stage<=IDLE;
        else
            cur_stage<=next_stage;
    end

    always@(posedge clk or negedge rst)
    begin
        if(!rst)
            {cur_stage_d2,cur_stage_d1}<={IDLE,IDLE};
        else
            {cur_stage_d2,cur_stage_d1}<={cur_stage_d1,cur_stage};
    end

    always@(*)
    begin
        if(!rst)
            next_stage=IDLE;
        else
            begin
                case(cur_stage)
                    IDLE:begin
                        if(i_valid)
                            next_stage = GTF;
                        else
                            next_stage = cur_stage;
                    end

                    GTF:begin
                        if(update_end)
                            next_stage = PO;
                        else
                            next_stage = cur_stage;
                    end

                    PO:begin
                        if( update_end || ( cur_stage_d1 == PO && PO_flag == 0 ) )
                            next_stage = STF;
                        else
                            next_stage = cur_stage;
                    end

                    STF:begin
                        if(update_end)
                            next_stage = TF_GEN;
                        else
                            next_stage = cur_stage;
                    end

                    TF_GEN:begin
                        if(gen_end)
                            begin
                                if(cnt_stage == 0)
                                    next_stage = IDLE;
                                else
                                    next_stage = PO;
                            end
                        else
                            next_stage = cur_stage;
                    end
                endcase
            end
    end



//--------------------------------output-----------------------------

reg [3:0] log2N;

always@(posedge clk or negedge rst)
begin
    if(!rst)
        log2N<=0;
    else if(i_valid)
        log2N<=i_log2N;
    else
        log2N<=log2N;     
end

//----------------------------
always@(posedge clk or negedge rst)
begin
    if(!rst)
        cnt_stage<=0;
    else if(i_valid)
        cnt_stage<=i_log2N;
    else if(cur_stage == IDLE)
        cnt_stage<=log2N;
    else if(gen_end && cnt_stage != 0)
        cnt_stage<=cnt_stage-1;
    else
        cnt_stage<=cnt_stage;     
end

//----------------------------

always@(posedge clk or negedge rst)
begin
    if(!rst)
        PO_cnt1_end <= 0;
    else if(cur_stage == TF_GEN && gen_end)
        PO_cnt1_end<=0;
    else if(cur_stage == PO)
        if(cnt_stage <= $clog2(n))
            PO_cnt1_end <= PIPELIEN_CC_PO-1-1;
        else if(cnt_stage == $clog2(n)+1 )
            PO_cnt1_end <= (PIPELIEN_CC_PO>>>1)-1-1;
        else 
            PO_cnt1_end <= 0;
    else
        PO_cnt1_end <= PO_cnt1_end;
end


assign cnt0_end = PIPELINE_CC + 3;

always@(posedge clk or negedge rst)
begin
    if(!rst)
        cnt1_end <= 0;
    else if(cur_stage_d1 == PO)
            cnt1_end <= PO_cnt1_end;
    else if(cur_stage == GTF)
        cnt1_end <= log2N-1;
    else if( (1<<cnt_stage) < n)
        if(log2N+1<$clog2(n))
            cnt1_end <= log2N-cnt_stage;
        else
            cnt1_end <= ($clog2(n)-cnt_stage-1);
    else
        cnt1_end <= 0;
end

reg cnt01_en, cnt01_en_d1;
always@(posedge clk or negedge rst)
begin
    if(!rst)
        cnt01_en<=0;
    else if(update_end)
        cnt01_en<=0;
    else if(cur_stage == GTF || cur_stage == STF || (cur_stage == PO && PO_flag) )
        cnt01_en<=1;
    else
        cnt01_en<=0;
end

always@(posedge clk or negedge rst)
begin
    if(!rst)
        cnt01_en_d1<=0;
    else
        cnt01_en_d1<=cnt01_en;
end


always@(posedge clk or negedge rst)
begin
    if(!rst)
        cnt0<=0;
    else if(cnt0 == cnt0_end)
        cnt0<=0;
    else if(cnt01_en_d1)
        cnt0<=cnt0+1;
    else
        cnt0<=0;
end

always@(posedge clk or negedge rst)
begin
    if(!rst)
        cnt1<=0;
    else if(update_end)
        cnt1<=0;
    else if(cnt01_en_d1 && cnt0 == cnt0_end)
        cnt1<=cnt1+1;
    else
        cnt1<=cnt1;
end

//-------------MUX CTRL-------------
reg       [n-1:0]                       input_ff_mux      ;//GTF
reg       [n-1:0]                       output_ff_mux     ;//STF
reg       [$clog2(n):0]                 tf_seed_mux       ;//GTF SELECT MUX
reg       [PIPELIEN_CC_PO-1:0]          po_ff_mux         ;//PO
reg       [$clog2(PIPELIEN_CC_PO):0]    po_seed_mux      ;

always@(posedge clk or negedge rst)
begin
    if(!rst)
        po_ff_mux <= 0;
    else if(cur_stage == PO)
        po_ff_mux <= 8'b11111111;
    else
        po_ff_mux <= 0;
end

always@(posedge clk or negedge rst)
begin
    if(!rst)
        po_seed_mux <= PIPELIEN_CC_PO;
    else if(PO_flag && cur_stage == TF_GEN)
        if(cnt_gen < PIPELIEN_CC_PO)
            po_seed_mux <= cnt_gen[$clog2(PIPELIEN_CC_PO)-1:0];
        else
            po_seed_mux <= PIPELIEN_CC_PO -1;
    else if(cnt_gen_1 == PIPELIEN_CC_PO -1 && cnt_gen_end_num>>>(log2N-cnt_stage) != PIPELIEN_CC_PO-1)
        po_seed_mux <= PIPELIEN_CC_PO;
    else if(cnt_gen_1 == cnt_gen_end_num>>>(log2N-cnt_stage) && cur_stage == TF_GEN && cnt_stage != log2N )
        po_seed_mux <= 0;
    else if(valid == 0 && valid_d1 == 1)
        po_seed_mux <= PIPELIEN_CC_PO;
    else
        po_seed_mux <= po_seed_mux;
end

always@(posedge clk or negedge rst)
begin
    if(!rst)
        input_ff_mux<=0;
    else if(cur_stage == GTF && cnt0 == 1+PIPELINE_CC)
        begin
            case(cnt1)
                0: input_ff_mux  <= 16'b1111111111111110;
                1: input_ff_mux  <= 16'b1111111111111100;
                2: input_ff_mux  <= 16'b1111111111111000;
                3: input_ff_mux  <= 16'b1111111111110000;
                4: input_ff_mux  <= 16'b1111111111100000;
                5: input_ff_mux  <= 16'b1111111111000000;
                6: input_ff_mux  <= 16'b1111111110000000;
                7: input_ff_mux  <= 16'b1111111100000000;
                8: input_ff_mux  <= 16'b1111111000000000;
                9: input_ff_mux  <= 16'b1111110000000000;
                10:input_ff_mux  <= 16'b1111100000000000;
                11:input_ff_mux  <= 16'b1111000000000000;
                12:input_ff_mux  <= 16'b1110000000000000;
                13:input_ff_mux  <= 16'b1100000000000000;
                14:input_ff_mux  <= 16'b1000000000000000;
                default: input_ff_mux <= 0 ;
            endcase
        end
    // else if(cur_stage == TF_GEN)
    //     input_ff_mux <= 16'b1111111111111111;
    else
        input_ff_mux<=0;
end

always@(posedge clk or negedge rst)
begin
    if(!rst)
        output_ff_mux<=0;
    else if(cur_stage == PO && cnt0 == 1+PIPELINE_CC)
        begin
            case({PO_cnt1_end[2:0],cnt1[2:0]})
                6'b110000:output_ff_mux <= { 8'b01111111,8'b00000000};
                6'b110001:output_ff_mux <= { 8'b00111111,8'b00000000};
                6'b110010:output_ff_mux <= { 8'b00011111,8'b00000000};
                6'b110011:output_ff_mux <= { 8'b00001111,8'b00000000};
                6'b110100:output_ff_mux <= { 8'b00000111,8'b00000000};
                6'b110101:output_ff_mux <= { 8'b00000011,8'b00000000};
                6'b110110:output_ff_mux <= { 8'b00000001,8'b00000000};

                6'b010000:output_ff_mux <= { 8'b00111111,8'b00000000};
                6'b010001:output_ff_mux <= { 8'b00001111,8'b00000000};
                6'b010010:output_ff_mux <= { 8'b00000011,8'b00000000};
                
                6'b000000:output_ff_mux <= { 8'b00001111,8'b00000000};
            endcase
        end
    else if(cur_stage == GTF && cnt0 == 1+PIPELINE_CC)
        output_ff_mux<=16'b1111111111111111;
    else if(cur_stage == STF && cnt0 == 1+PIPELINE_CC)
        begin
            case({cnt_stage[2:0],cnt1[2:0]})
                6'b011000:output_ff_mux<=16'b0000000011111111;

                6'b010000:output_ff_mux<=16'b0000111100001111;
                6'b010001:output_ff_mux<=16'b0000000011111111;

                6'b001000:output_ff_mux<=16'b0011001100110011;
                6'b001001:output_ff_mux<=16'b0000111100001111;
                6'b001010:output_ff_mux<=16'b0000000011111111;


                6'b000000:output_ff_mux<=16'b0101010101010101;
                6'b000001:output_ff_mux<=16'b0011001100110011;
                6'b000010:output_ff_mux<=16'b0000111100001111;
                6'b000011:output_ff_mux<=16'b0000000011111111;

                default:output_ff_mux<=0;
            endcase
        end
    else if(cur_stage == TF_GEN && cnt_gen >= PIPELINE_CC)
        output_ff_mux<=16'b1111111111111111;
    else
        output_ff_mux<=0;
end

always@(posedge clk or negedge rst)
begin
    if(!rst)
        tf_seed_mux <= 0;
    else if(cur_stage == PO && cur_stage != cur_stage_d1)
        tf_seed_mux <= cnt_stage+1; 
    else if(cnt01_en & ~cnt01_en_d1)
    begin
        if(cur_stage == GTF)
            tf_seed_mux <= 0;
        else if(cur_stage != PO)
            tf_seed_mux <= cnt_stage;
    end  
    else if(cur_stage == GTF && cnt0 == 1)
    begin
        tf_seed_mux <= cnt1;
    end
    else if(cur_stage == STF && cnt0 == 1)
    begin
        tf_seed_mux <= (log2N - cnt1);
    end 
//    else if(cur_stage == TF_GEN)
//    begin
//        if(cnt_stage == log2N || log2N<=$clog2(n))
//            tf_seed_mux <= n;
//        else if(cnt_gen_1 == 0 && cnt_gen!=0)
//            tf_seed_mux <= cnt_stage+1;
//        else    
//            tf_seed_mux <= n;
//    end 
    else
        tf_seed_mux <= tf_seed_mux;
end

reg output_ff_initial;

always@(posedge clk or negedge rst)
begin
    if(!rst)
        output_ff_initial<=0;
    else if(cur_stage == PO && cur_stage != cur_stage_d1)
        output_ff_initial<=1;
    else if(cnt01_en & ~cnt01_en_d1 && cur_stage != PO)
        output_ff_initial<=1;
    else
        output_ff_initial<=0;
end

always@(posedge clk or negedge rst) 
begin
    if(!rst)
        cnt_gen<=0;
    else if(gen_end)
        cnt_gen<=0;
    else if(cur_stage == TF_GEN)
        cnt_gen<=cnt_gen+1;
    else
        cnt_gen<=0;
end

always@(posedge clk or negedge rst) 
begin
    if(!rst)
        cnt_gen_1<=0;
    else if(gen_end || cnt_gen_1 == cnt_gen_end_num>>>(log2N-cnt_stage) )
        cnt_gen_1<=0;
    else if(cur_stage == TF_GEN)
        cnt_gen_1<=cnt_gen_1+1;
    else
        cnt_gen_1<=0;
end

endmodule