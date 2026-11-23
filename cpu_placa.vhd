library ieee;
use ieee.std_logic_1164.all;

entity cpu_placa is
    port (
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(3 downto 0);
        SW       : in  std_logic_vector(17 downto 0);
        LEDG     : out std_logic_vector(8 downto 0);
        HEX0     : out std_logic_vector(6 downto 0);
        HEX1     : out std_logic_vector(6 downto 0);
        HEX2     : out std_logic_vector(6 downto 0);
        HEX3     : out std_logic_vector(6 downto 0);
        HEX4     : out std_logic_vector(6 downto 0);
        HEX5     : out std_logic_vector(6 downto 0);
        HEX6     : out std_logic_vector(6 downto 0);
        HEX7     : out std_logic_vector(6 downto 0)
    );
end entity cpu_placa;

architecture estrutural of cpu_placa is

    component debouncer is
        port (
            clk_50 : in  std_logic;
            btn_n  : in  std_logic;
            saida  : out std_logic
        );
    end component;

    component memoria is
        port (
            clk       : in  std_logic;
            mem_write : in  std_logic;
            endereco  : in  std_logic_vector(15 downto 0);
            dado_in   : in  std_logic_vector(15 downto 0);
            dado_out  : out std_logic_vector(15 downto 0)
        );
    end component;

    component controle is
        port (
            clk           : in  std_logic;
            rst           : in  std_logic;
            opcode        : in  std_logic_vector(3 downto 0);
            zero          : in  std_logic;
            estado_leds   : out std_logic_vector(3 downto 0);
            pc_write_cond : out std_logic;
            pc_write      : out std_logic;
            i_or_d        : out std_logic;
            mem_read      : out std_logic;
            mem_write     : out std_logic;
            mem_to_reg    : out std_logic;
            ir_write      : out std_logic;
            pc_source     : out std_logic_vector(1 downto 0);
            alu_op        : out std_logic_vector(2 downto 0);
            alu_src_a     : out std_logic;
            alu_src_b     : out std_logic_vector(1 downto 0);
            reg_write     : out std_logic;
            reg_dst       : out std_logic
        );
    end component;

    component datapath is
        port (
            clk           : in  std_logic;
            rst           : in  std_logic;
            pc_write_cond : in  std_logic;
            pc_write      : in  std_logic;
            i_or_d        : in  std_logic;
            mem_to_reg    : in  std_logic;
            ir_write      : in  std_logic;
            pc_source     : in  std_logic_vector(1 downto 0);
            alu_op        : in  std_logic_vector(2 downto 0);
            alu_src_a     : in  std_logic;
            alu_src_b     : in  std_logic_vector(1 downto 0);
            reg_write     : in  std_logic;
            reg_dst       : in  std_logic;
            mem_dado_in   : in  std_logic_vector(15 downto 0);
            mem_endereco  : out std_logic_vector(15 downto 0);
            mem_dado_out  : out std_logic_vector(15 downto 0);
            opcode        : out std_logic_vector(3 downto 0);
            zero          : out std_logic;
            pc_out        : out std_logic_vector(15 downto 0);
            ula_out       : out std_logic_vector(15 downto 0);
            rdm_out       : out std_logic_vector(15 downto 0)
        );
    end component;

    component conversor_7seg is
        port (
            hex : in  std_logic_vector(3 downto 0);
            seg : out std_logic_vector(6 downto 0)
        );
    end component;

    signal clk_cpu       : std_logic;
    signal rst           : std_logic;
    signal clk_mem       : std_logic;

    signal opcode        : std_logic_vector(3 downto 0);
    signal zero          : std_logic;
    signal estado_leds   : std_logic_vector(3 downto 0);
    signal pc_write_cond : std_logic;
    signal pc_write      : std_logic;
    signal i_or_d        : std_logic;
    signal mem_read      : std_logic;
    signal mem_write     : std_logic;
    signal mem_to_reg    : std_logic;
    signal ir_write      : std_logic;
    signal pc_source     : std_logic_vector(1 downto 0);
    signal alu_op        : std_logic_vector(2 downto 0);
    signal alu_src_a     : std_logic;
    signal alu_src_b     : std_logic_vector(1 downto 0);
    signal reg_write     : std_logic;
    signal reg_dst       : std_logic;

    signal mem_endereco  : std_logic_vector(15 downto 0);
    signal mem_dado_in   : std_logic_vector(15 downto 0);
    signal mem_dado_out  : std_logic_vector(15 downto 0);

    signal pc            : std_logic_vector(15 downto 0);
    signal ula           : std_logic_vector(15 downto 0);
    signal rdm           : std_logic_vector(15 downto 0);
    signal mostrador     : std_logic_vector(15 downto 0);

begin

    rst     <= not KEY(1);
    clk_mem <= clk_cpu or rst;

    DEB: debouncer
        port map (
            clk_50 => CLOCK_50,
            btn_n  => KEY(0),
            saida  => clk_cpu
        );

    UC: controle
        port map (
            clk           => clk_cpu,
            rst           => rst,
            opcode        => opcode,
            zero          => zero,
            estado_leds   => estado_leds,
            pc_write_cond => pc_write_cond,
            pc_write      => pc_write,
            i_or_d        => i_or_d,
            mem_read      => mem_read,
            mem_write     => mem_write,
            mem_to_reg    => mem_to_reg,
            ir_write      => ir_write,
            pc_source     => pc_source,
            alu_op        => alu_op,
            alu_src_a     => alu_src_a,
            alu_src_b     => alu_src_b,
            reg_write     => reg_write,
            reg_dst       => reg_dst
        );

    DP: datapath
        port map (
            clk           => clk_cpu,
            rst           => rst,
            pc_write_cond => pc_write_cond,
            pc_write      => pc_write,
            i_or_d        => i_or_d,
            mem_to_reg    => mem_to_reg,
            ir_write      => ir_write,
            pc_source     => pc_source,
            alu_op        => alu_op,
            alu_src_a     => alu_src_a,
            alu_src_b     => alu_src_b,
            reg_write     => reg_write,
            reg_dst       => reg_dst,
            mem_dado_in   => mem_dado_out,
            mem_endereco  => mem_endereco,
            mem_dado_out  => mem_dado_in,
            opcode        => opcode,
            zero          => zero,
            pc_out        => pc,
            ula_out       => ula,
            rdm_out       => rdm
        );

    MEM: memoria
        port map (
            clk       => clk_mem,
            mem_write => mem_write,
            endereco  => mem_endereco,
            dado_in   => mem_dado_in,
            dado_out  => mem_dado_out
        );

    mostrador <= ula when SW(17) = '1' else rdm;

    LEDG(3 downto 0) <= estado_leds;
    LEDG(8 downto 4) <= (others => '0');

    D0: conversor_7seg port map (hex => pc(3 downto 0),   seg => HEX0);
    D1: conversor_7seg port map (hex => pc(7 downto 4),   seg => HEX1);
    D2: conversor_7seg port map (hex => pc(11 downto 8),  seg => HEX2);
    D3: conversor_7seg port map (hex => pc(15 downto 12), seg => HEX3);

    D4: conversor_7seg port map (hex => mostrador(3 downto 0),   seg => HEX4);
    D5: conversor_7seg port map (hex => mostrador(7 downto 4),   seg => HEX5);
    D6: conversor_7seg port map (hex => mostrador(11 downto 8),  seg => HEX6);
    D7: conversor_7seg port map (hex => mostrador(15 downto 12), seg => HEX7);

end architecture estrutural;
