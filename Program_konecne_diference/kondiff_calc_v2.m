function [xres, yres, presnost_out, krok_out, msg]...
  = kondiff_calc_v2(difeq,RHS,podm_a,podm_b,presnost,...
  max_iter,over_jednoznacost)
%% logika na podmienky, dirichlet alebo obecne
a = podm_a(1);
a_alfa1 = podm_a(2);
a_alfa2 = podm_a(3);
if (a_alfa2 == 0)
    if (a_alfa1 == 0)
       msg='Zle zadané okraj. podm.';
       xres = 0;
       yres = 0;
       presnost_out = Inf;
       krok_out = Inf;
       return; 
    end
    %podmienka nie je derivacia, 
    %podmienka je dirichletova
    a_dirichlet = 1;
    ya=podm_a(4)/a_alfa1;
else
    a_dirichlet = 0;
    a_RHS = podm_a(4);
end
b = podm_b(1);
b_beta1 = podm_b(2);
b_beta2 = podm_b(3);
if (b_beta2 == 0)
    if (b_beta1 == 0)
       msg='Zle zadané okraj. podm.';
       xres = 0;
       yres = 0;
       presnost_out = Inf;
       krok_out = Inf;
       return; 
    end
    b_dirichlet = 1;
    yb=podm_b(4)/b_beta1;
else
    b_dirichlet = 0;
    b_RHS = podm_b(4);
end
%% krok site, krok vzdy mensi ako 1
if ((b-a)>=2)
    %ak je rozsah vacsi ako 2 tak krok 0.5
    krok_start = 0.5; 
else
    %ak je rozsah maly <2, krok stvrtina rozsahu
    krok_start = (b-a)/4; 
end
%% extrahovanie koeficientov pre maticu
syms x y_ip y_i y_in h
%extrahovanie funkcii koeficientov pri 
%yi+1. yi, yi-1 do vektrou c
[c ref] = coeffs(difeq,[y_ip y_i y_in]);
%c(1) je koeficient pri y_i+1
%c(2) je koeficient pri y_i
%c(3) je koeficient pri y_i-1
%koeficieny su funkcie h a x

%% jednoznacost?
if (over_jednoznacost)
    %overenie jednoznacnosti riessenia. Ci matica bude 
    %diagonalne dominantna. overenie je iba na kontrolu 
    %uzivatlskeho zadania. Uzivatel si MUSI overit 
    %jednoznacnost riesenia. Tato funkcia nezarucuje 
    %100% istotu ze sustava je riesitelna ak vyhodnoti 
    %ze je riesitelna!
    if (over_jednoznacnost(c,a,b,100)==0)
        xres = 0;
        yres = 0;
        presnost_out = Inf;
        krok_out = Inf;
        msg = 'Nedá sa rozhodnú jednoznaènos riesenia!';
        return;
    end
end
%% samotny algoritmus na metodu.
krok_actual = krok_start;
for q=1:max_iter
    %subituce kroku
    c_actual = subs(c,h,krok_actual);%k-1,k1,k+1
    c_actual = eval(c_actual); 
    RHS_actual = subs(RHS,h,krok_actual);%prava strana
    RHS_actual = eval(RHS_actual);
    %vyrvorenie site
    xh = a+krok_actual : krok_actual : b-krok_actual;    
    n = length(xh); %pocet rovnic
    %vutvor tridiag maticu A
    diagn(1:n-1)= eval(subs(c_actual(3),x,xh(2:n)));
    diagp(1:n-1)= eval(subs(c_actual(1),x,xh(1:n-1)));
    diaghl (1:n)= eval(subs(c_actual(2),x,xh));
    A = diag(diagn,-1) + diag(diaghl) + diag(diagp,1);
    %prava strana, tiez dosadit sit
    F(1:n) = eval(subs(RHS_actual,x,xh));
    if (a_dirichlet == 1) %zaciatocna podm dirichletova
        F(1) = F(1) - eval(subs(c_actual(3),x,xh(1)))*ya;
    else %nie dirichletova
        %pridat stlpec do matice A ako prvy, hodnota y(a)
        %sa bude pocitat v sustave
        A_a = zeros(n,1); %stlpec
        A_a(1) = eval(subs(c_actual(3),x,xh(1)));
        A = [A_a A]; %pridanie do matice
        %ROVNICA (1.16)
        %pridat dalsiu rovnicu do sustavy na zaciatok
        %a_RHS=gamma1,a_alfa1,a_alfa2 su k dispozicii
        %rovnica  (a_alfa1 - 3*a_alfa2/(2*h))*y_0 + 
        %(4*a_alfa2/(2*h))*y_1 + (-a_alfa2/(2*h))*y_2= a_RHS
        a_LHS = zeros(1,n+1);
        a_LHS(1) = (a_alfa1 - 3*a_alfa2/(2*krok_actual));
        a_LHS(2) = (4*a_alfa2/(2*krok_actual));
        a_LHS(3) = (-a_alfa2/(2*krok_actual));
        
        %rovnica nastavena, teraz maticova uprava 
        %aby bola A tridiagonalna po pripojeni a_LHS
        %na prvy riadok. cize vynulovat prvok a_LHS(3)
        factor_to_tridiag = -a_LHS(3)/A(1,3);
        %prvy riadok A sa vynasobi faktorom a pricita k a_LHS
        a_LHS = a_LHS + (factor_to_tridiag.*A(1,:));
        %to iste na pravej strane
        a_RHS_actual = a_RHS + (factor_to_tridiag*F(1));
        
        %rovnica je teraz pripravena na spojenie s A
        A = [a_LHS;A];
        F = [a_RHS_actual,F];
        
        %inkrementuj n lebo som pridal novu rovnicu, 
        %riesenie bude aj pre zaciatocny bod y(a)
        xh = [a xh];
        n=n+1;
    end
    
    if (b_dirichlet == 1) %podobne ako so zaciatocnou
        F(n) = F(n) - eval(subs(c_actual(1),x,xh(n)))*yb;
    else
        %pridat stlpec do matice A, pre koncovy bod yb
        A_b = zeros(n,1);
        A_b(n) = eval(subs(c_actual(1),x,xh(n)));
        A = [A A_b];
        %rovnica  (b_beta2/(2*h))*y_inn + (-4*b_beta2/(2*h))
        %*y_in + (b_beta1 + 3*b_beta2/(2*h))*y_i = b_RHS
        b_LHS = zeros(1,n+1);
        b_LHS(n+1) = (b_beta1 + 3*b_beta2/(2*krok_actual));
        b_LHS(n)   = (-4*b_beta2/(2*krok_actual));
        b_LHS(n-1) = (b_beta2/(2*krok_actual));
        
        %rovnica nastavena, teraz maticova uprava aby bola 
        %A tridiagonalna po pripojeni b_LHS na posledny riadok.
        factor_to_tridiag = -b_LHS(n-1)/A(n,n-1);
        %posledny riadok A sa vynasobi faktorom a pricita k b_LHS
        b_LHS = b_LHS + (factor_to_tridiag.*A(n,:));
        %to iste na pravej strane
        b_RHS_actual = b_RHS + (factor_to_tridiag*F(n));
        %rovnica je teraz pripravena na spojenie s A
        A = [A;b_LHS];
        F = [F, b_RHS_actual];
        %riesenie bude aj pre koncovy bod: y(b)
        xh = [xh b];
        n=n+1;
    end
    
    %debug, vypis cislo iteracie a velkost matice
    fprintf(1,'Iteracia kon.diff:%2d,velkost matice: %5d\n',q,n);
    
    %DVE METODY RIESENIA SUSTAVY
    metoda = 2;
    if metoda ==1 
        %#1 Gauss-Seidelova metoda
        if (a_dirichlet==1)&&(b_dirichlet==1)
            start_ya = ya;start_yb = yb;
        else
            start_ya = 0;start_yb = 0;
        end
        %disp('Cas Gauss-Sidel:'); tic
        max_it_SG = 3000;
        [Y1, successSG] = GaussSeidel(A,F',presnost/200,...
            max_it_SG,start_ya,start_yb);
        %toc
        if (successSG ==0)
            %popisane nizsie
            if (b_dirichlet == 0)b = [];yb = [];end
            if (a_dirichlet == 0)a = [];ya = [];end
            xres = [a xh b]';
            yres = [ya Y1' yb]';
            presnost_out = max(abs(abs(Y0) - abs(Y1(2:2:n))));
            krok_out = krok_actual;
            msg = ...
             sprintf('Gauss-Seidel nekonverguje po %d iter.!'...
             ,max_it_SG);
           return; 
        end
    else
        %#2 Matlab metoda
        %disp('Cas matlab /:');tic;
        Y1 = eval(vpa(mldivide(A,F'),32));
        %toc;
        [msg,msgid]=lastwarn;
        if strcmp(msgid,'MATLAB:nearlySingularMatrix')
            xres = [a xh b]';
            yres = [ya Y1' yb]';
            if q>1
                presnost_out = max(abs(abs(Y0) - abs(Y1(2:2:n))));
            else
                presnost_out = presnost;
            end
            krok_out = krok_actual;
            msg = ...
            sprintf('Vypocet nedosiahol presnost!');
            warning('Vypocet skoncil');%na vymazanie chyby
            return;
        end
    end
if (q==max_iter)
    msg = sprintf('Presnos nedosiahnutá po %d iteráciách!',q);
    presnost_out = max(abs(abs(Y0) - abs(Y1(2:2:n))));
    krok_out = krok_actual;
    if (b_dirichlet == 0)
       b = [];
       yb = [];
    end
    if (a_dirichlet == 0)
       a = [];
       ya = [];
    end
    xres = [a xh b]';
    yres = [ya Y1' yb]';
    return; 
end
    
if (q>1) %vzdy sa musia vykonat aspon 2 iteracie, 
   %aby bolo ako vyhodnotit presnost; vyhodnotenie
   %Y0 je minuly vypocet, Y1 je aktualny
   %porovnanie v uzlovych bodoch, absolutna hodnota.
   if (a_dirichlet == 1)
        presnost_out = max(abs(abs(Y0) - abs(Y1(2:2:n))));
   else
        presnost_out = max(abs(abs(Y0) - abs(Y1(1:2:n))));
   end
   if (presnost > presnost_out)
       krok_out = krok_actual;
        if (b_dirichlet == 0) 
            %bod b a riesenie je vo vektore xh a Y1, 
            %takze sa nepridava z okrajovych podmienok
            b = [];
            yb = [];
        end
        if (a_dirichlet == 0) 
            %bod a a riesenie je vo vektore xh a Y1, 
            %takze sa nepridava z okrajovych podmienok
            a = [];
            ya = [];
        end
       xres = [a xh b]';
       yres = [ya Y1' yb]';
       msg = 'Výpoèet prebehol úspešne!';
       return;
   end %presnost
end %q>1
%polovicny krok a opakuj vypocet
krok_actual = krok_actual/2;
Y0 = Y1; %aktualny vypocet kopia do minuleho
end %iteracie koecnych diferencii
end %function