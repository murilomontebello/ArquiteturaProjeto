library ieee;
use ieee.std_logic_1164.all;

entity registrador_16bits is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        reg_write : in  std_logic;
        d_in      : in  std_logic_vector(15 downto 0);
        d_out     : out std_logic_vector(15 downto 0)
    );
end entity registrador_16bits;

architecture comportamental of registrador_16bits is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            d_out <= (others => '0');
        elsif rising_edge(clk) then
            if reg_write = '1' then
                d_out <= d_in;
            end if;
        end if;
    end process;
end architecture comportamental;

