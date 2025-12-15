library ieee;
use ieee.numeric_bit.all;

entity sign_extend_tb is
end entity sign_extend_tb;

architecture tb of sign_extend_tb is
    constant I_SIZE : natural := 32;
    constant O_SIZE : natural := 64;
    constant MAX_P  : natural := 5;

    signal s_inData      : bit_vector(I_SIZE-1 downto 0) := (others => '0');
    signal s_inDataStart : bit_vector(MAX_P-1 downto 0)  := (others => '0');
    signal s_inDataEnd   : bit_vector(MAX_P-1 downto 0)  := (others => '0');
    signal s_outData     : bit_vector(O_SIZE-1 downto 0);

begin
    uut: entity work.sign_extend
        generic map (
            dataISize       => I_SIZE,
            dataOSize       => O_SIZE,
            dataMaxPosition => MAX_P
        )
        port map (
            inData      => s_inData,
            inDataStart => s_inDataStart,
            inDataEnd   => s_inDataEnd,
            outData     => s_outData
        );

    stim_proc: process
    begin
        -- CASO 1: Número positivo (8 bits: 0 a 7). Valor: 0x0F (15)
        -- O bit 7 (sinal) é '0'.
        s_inData      <= x"0000000F";
        s_inDataStart <= "00111"; -- Índice 7
        s_inDataEnd   <= "00000"; -- Índice 0
        wait for 10 ns;
        assert (s_outData(63 downto 0) = x"000000000000000F") 
            report "Erro Caso 1: Extensão de positivo falhou" severity error;

        -- CASO 2: Número negativo (8 bits: 0 a 7). Valor: 0x80 (-128)
        -- O bit 7 (sinal) é '1'.
        s_inData      <= x"00000080";
        s_inDataStart <= "00111"; -- Índice 7
        s_inDataEnd   <= "00000"; -- Índice 0
        wait for 10 ns;
        -- Espera-se que todos os bits de 8 a 63 tornem-se '1'
        assert (s_outData(63 downto 8) = x"FFFFFFFFFFFFFF" and s_outData(7 downto 0) = x"80")
            report "Erro Caso 2: Extensão de negativo falhou" severity error;

        -- CASO 3: Campo deslocado no meio do vetor (Bits 15 a 12)
        -- Valor útil: "1010" (Bit 15 é o sinal = '1')
        s_inData      <= x"0000A000"; 
        s_inDataStart <= "01111"; -- Índice 15
        s_inDataEnd   <= "01100"; -- Índice 12
        wait for 10 ns;
        -- O tamanho útil é 4 bits. outData(0..3) recebe inData(12..15).
        -- Bits 4 em diante devem ser o sinal (inData(15) = '1').
        assert (s_outData(3 downto 0) = "1010" and s_outData(4) = '1')
            report "Erro Caso 3: Campo deslocado falhou" severity error;

        -- CASO 4: Teste de limite (Apenas 1 bit de sinal)
        s_inData      <= x"FFFFFFFF";
        s_inDataStart <= "00000"; -- Bit de sinal é o índice 0
        s_inDataEnd   <= "00000";
        wait for 10 ns;
        assert (s_outData = (x"FFFFFFFF"))
            report "Erro Caso 4: Extensão de bit único falhou" severity error;

        report "Testes finalizados com sucesso!";
        wait;
    end process;


end architecture;
