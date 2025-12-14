library ieee;
use ieee.numeric_bit.all;

entity regfile is 
    port (
        clock    : in bit;                       -- entrada de clock
        reset    : in bit;                       -- entrada de reset
        regWrite : in bit;                       -- entrada de carga do registrador wr
        rr1      : in bit_vector(4 downto 0);    -- entrada define registrador 1 
        rr2      : in bit_vector (4 downto 0);   -- entrada define registrador 2 
        wr       : in bit_vector(4 downto 0);    -- entrada define registrador de escrita 
        d        : in bit_vector(63 downto 0);   -- entrada de dado para carga paralela 
        q1       : out bit_vector(63 downto 0);  -- saida do registrador rr1
        q2       : out bit_vector(63 downto 0)   -- saida do registrador rr2
    );
end entity regfile;

architecture arch_regfile of regfile is
    component reg is  -- Declaracao do componente 'reg' feito na Parte 1
        generic (dataSize: natural := 64);
        port (
            clock, reset, enable : in bit; 
            d : in bit_vector(dataSize-1 downto 0);
            q : out bit_vector(dataSize-1 downto 0)
        );
    end component;

    type reg_array is array (0 to 31) of bit_vector(dataSize-1 downto 0);
    signal banco_sinais : reg_array; 

    -- Sinal auxiliar para decodificacao do enable de escrita 
    signal write_enable_decoded : bit_vector(31 downto 0);

begin 
    gerador_regs: for i in 0 to 31 generate 

        -- Caso 1: x0 ate X30
        reg_normal: if i < 31 generate 
            -- Ativa se regWrite = 1 e se wr for igualao indice atual (i)
            write_enable_decoded(i) <= '1' when (regWrite = '1' and to_integer(unsigned(wr)) = i) else '0';

            instancia_reg: reg 
                generic map (dataSize => dataSize)
                    port map (
                        clock   => clock,
                        reset   => reset,
                        enable  => write_enable_decoded(i),
                        d       => d,
                        q       => banco_sinais(i)   -- A saida eh guardada na posicao correspondente do array
                    );
        end generate reg_normal;

        -- Caso 2: Registrador X31 ou XZR
        reg_zero: if i = 31 generate 
            -- Nao ha instancia do componente 'reg' aqui, apenas forcamos o sinal para 0
            banco_sinais(i) <= (others => '0');
        end generate reg_zero; 

    end generate gerador_regs;

    q1 <= banco_sinais(to_integer(unsigned(rr1)));
    q2 <= banco_sinais(to_integer(unsigned(rr2)));

end architecture arch_regfile;
