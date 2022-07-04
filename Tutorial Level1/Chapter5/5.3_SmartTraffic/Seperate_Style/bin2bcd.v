module bin2bcd (
    input [7:0] bitcode, 
    output [7:0] bcdcode
);

reg [11:0] data;
integer i;
assign bcdcode = data[7:0];

always@(bitcode) begin 
    data = 12'd0;
    for(i=7;i>=0;i=i-1) begin  //二进制码总共8位，所以循环位数是8
        if(data[11:8]>=5)
            data[11:8] = data[11:8] + 3;
        if(data[7:4]>=5)
            data[7:4] = data[7:4] + 3;
        if(data[3:0]>=5)
            data[3:0] = data[3:0] + 3;
 
        data[11:8] = data[11:8] << 1;
        data[8] = data[7];
 
        data[7:4] = data[7:4] << 1;
        data[4] = data[3];
 
        data[3:0] = data[3:0] << 1;
        data[0]= bitcode[i];
    end     
end
endmodule