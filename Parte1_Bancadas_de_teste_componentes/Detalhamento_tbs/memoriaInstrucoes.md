# :wrench: Testbench memória de instruções
A implementação da testbench da memória de instruções necessita apenas testar o acesso correto dos dados na memória, garantindo o funcionamento também combinacional e assíncrono da mesma. Segue os casos:
- Verificar a saída da instrução 0, se esta corresponde à saída esperada;
- Verificar o endereço 1;
- Verificar um endereço aleatório à frente. Com estes 3 testes funcionando, sabe-se que o endereçamento e o acesso à memória estão corretos.
- Verificação do comportamento combinacional da memória, garantindo que a saída irá se alterar conforme a alteração do endereço na entrada.