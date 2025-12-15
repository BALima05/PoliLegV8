library ieee;
use ieee.numeric_bit.all;

entity adder_n_tb is
end entity adder_n_tb;

architecture behavior of adder_n_tb is
    constant N : natural := 4; -- Testando com 4 bits para facilitar leitura
    signal ino_tb, in1_tb, sum_tb : bit_vector(N-1 downto 0);
    signal cOut_tb : bit;

begin
    uut: entity work.adder_n
        generic map (dataSize => N)
        port map (
            in0 => ino_tb, in1 => in1_tb,
            sum => sum_tb, cOut => cOut_tb
        );

    stim_proc: process
    begin
        -- Caso 1: Soma simples sem carry out (2 + 3 = 5)
        ino_tb <= "0010"; in1_tb <= "0011";
        wait for 10 ns;
        assert (sum_tb = "0101" and cOut_tb = '0') report "Erro no Caso 1" severity error;

        -- Caso 2: Soma com geração de carry out (15 + 1 = 16 -> 0 e cOut=1)
        ino_tb <= "1111"; in1_tb <= "0001";
        wait for 10 ns;
        assert (sum_tb = "0000" and cOut_tb = '1') report "Erro no Caso 2 (Carry)" severity error;

        -- Caso 3: Soma resultando no valor máximo de 4 bits (7 + 8 = 15)
        ino_tb <= "0111"; in1_tb <= "1000";
        wait for 10 ns;
        assert (sum_tb = "1111" and cOut_tb = '0') report "Erro no Caso 3" severity error;

        -- Caso 4: Soma de zeros
        ino_tb <= "0000"; in1_tb <= "0000";
        wait for 10 ns;
        assert (sum_tb = "0000" and cOut_tb = '0') report "Erro no Caso 4" severity error;

        report "Simulação do somador finalizada!";
        wait;
    end process;

end architecture behavior;
