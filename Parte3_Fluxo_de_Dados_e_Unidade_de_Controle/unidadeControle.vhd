library ieee;
use ieee.numeric_bit.all;

entity unidadeControle is 
    port (
        opcode       : in bit_vector (10 downto 0); -- sinal de condição código da instrução
        extendMSB    : out bit_vector (4 downto 0); -- sinal de controle sign-extend
        extendLSB    : out bit_vector (4 downto 0); -- sinal de controle sign-extend
        reg2Loc      : out bit;                     -- sinal de controle MUX Read Register 2
        regWrite     : out bit;                     -- sinal de controle Write Register
        aluSrc       : out bit;                     -- sinal de controle MUX entrada B ULA
        alu_control  : out bit_vector (3 downto 0); -- sinal de controle da ULA
        branch       : out bit;                     -- sinal de controle desvio condicional
        uncondBranch : out bit;                     -- sinal de controle desvio incondicional
        memRead      : out bit;                     -- sinal de controle leitura RAM dados
        memWrite     : out bit;                     -- sinal de controle escrita RAM dados
        memToReg     : out bit;                     -- sinal de controle MUX Write Data
    );
end entity unidadeControle; 

architecture structure_unidControle of unidadeControle is 

    -- sinais auxiliares das instrucoes
    signal s_ADD  : bit;
    signal s_SUB  : bit;
    signal s_AND  : bit;
    signal s_ORR  : bit;
    signal s_LDUR : bit;
    signal s_STUR : bit;
    signal s_CBZ  : bit;
    signal s_B    : bit;

begin 

    s_ADD  <= '1' when opcode = "10001011000" else '0';
    s_SUB  <= '1' when opcode = "11001011000" else '0';
    s_AND  <= '1' when opcode = "10001010000" else '0';
    s_ORR  <= '1' when opcode = "10101010000" else '0';
    s_LDUR <= '1' when opcode = "11111000010" else '0';
    s_STUR <= '1' when opcode = "11111000000" else '0';
    s_CBZ  <= '1' when opcode(10 downto 3) = "10110100" else '0';
    s_B    <= '1' when opcode(10 downto 5) = "000101" else '0';

    -- Definicao dos sinais de controle
    reg2Loc      <= '1' when (s_STUR = '1' or s_CBZ = '1') else '0';
    aluSrc       <= '1' when (s_LDUR = '1' or s_STUR = '1') else '0';
    memToReg     <= '1' when s_LDUR = '1' else '0';
    regWrite     <= '1' when (s_ADD = '1' or s_SUB = '1' or s_AND = '1' or s_ORR = '1' or s_LDUR = '1') else '0'; 
    memRead      <= '1' when s_LDUR = '1' else '0'; 
    memWrite     <= '1' when s_STUR = '1' else '0';
    branch       <= '1' when s_CBZ = '1' else '0';
    uncondBranch <= '1' when s_B = '1' else '0';

    -- Controle da ULA
    alu_control <= "0010" when (s_ADD = '1' or s_LDUR = '1' or s_STUR = '1') else 
                   "0110" when (s_SUB = '1') else 
                   "0000" when (s_AND = '1') else
                   "0001" when (s_ORR = '1') else
                   "0111" when (s_CBZ = '1') else 
                   "0000";
    
    -- Controle do Sign Extend 
    extendMSB <= "10100" when (s_LDUR = '1' or s_STUR = '1') else 
                 "10111" when (s_CBZ = '1') else                   
                 "11001" when (s_B = '1') else                     
                 "00000";

    extendLSB <= "01100" when (s_LDUR = '1' or s_STUR = '1') else 
                 "00101" when (s_CBZ = '1') else                   
                 "00000" when (s_B = '1') else               
                 "00000"; 
                 
end structure_unidControle;

