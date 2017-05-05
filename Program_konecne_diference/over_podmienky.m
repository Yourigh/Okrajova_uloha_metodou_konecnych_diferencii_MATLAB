function [ok_subs_center, ok_subs_pos] = over_podmienky(...
    b,c,d,start,stop,n)
x_span = linspace(start,stop,n);
h = x_span(2)-x_span(1);
syms x
bx = eval(b);
cx = eval(c);
dx = eval(d);
%podmienka pre subs_yd center = '(((y_ip-y_in)/2)*h)';
pml_c = abs(eval(subs(2*bx+cx*h-dx,x,x_span)));%p minus l
p_c = abs(eval(subs(2*bx+cx*h,x,x_span)));%p
%figure(1);plot(x_span,pml_c,x_span,p_c);title('center');

%podmienka pre subs_yd positive = '((y_ip-y_i)*h)';
pml_p = abs(eval(subs(2*bx-dx,x,x_span)));
p_p = abs(eval(subs(2*bx,x,x_span)));
%figure(2);plot(x_span,pml_p,x_span,p_p);title('positive');

ok_subs_pos = 1; %prepokladam ze splnene
ok_subs_center = 1;
for i=1:n %ak nastane podmienka, nastavi do 0
   if (pml_c(i) < p_c(i))
       ok_subs_center = 0;
   end
   if (pml_p(i) < p_p(i))
       ok_subs_pos = 0;
   end
end
end