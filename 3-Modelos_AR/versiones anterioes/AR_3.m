%
% Este script se utiliza para generar un modelo AR con los datos filtrados
% Con filtro FIR no causal
%
%% Cargamos los datos
clear, clc, close all
% Carpeta con las funciones
addpath('matlab_fun')

% Cargamos los datos
dat = csvread('data\datos.csv', 1);      
s0 = dat(:,4);                          % Columna 2 -> datos filtrados

dat = csvread('data\datos_train.csv', 1);   
s0_train = dat(:,4);                        % Columna 2 -> datos raw

dat = csvread('data\datos_test.csv', 1);     
s0_test = dat(:,4);                         % Columna 2 -> datos raw

%% Entrenamiento de los modelos

% Generamos el modelo
na_max = 150;
rmse_train_vec = zeros(1, na_max);
rmse_test_vec = zeros(1, na_max);
theta_matrix = zeros(na_max, na_max);
for na=1:na_max     % Orden del modelo
    
    % Entrenamos el modelo
    sys = ar(s0_train, na, 'ls');   % modelo AR

    % Extraemos el vector theta
    theta = sys.A(2:end);       % El primero termino siempre es 1
    theta = transpose(theta);% Se debe transponer el vector (tamano [nax1])
    theta_matrix(1:na,na) = theta;
    % Generamos la matriz phi para train y test
    phi_train = zeros(na, length(s0_train)-na+1);
    for i=1:(length(s0_train)-na+1)
        phi_train(:,i) = flip(-s0_train(i:i+na-1));
    end

    phi_test = zeros(na, length(s0_test)-na+1);
    for i=1:(length(s0_test)-na+1)
        phi_test(:,i) = flip(-s0_test(i:i+na-1));
    end

    % Realizamos la prediccion de 6 pasos adelante para train y test
    k_step_train = k_pasos_prediccion(theta, phi_train, 6);
    s_hat6_train = k_step_train(6,:);

    k_step_test = k_pasos_prediccion(theta, phi_test, 6);
    s_hat6_test = k_step_test(6,:);

    % Calculamos la metrica
    error_train = transpose(s0_train(na+6:end))- s_hat6_train(1:end-6);
    rmse_train = RMSE(error_train);
    rmse_train_vec(na) = rmse_train;
    
    error_test = transpose(s0_test(na+6:end)) - s_hat6_test(1:end-6);
    rmse_test = RMSE(error_test);
    rmse_test_vec(na) = rmse_test;
    
    fprintf('-- na = %i --\n', na)
    fprintf('RMSE train:  %f\n', rmse_train);
    fprintf('RMSE test:   %f\n', rmse_test);
    fprintf('\n')
end

%% Graficamos los desempenos del RMSE
figure(1)
set(gcf, 'Position', [10 250 800 350])
%movegui(fig1,[0, 250]);
hold on
plot(rmse_train_vec,'b')
plot(rmse_test_vec,'r')
grid minor
%legend('RMSE train', 'RMSE test')
title('Gráfico de error en funcion de n_a')
xlabel('n_a')
ylabel('error [mg/dL]')
saveas(gcf, 'figs/AR_3_err_1.pdf')
%% Grafico de theta
figure(2);
set(gcf, 'Position', [750 250 800 300])
hold on
for i=1:length(theta_matrix)
    stem(theta_matrix(1:i,i),'x-')
end

xlim([0.5, 150])
%ylim([-2.5 2.5])
legend({'n_a=1', 'n_a=2', 'n_a=3'})
grid on
title('Gráfico de parametros theta en funcion de n_a')
xlabel('Indices de theta')
ylabel('Valores de theta')
saveas(gcf, 'figs/AR_3_theta.pdf')
%% Modelo AR obtenido
% Se escoge el modelo AR(20) (en funcion de los graficos de theta)
na = 80;
fprintf('\n')
fprintf('--------------------------------\n')
fprintf('Modelo escogido: AR(%i)\n', na);

% Entrenamos el modelo
sys = ar(s0_train, na, 'ls');   % modelo AR

theta = sys.A(2:end);       % El primero termino siempre es 1
theta = transpose(theta);   % Se debe transponer el vector (tamano [nax1])
theta_na2 = theta;

% Generamos la matriz phi para train y test
phi_train = zeros(na, length(s0_train)-na+1);
for i=1:(length(s0_train)-na+1)
    phi_train(:,i) = flip(-s0_train(i:i+na-1));
end

phi_test = zeros(na, length(s0_test)-na+1);
for i=1:(length(s0_test)-na+1)
    phi_test(:,i) = flip(-s0_test(i:i+na-1));
end

% Realizamos la prediccion de 6 pasos adelante para train y test
k_step_train_na2 = k_pasos_prediccion(theta, phi_train, 6);
s_hat6_train = k_step_train_na2(6,:);

k_step_test_na2 = k_pasos_prediccion(theta, phi_test, 6);
s_hat6_test = k_step_test_na2(6,:);

% Calculamos la metrica
error_train = transpose(s0_train(na+6:end))- s_hat6_train(1:end-6);
rmse_train = RMSE(error_train);

error_test = transpose(s0_test(na+6:end)) - s_hat6_test(1:end-6);
rmse_test = RMSE(error_test);

fprintf('-- na = %i --\n', na)
fprintf('RMSE train:  %f\n', rmse_train);
fprintf('RMSE test:   %f\n', rmse_test);
fprintf('\n')

fprintf('mean train:  %f\n', mean(error_train));
fprintf('mean test:   %f\n', mean(error_test));
fprintf('\n')

fprintf('std train:  %f\n', std(error_train));
fprintf('std test:   %f\n', std(error_test));

%% Grafico en el tiempo
plot_6(s0_test, s_hat6_test, na)
set(gcf, 'Position', [050 050 800 300])
saveas(gcf, 'figs/AR_3_time_serie.pdf')

%% Gráfico de error
figure(4)
set(gcf, 'Position', [050 050 800 500])
subplot(2, 1, 1)
plot(error_train)
legend('Error train')
xlabel('tiempo discreto [n=5min]')
ylabel('glucosa [mg/dL]')
%ylim([-5 5])
grid minor

subplot(2, 1, 2)
plot(error_test)
legend('Error test')
xlabel('tiempo discreto [n=5min]')
ylabel('glucosa [mg/dL]')
%ylim([-5 5])
grid minor
saveas(gcf, 'figs/AR_3_error_grafico.pdf')
%% Guardamos los datos
csvwrite('data\AR_3_theta.csv',theta_matrix)
csvwrite('data\AR_3_pred_train.csv', k_step_train_na2)
csvwrite('data\AR_3_pred_test.csv', k_step_test_na2)



% Conclusiones:
% Un filtro FIR puede obtener un muy buen performance, pero tambien
% genera parametros de theta que inestabilizan el sistema (a_n muy
% grandes), lo que vuelve al modelo muy suceptible al ruido.
% 
% De todos modos se puede concluir teoricamente se podria estimar bien
% la senal si se cuenta con un modelo para el ruido, lo que sugiere
% un modelo ARMA por ejemplo