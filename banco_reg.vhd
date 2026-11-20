library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity banco_reg is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        en       : in  std_logic;
        reg_esc  : in  std_logic;
        end_le1  : in  std_logic_vector(2 downto 0);
        end_le2  : in  std_logic_vector(2 downto 0);
        end_esc  : in  std_logic_vector(2 downto 0);
        dado_esc : in  std_logic_vector(15 downto 0);
        le1      : out std_logic_vector(15 downto 0);
        le2      : out std_logic_vector(15 downto 0)
    );
end entity banco_reg;

architecture comportamental of banco_reg is
    type banco_t is array (0 to 7) of std_logic_vector(15 downto 0);
    signal regs : banco_t := (others => (others => '0'));
begin

    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                regs <= (others => (others => '0'));
            elsif en = '1' and reg_esc = '1' then
                regs(to_integer(unsigned(end_esc))) <= dado_esc;
            end if;
        end if;
    end process;

    le1 <= regs(to_integer(unsigned(end_le1)));
    le2 <= regs(to_integer(unsigned(end_le2)));

end architecture comportamental;
