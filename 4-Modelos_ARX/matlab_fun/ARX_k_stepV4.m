function Y_hat = ARX_k_stepV4(data, theta, n_order, k)
    % Funcion que sirve para predecedir k puntos a futuro
    %
    % Parametros
    %   - data: Matriz con los datos de "y" y "u". Tamano esperado de
    %       [N * 2], siendo N el numero de datos. Se espera data = [y, u]
    %   - theta: Vector fila con los parametros del modelo. 
    %       Tamano esperado de [na + nb, 1]
    %   - n_order: Vector con los ordenes de la matriz theta. Se espera
    %       n_order = [na, nb].
    %   - k: Horizonte de prediccion.
    %
    % Retorna
    %   - Y_hat: Matriz de tamano [k, N - max(na,nb) - k + 1] con las pre- 
    %       dicciones y_hat hasta k pasos. Cada fila i contiene los datos 
    %       y_hat(max(na,nb) + i) hasta y_hat(N - i).
    %
    
    % Extraemos los valores y vectores necesarios
    na = n_order(1);
    nb = n_order(2);
    n = max([na, nb]);
    y = data(:,1);
    u1 = data(:,2);
    u2 = data(:,3);
    u3 = data(:,4);
    u4 = data(:,5);
    u5 = data(:,6);
    u6 = data(:,7);
    N = length(data);
    % Numero de columnas de salida. Datos desde n+k hasta N
    N_colums = N - n - k + 1;
    
    % Generamos la matriz de regresion para cada variable
    phi_y = zeros(na + k, N_colums);
    phi_u1 = zeros(nb + k, N_colums);
    phi_u2 = zeros(nb + k, N_colums);
    phi_u3 = zeros(nb + k, N_colums);
    phi_u4 = zeros(nb + k, N_colums);
    phi_u5 = zeros(nb + k, N_colums);
    phi_u6 = zeros(nb + k, N_colums);
    
    % Iteramos para llenar la matriz de y. Se dejan vacias las filas entre
    % 1 y k, ya que estas seran llenadas a futuro mediante iteraciones
    for i=1:N_colums
        phi_y(k + 1:end, i) = flip(-y(i:na + i - 1));
    end

    % Iteramos para llenar la matriz u. Esta se llena completamente
    for i=1:N_colums
        phi_u1(:, i) = flip(u1(i:nb + k + i - 1));
    end
    for i=1:N_colums
        phi_u2(:, i) = flip(u2(i:nb + k + i - 1));
    end
    for i=1:N_colums
        phi_u3(:, i) = flip(u3(i:nb + k + i - 1));
    end
    for i=1:N_colums
        phi_u4(:, i) = flip(u4(i:nb + k + i - 1));
    end
    for i=1:N_colums
        phi_u5(:, i) = flip(u5(i:nb + k + i - 1));
    end
    for i=1:N_colums
        phi_u6(:, i) = flip(u6(i:nb + k + i - 1));
    end

    % Calculamos las predicciones
    for i=1:k
        % Creamos la matriz de regresores phi para predecir
        phi = [phi_y(k + 2 - i:end + 1 - i, :); ...
               phi_u1(k + 2 - i:end + 1 - i, :); ...
               phi_u2(k + 2 - i:end + 1 - i, :);
               phi_u3(k + 2 - i:end + 1 - i, :);
               phi_u4(k + 2 - i:end + 1 - i, :);
               phi_u5(k + 2 - i:end + 1 - i, :);
               phi_u6(k + 2 - i:end + 1 - i, :)];
        % Actualizamos la matriz de datos de phi de y
        phi_y(k - i + 1, :) = - theta' * phi;
    end
    
    % Retornamos las predicciones
    Y_hat = - flip(phi_y(1:k,:), 1);
end
