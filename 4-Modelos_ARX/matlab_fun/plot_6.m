function plot_6(s, s_hat6, na)
    m = length(s);      % Obtenemos el numero de puntos
    % Generamos la figura y la mantenemos
    figure()                  
    hold on
    % para s_hat_6
    t6 = na+6:length(s_hat6)+na+6-1;
    plot(t6, s_hat6, 'Color',  1/255*[240,128,128], 'LineWidth', 1.5)
    
    % Graficamos
    plot(s, 'b', 'LineWidth', 1.5)
    
    % Generamos las leyendas y parametros
    leg = {'s_0^{t+6}'; 's_0'};
    legend(leg);
    title('grafico en el tiempo')
    xlabel('tiempo discreto [n=5min]')
    ylabel('glucosa [mg/dL]')
    grid minor
    %xlim([1236,1524])