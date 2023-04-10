----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/26/2023 07:39:54 PM
-- Design Name: 
-- Module Name: ALU_tb - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU_tb is
--  Port ( );
end ALU_tb;

architecture Behavioral of ALU_tb is
 signal a_s, b_s, res_s : std_logic_vector(31 downto 0);
 signal op_s : std_logic_vector(4 downto 0);
 signal of_s, z_s : std_logic;

begin

duv: entity work.ALU 
 Port map(
 a_i => a_s,
 b_i => b_s,
 op_i => op_s,
 res_o => res_s,
 of_o => of_s,
 zero_o => z_s
 );
 
 stim_gen: process
 begin
 op_s <= "00010";
 a_s <= X"00000001", X"7FFFFFFF" after 500ns;
 b_s <= X"0000000D", X"7FFFFFFF" after 500ns;
 wait;
 end process; 
 
end Behavioral;
