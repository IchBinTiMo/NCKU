`timescale 1ns/10ps
module traffic_light_tb;

reg clk, pass, rst;
wire R, G, Y;

initial begin
  clk = 0;
  pass = 0;
  rst = 0;

  forever #1 clk = ~clk;
  #7000 pass = 1;
  #1 pass = 0;
  #1000 rst = 1;
  #1 rst = 0;
  #6144 ;
  $finish;
end



traffic_light TL(.pass(pass), .clk(clk), .rst(rst), .R(R), .G(G), .Y(Y));


  
endmodule