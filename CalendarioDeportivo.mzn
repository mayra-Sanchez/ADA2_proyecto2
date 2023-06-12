% ------- Grupo de trabajo -------
% Jesús Adrian Peña - 2025513
% Santiago Casañas  - 2025301
% Laura Jaimes      - 2040430
% Mayra Sánchez     - 2040506

% -------------- Calendario deportivo --------------

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
int: n; % Num equipos total
int: Min; % Mínimo de giras o permanecias
int: Max; % Máximo de giras o permanecias

array[1..n, 1..n] of int: Distancia; % Matriz de distancias n * n

% ------- Variables -------
% i = 2(n-1) y j = equipos 
array[1..2*(n-1),1..n] of var int: Cal; % Cal i,j
array[1..n] of var int: Gira; % Gira j
array[1..n] of var int: Permanencia; % Permanencia j
array[1..n] of var int: CostoG; % CostoG j

% ------- Restricciones -------
constraint n mod 2 == 0; % n tiene que ser par

% No programar partidos de vuelta hasta tanto no se hayan programado todos los partidos de ida
constraint forall(i, k in 1..(n-1), j in 1..n where i != k) (
  abs(Cal[i, j]) != abs(Cal[k, j])
); 

% Hay un partido de ida y uno de vuelta
constraint forall(j in 1..n, k in 1..n where k != j) (
  exists(i1, i2 in 1..2*(n-1)) (
    Cal[i1, j] = k /\ Cal[i2, j] = -k
  )
);

% Todos los números de las listas Gira y Permanencia deben ser mayores o iguales a Min
constraint forall(j in 1..n) (
  Gira[j] >= Min /\ Permanencia[j] >= Min
);

% Todos los números de las listas Gira y Permanencia deben ser menores o iguales a Max
constraint forall(j in 1..n)(
  Gira[j] <= Max /\ Permanencia[j] <= Max
);

% Que no sea cero ninguna posición en la matriz
constraint forall(i in 1..2*(n-1), j in 1..n)(
  Cal[i,j]!=0
);

% No puede repetirse un partido en dos fechas consecutivas
constraint forall(i in 1..(2*(n-1)-1), j in 1..n)(
  abs(Cal[i,j])!= abs(Cal[i+1,j])
);

% Equipo local en una fecha y el otro juega como visitante
constraint forall(i in 1..2*(n-1), j in 1..n,k in 1..n)(
  (Cal[i,j]=k) <-> (Cal[i,k] = -j)
);

% Un equipo no puede tener más de 2 partidos iguales
constraint forall(i,k in 1..2*(n-1), j in 1..n where i != k)(
  Cal[i,j] != Cal[k,j]
);
% ------- Funciones auxiliares --------

% ------- Función Objetivo -------
var int: funcion_objetivo;

% ------- Solución -------
solve minimize funcion_objetivo;