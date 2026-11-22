library ieee;
use ieee.std_logic_1164.all;

entity controle is
    port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        opcode        : in  std_logic_vector(3 downto 0);
        zero          : in  std_logic;
        
        -- leds verdes da placa
        estado_leds   : out std_logic_vector(3 downto 0);
        
        -- sinais de controle
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
end entity controle;

architecture comportamental of controle is

    type estado_t is (
        S_FETCH,
        S_DECODE,
        S_EXEC_R,
        S_WB_R,
        S_EXEC_ADDI,
        S_WB_ADDI,
        S_MEM_ADDR,
        S_MEM_READ,
        S_WB_LD,
        S_MEM_WRITE,
        S_BEQ,
        S_BNE,
        S_JMP
    );

    signal estado_atual, proximo_estado : estado_t;

begin

    process(clk, rst)
    begin
        if rst = '1' then
            estado_atual <= S_FETCH;
        elsif rising_edge(clk) then
            estado_atual <= proximo_estado;
        end if;
    end process;

    process(estado_atual, opcode)
    begin
        case estado_atual is
            when S_FETCH =>
                proximo_estado <= S_DECODE;

            when S_DECODE =>
                case opcode is
                    when "0000" | "0001" | "0010" | "0011" | "0100" => -- Tipo R (ADD, SUB, AND, OR, SLT)
                        proximo_estado <= S_EXEC_R;
                    when "0101" => -- ADDI
                        proximo_estado <= S_EXEC_ADDI;
                    when "0110" | "0111" => -- LD ou ST
                        proximo_estado <= S_MEM_ADDR;
                    when "1000" => -- BEQ
                        proximo_estado <= S_BEQ;
                    when "1001" => -- BNE
                        proximo_estado <= S_BNE;
                    when "1010" => -- JMP
                        proximo_estado <= S_JMP;
                    when others =>
                        proximo_estado <= S_FETCH;
                end case;

            when S_EXEC_R =>
                proximo_estado <= S_WB_R;

            when S_WB_R =>
                proximo_estado <= S_FETCH;

            when S_EXEC_ADDI =>
                proximo_estado <= S_WB_ADDI;

            when S_WB_ADDI =>
                proximo_estado <= S_FETCH;

            when S_MEM_ADDR =>
                if opcode = "0110" then
                    proximo_estado <= S_MEM_READ;   -- LD
                else
                    proximo_estado <= S_MEM_WRITE;  -- ST
                end if;

            when S_MEM_READ =>
                proximo_estado <= S_WB_LD;

            when S_WB_LD =>
                proximo_estado <= S_FETCH;

            when S_MEM_WRITE =>
                proximo_estado <= S_FETCH;

            when S_BEQ | S_BNE | S_JMP =>
                proximo_estado <= S_FETCH;

            when others =>
                proximo_estado <= S_FETCH;
        end case;
    end process;

    process(estado_atual, opcode, zero)
    begin
        -- inicializa todos os sinais
        estado_leds   <= "0000";
        pc_write_cond <= '0';
        pc_write      <= '0';
        i_or_d        <= '0';
        mem_read      <= '0';
        mem_write     <= '0';
        mem_to_reg    <= '0';
        ir_write      <= '0';
        pc_source     <= "00";
        alu_op        <= "000";
        alu_src_a     <= '0';
        alu_src_b     <= "00";
        reg_write     <= '0';
        reg_dst       <= '0';

        case estado_atual is
            when S_FETCH =>
                estado_leds   <= "0000";
                mem_read      <= '1';
                i_or_d        <= '0';          
                ir_write      <= '1';          
                alu_src_a     <= '0';          
                alu_src_b     <= "01";         
                alu_op        <= "000";        
                pc_source     <= "00";         
                pc_write      <= '1';          

            when S_DECODE =>
                estado_leds   <= "0001";
                -- cálculo do branch
                alu_src_a     <= '0';          
                alu_src_b     <= "10";         
                alu_op        <= "000";        

            when S_EXEC_R =>
                estado_leds   <= "0010";
                alu_src_a     <= '1';          
                alu_src_b     <= "00";         
                alu_op        <= opcode(2 downto 0); -- "000"=ADD, "001"=SUB, "010"=AND, "011"=OR, "100"=SLT

            when S_WB_R =>
                estado_leds   <= "0011";
                reg_dst       <= '1';         
                mem_to_reg    <= '0';         
                reg_write     <= '1';          

            when S_EXEC_ADDI =>
                estado_leds   <= "0100";
                alu_src_a     <= '1';          
                alu_src_b     <= "10";         
                alu_op        <= "000";       

            when S_WB_ADDI =>
                estado_leds   <= "0101";
                reg_dst       <= '0';          
                mem_to_reg    <= '0';          
                reg_write     <= '1';          

            when S_MEM_ADDR =>
                estado_leds   <= "0110";
                alu_src_a     <= '1';         
                alu_src_b     <= "10";        
                alu_op        <= "000";       

            when S_MEM_READ =>
                estado_leds   <= "0111";
                i_or_d        <= '1';          
                mem_read      <= '1';          

            when S_WB_LD =>
                estado_leds   <= "1000";
                reg_dst       <= '0';          
                mem_to_reg    <= '1';          
                reg_write     <= '1';          

            when S_MEM_WRITE =>
                estado_leds   <= "1001";
                i_or_d        <= '1';          
                mem_write     <= '1';          

            when S_BEQ =>
                estado_leds   <= "1010";
                alu_src_a     <= '1';          
                alu_src_b     <= "00";         
                alu_op        <= "001";        
                pc_source     <= "01";         
                if zero = '1' then
                    pc_write_cond <= '1';      
                end if;

            when S_BNE =>
                estado_leds   <= "1011";
                alu_src_a     <= '1';          
                alu_src_b     <= "00";         
                alu_op        <= "001";        
                pc_source     <= "01";         
                if zero = '0' then
                    pc_write_cond <= '1';      
                end if;

            when S_JMP =>
                estado_leds   <= "1100";
                pc_source     <= "10";         
                pc_write      <= '1';          

        end case;
    end process;

end architecture comportamental;

