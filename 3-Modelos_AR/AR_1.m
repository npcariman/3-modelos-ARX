%% Limpiamos las variables
clear, clc, close all

%% Parametro
% Parametros para entrenar el sistema
n_max_order = 100;   % Orden maximo de iteracion. en este caso n=na=nb
k = 6;               % Horizonte de prediccion (6 = 30 minutos)
nk = 1;              % Tiempo muerto. Segun la definicion del libro nk = 1

% Parametros para extraer los datos de la base de datos
input_db = 'cgm_filtrado';
y_train_name = 'y_0_train';
y_test_name  = 'y_0_test';

% Parametros para guardar el RMSE en la base de datos
output_db = 'rmse';               % Base de datos
table_name = 'rmse_AR1';          % Tabla (1 para cada conjunto de y
new_columns = { 'train_y0',...
                 'test_y0'}; % Columnas
guardar_datos = true;              % Parametro para activar guardar datos


%% Carga de base de datos
% Agregamos la carpeta con las funciones a utilizar
addpath('matlab_fun')

% Abrimos la base de datos de los datos
username = 'root';
password = '7461143';
conn = database(input_db, username, password, 'Vendor', 'MySQL');

% Pedimos y separamos los datos de y de training
curs = exec(conn, ['SELECT ', y_train_name, ' FROM y_train']);
curs = fetch(curs);
data = curs.Data;
y_train = cell2mat(data(:,1));

% Pedimos y separamos los datos de y de test
curs = exec(conn, ['SELECT ', y_test_name, ' FROM y_test']);
curs = fetch(curs);
data = curs.Data;
y_test = cell2mat(data(:,1));

% Cerramos la conexion y limpiamos la consola
close(conn);
clc

%% Seleccion de base de datos para trabajar

% Extraemos los datos de training
data_train = y_train;
fprintf('N de train: %i\n', length(data_train))

% Extraemos los datos del testing
data_test = y_test;
fprintf('N de test:  %i\n', length(data_test))


%% Busqueda del sistema optimo

% Creamos un vector para almacenar el rmse
RMSE_train_vec = zeros(1, n_max_order);     % RMSE para train
RMSE_test_vec  = zeros(1, n_max_order);     % RMSE para test

% Vectores para almacenar los valores de theta
% Los valores de theta para A se agregan a cada fila
theta_A_matrix = zeros(n_max_order, n_max_order);

% Realizamos las iteraciones
for n=1:n_max_order
    % Actualizamos los valores para la iteracion
    na = n;

    % Calculamos el modelo AR para el orden n
    sys = ar(data_train, na, 'ls');
    sys = setPolyFormat(sys, 'double');
    % Extraemos los datos de A y los guardamos en su respectiva variable
    A = sys.A;
    A = A(2:end);   % Por definicion, el primer parametro no sirve (es 1)
    theta_A_matrix(n, 1:n) = A; % Guardamos el dato en su respectiva matriz
    
    % Generamos el vector de parametros
    theta = A';     % Por definicion es vector fila 
    
    % Realizamos las predicciones con una funcion dedicada
    Y_hat_train = AR_k_step(data_train, theta, na, k);
    Y_hat_test  = AR_k_step(data_test,  theta, na, k);
    
    % Extraemos la fila que contiene la serie de tiempo de la prediccion
    y6_hat_train = Y_hat_train(k,:);
    y6_hat_test  = Y_hat_test (k,:);

    % Calculamos las metricas
    % RMSE del training
    error_train = y6_hat_train' - y_train(na + k:end);   % Vector error
    % Para evitar variaciones en el RMSE, se eliminaron eliminaron los
    % datos del error entre 1 y n_max_order + k, para que al calcular el
    % RMSE, sean para todos con los mismos datos
    N = length(y_train);                        % Largo teorico
    error_train = error_train(end - N + k + n_max_order:end); 
    N_train = length(error_train);
    rmse_train = sqrt(mean((error_train).^2));  % Calculamos el RMSE
    RMSE_train_vec(n) = rmse_train;             % Guardamo el valor
    
    % RMSE del testing
    error_test = y6_hat_test' - y_test(n+k:end);
    N = length(y_test);                        % Largo teorico
    error_test = error_test(end - N + k + n_max_order:end);
    N_test = length(error_test);
    rmse_test = sqrt(mean((error_test).^2));    % Calculamos el RMSE
    RMSE_test_vec(n) = rmse_test;               % Guardamos el valor

    % Desplegamos los resultados por consola
    fprintf('-- n = %i --\n', n)
    fprintf('RMSE train:  %f, N° puntos: %i \n', rmse_train, N_train);
    fprintf('RMSE test:   %f, N° puntos: %i \n', rmse_test, N_test);
    fprintf('\n')
end

%% Graficamos los desempenos del RMSE

% Creamos la figura
figure('Position', [10 250 800 350], 'renderer', 'painters')
hold on

% Realizamos el grafico del error
plot(RMSE_train_vec,'b-x')  % En azul el train
plot(RMSE_test_vec,'r-x')   % En rojo el test

% Configuracion
grid minor
title('Gráfico de error en funcion de n')
ylabel('error [mg/dL]')
xlabel('Orden n = n_a = n_b')
legend('RMSE train', 'RMSE test')

%% Grafico de theta

% Creamos la figura
figure('Position', [550 50 800 500], 'renderer', 'painters')
hold on

% Graficos
for i=1:length(theta_A_matrix)
    stem(theta_A_matrix(i,1:i),'x-')    
end

% Configuracion
grid on
title('Gráfico de parametros \theta_A en funcion de n_a')
ylabel('Valores de theta')
xlabel('Indices de theta')
xlim([0.5, na])
ylim([-2.5 2.5])
legend({'n_a=1', 'n_a=2', 'n_a=3'})

%% ---------------------------------------
% Guardamos los datos en la base de datos
%-----------------------------------------
%-----------------------------------------

if (guardar_datos == true)
    % Abrimos la base de datos de los datos de y filtrados
    username = 'root';
    password = '7461143';
    conn = database(output_db, username, password, 'Vendor', 'MySQL');

    % Creamos la tabla si no existe
    sql_query = ['CREATE TABLE IF NOT EXISTS '...
        table_name ' (n BIGINT NOT NULL, PRIMARY KEY(n));'];
    exec(conn, sql_query);

    % Agregamos los indices si la tabla no cuenta con ellos
    sql_query = ['SELECT COUNT(*) FROM ', table_name,';'];
    curs = exec(conn, sql_query);
    curs = fetch(curs);
    numero_datos = curs.Data;
    % Si no hay datos, agregamos el orden utilizado
    if (numero_datos{1} == 0)
        datainsert(conn, table_name, {'n'}, transpose(1:n_max_order))
    end

    %%% Extraemos las columnas de la tabla y eliminamos las que queremos crear
    sql_query = ['SHOW COLUMNS FROM ', table_name, ';']; % Generamos la query
    curs = exec(conn, sql_query);               % Ejecutamos la query
    curs = fetch(curs);                         % Obtenemos el resultado
    table_columns = curs.Data;                  % Extraemos los datos
    table_columns = table_columns(:,1);         % El nombre esta la col 1
    % Eliminamos la primera columna si existe
    if any(strcmp(table_columns, new_columns{1}))
        sql_query = ['ALTER TABLE ' table_name ' DROP COLUMN ' ...
            new_columns{1} ';'];
        exec(conn, sql_query);
    end
    % Eliminimamos la segunda columna si existe
    if any(strcmp(table_columns, new_columns{2}))
        sql_query = ['ALTER TABLE ' table_name ' DROP COLUMN ' ...
            new_columns{2} ';'];
        exec(conn, sql_query);
    end

    %%% Creamos nuevamente las columnas
    % Creamos la columna 1
    sql_query = ['ALTER TABLE ' table_name ' ADD COLUMN '...
        new_columns{1}, ' DOUBLE;'];
    exec(conn, sql_query);
    % Creamos la columna 2
    sql_query = ['ALTER TABLE ' table_name ' ADD COLUMN '...
        new_columns{2}, ' DOUBLE;'];
    exec(conn, sql_query);


    col_sql = {new_columns{1},new_columns{2}};
    data_sql = [RMSE_train_vec', RMSE_test_vec'];
    wereclause = cell(n_max_order, 1);
    for n=1:n_max_order
        wereclause{n,1} = ['WHERE n = ', num2str(n)];
    end
    update(conn, table_name, col_sql, data_sql, wereclause)

    close(conn);

end

