library ieee;
use ieee.numeric_bit.all;

entity two_left_shifts_tb is
end entity two_left_shifts_tb;

architecture tb of two_left_shifts_tb is
    constant DATA_SIZE : natural := 64;

    signal s_input  : bit_vector(DATA_SIZE-1 downto 0) := (others => '0');
    signal s_output : bit_vector(DATA_SIZE-1 downto 0);

begin
    uut: entity work.two_left_shifts
        generic map (
            dataSize => DATA_SIZE -- [cite: 1]
        )
        port map (
            input  => s_input,  -- [cite: 2]
            output => s_output  -- [cite: 2]
        );

    stim_proc: process
    begin
        -- CASO 1: Deslocamento básico (Valor 1 -> 4)
        s_input <= (0 => '1', others => '0'); -- 0x0...01
        wait for 10 ns;
        assert (s_output(2) = '1' and s_output(1 downto 0) = "00")
            report "Erro Caso 1: Deslocamento basico falhou" severity error;

        -- CASO 2: Overflow (Perda dos bits 63 e 62) 
        -- Entrada com '1' nos bits mais significativos
        s_input <= (63 => '1', 62 => '1', 0 => '1', others => '0'); 
        wait for 10 ns;
        -- Espera-se que os bits 63 e 62 da entrada sumam. O bit 0 deve ir para a pos 2.
        assert (s_output(63) = '0' and s_output(62) = '0' and s_output(2) = '1')
            report "Erro Caso 2: Bits MSB nao foram descartados corretamente" severity error;

        -- CASO 3: Todos os bits em '1'
        s_input <= (others => '1');
        wait for 10 ns;
        -- O resultado deve ter '00' nos indices 1 e 0, e '1' no restante 
        assert (s_output(DATA_SIZE-1 downto 2) = (bit_vector'(DATA_SIZE-3 downto 0 => '1')) 
                and s_output(1 downto 0) = "00")
            report "Erro Caso 3: Preenchimento de zeros falhou" severity error;

        -- CASO 4: Teste do bit limite (Posicao 61)
        s_input <= (others => '0');
        s_input(DATA_SIZE-3) <= '1'; -- Bit 61
        wait for 10 ns;
        -- O bit 61 deve ser deslocado para a posicao 63 (MSB da saida) 
        assert (s_output(DATA_SIZE-1) = '1')
            report "Erro Caso 4: Bit limite nao atingiu o topo da saida" severity error;

        report "Todos os testes do deslocador finalizados!";
        wait;
    end process;

end architecture;