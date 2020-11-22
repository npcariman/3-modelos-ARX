%% Cargamos la base de datos
clear, clc, close all

% Agregamos la carpeta con las funciones a utilizar
addpath('matlab_fun')

% Abrimos la base de datos de los datos
instance = 'u_holter';
username = 'root';
password = '7461143';
conn = database(instance, username, password, 'Vendor', 'MySQL');


% Pedimos los datos a la base de datos
curs = exec(conn, 'SELECT * FROM u_holter_train');
curs = fetch(curs);
data = curs.Data;
y0          = cell2mat(data(:,2));
u0_bolo     = cell2mat(data(:,3));
u0_meal     = cell2mat(data(:,4));
u0_sys      = cell2mat(data(:,5));
u0_dia      = cell2mat(data(:,6));
u0_HR       = cell2mat(data(:,7));
u0_mean     = cell2mat(data(:,8));

curs = exec(conn, 'SELECT * FROM u_holter_test');
curs = fetch(curs);
data = curs.Data;
y1         = cell2mat(data(:,2));
u1_bolo    = cell2mat(data(:,3));
u1_meal    = cell2mat(data(:,4));
u1_sys     = cell2mat(data(:,5));
u1_dia     = cell2mat(data(:,6));
u1_HR      = cell2mat(data(:,7));
u1_mean    = cell2mat(data(:,8));

% Cerramos la conexion
close(conn);

% Limpiamos la consola de comandos
clc

% Creamos los conjuntos de datos

%% Parametro
% Parametros para entrenar el sistema
n_max_order = 15;   % Orden maximo de iteracion. en este caso n=na=nb
k = 6;               % Horizonte de prediccion (6 = 30 minutos)
nk = 1;              % Tiempo muerto. Segun la definicion del libro nk = 1

% Parametros para guardar el RMSE en la base de datos
db_instance = 'rmse';               % Base de datos
table_name = 'rmse_ARX_3_y0_holter';       % Tabla (1 para cada conjunto de y
new_columns = { 'train_bolo_meal_sys',...
                 'test_bolo_meal_sys'}; % Columnas
guardar_datos = false;              % Parametro para activar guardar datos

% Eleccion del conjunto de prueba
y_train = y0;
y_test  = y1;

u1_train = u0_bolo;
u1_test  = u1_bolo;

u2_train = u0_meal;
u2_test  = u1_meal;

u3_train = u0_sys;
u3_test  = u1_sys;
%% Seleccion de base de datos para trabajar

% Extraemos los datos de training
data_train = [y_train, u1_train, u2_train, u3_train];
fprintf('N de train: %i\n', length(data_train))

% Extraemos los datos del testing
data_test = [y_test, u1_test, u2_test, u3_test];
fprintf('N de test:  %i\n', length(data_test))


%% Busqueda del sistema optimo

% Creamos un vector para almacenar el rmse
RMSE_train_vec = zeros(1, n_max_order);     % RMSE para train
RMSE_test_vec  = zeros(1, n_max_order);     % RMSE para test

% Vectores para almacenar los valores de theta
% Los valores de theta para A y B se agregan a cada fila
theta_A_matrix = zeros(n_max_order, n_max_order);
theta_B_matrix = zeros(n_max_order, n_max_order);

% Realizamos las iteraciones
for n=1:n_max_order
    % Actualizamos los valores para la iteracion
    na = n;
    nb = [n, n, n];
    nk = [1, 1, 1];
    n_max = max([na, max(nb)]);

    % Calculamos el modelo ARX para el orden n
    sys = arx(data_train, 'na', na, 'nb', nb, 'nk', nk);
    sys = setPolyFormat(sys, 'double');
    % Extraemos los datos de A y los guardamos en su respectiva variable
    A = sys.A;
    A = A(2:end);   % Por definicion, el primer parametro no sirve (es 1)
    theta_A_matrix(n, 1:n) = A; % Guardamos el dato en su respectiva matriz
    
    % Extraemos los datos de B y los guardamos en su respectiva variable
    B = sys.B;
    B = B(:, max(nk) + 1:end);          % Eliminamos el dato extra
    %theta_B_matrix(n, 1:n) = B; % Guardamos el dato en su respectiva matriz
    
    % Generamos el vector de parametros
    theta = [A B(1,:) B(2,:) B(3,:)];      
    theta = theta'; % Por definicion es vector fila

    % Realizamos las predicciones con una funcion dedicada
    Y_hat_train = ARX_k_stepV3(data_train, theta, [na max(nb)], k);
    Y_hat_test  = ARX_k_stepV3(data_test,  theta, [na max(nb)], k);
    
    % Extraemos la fila que contiene la serie de tiempo de la prediccion
    y6_hat_train = Y_hat_train(6,:);
    y6_hat_test  = Y_hat_test (6,:);

    % Calculamos las metricas
    
    % RMSE del training
    error_train = y6_hat_train' - y_train(n_max + k:end);   % Vector error
    % Para evitar variaciones en el RMSE, se eliminaron eliminaron los
    % datos del error entre 1 y n_max_order + k, para que al calcular el
    % RMSE, sean para todos con los mismos datos
    N = length(y_train);                        % Largo teorico
    error_train = error_train(end - N + k + n_max_order:end); 
    N_train = length(error_train);
    rmse_train = sqrt(mean((error_train).^2));  % Calculamos el RMSE
    RMSE_train_vec(n) = rmse_train;             % Guardamo el valor
    
    % RMSE del testing
    error_test = y6_hat_test' - y_test(n_max+k:end);
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


% Figura superior
subplot(2,1,1)
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
%xlim([0.5, 30])
ylim([-2.5 2.5])
legend({'n_a=1', 'n_a=2', 'n_a=3'})


% Figura inferior
subplot(2,1,2)
hold on

% Graficamos
for i=1:length(theta_B_matrix)
    stem(theta_B_matrix(i,1:i),'x-')    
end

% Configuracion
grid on
title('Gráfico de parametros \theta_B en funcion de n_b')
xlabel('Indices de theta')
ylabel('Valores de theta')
legend({'n_a=1', 'n_a=2', 'n_a=3'})

%% ---------------------------------------
% Guardamos los datos en la base de datos
%-----------------------------------------
%-----------------------------------------

if (guardar_datos == true)
    % Abrimos la base de datos de los datos de y filtrados
    username = 'root';
    password = '7461143';
    conn = database(db_instance, username, password, 'Vendor', 'MySQL');

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
