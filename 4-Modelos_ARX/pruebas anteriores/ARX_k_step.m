function prediccion = ARX_k_step(data, theta, n_order, k_step)
    na = n_order(1);
    nb = n_order(2);
    y = data(:,1);
    u = data(:,2);
    n_max = max([na, nb]);
    N = length(data);
    % Generamos la matriz phi para y (dejando en cero los valores a predecir)
    N_puntos = N - n_max - k_step;
    phi_y = zeros(na + k_step, N_puntos);
    for i=1:N_puntos
        phi_y(k_step+1:end, i) = flip(-y(i:i+na-1));
    end

    % Generamos la matriz phi para u
    phi_u = zeros(nb + k_step, N_puntos);
    for i=1:N_puntos
        phi_u(:, i) = flip(u(i:i+k_step+nb-1));
    end

    % Realizamos la prediccion

    prediccion = zeros(k_step, N_puntos);
    for i=1:k_step
        % Creamos la matriz de phi para predecir
        phi = [phi_y(k_step - i + 2: end - i + 1, :); ...
               phi_u(k_step - i + 2: end - i + 1, :)];
        % Guardamos la prediccion en el vector de prediccion
        prediccion(i, :) = transpose(theta) * phi;
        % Actualizamos la matriz de datos de y
        phi_y(k_step - i + 1, :) = - prediccion(i, :);
    end
end