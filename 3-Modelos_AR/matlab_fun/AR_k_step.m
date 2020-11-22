function Y_hat = AR_k_step(data, theta, n_order, k)
    % Funcion que sirve para predecedir k puntos a futuro
    %
    % Parametros
    %   - data: Matriz con los datos de "y". Tamano esperado de
    %       [N * 1], siendo N el numero de datos. Se espera data = [y]
    %   - theta: Vector fila con los parametros del modelo. 
    %       Tamano esperado de [na, 1]
    %   - n_order: Vector con los ordenes de la matriz theta. Se espera
    %       n_order = [na].
    %   - k: Horizonte de prediccion.
    %
    % Retorna
    %   - Y_hat: Matriz de tamano [k, N - na - k + 1] con las pre- 
    %       dicciones y_hat hasta k pasos. Cada fila i contiene los datos 
    %       y_hat(na + i) hasta y_hat(N - i).
    %
    
    % Extraemos los valores y vectores necesarios
    na = n_order(1);
    y = data(:,1);
    N = length(data);
    % Numero de columnas de salida. Datos desde n+k hasta N
    N_colums = N - na - k + 1;
    
    % Generamos la matriz de regresion para cada variable
    phi_y = zeros(na + k, N_colums);
    
    % Iteramos para llenar la matriz de y. Se dejan vacias las filas entre
    % 1 y k, ya que estas seran llenadas a futuro mediante iteraciones
    for i=1:N_colums
        phi_y(k + 1:end, i) = flip(-y(i:na + i - 1));
    end

    % Calculamos las predicciones
    for i=1:k
        % Creamos la matriz de regresores phi para predecir
        phi = phi_y(k + 2 - i:end + 1 - i, :);
        % Actualizamos la matriz de datos de phi de y
        phi_y(k - i + 1, :) = - theta' * phi;
    end

    % Retornamos las predicciones
    Y_hat = - flip(phi_y(1:k,:), 1);
end
