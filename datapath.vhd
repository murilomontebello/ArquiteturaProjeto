library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
    port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        
        -- sinais
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
        
        --  memória
        mem_dado_in   : in  std_logic_vector(15 downto 0);
        mem_endereco  : out std_logic_vector(15 downto 0);
        mem_dado_out  : out std_logic_vector(15 downto 0);
        
        -- sinais feedbacl
        opcode        : out std_logic_vector(3 downto 0);
        zero          : out std_logic;
        
        -- sinais para a placa
        pc_out        : out std_logic_vector(15 downto 0);
        ula_out       : out std_logic_vector(15 downto 0);
        rdm_out       : out std_logic_vector(15 downto 0)
    );
end entity datapath;

architecture estrutural of datapath is

    component ula is
        port (
            A      : in  std_logic_vector(15 downto 0);
            B      : in  std_logic_vector(15 downto 0);
            ALUOp  : in  std_logic_vector(2 downto 0);
            Result : out std_logic_vector(15 downto 0);
            Zero   : out std_logic
        );
    end component;

    component banco_reg is
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
    end component;

    component extensor_sinal is
        port (
            imed_in  : in  std_logic_vector(5 downto 0);
            imed_out : out std_logic_vector(15 downto 0)
        );
    end component;

    component registrador_16bits is
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            reg_write : in  std_logic;
            d_in      : in  std_logic_vector(15 downto 0);
            d_out     : out std_logic_vector(15 downto 0)
        );
    end component;

    signal pc_en         : std_logic;
    signal pc_in         : std_logic_vector(15 downto 0);
    signal pc_atual      : std_logic_vector(15 downto 0);
    signal instr         : std_logic_vector(15 downto 0);
    signal rdm_reg       : std_logic_vector(15 downto 0);
    
    signal end_le2       : std_logic_vector(2 downto 0);
    signal end_esc       : std_logic_vector(2 downto 0);
    signal dado_esc      : std_logic_vector(15 downto 0);
    signal le1_banco     : std_logic_vector(15 downto 0);
    signal le2_banco     : std_logic_vector(15 downto 0);
    signal reg_a         : std_logic_vector(15 downto 0);
    signal reg_b         : std_logic_vector(15 downto 0);
    
    signal imed_ext      : std_logic_vector(15 downto 0);
    signal ula_in_a      : std_logic_vector(15 downto 0);
    signal ula_in_b      : std_logic_vector(15 downto 0);
    signal ula_res       : std_logic_vector(15 downto 0);
    signal alu_out_reg   : std_logic_vector(15 downto 0);

begin

    -- LOGICA DO PC
    pc_en <= pc_write or pc_write_cond;

    with pc_source select
        pc_in <= ula_res                          when "00",  
                 alu_out_reg                      when "01",  
                 "0000" & instr(11 downto 0)      when "10",  
                 ula_res                          when others;

    REG_PC: registrador_16bits
        port map (
            clk       => clk,
            rst       => rst,
            reg_write => pc_en,
            d_in      => pc_in,
            d_out     => pc_atual
        );

    -- LOGICA DA MEMORIA
    mem_endereco <= alu_out_reg when i_or_d = '1' else pc_atual;
    mem_dado_out <= reg_b; -- O dado a ser salvo na memória em ST vem de Ri (que está em reg_b)

    -- LOGICA DO IR
    REG_IR: registrador_16bits
        port map (
            clk       => clk,
            rst       => rst,
            reg_write => ir_write,
            d_in      => mem_dado_in,
            d_out     => instr
        );

    REG_RDM: registrador_16bits
        port map (
            clk       => clk,
            rst       => rst,
            reg_write => '1',
            d_in      => mem_dado_in,
            d_out     => rdm_reg
        );

    opcode <= instr(15 downto 12);

    -- LOGICA DO BANCO DE REG
    end_le2 <= instr(5 downto 3) when (instr(15 downto 12) <= "0100") else instr(11 downto 9);

    end_esc <= instr(11 downto 9);

    dado_esc <= rdm_reg when mem_to_reg = '1' else alu_out_reg;

    BANCO: banco_reg
        port map (
            clk      => clk,
            rst      => rst,
            en       => '1',
            reg_esc  => reg_write,
            end_le1  => instr(8 downto 6),
            end_le2  => end_le2,
            end_esc  => end_esc,
            dado_esc => dado_esc,
            le1      => le1_banco,
            le2      => le2_banco
        );

    -- regs temp
    INST_REG_A: registrador_16bits
        port map (
            clk       => clk,
            rst       => rst,
            reg_write => '1',
            d_in      => le1_banco,
            d_out     => reg_a
        );

    INST_REG_B: registrador_16bits
        port map (
            clk       => clk,
            rst       => rst,
            reg_write => '1',
            d_in      => le2_banco,
            d_out     => reg_b
        );

    -- extenao de sinal
    EXTENSOR: extensor_sinal
        port map (
            imed_in  => instr(5 downto 0),
            imed_out => imed_ext
        );

    -- escolha da ula
    ula_in_a <= reg_a when alu_src_a = '1' else pc_atual;

    with alu_src_b select
        ula_in_b <= reg_b    when "00",
                    x"0001"  when "01",  
                    imed_ext when "10",
                    reg_b    when others;

    -- LOGICA ULA
    ALU_INST: ula
        port map (
            A      => ula_in_a,
            B      => ula_in_b,
            ALUOp  => alu_op,
            Result => ula_res,
            Zero   => zero
        );

    REG_ALUOUT: registrador_16bits
        port map (
            clk       => clk,
            rst       => rst,
            reg_write => '1',
            d_in      => ula_res,
            d_out     => alu_out_reg
        );

    -- SAÍDAS
    pc_out  <= pc_atual;
    ula_out <= ula_res;
    rdm_out <= rdm_reg;

end architecture estrutural;

