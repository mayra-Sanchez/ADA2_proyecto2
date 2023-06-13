% ------- Grupo de trabajo -------
% Jesús Adrian Peña - 2025513
% Santiago Casañas  - 2025301
% Laura Jaimes      - 2040430
% Mayra Sánchez     - 2040506

% -------------- Calendario deportivo --------------

% Implementación del modelo genérico          
% Parámetros
int: n; % Num equipos total
int: Min; % Mínimo de giras o permanecias
int: Max; % Máximo de giras o permanecias

array[1..n, 1..n] of int: Distancia; % Matriz de distancias n * n

% ------- Variables -------
% i = 2(n-1) y j = equipos 
array[1..2*(n-1),1..n] of var int: Cal; % Cal i,j
array[1..2*(n-1),1..n] of var 0..Max: Gira; % Gira
array[1..2*(n-1),1..n] of var 0..Max: Permanencia; % Permanencia

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

% No se puede repetir partidos
constraint forall(i,k in 1..2*(n-1), j in 1..n where i != k)(
  Cal[i,j] != Cal[k,j]
);

%No se puede superar el máximo de giras consecutivas
constraint forall(i in 1..2*(n-1))(
           forall(j in 1..n)(
              if Cal[i,j] < 0 then
                if i==1 then
                Gira[i,j] = 1
              else Gira[i,j] = Gira[i-1,j] + 1
              endif
              else Gira[i,j] = 0
                
              endif
           )  
);

%No se puede superar el máximo de permanencias consecutivas
constraint forall(i in 1..2*(n-1))(
           forall(j in 1..n)(
              if Cal[i,j] > 0 then
                if i==1 then
                  Permanencia[i,j] = 1
                else Permanencia[i,j] = Permanencia[i-1,j] + 1
              endif
              else Permanencia[i,j] = 0
                
              endif
           )  
);

%Debe haber un mínimo de giras consecutivas
constraint forall(j in 1..n)(
           forall(i in 2..2*(n-1))(
              if i == 2*(n-1) then 
                  if Cal[i,j] < 0 then 
                   Gira[i,j]>=Min
                  endif
             else
                if (Cal[i,j] > 0)then 
                  if(Cal[i-1,j] < 0)
                    then Gira[i-1,j]>=Min              
                  endif               
                endif
              endif
           )  
);

%Debe haber un mínimo de permanencias consecutivas
constraint forall(j in 1..n)(
           forall(i in 2..2*(n-1))(
              if i == 2*(n-1) then 
                  if Cal[i,j] > 0 then 
                   Permanencia[i,j]>=Min
                  endif
             else
                if (Cal[i,j] < 0)then 
                  if(Cal[i-1,j] > 0)
                    then Permanencia[i-1,j]>=Min              
                  endif               
                endif
              endif
           )  
);


% ------- Función Objetivo -------
var int: funcion_objetivo = sum(j in 1..n)(
    sum(i in 1..2*(n-1))(
        if i=1 then 
            if Cal[i, j] > 0 then 0 else  Distancia[j, abs(Cal[i, j])] endif
        else
            if Cal[i,j] > 0 then 
              if Cal[i-1, j] < 0 then Distancia[j, abs(Cal[i-1,j])] 
              else
                  0
              endif
            else
                if i = 2*(n-1) then Distancia[abs(Cal[i-1,j]),abs(Cal[i,j])] + Distancia[abs(Cal[i,j]),j]
                else 
                    Distancia[abs(Cal[i-1,j]),abs(Cal[i,j])]
                endif
            endif        
        endif
    )
);

% ------- Solución -------
solve minimize funcion_objetivo;

output ["Gira: \(Gira)\n",
        "Permanencia: \(Permanencia)\n",
        "Cal: \(Cal)\n",
        "Función Objetivo: \(funcion_objetivo)\n"];
