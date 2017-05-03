%vysledky

%save('pr2_1','xres','yres','presnost_out')
T=load('aktualny_vypocet');
syms x
Xp = eval(subs(T.fexact,x,T.xres));
porov=[T.xres T.yres Xp];
porov(:,4)=porov(:,3)-porov(:,2);

figure(1); hold on
title('Absolútna chyba oproti presnému riešeniu, pr. 4');
xlabel('x');
ylabel('Chyba y(x)');
plot(porov(:,1),porov(:,4));
hold off