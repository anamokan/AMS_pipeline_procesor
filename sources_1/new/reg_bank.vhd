----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/24/2023 08:58:24 PM
-- Design Name: 
-- Module Name: reg_bank - Behavioral
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

entity reg_bank is
 Generic (WIDTH : positive := 32);
 Port (
       clk : in std_logic;
       reset : in std_logic; 
    -- Interfejs 1 za citanje podataka
       rs1_address_i : in std_logic_vector(4 downto 0);
       rs1_data_o : out std_logic_vector(WIDTH - 1 downto 0);
    -- Interfejs 2 za citanje podataka
       rs2_address_i : in std_logic_vector(4 downto 0);
       rs2_data_o : out std_logic_vector(WIDTH - 1 downto 0);
    -- Interfejs za upis podataka
       rd_we_i : in std_logic; -- port za dozvolu upisa
       rd_address_i : in std_logic_vector(4 downto 0);
       rd_data_i : in std_logic_vector(WIDTH - 1 downto 0)
);
end reg_bank;

architecture Behavioral of reg_bank is
type reg_file_t is array (0 to 31) of std_logic_vector(31 downto 0);
signal reg_file_s: reg_file_t;

begin

write: process(clk) is
begin
if(falling_edge(clk)) then
 if(reset = '0') then
  reg_file_s <= (others=>(others=>'0'));
 else
  if(rd_we_i = '1') then
    reg_file_s(to_integer(unsigned(rd_address_i))) <= rd_data_i;
  end if;
 end if;   
end if; 
end process;

read: rs1_data_o <= reg_file_s(to_integer(unsigned(rs1_address_i)));
      rs2_data_o <= reg_file_s(to_integer(unsigned(rs2_address_i)));

end Behavioral;
