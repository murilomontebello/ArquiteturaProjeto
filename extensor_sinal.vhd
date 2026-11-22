library ieee;
use ieee.std_logic_1164.all;

entity extensor_sinal is
    port (
        imed_in  : in  std_logic_vector(5 downto 0);
        imed_out : out std_logic_vector(15 downto 0)
    );
end entity extensor_sinal;

architecture comportamental of extensor_sinal is
begin
    imed_out <= (15 downto 6 => imed_in(5)) & imed_in;
end architecture comportamental;

