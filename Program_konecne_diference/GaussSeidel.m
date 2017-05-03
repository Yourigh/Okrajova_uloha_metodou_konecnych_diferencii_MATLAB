function [Y, success] = GaussSeidel(A,b,presnost,max_it,ya,yb)
n = length(b);
%tu bude vysledok, ako zaciatocna 
%hodnota je priamka prepojujuca okrajove podm
%ak nie su dirichletove, vstup je 0,0
Y = linspace(ya,yb,n)'; 
chyba = 1e10*ones(n,1);

%% Ay=f riesim y
it = 0; %pocitadlo iteracii
while max(chyba) > presnost %opakuj pokial nebude dost presne
    it = it + 1; %na zastavenie nekonecnej slucky
    if (it > max_it)
       success = 0;
       return; 
    end
    Xold = Y;  % ulozit hodnoty aby sa dala porovnat chyba
    for i = 1:n  %vsetky rovnice
        j = 1:n; % pocitat cez vsetky stlpce
        j(i) = [];  % okrem stlpca i
        Xtemp = Y;  % kopia
        Xtemp(i) = [];  % nepocita sa s xi
        Y(i) = (b(i) - sum(A(i,j) * Xtemp)) / A(i,i);
        %v dalsej iteracii pouzije vysledky z 
        %predchadzajucej pre uz vypocitane Y
    end
    chyba = abs(abs(Y) - abs(Xold));
end
success = 1; %konvergovalo s menej ako max_it iteraciami
end