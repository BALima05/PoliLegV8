library ieee;
use ieee.numeric_bit.all;

entity memoriaInstrucoes_tb is
end entity memoriaInstrucoes_tb;

architecture behavior of memoriaInstrucoes_tb is
    constant ADDR_WIDTH : natural := 8;
    constant DATA_WIDTH : natural := 8;
    
    signal addr_tb : bit_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal data_tb : bit_vector(DATA_WIDTH-1 downto 0);

begin
    dut: entity work.memoriaInstrucoes
        generic map (
            addressSize => ADDR_WIDTH,   -- 
            dataSize    => DATA_WIDTH,    -- 
            datFileName => "memInstr_conteudo.dat" -- 
        )
        port map (
            addr => addr_tb, -- [cite: 6]
            data => data_tb  -- [cite: 6]
        );

    stim_proc: process
    begin
        -- Caso 1: Verificar a primeira instrução (Endereço 0)
        -- Esperado: 11111000 conforme a linha 1 do arquivo 
        addr_tb <= "00000000";
        wait for 10 ns;
        assert (data_tb = "11111000") 
            report "Erro: Dado no endereco 0 incorreto" severity error;

        -- Caso 2: Verificar a segunda instrução (Endereço 1)
        -- Esperado: 01000000 conforme a linha 2 do arquivo 
        addr_tb <= "00000001";
        wait for 10 ns;
        assert (data_tb = "01000000") 
            report "Erro: Dado no endereco 1 incorreto" severity error;

        -- Caso 3: Testar acesso em um endereço mais distante (Endereço 12)
        -- O endereço 12 em binário é 00001100. Esperado: 11001011 
        addr_tb <= "00001100";
        wait for 10 ns;
        assert (data_tb = "11001011") 
            report "Erro: Dado no endereco 12 incorreto" severity error;

        -- Caso 4: Verificação de comportamento combinacional
        -- Mudança rápida de endereço para garantir que a saída segue a entrada 
        addr_tb <= "00000010"; wait for 5 ns;
        addr_tb <= "00000000"; wait for 5 ns;
        assert (data_tb = "11111000") report "Erro na alternancia rapida" severity error;

        report "Simulacao da Memoria concluida!";
        wait;
    end process;

end architecture behavior;