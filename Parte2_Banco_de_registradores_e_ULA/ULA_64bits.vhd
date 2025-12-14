library ieee;
use ieee.numeric_bit.all;

entity ula is
    port (
        A  : in bit_vector(63 downto 0);   -- entrada A
        B  : in bit_vector(63 downto 0);   -- entrada B
        S  : in bit_vector(3 downto 0);    -- seleciona operacao
        F  : out bit_vector(63 downto 0);  -- saida 
        Z  : out bit;                      -- flag zero
        Ov : out bit;                      -- flag overflow 
        Co : out bit                       -- flag carry out 
    );
end entity ula; 

architecture structure_ula of ula is 
    component ula1bit is 
        port (
            a         : in bit;
            b         : in bit;
            cin       : in  bit;
            ainvert   : in  bit;
            binvert   : in  bit;
            operation : in  bit_vector(1 downto 0);
            result    : out bit;
            cout      : out bit;
            overflow  : out bit
         );
    end component; 

    -- Sinais de controle internos 
    signal op_internal : bit_vector(1 downto 0);
    signal a_inv : bit;
    signal b_inv : bit;
    signal carry_in : bit; -- Carry In do bit 0

    -- Sinais de interconexao
    signal carry_c : bit_vector(64 downto 0); -- Cadeia de carry 
    signal result_vector : bit_vector(63 downto 0); -- Vetor para compor o resultado
    signal ov_vector : bit_vector(63 downto 0);

begin 

    -- 1 Decodificacao de S para Sinais de controle 
    -- 00: AND/NOR, 01: OR, 10: ADD/SUB, 11: PassB
    with S select
        op_internal <= "00" when "0000" | "1100",                   -- AND (0000) e NOR (1100)
                       "01" when "0001",                            -- OR (0001)
                       "10" when "0010" | "0110",                   -- ADD (0010) e SUB (0110)
                       "11" when "0011" | "0111" | "1011" | "1111", -- Pass B (Termina em 11)
                       "00" when others;                            -- Segurança padrao: AND

    -- Seleção da Inversão de B
    with S select
        b_inv_internal <= '1' when "0110" | "0111" | "1100",
                          '0' when others;

    -- Seleção da Inversão de A
    -- A é invertido apenas no NOR (1100) 
    with S select
        a_inv_internal <= '1' when "1100",
                          '0' when others;

    -- Seleção do Carry In Inicial
    -- Carry In é 1 na Subtração (0110) e NOR (1100) 
    with S select
        c_in_base <= '1' when "0110" | "1100", 
                     '0' when others;

    carry_c(0) <= carry_in;

    gen_ula: for i in 0 to 63 generate 
        instancia_bit: ula1bit 
            port map (
                a => A(i),
                b => B(i);
                cin => carry_c(i),
                ainvert => a_inv, 
                binvert => b_inv,
                operation => op_internal, 
                result => result_vector(i),
                cout => carry_c(i+1),
                overflow => ov_vector(i)
            );
    end generate gen_ula;

    -- Atribui o vetor interno a saida F 
    F <= result_vector;

    -- Flag Zero
    Z <= '1' when (result_vector = (result_vector'range => '0')) else '0';

    -- Flag Carry Out 
    Co <= carry_c(64);

    -- Flag Overflow 
    Ov <= ov_vector(63);

end architecture structure_ula;



