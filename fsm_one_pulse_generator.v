module monostable(input clk,din,reset,output dout);
reg [1:0] current_state,next_state;
localparam idle=2'b00;
localparam pulse=2'b01;
localparam debounce=2'b10;
localparam wait_for=2'b11;
reg prev_in;
reg [3:0]delay_counter,dcounter;
always @(posedge clk or posedge reset)
begin
if(reset)
begin
prev_in<=0;
current_state<=idle;
end
else begin
current_state<=next_state;
prev_in<=din;

if(current_state==pulse) delay_counter<=delay_counter+1;
else delay_counter<=0;
end
end

always @(posedge clk or posedge reset)
begin
if(reset || ~prev_in && din)
dcounter<=0;
else begin
if(current_state==debounce && din==1) begin
dcounter<=dcounter+1;
end
else
dcounter<=0;
end
end

always @(current_state, din, delay_counter,dcounter)
begin
case(current_state)
idle : if(din && ~prev_in) next_state<=debounce;
       else next_state<=idle;
       
debounce : begin if(!din) next_state<=idle;
           else if(dcounter>=1)
           next_state<=pulse;
           end
pulse :begin  if(delay_counter>=4'd3)
       next_state<=wait_for;
       else next_state<=pulse;
       end
wait_for :begin if( !din && prev_in)
           next_state<=idle;
           else next_state<=wait_for; end
        
endcase
end

assign dout=(current_state==pulse)?1:0;   

       
endmodule

`timescale 1ns / 1ps

module testbench;
    reg clk, din, reset;
    wire dout;

    monostable m1 (.clk(clk), .din(din), .reset(reset), .dout(dout));

    // Clock generation: 100 MHz (10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Initialize
        reset = 1;
        din = 0;
        #13 reset = 0; // Deassert reset after 13 ns

        // Test Case 1: Single pulse
        #5 din = 1;    // Rising edge at 18 ns
        #50 din = 0;   // Falling edge at 68 ns
        #50;           // Wait to return to idle

        // Test Case 2: Held high (retriggering test)
        #5 din = 1;    // Rising edge at 123 ns
        #100;          // Hold high for 100 ns
        #5 din = 0;    // Falling edge at 228 ns
        #50;           // Wait to return to idle

        // Test Case 3: Rapid toggling
        #5 din = 1;    // Rising edge at 283 ns
        #20 din = 0;   // Falling edge at 303 ns
        #10 din = 1;   // Rising edge at 313 ns
        #50 din = 0;   // Falling edge at 363 ns
        #50;           // Wait to return to idle

        // Test Case 4: Reset during pulse
        #5 din = 1;    // Rising edge at 418 ns
        #20 reset = 1; // Reset at 438 ns
        #13 reset = 0; // Deassert reset at 451 ns
        #50 din = 0;   // Falling edge at 501 ns
        #50;           // Wait

        #100 $finish;  // End simulation at 651 ns
    end

    // Monitor signals
    initial begin
        $monitor("Time=%0t ns reset=%b din=%b dout=%b state=%b delay_counter=%d dcounter=%d", 
                 $time, reset, din, dout, m1.current_state, m1.delay_counter, m1.dcounter);
    end

endmodule


