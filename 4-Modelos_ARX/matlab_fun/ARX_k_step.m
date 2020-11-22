function Y_hat = ARX_k_step(data, theta, n_order, k)
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
    u = data(:,2);
    N = length(data);
    % Numero de columnas de salida. Datos desde n+k hasta N
    N_colums = N - n - k + 1;
    
    % Generamos la matriz de regresion para cada variable
    phi_y = zeros(na + k, N_colums);
    phi_u = zeros(nb + k, N_colums);
    
    % Iteramos para llenar la matriz de y. Se dejan vacias las filas entre
    % 1 y k, ya que estas seran llenadas a futuro mediante iteraciones
    for i=1:N_colums
        phi_y(k + 1:end, i) = flip(-y(i:na + i - 1));
    end

    % Iteramos para llenar la matriz u. Esta se llena completamente
    for i=1:N_colums
        phi_u(:, i) = flip(u(i:nb + k + i - 1));
    end

    % Calculamos las predicciones
    for i=1:k
        % Creamos la matriz de regresores phi para predecir
        phi = [phi_y(k + 2 - i:end + 1 - i, :); ...
               phi_u(k + 2 - i:end + 1 - i, :)];
        % Actualizamos la matriz de datos de phi de y
        phi_y(k - i + 1, :) = - theta' * phi;
    end
    
    % Retornamos las predicciones
    Y_hat = - flip(phi_y(1:k,:), 1);
end
