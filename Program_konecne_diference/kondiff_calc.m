function [xres, yres, presnost_out, krok_out, msg] = kondiff_calc(difeq,RHS,a,b,ya,yb,presnost,max_iter)
%vytvor sit, krok vzdy mensi ako 1
if ((b-a)>=2)
    krok_start = 0.5; %ak je rozsah vacsi ako 2 tak krok 0.5
else
    krok_start = (b-a)/4; %ak je rozsah maly <2, krok stvrtina rozsahu
end

syms x y_ip y_i y_in h

%estrahovanie koericientov pri yi+1. yi, yi-1 do premennej c
[c ref] = coeffs(difeq,[y_ip y_i y_in]);
%c(1) je koeficient pri y_i+1
%c(2) je koeficient pri y_i
%c(3) je koeficient pri y_i-1
%koeficieny su funkcie h a x


%overenie jednoznacnosti riessenia. Ci matica bude diagonalne dominantna. 
%overenie je iba na kontrolu uzivatlskeho zadania. Uzivatel si MUSI overit
%jednoznacnost riesenia. Tato funkcia nezarucuje 100% istotu ze sustava je
%riesitelna ak vyhodnoti ze je riesitelna!
if (over_jednoznacnost(c,a,b,100)==0)
    xres = 0;
    yres = 0;
    presnost_out = Inf;
    krok_out = Inf;
    msg = 'Nedá sa rozhodnú jednoznaènos riesenia!';
    return;
end

%samotny algoritmus na metodu.
krok_actual = krok_start;

for q=1:max_iter

    c_actual = subs(c,h,krok_actual);
    c_actual = eval(c_actual); %urob cisla zo symbolickeho zapisu

    RHS_actual = subs(RHS,h,krok_actual);
    RHS_actual = eval(RHS_actual);

    xh = a+krok_actual : krok_actual : b-krok_actual;    
    n = length(xh);
    diagn(1:n-1)= eval(subs(c_actual(3),x,xh(2:n)));
    diagp(1:n-1)= eval(subs(c_actual(1),x,xh(1:n-1)));
    diaghl (1:n)= eval(subs(c_actual(2),x,xh));

    A = diag(diagn,-1) + diag(diaghl) + diag(diagp,1);  % matice soustavy
    F(1:n) = eval(subs(RHS_actual,x,xh));
    F(1) = F(1) - eval(subs(c_actual(3),x,xh(1)))*ya;
    F(n) = F(n) - eval(subs(c_actual(1),x,xh(n)))*yb;

    %debug, vypis cislo iteracie a velkost matice.
    s=size(F);
    iter_sizeA = [q s(2)]
    
    disp('Cas inverzna matica:');
    tic
    %matlab inverzna matica
    %https://www.mathworks.com/help/matlab/ref/inv.html
    Y1 = A\F'; %akualny vysledok
    toc

if (q==max_iter)
    msg = sprintf('Presnos nedosiahnutá po %d iteráciách!',q);
    presnost_out = max(abs(abs(Y0) - abs(Y1(2:2:n))));
    krok_out = krok_actual;
    xres = [a xh b]';
    yres = [ya Y1' yb]';
    return; 
end
    
if (q>1) %vzdy sa musia vykonat aspon 2 iteracie, aby bolo ako vyhodnotit presnost
   %vyhodnotenie
   %Y0 je minuly vypocet, Y1 je aktualny
   %porovnanie v uzlovych bodoch, absolutna hodnota.
   if (presnost > max(abs(abs(Y0) - abs(Y1(2:2:n)))))
       presnost_out = max(abs(abs(Y0) - abs(Y1(2:2:n))));
       krok_out = krok_actual;
       xres = [a xh b]';
       yres = [ya Y1' yb]';
       msg = 'Vypocet prebehol uspesne!';
       return;
   end
end
%polovicny krok a opakuj vypocet
krok_actual = krok_actual/2;
Y0 = Y1; %aktualny vypocet kopia do minuleho


end

end
