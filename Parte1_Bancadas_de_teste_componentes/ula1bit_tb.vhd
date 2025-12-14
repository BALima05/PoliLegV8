entity ula1bit_tb is
end entity ula1bit_tb;

architecture behavior of ula1bit_tb is
    signal a_tb, b_tb, cin_tb, ai_tb, bi_tb : bit := '0';
    signal op_tb : bit_vector(1 downto 0) := "00";
    signal res_tb, cout_tb, over_tb : bit;

begin
    uut: entity work.ula1bit
        port map (
            a => a_tb, b => b_tb, cin => cin_tb,
            ainvert => ai_tb, binvert => bi_tb,
            operation => op_tb, result => res_tb,
            cout => cout_tb, overflow => over_tb
        );

    stim_proc: process
    begin
        -- Caso 1: Operação AND (00) -> 1 AND 1 = 1
        a_tb <= '1'; b_tb <= '1'; op_tb <= "00";
        wait for 10 ns;
        assert res_tb = '1' report "Erro no AND" severity error;

        -- Caso 2: Operação OR (01) com inversão de B -> 1 OR (NOT 0) = 1
        a_tb <= '1'; b_tb <= '0'; bi_tb <= '1'; op_tb <= "01";
        wait for 10 ns;
        assert res_tb = '1' report "Erro no OR com binvert" severity error;
        bi_tb <= '0'; -- reset binvert

        -- Caso 3: Operação ADD (10) -> 1 + 1 + cin(0) = 0, cout=1
        a_tb <= '1'; b_tb <= '1'; cin_tb <= '0'; op_tb <= "10";
        wait for 10 ns;
        assert (res_tb = '0' and cout_tb = '1') report "Erro no ADD" severity error;

        -- Caso 4: Operação Pass B (11) -> ignora A e passa B
        a_tb <= '0'; b_tb <= '1'; op_tb <= "11";
        wait for 10 ns;
        assert res_tb = '1' report "Erro no Pass B" severity error;

        -- Caso 5: Teste de Overflow no MSB (Soma de dois negativos resultando em positivo)
        -- Em complemento de 2 (1 bit), 1 + 1 com cin=1 -> res=1, cout=1. Over = 1 xor 1 = 0
        -- Um caso real de overflow: cin=1, a=0, b=0 -> res=1, cout=0. Over = 1 xor 0 = 1
        a_tb <= '0'; b_tb <= '0'; cin_tb <= '1'; op_tb <= "10";
        wait for 10 ns;
        assert over_tb = '1' report "Erro na deteccao de overflow" severity error;

        report "Simulação da ULA de 1 bit concluída!";
        wait;
    end process;
end architecture behavior;