# :wrench: Implementação do Deslocador de 2 bits
O testbench do Deslocador Assíncrono de 2 bits à esquerda tem em sua implementação a verificação do funcionamento de deslocamentos simples e de cenários extraordinários, como overflow e a testagem do preenchimento de forma correta. A implementação dos casos são os seguintes:
- Verificação do deslocamento simples, garantindo que o valor esperado seja retornado;
- Overflow, garantindo que os valores dos dois bits mais significativos serão descartados corretamente e que o resto do vetor será preenchido corretamente;
- Teste com o vetor cheio, para ver se apenas os últimos dois bits são preenchidos com zero, garantindo que o preenchimento está correto;
- Teste do deslocamento no limite do vetor, garantindo que o bit será deslocado para o MSB corretamente.

Com esses testes, será verificado se o preenchimento com '00' será feito corretamente, independente da entrada, se o truncamento à esquerda está funcionando, garantindo que os dois bits à esquerda serão descartados sem afetar o resto do vetor e garantindo que este funciona de forma assíncrona.