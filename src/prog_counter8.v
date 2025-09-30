// 8-bit programmable binary counter with async reset, sync load,
// enable, and tri-state-able output bus.
module prog_counter8 (
    input  wire        clk,
    input  wire        rst_n,     // asynchronous active-low reset
    input  wire        en,        // count enable
    input  wire        load,      // synchronous load
    input  wire [7:0]  load_val,  // value to load when load=1
    input  wire        oe,        // output enable for tri-state bus
    output wire [7:0]  y_tri,     // tri-stated bus (Z when oe=0)
    output reg  [7:0]  q          // registered count (always valid)
);
    // counter with async reset, sync load
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= 8'd0;
        end else if (load) begin
            q <= load_val;
        end else if (en) begin
            q <= q + 8'd1;
        end
    end

    // tri-state output bus
    assign y_tri = oe ? q : 8'bz;
endmodule
