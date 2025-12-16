library ieee;
use ieee.numeric_bit.all;

entity tb_regfile is
end entity tb_regfile;

architecture sim of tb_regfile is

    component regfile is 
        port (
            clock    : in bit;
            reset    : in bit;
            regWrite : in bit;
            rr1      : in bit_vector(4 downto 0);
            rr2      : in bit_vector(4 downto 0);
            wr       : in bit_vector(4 downto 0);
            d        : in bit_vector(63 downto 0);
            q1       : out bit_vector(63 downto 0);
            q2       : out bit_vector(63 downto 0)
        );
    end component;

    signal s_clock    : bit := '0';
    signal s_reset    : bit := '0';
    signal s_regWrite : bit := '0';
    signal s_rr1      : bit_vector(4 downto 0) := (others => '0');
    signal s_rr2      : bit_vector(4 downto 0) := (others => '0');
    signal s_wr       : bit_vector(4 downto 0) := (others => '0');
    signal s_d        : bit_vector(63 downto 0) := (others => '0');
    signal s_q1       : bit_vector(63 downto 0);
    signal s_q2       : bit_vector(63 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT: regfile
        port map (
            clock    => s_clock,
            reset    => s_reset,
            regWrite => s_regWrite,
            rr1      => s_rr1,
            rr2      => s_rr2,
            wr       => s_wr,
            d        => s_d,
            q1       => s_q1,
            q2       => s_q2
        );

    p_clock: process
    begin
        s_clock <= '0';
        wait for CLK_PERIOD / 2;
        s_clock <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    p_stimulus: process
    begin
        -- === PASSO 1: Reset Global ===
        report "Iniciando Teste: Reset";
        s_reset <= '1';
        wait for CLK_PERIOD * 2;
        s_reset <= '0';
        wait for CLK_PERIOD;

        -- === PASSO 2: Escrever no Registrador X1 ===
        -- Valor esperado: FFFFFFFFFFFFFFFF
        report "Teste: Escrevendo tudo '1' no Registrador X1";
        s_regWrite <= '1';
        s_wr       <= "00001"; -- Endereço 1
        s_d        <= (others => '1'); -- Dado: F...F
        wait for CLK_PERIOD; -- Aguarda borda de subida para escrever

        -- Desabilitar escrita para testar leitura
        s_regWrite <= '0';
        
        -- === PASSO 3: Escrever no Registrador X2 ===
        -- Valor esperado: AAAAAAAAAAAAAAAA (1010...)
        report "Teste: Escrevendo padrão 1010... no Registrador X2";
        s_regWrite <= '1';
        s_wr       <= "00010"; -- Endereço 2
        s_d        <= X"AAAAAAAAAAAAAAAA"; 
        wait for CLK_PERIOD;
        s_regWrite <= '0';

        -- === PASSO 4: Leitura Simultânea (X1 e X2) ===
        report "Teste: Lendo X1 (q1) e X2 (q2) simultaneamente";
        s_rr1 <= "00001"; -- Lê X1 na porta q1
        s_rr2 <= "00010"; -- Lê X2 na porta q2
        wait for CLK_PERIOD;
        
        -- Verificações (Asserts)
        assert s_q1 = (63 downto 0 => '1') 
            report "ERRO: X1 deveria ser tudo 1." severity error;
        assert s_q2 = X"AAAAAAAAAAAAAAAA" 
            report "ERRO: X2 deveria ser AAAAA..." severity error;

        -- === PASSO 5: Teste do Registrador Zero (XZR / X31) ===
        report "Teste: Tentando escrever no XZR (X31)";
        s_regWrite <= '1';
        s_wr       <= "11111"; -- Endereço 31
        s_d        <= (others => '1'); -- Tenta escrever tudo 1
        wait for CLK_PERIOD;
        s_regWrite <= '0';

        -- Ler o XZR
        s_rr1 <= "11111"; 
        wait for CLK_PERIOD;

        assert s_q1 = (63 downto 0 => '0')
            report "ERRO: XZR (X31) nao e zero! Ele foi sobrescrito." severity error;

        -- === PASSO 6: Teste de Sobrescrita (Overwrite) ===
        report "Teste: Sobrescrevendo X1 com zero";
        s_regWrite <= '1';
        s_wr       <= "00001";
        s_d        <= (others => '0');
        wait for CLK_PERIOD;
        s_regWrite <= '0';
        
        -- Ler X1 novamente
        s_rr1 <= "00001";
        wait for CLK_PERIOD;
        assert s_q1 = (63 downto 0 => '0')
            report "ERRO: X1 nao foi atualizado para zero." severity error;

        report "--- FIM DA SIMULACAO: SUCESSO SE NAO HOUVE ERROS ---";
        wait for CLK_PERIOD * 2;
    end process;

end architecture sim;