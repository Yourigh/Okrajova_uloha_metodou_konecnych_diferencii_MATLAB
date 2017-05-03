function riesitelne = over_jednoznacnost(koeficienty,a,b,n)

%%
%overenie riesitelnosti, nie idalne iba ako tak na 100 bodov
syms x y_ip y_i y_in h
x_span = linspace(a,b,n);
%krok eval 
c_notH = subs(koeficienty,h,(b-a)/(n+1));
diag_max = max(abs(eval(subs(c_notH(2),x_span))));
sum_tri_max = max(abs(eval(subs(c_notH(1),x_span)+abs(subs(c_notH(3),x_span)))));

if (diag_max == sum_tri_max)
    disp('Neostre diagonalne dominantna')
    sum_tri_max1 = max(abs(subs(c_notH(1),x_span)));
    sum_tri_max2 = max(abs(subs(c_notH(3),x_span)));
    if (diag_max > sum_tri_max1)||(diag_max > sum_tri_max2)
        disp('Mininalne jedna ronica ostra, OK');
        riesitelne = 1;
    else
        riesitelne = 0;
        disp('Neda sa rozhodnut jednoznacnost riesenia!')
    end
else
    if (diag_max < sum_tri_max)
        riesitelne = 0;
        disp('Neda sa rozhodnut jednoznacnost riesenia! nie je diagonalne dominantna')
    else
        riesitelne = 1;
        disp('Diagonalne dominantna')
    end
end
end