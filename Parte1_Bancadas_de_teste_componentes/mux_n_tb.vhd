entity mux_n_tb is
end entity mux_n_tb;

architecture behavior of mux_n_tb is
    constant N : natural := 4;

    -- Sinais para conectar ao componente
    signal in0_tb  : bit_vector(N-1 downto 0) := (others => '0');
    signal in1_tb  : bit_vector(N-1 downto 0) := (others => '0');
    signal sel_tb  : bit :='0';
    signal dOut_tb : bit_vector(N-1 downto 0);

begin
    dut: entity work.mux_n
        generic map (dataSize => N) -- 
        port map (
            in0  => in0_tb,  -- [cite: 2]
            in1  => in1_tb,  -- [cite: 2]
            sel  => sel_tb,  -- [cite: 2]
            dOut => dOut_tb  -- [cite: 2]
        );

    stim_proc: process
    begin
        -- Caso 1: Seleção da Entrada 0 (sel = '0')
        in0_tb <= "1010";
        in1_tb <= "0101";
        sel_tb <= '0';
        wait for 10 ns;
        assert (dOut_tb = in0_tb) 
            report "Erro: dOut deveria ser igual a in0 quando sel=0" severity error;

        -- Caso 2: Seleção da Entrada 1 (sel = '1')
        sel_tb <= '1';
        wait for 10 ns;
        assert (dOut_tb = in1_tb) 
            report "Erro: dOut deveria ser igual a in1 quando sel=1" severity error;

        -- Caso 3: Mudança de dado na entrada selecionada
        -- Com sel='1', dOut deve acompanhar in1 imediatamente
        in1_tb <= "1111";
        wait for 10 ns;
        assert (dOut_tb = "1111") 
            report "Erro: dOut não acompanhou a mudança em in1" severity error;

        -- Caso 4: Mudança de dado na entrada NÃO selecionada
        -- Com sel='1', mudar in0 não deve afetar dOut
        in0_tb <= "0000";
        wait for 10 ns;
        assert (dOut_tb = "1111") 
            report "Erro: dOut mudou indevidamente quando in0 foi alterado (sel=1)" severity error;

        -- Caso 5: Verificação de bordas (Alternância rápida)
        sel_tb <= '0'; wait for 5 ns;
        sel_tb <= '1'; wait for 5 ns;
        
        report "Simulação do MUX concluída com sucesso!";
        wait;
    end process;

end architecture behavior;