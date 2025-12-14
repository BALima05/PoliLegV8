# :wrench: Implementação do adder
O somador binário tem como testagem a verificação do seu funcionamento adequado, garantindo que sua saída e seu carry-out estão corretos. Os casos de teste envolvem:
- Soma sem carry-out, para verificar a integridade da soma sem overflow;
- Soma com carry-out, para verificar a integridade da soma e o funcionamento do sinal cOut, que juntamente com o último teste validarão a propagação do carry;
- Soma resultando no valor máximo de 4 bits, verificando o limite antes do carry-out;
- Soma entre zeros, verificando a validação do resultado e a identidade da soma com zero.