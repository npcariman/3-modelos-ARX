%% Cargamos la base de datos
clear, clc, close all

addpath('matlab_fun')

% Abrimos la base de datos de los datos de y filtrados
instance = 'cgm_filtrado';
username = 'root';
password = '7461143';
conn = database(instance, username, password, 'Vendor', 'MySQL');

% Datos de y de training
curs = exec(conn, 'SELECT * FROM y_train');
curs = fetch(curs);
data = curs.Data;
y_0_train = cell2mat(data(:,2));
y_sv_train = cell2mat(data(:,3));
y_mm_train = cell2mat(data(:,4));

% Datos de y de test
curs = exec(conn, 'SELECT * FROM y_test');
curs = fetch(curs);
data = curs.Data;
y_0_test = cell2mat(data(:,2));
y_sv_test = cell2mat(data(:,3));
y_mm_test = cell2mat(data(:,4));

% Cerramos la conexion
close(conn);

% Abrimos la base de datos de los datos de y filtrados
instance = 'input_u';
username = 'root';
password = '7461143';
conn = database(instance, username, password, 'Vendor', 'MySQL');

% Datos de y de training
curs = exec(conn, 'SELECT * FROM u_bolo_fir_train');
curs = fetch(curs);
data = curs.Data;
u_bolo_delta_train = cell2mat(data(:,2));
u_bolo_gaus_train = cell2mat(data(:,3));
u_bolo_hov_train = cell2mat(data(:,4));
u_bolo_biexp_train = cell2mat(data(:,5));
u_bolo_rem_train = cell2mat(data(:,6));

% Datos de y de test
curs = exec(conn, 'SELECT * FROM u_bolo_fir_test');
curs = fetch(curs);
data = curs.Data;
u_bolo_delta_test = cell2mat(data(:,2));
u_bolo_gaus_test = cell2mat(data(:,3));
u_bolo_hov_test = cell2mat(data(:,4));
u_bolo_biexp_test = cell2mat(data(:,5));
u_bolo_rem_test = cell2mat(data(:,6));

% Cerramos la conexion
close(conn);
clc
%% Trabajamos con los datos
y_train = y_0_train;
u_train = u_bolo_hov_train;
data_train = [y_train, u_train];
fprintf('N de train: %i\n', length(data_train))

y_test = y_0_test;
u_test = u_bolo_hov_test;
data_test = [y_test, u_test];

fprintf('N de test:  %i\n', length(data_test))
%% Entrenamos el sistema
n = 2;
na = n;
nb = 0;
nk = 1;
n_max = max([na, nb]);
k_step = 6;

sys = arx(data_train, [na nb nk]);

A = sys.A;
A = A(2:end);
B = sys.B;
B = B(nk+1:end);
theta = [A B];
theta = theta';

%% Generacion de matriz phi y prediccion

prediccion_train = ARX_k_step(data_train, theta, [na nb], k_step);
y_hat6_train = prediccion_train(6,:);

prediccion_test = ARX_k_step(data_test, theta, [na nb], k_step);
y_hat6_test = prediccion_test(6,:);


%% Grafico de la serie de tiempo
plot_6(y_test, y_hat6_test, na)
set(gcf, 'Position', [050 050 800 300])

%% Calculo de metricas
error_train = y_hat6_train' - y_train(n_max+k_step + 1:end);
rmse_train = sqrt(mean((error_train).^2));

error_test = y_hat6_test' - y_test(n_max+k_step + 1:end);
rmse_test = sqrt(mean((error_test).^2));


fprintf('-- na = %i --\n', na)
fprintf('RMSE train:  %f\n', rmse_train);
fprintf('RMSE test:   %f\n', rmse_test);
fprintf('\n')

fprintf('mean train:  %f\n', mean(error_train));
fprintf('mean test:   %f\n', mean(error_test));
fprintf('\n')

fprintf('std train:  %f\n', std(error_train));
fprintf('std test:   %f\n', std(error_test));




