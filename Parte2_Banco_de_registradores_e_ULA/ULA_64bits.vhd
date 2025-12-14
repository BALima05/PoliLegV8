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
    signal carry_c : bit_vector(64 downto 0);       -- Cadeia de carry 
    signal result_vector : bit_vector(63 downto 0); -- Vetor para compor o resultado
    signal ov_vector : bit_vector(63 downto 0);

begin 

    -- 1 Decodificacao de S para Sinais de controle 
    process(S)
    begin 
        op_internal <= "00";
        a_inv <= '0';
        b_inv <= '0';
        carry_in <= '0';

        case S is 
            when "0000" => -- AND
                op_internal <= "00";
            
            when "0001" => -- OR
                op_internal <= "01";

            when "0010" => -- ADD
                op_internal <= "10";
                carry_in <= '0';

            when "0110" => -- SUB
                op_internal <= "10";
                b_inv <= '1';
                carry_in <= '1';

            when "1100" => -- NOR
                op_internal <= "00";
                a_inv <= '1';
                b_inv <= '1';
            
            when "0011" | "0111" | "1011" | "1111" => -- Pass B
                op_internal <= '0';
                b_inv <= '0';
            
            when others => 
                -- Seguranca padrao: AND
                op_internal <= "00";
        end case;
    end process;

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
    F =< result_vector;

    -- Flag Zero
    Z <= '1' when (result_vector = (result_vector'range => '0')) else '0';

    -- Flag Carry Out 
    Co <= carry_c(64);

    -- Flag Overflow 
    Ov <= ov_vector(63);

end architecture structure_ula;

