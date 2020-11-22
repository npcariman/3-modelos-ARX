function predict = k_pasos_prediccion(theta, phi, k_step)
[na, m] = size(phi);
predict = zeros(k_step, m);

for i=1:k_step
    predict(i,:) = transpose(theta) * phi;
    phi = [-predict(i,:); phi(1:na-1,:)];
end