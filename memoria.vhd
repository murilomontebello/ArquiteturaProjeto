library ieee;
use ieee.std_logic_1164.all;

library altera_mf;
use altera_mf.altera_mf_components.all;


entity memoria is
    port (
        clk       : in  std_logic;                      -- mesmo clk da CPU
        mem_write : in  std_logic;                      -- sinal do controle
        endereco  : in  std_logic_vector(15 downto 0);  -- mem_endereco do datapath
        dado_in   : in  std_logic_vector(15 downto 0);  -- mem_dado_out do datapath
        dado_out  : out std_logic_vector(15 downto 0)   -- mem_dado_in do datapath
    );
end entity memoria;

architecture estrutural of memoria is
    signal clk_n : std_logic;
begin
    clk_n <= not clk;

    ram : altsyncram
        generic map (
            operation_mode         => "SINGLE_PORT",
            width_a                => 16,
            widthad_a              => 8,
            numwords_a             => 256,
            outdata_reg_a          => "UNREGISTERED",
            init_file              => "programa.mif",
            intended_device_family => "Cyclone IV E",
            lpm_type               => "altsyncram"
        )
        port map (
            clock0    => clk_n,
            address_a => endereco(7 downto 0),
            data_a    => dado_in,
            wren_a    => mem_write,
            q_a       => dado_out
        );
end architecture estrutural;
