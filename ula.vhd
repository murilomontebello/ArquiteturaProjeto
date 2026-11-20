library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula is
    port (
        A      : in  std_logic_vector(15 downto 0);
        B      : in  std_logic_vector(15 downto 0);
        ALUOp  : in  std_logic_vector(2 downto 0);
        Result : out std_logic_vector(15 downto 0);
        Zero   : out std_logic
    );
end entity ula;

architecture comportamental of ula is
    signal res : std_logic_vector(15 downto 0);
begin

    process (A, B, ALUOp)
    begin
        case ALUOp is
            when "000" =>
                res <= std_logic_vector(signed(A) + signed(B));
            when "001" =>
                res <= std_logic_vector(signed(A) - signed(B));
            when "010" =>
                res <= A and B;
            when "011" =>
                res <= A or B;
            when "100" =>
                if signed(A) < signed(B) then
                    res <= x"0001";
                else
                    res <= x"0000";
                end if;
            when others =>
                res <= (others => '0');
        end case;
    end process;

    Result <= res;
    Zero   <= '1' when res = x"0000" else '0';

end architecture comportamental;