function plot_todo(s, s_hat1, s_hat2, s_hat3, s_hat4, s_hat5, s_hat6,...
    na)
    m = length(s);      % Obtenemos el numero de puntos
    % Generamos la figura y la mantenemos
    figure()                  
    hold on
    
    % para s_hat_1 
    t1 = na+1:m+1;
    plot(t1, s_hat1, 'Color',  1/255*[139,0,0])
    
    % para s_hat_2
    t2 = na+2:m+2;
    plot(t2, s_hat2, 'Color',  1/255*[128,0,0])
    
    % para s_hat_3
    t3 = na+3:m+3;
    plot(t3, s_hat3, 'Color',  1/255*[178,34,34])
    
    % para s_hat_4
    t4 = na+4:m+4;
    plot(t4, s_hat4, 'Color',  1/255*[165,42,42])
    
    % para s_hat_5
    t5 = na+5:m+5;
    plot(t5, s_hat5, 'Color',  1/255*[205,92,92])
    
    % para s_hat_6
    t6 = na+6:m+6;
    plot(t6, s_hat6, 'Color',  1/255*[240,128,128])
    
    % Graficamos la senal original
    plot(s, 'b', 'LineWidth', 1.5)
    
    % Generamos las leyendas
    leg = { 's_0^{t+1}'; 's_0^{t+2}';...
            's_0^{t+3}'; 's_0^{t+4}';...
            's_0^{t+5}'; 's_0^{t+6}';...
            's_0'};
    legend(leg);
    grid minor
    xlim([1236,1524])
end
