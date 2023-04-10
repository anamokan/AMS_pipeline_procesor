----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2023 12:24:53 PM
-- Design Name: 
-- Module Name: ctrl_decoder - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ctrl_decoder is
Port (
-- opcode instrukcije
opcode_i : in std_logic_vector (6 downto 0);
funct3_i : in std_logic_vector(2 downto 0);
-- kontrolni signali
branch_o : out std_logic;
mem_to_reg_o : out std_logic;
data_mem_we_o : out std_logic_vector(1 downto 0);      -- write enable za memoriju
alu_src_b_o : out std_logic;
rd_we_o : out std_logic;          -- write enable za reg bank
rs1_in_use_o : out std_logic;         
rs2_in_use_o : out std_logic;         
alu_2bit_op_o : out std_logic_vector(1 downto 0)
);
end ctrl_decoder;

architecture Behavioral of ctrl_decoder is

begin

ctrl: process(opcode_i, funct3_i)
begin
 if(opcode_i = "0110011") then   -- R-type
     branch_o <= '0';
     mem_to_reg_o <= '0';
     data_mem_we_o <= "00";
     alu_src_b_o <= '0';
     rd_we_o <= '1';
     rs1_in_use_o <= '1';
     rs2_in_use_o <= '1';
     alu_2bit_op_o <= "10";
  elsif(opcode_i = "0000011") then   -- I-type LW
     branch_o <= '0';
     mem_to_reg_o <= '1';
     data_mem_we_o <= "00";
     alu_src_b_o <= '1';
     rd_we_o <= '1';
     rs1_in_use_o <= '1';
     rs2_in_use_o <= '0';
     alu_2bit_op_o <= "00";
   elsif(opcode_i = "0100011")  then   -- S-type SW, SH, SB
     branch_o <= '0';
     mem_to_reg_o <= '0';    -- x, stavi sta god
     if(funct3_i = "000") then
      data_mem_we_o <= "01";
     elsif(funct3_i = "001") then
      data_mem_we_o <= "10";
     else
      data_mem_we_o <= "11";
     end if;
     alu_src_b_o <= '1';
     rd_we_o <= '0';
     rs1_in_use_o <= '1';
     rs2_in_use_o <= '1';
     alu_2bit_op_o <= "00"; 
   elsif(opcode_i = "1100011") then    -- B-type BEQ
     branch_o <= '1';
     mem_to_reg_o <= '0';    -- x, stavi sta god
     data_mem_we_o <= "00";
     alu_src_b_o <= '0';
     rd_we_o <= '0';
     rs1_in_use_o <= '1';
     rs2_in_use_o <= '1';
     alu_2bit_op_o <= "01"; 
   elsif(opcode_i = "0010011") then  -- I-type ADDI 
     branch_o <= '0';
     mem_to_reg_o <= '0';    -- x, stavi sta god
     data_mem_we_o <= "00";
     alu_src_b_o <= '1';
     rd_we_o <= '1';
     rs1_in_use_o <= '1';
     rs2_in_use_o <= '0';
     alu_2bit_op_o <= "11"; 
    else                      -- pocetne vrednosti
     branch_o <= '0';
     mem_to_reg_o <= '0';    
     data_mem_we_o <= "00";
     alu_src_b_o <= '0';
     rd_we_o <= '0';
     rs1_in_use_o <= '0';
     rs2_in_use_o <= '0';
     alu_2bit_op_o <= "00"; 
 end if;

end process;


end Behavioral;
