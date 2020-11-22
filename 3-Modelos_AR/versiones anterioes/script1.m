%% Cargamos los datos
clear, clc, close all
% Funciones
addpath('matlab_fun')

% Datos
datos1 = csvread('datos1.csv', 1);
s0 = datos1(:,2);
s1 = datos1(:,3);
s2 = datos1(:,4);

datos2 = csvread('datos2.csv', 1);
s0_diff = datos2(:,2);
s1_diff = datos2(:,3);
s2_diff = datos2(:,4);

%% Modelos
% Generamos el modelo
na = 30;                 % Orden del modelo
sys = ar(s0, na);       % modelo AR

% Extraemos el vector theta
theta = sys.A(2:end);       % El primero termino siempre es 1
theta = transpose(theta);   % Se debe transponer el vector (tamano [nax1])

% Generamos la matriz phi
phi = zeros(na, length(s0)-na+1);
for i=1:(length(s0)-na+1)
    phi(:,i) = flip(-s0(i:i+na-1));
end
% Primera prediccion
s0_hat1 = transpose(theta) * phi;

% Actualizamos la matriz phi y predecimos
phi = [-s0_hat1; phi];
phi = phi(1:na, :);
s0_hat2 = transpose(theta) * phi;

phi = [-s0_hat2; phi];
phi = phi(1:na, :);
s0_hat3 = transpose(theta) * phi;

phi = [-s0_hat3; phi];
phi = phi(1:na, :);
s0_hat4 = transpose(theta) * phi;

phi = [-s0_hat4; phi];
phi = phi(1:na, :);
s0_hat5 = transpose(theta) * phi;

phi = [-s0_hat5; phi];
phi = phi(1:na, :);
s0_hat6 = transpose(theta) * phi;




%% Graficamos
close
plot_6(s0, s0_hat6, na)
plot_todo(s0, s0_hat1, s0_hat2, s0_hat3, s0_hat4, s0_hat5, s0_hat6, na)


%% Metricas
error = transpose(s0(na+6:end))- s0_hat6(1:end-6);
rmse = RMSE(error);
fprintf('RMSE:        %f\n', rmse);



