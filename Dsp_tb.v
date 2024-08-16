module DSP_tb ();
parameter A0REG=0 ,A1REG=1 ,B0REG=0 ,B1REG=1;
parameter CREG=1 ,DREG=1 ,MREG=1 ,PREG=0 ,CARRYINREG=1 ,CARRYOUTREG=1
,OPMODEREG=1;
parameter CARRYINSEL="OPMODE5";
parameter B_INPUT="DIRECT";
parameter RSTTYPE="SYNC";
reg [17:0]A,B,D,BCIN;
reg CARRYIN,CLK,RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE,CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE;
reg [7:0]OPMODE;
reg [47:0]C,PCIN;
wire CARRYOUT,CARRYOUTF;
wire [17:0] BCOUT;
wire [35:0] M;
wire [47:0] PCOUT,P;
DSP #(A0REG ,A1REG ,B0REG ,B1REG ,CREG ,DREG ,MREG ,PREG ,CARRYINREG ,CARRYOUTREG 
,OPMODEREG ,CARRYINSEL ,B_INPUT ,RSTTYPE) 
dut(A,B,D,C,CLK,CARRYIN,OPMODE,BCIN,RSTA,RSTB,RSTM,
RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE,CEA,CEB,CEM,CEP,CEC,CED,
CECARRYIN,CEOPMODE,PCIN,BCOUT,PCOUT,P,M,CARRYOUT,CARRYOUTF);
initial begin
CLK=0;
forever begin
#1; CLK=~CLK;
end
end
initial begin
// put A=0
A=0;
CEA=1;
#10;
//(D+B)*A +C=P,but the out of mult is zero as CEA=0  and p=c
A=14;
B=15;
C=10;
D=11;
CARRYIN=0;
OPMODE=8'b00011101;
RSTA=0;RSTB=0;RSTM=0;RSTP=0;RSTC=0;RSTD=0;RSTCARRYIN=0;RSTOPMODE=0;
CEA=0;CEB=1;CEM=1;CEP=1;CEC=1;CED=1;CECARRYIN=1;CEOPMODE=1;
#20;
// CEA enabled then the out will be (D+B)*A +C=P
CEA=1;
#20;
//reset all signal
RSTA=1;RSTB=1;RSTM=1;RSTP=1;RSTC=1;RSTD=1;RSTCARRYIN=1;RSTOPMODE=1;
#20;
//Back to normal operation 
RSTA=0;RSTB=0;RSTM=0;RSTP=0;RSTC=0;RSTD=0;RSTCARRYIN=0;RSTOPMODE=0;
#20;
// C-B*A
OPMODE=8'b10001101;
#20;
$stop;
end
endmodule