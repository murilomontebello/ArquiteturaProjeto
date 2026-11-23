library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
    generic (
        ESPERA : natural := 1_000_000   -- 20 ms @ 50 MHz (use ~4 na simulacao)
    );
    port (
        clk_50 : in  std_logic;   -- clock da placa (PIN_Y2 na DE2-115)
        btn_n  : in  std_logic;   -- botao, ativo em 0
        saida  : out std_logic    -- botao limpo, ativo em 1
    );
end entity debouncer;

architecture comportamental of debouncer is
    signal sync    : std_logic_vector(1 downto 0) := "00";
    signal estavel : std_logic := '0';
    signal cont    : natural range 0 to ESPERA := 0;
begin
    process (clk_50)
    begin
        if rising_edge(clk_50) then
            -- sincronizador (evita metaestabilidade) + inversao do botao
            sync(0) <= not btn_n;
            sync(1) <= sync(0);

            if sync(1) = estavel then
                cont <= 0;                 -- sem mudanca: zera a contagem
            elsif cont = ESPERA then
                estavel <= sync(1);        -- mudou e ficou estavel: aceita
                cont    <= 0;
            else
                cont <= cont + 1;
            end if;
        end if;
    end process;

    saida <= estavel;
end architecture comportamental;
