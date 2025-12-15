library ieee;
use ieee.numeric_bit.all;

entity tb_ula is
end entity tb_ula;

architecture sim of tb_ula is

    component ula is
        port (
            A  : in bit_vector(63 downto 0);
            B  : in bit_vector(63 downto 0);
            S  : in bit_vector(3 downto 0);
            F  : out bit_vector(63 downto 0);
            Z  : out bit;
            Ov : out bit;
            Co : out bit
        );
    end component;

    signal s_A  : bit_vector(63 downto 0) := (others => '0');
    signal s_B  : bit_vector(63 downto 0) := (others => '0');
    signal s_S  : bit_vector(3 downto 0)  := (others => '0');
    signal s_F  : bit_vector(63 downto 0);
    signal s_Z  : bit;
    signal s_Ov : bit;
    signal s_Co : bit;

    constant OP_AND   : bit_vector(3 downto 0) := "0000";
    constant OP_OR    : bit_vector(3 downto 0) := "0001";
    constant OP_ADD   : bit_vector(3 downto 0) := "0010";
    constant OP_SUB   : bit_vector(3 downto 0) := "0110";
    constant OP_PASSB : bit_vector(3 downto 0) := "0111";
    constant OP_NOR   : bit_vector(3 downto 0) := "1100";

    constant TIME_DELTA : time := 10 ns;

begin

    DUT: ula
        port map (
            A  => s_A,
            B  => s_B,
            S  => s_S,
            F  => s_F,
            Z  => s_Z,
            Ov => s_Ov,
            Co => s_Co
        );

    process
    begin
        report "=== INICIO DA SIMULACAO DA ULA ===";

        -- =========================================================
        -- CASO 1: AND (0000)
        -- Teste: A = FFFF...FFFF, B = 0000...FFFF => F deve ser 0000...FFFF
        -- =========================================================
        s_S <= OP_AND;
        s_A <= (others => '1'); -- Tudo 1
        s_B <= (63 downto 16 => '0', others => '1'); -- 0...0000FFFF
        wait for TIME_DELTA;
        
        assert s_F = s_B report "ERRO no AND: Resultado inesperado" severity error;
        assert s_Z = '0' report "ERRO no AND: Flag Zero incorreta" severity error;

        -- =========================================================
        -- CASO 2: OR (0001)
        -- Teste: A = 1010..., B = 0101... => F deve ser 1111...
        -- =========================================================
        s_S <= OP_OR;
        s_A <= X"AAAAAAAAAAAAAAAA"; -- 1010...
        s_B <= X"5555555555555555"; -- 0101...
        wait for TIME_DELTA;
        
        assert s_F = (63 downto 0 => '1') report "ERRO no OR" severity error;

        -- =========================================================
        -- CASO 3: ADD (0010) - Simples
        -- Teste: 2 + 3 = 5
        -- =========================================================
        s_S <= OP_ADD;
        s_A <= bit_vector(to_unsigned(2, 64));
        s_B <= bit_vector(to_unsigned(3, 64));
        wait for TIME_DELTA;

        assert s_F = bit_vector(to_unsigned(5, 64)) report "ERRO no ADD Simples" severity error;
        assert s_Z = '0' report "ERRO Flag Z no ADD" severity error;

        -- =========================================================
        -- CASO 4: ADD com Overflow (Signed)
        -- Teste: Max Positive + 1 
        -- Max Positivo (Signed 64) = 0111...111
        -- =========================================================
        s_A <= (63 => '0', others => '1'); 
        s_B <= bit_vector(to_unsigned(1, 64));
        wait for TIME_DELTA;
        
        -- Resultado será 1000... (negativo), indicando overflow de sinal
        assert s_Ov = '1' report "ERRO: Overflow nao detectado na SOMA" severity error;

        -- =========================================================
        -- CASO 5: SUB (0110) - Teste de Zero
        -- Teste: 15 - 15 = 0
        -- =========================================================
        s_S <= OP_SUB;
        s_A <= bit_vector(to_unsigned(15, 64));
        s_B <= bit_vector(to_unsigned(15, 64));
        wait for TIME_DELTA;

        assert to_integer(unsigned(s_F)) = 0 report "ERRO na SUB (15-15)" severity error;
        assert s_Z = '1' report "ERRO: Flag Zero nao ativou na SUB (15-15)" severity error;

        -- =========================================================
        -- CASO 6: SUB - Resultado Negativo
        -- Teste: 10 - 20 = -10 (Representado em complemento de 2)
        -- =========================================================
        s_A <= bit_vector(to_unsigned(10, 64));
        s_B <= bit_vector(to_unsigned(20, 64));
        wait for TIME_DELTA;
        
        -- Verificacao manual do resultado (FF...FFF6)
        -- -10 em 64 bits hexa: FFFFFFFFFFFFFFF6
        assert s_F = X"FFFFFFFFFFFFFFF6" report "ERRO na SUB Negativa" severity error;

        -- =========================================================
        -- CASO 7: Pass B (0111)
        -- =========================================================
        s_S <= OP_PASSB;
        s_A <= (others => '0'); -- A nao importa
        s_B <= X"123456789ABCDEF0";
        wait for TIME_DELTA;

        assert s_F = X"123456789ABCDEF0" report "ERRO no PASS B" severity error;

        -- =========================================================
        -- CASO 8: NOR (1100)
        -- Teste: 0 NOR 0 = 1 (Tudo 1)
        -- =========================================================
        s_S <= OP_NOR;
        s_A <= (others => '0');
        s_B <= (others => '0');
        wait for TIME_DELTA;

        assert s_F = (63 downto 0 => '1') report "ERRO no NOR" severity error;

        report "=== FIM DA SIMULACAO: SUCESSO SE NAO HOUVE ERROS ===";
        wait;
    end process;

end architecture sim;