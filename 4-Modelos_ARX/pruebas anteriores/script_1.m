%% Cargamos los datos
clear, clc, close all
table = readtable('data_from_pandas.csv');  % Cargamos los datos del archivo csv
% extraemos las variables importantes
y = table2array(table(:,'y'));
u_meal = table2array(table(:,'u_meal'));
u_bolo = table2array(table(:,'u_bolo'));
clearvars table                 % Eliminamos la tabla
%% Separamos los datos de train y test
N_train = 1152;

y_train = y(1:N_train);
y_test = y(N_train+1:end);

u_meal_train = u_meal(1:N_train);
u_meal_test = u_meal(N_train+1:end);

u_bolo_train = u_bolo(1:N_train);
u_bolo_test = u_bolo(N_train+1:end);
%% Entrenamos el modelo ARX
na_max = 60;
nb_max = 60;
%% Entrenamiento para u_meal
fprintf('---------------------------------------\n')
fprintf('---   Entrenamiento para meal       ---\n')
fprintf('---------------------------------------\n')

data_train = [y_train, u_meal_train];
data_test = [y_test, u_meal_test];

RMSE_train_meal = zeros(na_max, nb_max);
RMSE_test_meal = zeros(na_max, nb_max);

for na = 1:na_max
    for nb = 1:nb_max
        sys = arx(data_train, [na, nb, 1]);
        % Realizamos la prediccion
        k = 6;
        y_train_hat = predict(sys, data_train, k);
        y_test_hat = predict(sys, data_test, k);

        % Eliminamos los primeros nb valores
        y_train_hat = y_train_hat(nb:end);
        y_train_comp = y_train(nb:end);
        y_test_hat = y_test_hat(nb:end);
        y_test_comp = y_test(nb:end);

        % Calculo del RMSE para train
        rmse_train = (y_train_hat - y_train_comp).^2;
        N = length(rmse_train);
        rmse_train = sqrt(sum(rmse_train)/N);
        RMSE_train_meal(na, nb) = rmse_train;
        
        % Calculo de RMSE para test
        rmse_test = (y_test_hat - y_test_comp).^2;
        N = length(rmse_test);
        rmse_test = sqrt(sum(rmse_test)/N);
        RMSE_test_meal(na, nb) = rmse_test;
  
        % Resultado de la prueba del modelo
        fprintf('na = %i, nb = %i \n', na, nb)
        fprintf(' - RMSE train = %2.3f, RMSE test = %2.3f\n', ...
                                            rmse_train, rmse_test)
    end
end

% Guardamos los datos
csvwrite('RMSE_train_meal.csv', RMSE_train_meal)
csvwrite('RMSE_test_meal.csv', RMSE_test_meal)

%% Entrenamiento para u_bolo
fprintf('---------------------------------------\n')
fprintf('---   Entrenamiento para bolo       ---\n')
fprintf('---------------------------------------\n')

data_train = [y_train, u_bolo_train];
data_test = [y_test, u_bolo_test];

RMSE_train_bolo = zeros(na_max, nb_max);
RMSE_test_bolo = zeros(na_max, nb_max);

for na = 1:na_max
    for nb = 1:nb_max
        sys = arx(data_train, [na, nb, 1]);
        % Realizamos la prediccion
        k = 6;
        y_train_hat = predict(sys, data_train, k);
        y_test_hat = predict(sys, data_test, k);

        % Eliminamos los primeros nb valores
        y_train_hat = y_train_hat(nb:end);
        y_train_comp = y_train(nb:end);
        y_test_hat = y_test_hat(nb:end);
        y_test_comp = y_test(nb:end);

        % Calculo del RMSE para train
        rmse_train = (y_train_hat - y_train_comp).^2;
        N = length(rmse_train);
        rmse_train = sqrt(sum(rmse_train)/N);
        RMSE_train_bolo(na, nb) = rmse_train;
        
        % Calculo de RMSE para test
        rmse_test = (y_test_hat - y_test_comp).^2;
        N = length(rmse_test);
        rmse_test = sqrt(sum(rmse_test)/N);
        RMSE_test_bolo(na, nb) = rmse_test;
  
        % Resultado de la prueba del modelo
        fprintf('na = %i, nb = %i \n', na, nb)
        fprintf(' - RMSE train = %2.3f, RMSE test = %2.3f\n', ...
                                            rmse_train, rmse_test)
    end
end

% Guardamos los datos
csvwrite('RMSE_train_bolo.csv', RMSE_train_bolo)
csvwrite('RMSE_test_bolo.csv', RMSE_test_bolo)

%% Configuraciones optimas

% Configuracion optima segun train
[~, n] = min(RMSE_train_meal(:));
[x, y] = ind2sub(size(RMSE_train_meal),n);
fprintf('Modelo que minimiza el training de meal: \n')
fprintf('- na = %i, nb = %i\n', x, y)
fprintf('- RMSE train = %2.3f \n', RMSE_train_meal(x,y))
fprintf('- RMSE test  = %2.3f \n', RMSE_test_meal(x,y))

% Configuracion optima segun test
[~, n] = min(RMSE_test_meal(:));
[x, y] = ind2sub(size(RMSE_test_meal),n);
fprintf('Modelo que minimiza el testing de meal: \n')
fprintf('- na = %i, nb = %i\n', x, y)
fprintf('- RMSE train = %2.3f \n', RMSE_train_meal(x,y))
fprintf('- RMSE test  = %2.3f \n', RMSE_test_meal(x,y))

% Configuracion optima segun train
[~, n] = min(RMSE_train_bolo(:));
[x, y] = ind2sub(size(RMSE_train_bolo),n);
fprintf('Modelo que minimiza el training de bolo: \n')
fprintf('- na = %i, nb = %i\n', x, y)
fprintf('- RMSE train = %2.3f \n', RMSE_train_bolo(x,y))
fprintf('- RMSE test  = %2.3f \n', RMSE_test_bolo(x,y))

% Configuracion optima segun test
[~, n] = min(RMSE_test_bolo(:));
[x, y] = ind2sub(size(RMSE_test_bolo),n);
fprintf('Modelo que minimiza el testing de bolo: \n')
fprintf('- na = %i, nb = %i\n', x, y)
fprintf('- RMSE train = %2.3f \n', RMSE_train_bolo(x,y))
fprintf('- RMSE test  = %2.3f \n', RMSE_test_bolo(x,y))

%% Modelos

% Modelo optimo para meal
na = 48;
nb = 6;
data_train = [y_train, u_meal_train];
sys_meal = arx(data_train, [na, nb, 1]);
csvwrite('A_meal.csv', sys_meal.A)
csvwrite('B_meal.csv', sys_meal.B)

% Modelo optimo para bolo
na = 48;
nb = 4;
data_train = [y_train, u_bolo_train];
sys_bolo = arx(data_train, [na, nb, 1]);
csvwrite('A_bolo.csv', sys_bolo.A)
csvwrite('B_bolo.csv', sys_bolo.B)

%% Modelo prueba
na = 2;
for nb = 1:60
    data_prueba = [y_train, u_meal_train, u_bolo_train];
    sys_prueba = arx(data_prueba, [na, nb, 1]);
    csvwrite('A_prueba.csv', sys_prueba.A)
    csvwrite('B_prueba.csv', sys_prueba.B)

    % Gráficos
    k = 6;
    y_test_hat = predict(sys_prueba, data_test, k);
    plot(y_test_hat, 'b')
    hold on
    plot(y_test, 'r')
    xlim([84, 371])
    ylim([0, 450])
    grid on
end

