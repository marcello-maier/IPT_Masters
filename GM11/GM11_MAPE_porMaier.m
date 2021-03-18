%Create symbolic variable a(Development coefficient)And b(Ash effect)
syms a b;
c = [a b]';

%Original sequence A
%A=input('Please enter the original sequence (format [1.5, 2.1, 3.3, 4.6, 5.7]): ');
arq='serv3_diskminmb_janfevmar_v2.csv'     % Le arquivo CSV com dados originais
h1=dlmread(arq,';');           % h1 = le a matriz com os dados originais (usada apenas para contabilizar a qtde de linhas)
A = h1';                       % IMPORTANTE: H1 E UM VETOR (EM PE) E ESTE PROGRAMA USA O VETOR A DEITADO, POR ISSO A=H1'
m=input('Please enter the number of data to be predicted in the future: ');
n = length(A);

%Accumulate the original sequence A to get the sequence B
B = cumsum(A);

%Logarithmic sequence B is generated next to the mean
for i = 2:n
    C(i) = (B(i) + B(i - 1))/2; 
end
C(1) = [];

%Construct the data matrix 
B = [-C;ones(1,n-1)];
Y = A; Y(1) = []; Y = Y';

%Use least squares method to calculate parameter a(Development coefficient)And b(Ash effect)
c = inv(B*B')*B*Y;
c = c';
a = c(1); b = c(2);

%Forecast follow-up data
F = []; F(1) = A(1);
for i = 2:(n+m)
    F(i) = (A(1)-b/a)/exp(a*(i-1))+ b/a;
end

%Logarithmic sequence F accumulatively reduce,Get the predicted data
G = []; G(1) = A(1);
for i = 2:(m)%(n+m)
    G(i) = F(i) - F(i-1); %Get predicted data
end
disp('The forecast data is:');
P = G'



%Model checking

%H = G(1:10);
% IMPORTANTE: H CONTEM A SEQUENCIA RESIDUAL. AO INVES DE USARMOS O VALOR FIXO 10 (PROGRAMA ORIGINAL)
% estamos usando o valor n que corresponde ao tamanho do vetor de entrada.
% Isso foi feito para garantir o tamanho das matrizes para o calculo da
% sequencia residual
%H = G(1:n);     
%Calculate the residual sequence
%epsilon = A - H;

%C test of variance ratio
%C = std(epsilon, 1)/std(A, 1)
%if C<0.35
%    disp('System prediction accuracy is good')
%%else if C<0.5
%        disp('System prediction accuracy is qualified')
%    else if C<0.65
%            disp('System prediction accuracy is barely accurate')
%        else
%            disp('The system prediction accuracy is unqualified')
%        end
%    end
%end


%====== calculo do MAPE  ===================================
% Apenas ate a quantidade n
Gerr = [0];    % erro relativo absoluto
MAPE = 0;       % Mean Absolute percentage Error (MAPE): indica o desempenho da predicao
for k = 2: 1: n
    if (k <= n)
        Gerr = [Gerr (abs(A(k)-G(k))/A(k))];
    MAPE = MAPE + (Gerr(k)/n)*100;
       end

end
MAPE
if MAPE<10
    disp('High Forecasting')
else if (MAPE>10) && (MAPE<20)
        disp('Good forecasting')
    else if (MAPE>20) && (MAPE<50)
            disp('Reasonable forecasting')
        else
            disp('Weak forecasting')
        end
    end
end
%====== fim do calculo do MAPE ============================

