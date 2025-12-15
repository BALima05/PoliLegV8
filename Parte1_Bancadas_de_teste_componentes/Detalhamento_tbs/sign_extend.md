# :wrench: Implementação do Extensor de Sinal
A testagem do extensor de sinal com tamanho configurável envolve a testagem da replicação correta do MSB (most significant bit), e portanto os casos de testagem revolvem ao redor dessa replicação e de ser feita com o bit certo. Portanto, desenvolvem-se os seguintes casos de testagem:
- Primeiro testa-se a extensão de um número positivo, verificando se foram extendidos '0';
- Testa-se números negativos, verificando se foram extendidos '1';
- Depois testa-se o campo deslocado no meio do vetor, garantindo que o valor da saída irá conter os valores úteis e a extensão correta;
- Testar o limite de conter apenas 1 bit, verificando se a extensão será feita corretamente;