% Calendario deportivo
% Implementación del modelo genérico

% Archivo de datos
n = 4;
Min = 1;
Max = 3;
Distancia = [|  0, 745, 665, 929,
             | 745, 0, 80, 337, 
             |665, 80, 0, 380,
             |929, 337, 380, 0|];

% Parámetros
int: n; %Num equipos total
int: Min; % Mínimo de giras o permanecias
int: Max; % Máximo de giras o permanecias

array[1..n, 1..n] of int: Distancia; % Matriz de distancias n * n
% Variables



% Restricciones

% Función Objetivo

% Solución