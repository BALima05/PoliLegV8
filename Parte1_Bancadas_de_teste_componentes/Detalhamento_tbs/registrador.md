# :wrench: Testbench do Registrador

Para o registrador, os casos de teste são os que validam o bom funcionamento do comportamento do registrador, portanto, foram definidos os seguintes casos:
- Testar o reset assíncrono, garantindo que a saída que estará em 0;
- Teste do enable:
  - Tentar escrever com enable em 0, verificando se é impedido;
  - Tentar escrever com enable em 1, garantindo que o dado será escrito.
- Verificar a retenção do dado, garantindo que q ficará disponível e manterá seu valor enquanto enable ficar desativado ou reset não for pressionado.
- Testar reset no mesmo ciclo de clock, garantindo que este funciona de forma assíncrona.