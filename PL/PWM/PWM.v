`timescale  1ns / 1ps

module PWM(
    Clk,
    Reset_n,
    pwm_gen_en,
    pwm_out
);
input Clk;
input Reset_n;
input pwm_gen_en;
output pwm_out;
parameter duty_cycle = 50; // 假设要设置50%的占空比
parameter frequency = 5000 ;
parameter counter_arr = 50_000_000 / frequency - 1; 
parameter counter_ccr = counter_arr * (duty_cycle / 100); 

PWM_gen  u_PWM_gen (
    .clk                     ( Clk                 ),
    .reset_n                 ( reset_n             ),
    .pwm_gen_en              ( pwm_gen_en          ),
    .counter_arr             ( counter_arr  [31:0] ),
    .counter_ccr             ( counter_ccr  [31:0] ),
    .pwm_out                 ( pwm_out             )
);
endmodule