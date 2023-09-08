:- encoding(utf8).
:- use_module(library(pce)).

% Clase vertical_spacer
:- pce_begin_class(vertical_spacer, device, "Vertical spacer").
:- pce_end_class.

% Predicado para mostrar una ventana de pregunta con varias opciones
preguntar(Opciones, Pregunta, Respuesta) :-
    new(Dialog, dialog('Pregunta de Selección Múltiple')),
    send(Dialog, append, new(Label, label('Selecione Una Opcion'))),
    send(Label, font, bold),
    send(Dialog, append, new(_, vertical_spacer)),
    send(Dialog, append, new(_, text(''))),
    send(Dialog, append, new(_, text(Pregunta))),
    send(Dialog, append, new(_, text(''))),
    % Agregar los botones de las opciones
    forall(member(Op, Opciones), (
        send(Dialog, append, new(Boton, button(Op, message(Dialog, return, Op)))),
        send(Dialog, append, new(_, vertical_spacer)),
        send(Boton, font, bold)
    )),
    send(Dialog, append, new(_, text(''))),
    send(Dialog, append, new(_, text(''))),
    % Mostrar la ventana y obtener la respuesta seleccionada
    get(Dialog, confirm, Respuesta),
    free(Dialog).

pregunta_codigo(Pregunta, Respuesta) :-
    new(D, dialog('Pregunta abierta')),
    send(D, append, label(question_label, Pregunta)),
    send(D, append, new(Text, text_item(respuesta))),
    send(D, append, button(ok, message(D, return, Text?selection))),
    send(D, default_button(ok)),
    send(D, open),
    get(D, confirm, _),
    get(Text, selection, Respuesta),
    free(D).

pregunta_abierta(Pregunta, Respuesta) :-
    new(D, dialog('Pregunta abierta', size(500, 200))),
    send(D, append, label(question_label, Pregunta)),
    send(D, append, new(Text, text_item(respuesta))),
    send(D, append, button(ok, message(D, return, Text?selection))),
    send(D, default_button(ok)),
    send(D, open),
    get(D, confirm, _),
    get(Text, selection, Respuesta),
    free(D).

mostrar_ventana(Informacion):-
    new(Dialogo, dialog('Información')),
    send(Dialogo, append, new(Texto, text(Informacion))),
    send(Texto, font, font(helvetica, bold, 14)),
    send(Dialogo, append, button('OK', message(Dialogo, destroy))),
    send(Dialogo, default_button, 'OK'),
    send(Dialogo, open).

%%reglas de indentificacion de patrones
% Hechos que representan palabras clave
%Palabras para Motor
palabra('olor').
palabra('oler').
palabra('huele').
palabra('quemado').
palabra('caucho').
palabra('madera').
palabra('quemada').
palabra('ruido').
palabra('querer').
palabra('quiere').
palabra('pareciera').
palabra('parece').
palabra('ruidos').
palabra('funciona').
palabra('encender').
palabra('consumos').
palabra('diferentes').
palabra('consumo').
palabra('diferente').
palabra('enciende').
palabra('pedal').
palabra('regresa').
palabra('chifido').
palabra('chifidos').
palabra('chifla').
palabra('culebrea').
palabra('fuerza').
palabra('poca').
palabra('facil').
palabra('frenar').
palabra('frena').
palabra('facilidad').
palabra('facilmente').
palabra('calienta').
palabra('caliente').
palabra('calento').
palabra('frenarlo').
palabra('sencillo').
palabra('empujon').
palabra('empujarlo').
palabra('empujandolo').
palabra('ayudarlo').
palabra('ayudandolo').
palabra('chispa').
palabra('anda').
palabra('va').
palabra('es').
palabra('trabaja').
palabra('despacio').
palabra('recalienta').
palabra('sobrecalienta').
palabra('prende').
palabra('prendo').
palabra('pierde').
palabra('prender').
palabra('no').
palabra('ni').
palabra('ningun').
palabra('tampoco').

%%palabras para el cabezote
palabra('salta').
palabra('puntada').
palabra('inferior').
palabra('superior').
palabra('floja').
palabra('nudos').
palabra('hilo').
palabra('rompe').
palabra('aguja').
palabra('agujas').
palabra('quiebra').
palabra('quiebran').
palabra('arrastre').
palabra('irregular').
palabra('daña').
palabra('material').
palabra('tuberias').
palabra('derrama').
palabra('rebota').
palabra('escapa').
palabra('aceite').
palabra('tapadas').
palabra('engranajes').
palabra('pegados').

% Predicado que identifica palabras clave en una lista de palabras
% Recibe como entrada una lista de palabras y devuelve una lista con las palabras clave encontradas
encontrar_palabras([], []):-true.
encontrar_palabras([PALABRA|RESTO], [PALABRA|ENCONTRADA]) :-
    palabra(PALABRA),
    encontrar_palabras(RESTO, ENCONTRADA).
encontrar_palabras([_|RESTO], ENCONTRADA) :-
    encontrar_palabras(RESTO, ENCONTRADA).

%Obtener datos
pregunta(1, RESPUESTA):-
    preguntar(['Hacer Diagnostico', 'Consultar Registro de Maquinas', 'Salir'], '¿Qué Acción Desea Realizar?', RESPUESTA),
    opcion(1, RESPUESTA).

pregunta(2, CODIGO):-
                      pregunta_codigo('Ingrese el Codigo de la Maqina', CODIGO).

pregunta(3, CODIGO):-
                     pregunta_abierta('Por favor describa el problema', RESPUESTA),
                     split_string(RESPUESTA, " ", "", PALABRAS),
                     maplist(downcase_atom, PALABRAS, MINUSCULAS),
                     encontrar_palabras(MINUSCULAS, ENCONTRADAS),!,
                     diagnosticar(CODIGO,ENCONTRADAS),
                     motor_diagnostico(CODIGO),inicio.

pregunta(4, CODIGO):-
                     pregunta_abierta('Por favor describa el problema', RESPUESTA),
                     split_string(RESPUESTA, " ", "", PALABRAS),
                     maplist(downcase_atom, PALABRAS, MINUSCULAS),
                     encontrar_palabras(MINUSCULAS, ENCONTRADAS),!,
                     diagnosticar2(CODIGO,ENCONTRADAS),
                     cabezote_diagnostico(CODIGO),inicio.


diagnosticar(CODIGO, ENCONTRADAS):-
     recorrer(ENCONTRADAS, CODIGO).

diagnosticar2(CODIGO, ENCONTRADAS):-
    recorrer2(ENCONTRADAS, CODIGO).

guardar_base_hechos:- limpiar_archivo_hechos,tell('base_hechos.txt'), listing, told.

limpiar_archivo_hechos :-open('base_hechos.txt', write, Stream), close(Stream).

cargar_base_hechos:-(exists_file('base_hechos.txt'),consult('base_hechos.txt') -> true
                                                                               ;
                                                                               open('base_hechos.txt', write, Stream), close(Stream)).

recorrer([], _).
recorrer([PALABRA|RESTO], CODIGO) :-
    identificar_hechos_motor(PALABRA, RESTO, CODIGO),!.

recorrer2([], _).
recorrer2([PALABRA|RESTO], CODIGO) :-
    identificar_hechos_cabezote(PALABRA, RESTO, CODIGO),!.

%%identificar hechos del motor
identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    PALABRA = 'no', (
        PALABRA2 = 'prende' -> assert(no_funciona_motor(CODIGO));
        PALABRA2 = 'funciona' -> assert(no_funciona_motor(CODIGO));
        PALABRA2 = 'ruido' -> assert(no_hace_ruido_motor(CODIGO));
        PALABRA2 = 'ruidos' -> assert(no_hace_ruido_motor(CODIGO));
        PALABRA2 = 'enciende' -> assert(no_enciende_motor(CODIGO))
    ),!,recorrer(RESTO, CODIGO).
    
identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    PALABRA = 'ni', (
        PALABRA2 = 'prende' -> assert(no_funciona_motor(CODIGO));
        PALABRA2 = 'funciona' -> assert(no_funciona_motor(CODIGO));
        PALABRA2 = 'ruido' -> assert(no_hace_ruido_motor(CODIGO));
        PALABRA2 = 'ruidos' -> assert(no_hace_ruido_motor(CODIGO));
        PALABRA2 = 'enciende' -> assert(no_enciende_motor(CODIGO))
    ),!,recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    PALABRA = 'tampoco', (
        PALABRA2 = 'prende' -> assert(no_funciona_motor(CODIGO));
        PALABRA2 = 'funciona' -> assert(no_funciona_motor(CODIGO));
        PALABRA2 = 'ruido' -> assert(no_hace_ruido_motor(CODIGO));
        PALABRA2 = 'ruidos' -> assert(no_hace_ruido_motor(CODIGO));
        PALABRA2 = 'enciende' -> assert(no_enciende_motor(CODIGO))
    ),!,recorrer(RESTO, CODIGO).
    
identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'ningun',PALABRA2 = 'ruido')-> assert(no_hace_ruido_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'consumo',PALABRA2 = 'diferente')-> assert(consumo_diferente_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'consumo', PALABRA2 = 'diferentes')-> assert(consumo_diferente_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'consumos', PALABRA2 = 'diferentes') -> assert(consumo_diferente_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'consumos', PALABRA2 = 'diferente' )-> assert(consumo_diferente_motor(CODIGO)),!,
        recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'ruido',PALABRA2 = 'querer',PALABRA3 = 'prender') -> assert(ruidos_querer_encender_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'ruidos',PALABRA2 = 'querer', PALABRA3 = 'prender') -> assert(ruidos_querer_encender_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'parece',PALABRA2 = 'quiere', PALABRA3 = 'prender') -> assert(ruidos_querer_encender_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'pareciera',PALABRA2 = 'quiere', PALABRA3 = 'prender') -> assert(ruidos_querer_encender_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'ruido',PALABRA2 = 'querer',PALABRA3 = 'encender') -> assert(ruidos_querer_encender_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'ruidos',PALABRA2 = 'querer', PALABRA3 = 'encender') -> assert(ruidos_querer_encender_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'parece',PALABRA2 = 'quiere', PALABRA3 = 'encender') -> assert(ruidos_querer_encender_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'pareciera',PALABRA2 = 'quiere', PALABRA3 = 'encender') -> assert(ruidos_querer_encender_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'olor',PALABRA2 = 'madera', PALABRA3 = 'quemada') -> assert(olor_madera_quemada_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'oler',PALABRA2 = 'madera', PALABRA3 = 'quemada') -> assert(olor_madera_quemada_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'huele',PALABRA2 = 'madera', PALABRA3 = 'quemada') -> assert(olor_madera_quemada_motor(CODIGO)),!,
        recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'pedal',PALABRA2 = 'no', PALABRA3 = 'regresa') -> assert(pedal_no_regresa_motor(CODIGO)),!,
        recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'no',PALABRA2 = 'regresa', PALABRA3 = 'pedal') -> assert(pedal_no_regresa_motor(CODIGO)),!,
        recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'olor',PALABRA2 = 'caucho', PALABRA3 = 'quemado') -> assert(olor_caucho_quemado_motor(CODIGO)),!,
        recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'oler',PALABRA2 = 'caucho', PALABRA3 = 'quemado') -> assert(olor_caucho_quemado_motor(CODIGO)),!,
        recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'huele',PALABRA2 = 'caucho', PALABRA3 = 'quemado') -> assert(olor_caucho_quemado_motor(CODIGO)),!,
        recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'olor', PALABRA2 = 'quemado') -> assert(olor_caucho_quemado_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'oler', PALABRA2 = 'quemado') -> assert(olor_caucho_quemado_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'huele', PALABRA2 = 'quemado') -> assert(olor_caucho_quemado_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'fuerza', PALABRA2 = 'poca') -> assert(poca_fuerza_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'va', PALABRA2 = 'lento') -> assert(poca_fuerza_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'es', PALABRA2 = 'lento') -> assert(poca_fuerza_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'trabaja', PALABRA2 = 'despacio') -> assert(poca_fuerza_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'trabaja', PALABRA2 = 'lento') -> assert(poca_fuerza_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'pierde', PALABRA2 = 'fuerza') -> assert(poca_fuerza_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'poca', PALABRA2 = 'fuerza') -> assert(poca_fuerza_motor(CODIGO)),!,
        recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'facil', PALABRA2 = 'frenar') -> assert(facil_frenar_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'sencillo', PALABRA2 = 'frenar') -> assert(facil_frenar_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'frena', PALABRA2 = 'facil') -> assert(facil_frenar_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'frena', PALABRA2 = 'facilidad') -> assert(facil_frenar_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'frenarlo', PALABRA2 = 'sencillo') -> assert(facil_frenar_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).
    
identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'sencillo', PALABRA2 = 'frenar') -> assert(facil_frenar_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).
    
identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'sencillo', PALABRA2 = 'frenarlo') -> assert(facil_frenar_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'frena', PALABRA2 = 'facilmente') -> assert(facil_frenar_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'empujon', PALABRA2 = 'enciende') -> assert(puchon_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'enciende', PALABRA2 = 'empujon') -> assert(puchon_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'enciende', PALABRA2 = 'empujarlo') -> assert(puchon_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'empujarlo', PALABRA2 = 'enciende') -> assert(puchon_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'empujandolo', PALABRA2 = 'enciende') -> assert(puchon_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'enciende', PALABRA2 = 'empujandolo') -> assert(puchon_motor(CODIGO)),!,
    recorrer(RESTO, CODIGO).

identificar_hechos_motor(PALABRA, RESTO, CODIGO) :-
       (
        (PALABRA = 'culebrea') -> assert(culebrea_motor(CODIGO))
        ;
        (PALABRA = 'calienta'; PALABRA = 'caliento'; PALABRA = 'recalienta'; PALABRA = 'sobrecalienta'; PALABRA = 'caliente') -> assert(calienta_motor(CODIGO))
        ;
        (PALABRA = 'chispa') -> assert(chispa_motor(CODIGO))
        ;
        (PALABRA = 'funciona'; PALABRA = 'prendo'; PALABRA = 'prende') -> assert(funciona_motor(CODIGO))
        ;
        (PALABRA = 'chiflido'; PALABRA = 'chiflidos'; PALABRA = 'chifla' ; PALABRA = 'ruido'; PALABRA = 'ruidos') -> assert(hace_ruido_motor(CODIGO))
    ),!,recorrer(RESTO, CODIGO).

identificar_hechos_motor(_, RESTO, CODIGO) :-
       recorrer(RESTO, CODIGO).

%%identificar hechos del cabezote

identificar_hechos_cabezote(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'puntada',PALABRA2 = 'superior',PALABRA3 = 'floja') -> assert(puntada_superior_floja(CODIGO)),!,
    recorrer2(RESTO, CODIGO).

identificar_hechos_cabezote(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'puntada',PALABRA2 = 'superior',PALABRA3 = 'nudos') -> assert(puntada_superior_nudos(CODIGO)),!,
    recorrer2(RESTO, CODIGO).

identificar_hechos_cabezote(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'puntada',PALABRA2 = 'inferior',PALABRA3 = 'floja') -> assert(puntada_inferior_floja(CODIGO)),!,
    recorrer2(RESTO, CODIGO).

identificar_hechos_cabezote(PALABRA, [PALABRA2, PALABRA3|RESTO], CODIGO) :-
    (PALABRA = 'puntada',PALABRA2 = 'inferior',PALABRA3 = 'nudos') -> assert(puntada_inferior_nudos(CODIGO)),!,
    recorrer2(RESTO, CODIGO).

identificar_hechos_cabezote(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'derrama', PALABRA2 = 'aceite') -> assert(tuberias_tapadas(CODIGO)),!,
    recorrer2(RESTO, CODIGO).

identificar_hechos_cabezote(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'rebota', PALABRA2 = 'aceite') -> assert(tuberias_tapadas(CODIGO)),!,
    recorrer2(RESTO, CODIGO).

identificar_hechos_cabezote(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'aceite', PALABRA2 = 'derrama') -> assert(tuberias_tapadas(CODIGO)),!,
    recorrer2(RESTO, CODIGO).

identificar_hechos_cabezote(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'aceite', PALABRA2 = 'rebota') -> assert(tuberias_tapadas(CODIGO)),!,
    recorrer2(RESTO, CODIGO).

identificar_hechos_cabezote(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'engranajes', PALABRA2 = 'pegados') -> assert(engranajes_pegados(CODIGO)),!,
    recorrer2(RESTO, CODIGO).

identificar_hechos_cabezote(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'salta', PALABRA2 = 'puntada') -> assert(salta_puntada(CODIGO)),!,
    recorrer2(RESTO, CODIGO).

identificar_hechos_cabezote(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'hilo', PALABRA2 = 'rompe') -> assert(rompe_hilo(CODIGO)),!,
    recorrer2(RESTO, CODIGO).

identificar_hechos_cabezote(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'rompe', PALABRA2 = 'hilo') -> assert(rompe_hilo(CODIGO)),!,
    recorrer2(RESTO, CODIGO).

identificar_hechos_cabezote(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'aguja', PALABRA2 = 'quiebra') -> assert(quiebra_aguja(CODIGO)),!,
    recorrer2(RESTO, CODIGO).

identificar_hechos_cabezote(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'quiebra', PALABRA2 = 'aguja') -> assert(quiebra_aguja(CODIGO)),!,
    recorrer2(RESTO, CODIGO).
    
identificar_hechos_cabezote(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'agujas', PALABRA2 = 'quiebran') -> assert(quiebra_aguja(CODIGO)),!,
    recorrer2(RESTO, CODIGO).

identificar_hechos_cabezote(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'quiebra', PALABRA2 = 'agujas') -> assert(quiebra_aguja(CODIGO)),!,
    recorrer2(RESTO, CODIGO).

identificar_hechos_cabezote(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'arrastre', PALABRA2 = 'irregular') -> assert(arrastre_irregular(CODIGO)),!,
    recorrer2(RESTO, CODIGO).

identificar_hechos_cabezote(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'irregular', PALABRA2 = 'arrastre') -> assert(arrastre_irregular(CODIGO)),!,
    recorrer2(RESTO, CODIGO).

identificar_hechos_cabezote(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'daña', PALABRA2 = 'material') -> assert(material(CODIGO)),!,
    recorrer2(RESTO, CODIGO).

identificar_hechos_cabezote(PALABRA, [PALABRA2|RESTO], CODIGO) :-
    (PALABRA = 'material', PALABRA2 = 'daña') -> assert(material(CODIGO)),!,
    recorrer2(RESTO, CODIGO).

identificar_hechos_cabezote(_, RESTO, CODIGO) :-
       recorrer2(RESTO, CODIGO).

opcion(1, 'Hacer Diagnostico'):-
    pregunta(2, CODIGO),
    hacerdiagnostico(CODIGO).

opcion(1, 'Consultar Registro de Maquinas'):-
    pregunta(2, CODIGO),
    consultarmaquina(CODIGO),
    inicio.

opcion(1, 'Salir'):-guardar_base_hechos,mostrar_ventana('\n ****HASTA LA PROXIMA!*****').

hacerdiagnostico(CODIGO):-
    limpiar_base_conocimientos(CODIGO),
    preguntar(['Cabezote', 'Motor', 'Ayuda'], '¿En que Parte de la Maquina Identifica el Problema', RESPUESTA),problema(RESPUESTA,CODIGO).

problema('Ayuda',_):-
        atom_concat('\n\n', '1. Cabezote: parte principal que contiene la mayoría de las piezas que hacen posible la costura.', P1),
        atom_concat(P1, '\n Se encuentra en la parte superior de la máquina y se compone de una base, una aguja,', P2),
        atom_concat(P2, '\n una placa de aguja, una lanzadera y una canilla. El cabezote también puede incluir otros', P3),
        atom_concat(P3, '\n componentes, como un pedal y una rueda de ajuste de tensión, dependiendo del modelo de la', P4),
        atom_concat(P4, '\n máquina. En resumen, el cabezote es la parte principal de la máquina de coser que contiene', P5),
        atom_concat(P5, '\n las piezas que realizan la costura.', P6),
        atom_concat(P6, '\n \n', P7),
        atom_concat(P7, '\n 2. Motor: Componente eléctrico que proporciona la energía necesaria para mover la aguja y otras', P8),
        atom_concat(P8, '\n partes de la máquina, permitiendo realizar la costura de manera automática.', P9),
        atom_concat(P9, '\n El motor convierte la energía eléctrica en energía mecánica para hacer funcionar la máquina de coser.', P10),
        atom_concat(P10, '\n También puede ser ajustado para controlar la velocidad de costura.', P11),
        mostrar_ventana(P11),inicio.

problema('Motor',CODIGO):-assert(fallamotor(CODIGO)),
                          pregunta(3, CODIGO).

problema('Cabezote',CODIGO):-assert(fallacabezote(CODIGO)),
                             pregunta(4, CODIGO).

consultarmaquina(CODIGO):-
     motor_diagnostico(CODIGO),
     cabezote_diagnostico(CODIGO).

%%reglas de diagnostico para el motor
motor_quemado(CODIGO):-
    (current_predicate(funciona_motor/1),funciona_motor(CODIGO),
    (poca_fuerza_motor(CODIGO); consumo_diferente_motor(CODIGO); facil_frenar_motor(CODIGO); (calienta_motor(CODIGO),olor_caucho_quemado_motor(CODIGO))))
    ;
    (current_predicate(no_funciona_motor/1),no_funciona_motor(CODIGO),olor_caucho_quemado_motor(CODIGO))
    ;
    (current_predicate(no_funciona_motor/1),no_funciona_motor(CODIGO), current_predicate(no_hace_ruido_motor/1),no_hace_ruido_motor(CODIGO)).

motor_sucio(CODIGO):-
    current_predicate(funciona_motor/1),
    funciona_motor(CODIGO),
    current_predicate(calienta_motor/1),
    calienta_motor(CODIGO),
    \+ (current_predicate(olor_caucho_quemado_motor/1),
        olor_caucho_quemado_motor(CODIGO)),
    \+ (current_predicate(olor_madera_quemada_motor/1),
        olor_madera_quemada_motor(CODIGO)).

motor_capacitor(CODIGO):-
      current_predicate(no_funciona_motor/1),no_funciona_motor(CODIGO),
      current_predicate(puchon_motor/1),puchon_motor(CODIGO).

motor_pedal(CODIGO):-
     current_predicate(no_funciona_motor/1),no_funciona_motor(CODIGO),
     current_predicate(ruidos_querer_encender_motor/1),ruidos_querer_encender_motor(CODIGO),
     current_predicate(pedal_no_regresa_motor/1),pedal_no_regresa_motor(CODIGO).

motor_electrica(CODIGO):-
     (current_predicate(no_funciona_motor/1),no_funciona_motor(CODIGO),
     current_predicate(no_hace_ruido_motor/1),no_hace_ruido_motor(CODIGO))
     ;
     (current_predicate(chispa_motor/1),chispa_motor(CODIGO)).

motor_corchos(CODIGO):-
    current_predicate(no_funciona_motor/1),no_funciona_motor(CODIGO),
    current_predicate(olor_madera_quemada_motor/1),olor_madera_quemada_motor(CODIGO).

motor_eje(CODIGO):-
    current_predicate(funciona_motor/1),funciona_motor(CODIGO),
    current_predicate(culebrea_motor/1),culebrea_motor(CODIGO),
    current_predicate(hace_ruido_motor/1),hace_ruido_motor(CODIGO).

motor_diagnostico(CODIGO):-
    atom_concat('\n **LA MAQUINA ', CODIGO, FESP),
    atom_concat(FESP, ' PRESENTA LOS SIGUIENTES  FALLOS**\n LISTA DE FALLAS EN EL MOTOR:\n', MSG),
    falla('Motor',1, CODIGO, 0, MSG).

%%reglas de diagnostico al cabezote.

cabezote_sucio(CODIGO):-
    current_predicate(tuberias_tapadas/1),tuberias_tapadas(CODIGO);
    current_predicate(engranajes_pegados/1),engranajes_pegados(CODIGO).

cabezote_puntada_inferior(CODIGO):-
      current_predicate(puntada_inferior_floja/1),puntada_inferior_floja(CODIGO);
      current_predicate(puntada_inferior_nudos/1),puntada_inferior_nudos(CODIGO).

cabezote_puntada_superior(CODIGO):-
      current_predicate(puntada_superior_floja/1),puntada_superior_floja(CODIGO);
      current_predicate(puntada_superior_nudos/1),puntada_superior_nudos(CODIGO).

cabezote_puntada(CODIGO):-
      current_predicate(salta_puntada/1),salta_puntada(CODIGO).

cabezote_hilo(CODIGO):-
      current_predicate(rompe_hilo/1),rompe_hilo(CODIGO).

cabezote_aguja(CODIGO):-
      current_predicate(quiebra_aguja/1),quiebra_aguja(CODIGO).

cabezote_arrastre(CODIGO):-
      current_predicate(arrastre_irregular/1),arrastre_irregular(CODIGO).

cabezote_material(CODIGO):-
      current_predicate(material/1),material(CODIGO).

%%recoger los diagnosticos del cabezote
cabezote_diagnostico(CODIGO):-
    atom_concat('\n **LA MAQUINA ', CODIGO, FESP),
    atom_concat(FESP, ' PRESENTA LOS SIGUIENTES  FALLOS**\n LISTA DE FALLAS EN EL CABEZOTE:\n', MSG),
    falla('Cabezote',1, CODIGO, 0, MSG).

falla('Motor', 1, CODIGO, N, FALLAS):-
    (motor_quemado(CODIGO),I is N + 1,
    atom_concat(FALLAS, '\n', FESP),
    atom_concat(I, '. ', NUM),
    atom_concat(NUM, 'Es posible que el motor esté quemado.', MSG),
    atom_concat(FESP, MSG, F),
    falla('Motor', 2, CODIGO, I, F));
    falla('Motor', 2, CODIGO, N, FALLAS).

falla('Motor', 2, CODIGO, N, FALLAS):-
    (motor_sucio(CODIGO),I is N + 1,
    atom_concat(FALLAS, '\n', FESP),
    atom_concat(I, '. ', NUM),
    atom_concat(NUM, 'Es posible que el motor esté sucio.',MSG),
    atom_concat(FESP, MSG, F),
    falla('Motor', 3, CODIGO, I, F));
    falla('Motor', 3, CODIGO, N, FALLAS).

falla('Motor', 3, CODIGO, N, FALLAS):-
    (motor_capacitor(CODIGO),I is N + 1,
    atom_concat(FALLAS, '\n', FESP),
    atom_concat(I, '. ', NUM),
    atom_concat(NUM, 'Es posible que el capacitor del motor esté dañado.',MSG),
    atom_concat(FESP, MSG, F),
    falla('Motor', 4, CODIGO, I, F));
    falla('Motor', 4, CODIGO, N, FALLAS).

falla('Motor', 4, CODIGO, N, FALLAS):-
    (motor_pedal(CODIGO),I is N + 1,
    atom_concat(FALLAS, '\n', FESP),
    atom_concat(I, '. ', NUM),
    atom_concat(NUM, 'Es posible que el pedal esté desajustado.',MSG),
    atom_concat(FESP, MSG, F),
    falla('Motor', 5, CODIGO, I, F));
    falla('Motor', 5, CODIGO, N, FALLAS).

falla('Motor', 5, CODIGO, N, FALLAS):-
    (motor_electrica(CODIGO),I is N + 1,
    atom_concat(FALLAS, '\n', FESP),
    atom_concat(I, '. ', NUM),
    atom_concat(NUM, 'Es posible que haya una falla eléctrica.',MSG),
    atom_concat(FESP, MSG, F),
    falla('Motor', 6, CODIGO, I, F));
    falla('Motor', 6, CODIGO, N, FALLAS).

falla('Motor', 6, CODIGO, N, FALLAS):-
    (motor_corchos(CODIGO),I is N + 1,
    atom_concat(FALLAS, '\n', FESP),
    atom_concat(I, '. ', NUM),
    atom_concat(NUM, 'Es posible que haya que cambiar los corchos del motor.',MSG),
    atom_concat(FESP, MSG, F),
    falla('Motor', 7, CODIGO, I, F));
    falla('Motor', 7, CODIGO, N, FALLAS).

falla('Motor', 7, CODIGO, N, FALLAS):-
    (motor_eje(CODIGO),I is N + 1,
    atom_concat(FALLAS, '\n', FESP),
    atom_concat(I, '. ', NUM),
    atom_concat(NUM, 'Es posible que el eje del motor se haya torcido.',MSG),
    atom_concat(FESP, MSG, F),
    falla('Motor', 8, CODIGO, I, F));
    falla('Motor', 8, CODIGO, N, FALLAS).

falla('Motor', 8, CODIGO, N, FALLAS):-
     (N>0,mostrar_ventana(FALLAS))
     ;
     (atom_concat('\n LA MAQUINA  ', CODIGO, FESP),
     atom_concat(FESP, '  NO PRESENTA FALLAS DE MOTOR', MSG),
     mostrar_ventana(MSG)).

%%fallas de cabezote

falla('Cabezote', 1, CODIGO, N, FALLAS):-
    (cabezote_sucio(CODIGO),I is N + 1,
    atom_concat(FALLAS, '\n', FESP),
    atom_concat(I, '. ', NUM),
    atom_concat(NUM, 'Es posible que el cabezote este sucio', MSG),
    atom_concat(FESP, MSG, F),
    falla('Cabezote', 2, CODIGO, I, F));
    falla('Cabezote', 2, CODIGO, N, FALLAS).

falla('Cabezote', 2, CODIGO, N, FALLAS):-
    (cabezote_puntada_inferior(CODIGO),I is N + 1,
    atom_concat(FALLAS, '\n', FESP),
    atom_concat(I, '. ', NUM),
    atom_concat(NUM, 'Posibles casusas de fallo de puntada inferior', IN),
    atom_concat(IN, '\n  a. Platos: Poca tensión', LA),
    atom_concat(LA, '\n  b. Transportador: Desajustado', LB),
    atom_concat(LB, '\n  c. Pie Prensatela: Poca Presión', LC),
    atom_concat(LC, '\n  d. Garfio: Desajustado', LD),
    atom_concat(LD, '\n', MSG),
    atom_concat(FESP, MSG, F),
    falla('Cabezote', 3, CODIGO, I, F));
    falla('Cabezote', 3, CODIGO, N, FALLAS).

falla('Cabezote', 3, CODIGO, N, FALLAS):-
    (cabezote_puntada_superior(CODIGO),I is N + 1,
    atom_concat(FALLAS, '\n', FESP),
    atom_concat(I, '. ', NUM),
    atom_concat(NUM, 'Posibles casusas de fallo de puntada superior', IN),
    atom_concat(IN, '\n  a. Bobina: Poca tensión en laina', LA),
    atom_concat(LA, '\n  b. Bobina: Agrietada o dañada', LB),
    atom_concat(LB, '\n', MSG),
    atom_concat(FESP, MSG, F),
    falla('Cabezote', 4, CODIGO, I, F));
    falla('Cabezote', 4, CODIGO, N, FALLAS).

falla('Cabezote', 4, CODIGO, N, FALLAS):-
    (cabezote_puntada(CODIGO),I is N + 1,
    atom_concat(FALLAS, '\n', FESP),
    atom_concat(I, '. ', NUM),
    atom_concat(NUM, 'Posibles casusas de salto de puntada', IN),
    atom_concat(IN, '\n  a. Garfio: Mal ajustado', LA),
    atom_concat(LA, '\n  b. Hilo Superior: Mucha tensión', LB),
    atom_concat(LB, '\n  c. Placa de Aguja: Desajustada', LC),
    atom_concat(LC, '\n  d. Pie Prensatelas: Desajustado', LD),
    atom_concat(LD, '\n  e. Hilo, Tela, Aguja: Desalineados', LE),
    atom_concat(LE, '\n', MSG),
    atom_concat(FESP, MSG, F),
    falla('Cabezote', 5, CODIGO, I, F));
    falla('Cabezote', 5, CODIGO, N, FALLAS).

falla('Cabezote', 5, CODIGO, N, FALLAS):-
    (cabezote_hilo(CODIGO),I is N + 1,
    atom_concat(FALLAS, '\n', FESP),
    atom_concat(I, '. ', NUM),
    atom_concat(NUM, 'Posibles casusas de rompimiento del hilo', IN),
    atom_concat(IN, '\n  a. Hilo: Demasiada tensión', LA),
    atom_concat(LA, '\n  b. Hilo: Viejo o Fragil', LB),
    atom_concat(LB, '\n  c. Bobina: Dañada o mal ajustada', LC),
    atom_concat(LC, '\n  d. Garfio: Desajustado, golpeado o con grietas', LD),
    atom_concat(LD, '\n  e. Dedo Retenedor: Desajustado', LE),
    atom_concat(LE, '\n  f. Aguja: Desajustada o recalentada', LF),
    atom_concat(LF, '\n  g. Guias de los Hilos: Desajustadas, golpeadas o agrietadas', LH),
    atom_concat(LH, '\n', MSG),
    atom_concat(FESP, MSG, F),
    falla('Cabezote', 6, CODIGO, I, F));
    falla('Cabezote', 6, CODIGO, N, FALLAS).

falla('Cabezote', 6, CODIGO, N, FALLAS):-
    (cabezote_aguja(CODIGO),I is N + 1,
    atom_concat(FALLAS, '\n', FESP),
    atom_concat(I, '. ', NUM),
    atom_concat(NUM, 'Posibles casusas de la ruptura de aguja', IN),
    atom_concat(IN, '\n  a. Garfio: Mal ajustado', LA),
    atom_concat(LA, '\n  b. Altura Barra Aguja: No es la adecuada', LB),
    atom_concat(LB, '\n  c. Transportador: Mal ajustado', LC),
    atom_concat(LC, '\n  d. Aguja: Medida o tipo incorrectos', LD),
    atom_concat(LD, '\n', MSG),
    atom_concat(FESP, MSG, F),
    falla('Cabezote', 7, CODIGO, I, F));
    falla('Cabezote', 7, CODIGO, N, FALLAS).

falla('Cabezote', 7, CODIGO, N, FALLAS):-
    (cabezote_arrastre(CODIGO),I is N + 1,
    atom_concat(FALLAS, '\n', FESP),
    atom_concat(I, '. ', NUM),
    atom_concat(NUM, 'Posibles casusas de arrastre irregular', IN),
    atom_concat(IN, '\n  a. Pie Prensatela: Poca presión o desajustado', LA),
    atom_concat(LA, '\n  b. Transportador: Descalibrado', LB),
    atom_concat(LB, '\n  c. Placa Aguja: Mal ajustada', LC),
    atom_concat(LC, '\n  d. Selector de Puntada: Desajustado', LD),
    atom_concat(LD, '\n', MSG),
    atom_concat(FESP, MSG, F),
    falla('Cabezote', 8, CODIGO, I, F));
    falla('Cabezote', 8, CODIGO, N, FALLAS).

falla('Cabezote', 8, CODIGO, N, FALLAS):-
    (cabezote_material(CODIGO),I is N + 1,
    atom_concat(FALLAS, '\n', FESP),
    atom_concat(I, '. ', NUM),
    atom_concat(NUM, 'Posibles casusas por las que se daña material', IN),
    atom_concat(IN, '\n  a. Aguja', LA),
    atom_concat(LA, '\n  b. Transportador: Descalibrado', LB),
    atom_concat(LB, '\n  c. Aceite: Mucho o muy poco aceite', LC),
    atom_concat(LC, '\n', MSG),
    atom_concat(FESP, MSG, F),
    falla('Cabezote', 9, CODIGO, I, F));
    falla('Cabezote', 9, CODIGO, N, FALLAS).

falla('Cabezote', 9, CODIGO, N, FALLAS):-
     (N>0,mostrar_ventana(FALLAS))
     ;
     (atom_concat('\n LA MAQUINA  ', CODIGO, FESP),
     atom_concat(FESP, '  NO PRESENTA FALLAS DE CABEZOTE', MSG),
     mostrar_ventana(MSG)).

%%limpiar toda la base de conocimientos
limpiar_base_conocimientos(CODIGO):- eliminar_no_funciona(CODIGO),eliminar_funciona(CODIGO),eliminar_poca_fuerza_motor(CODIGO),
eliminar_consumo_diferente_motor(CODIGO), eliminar_facil_frenar_motor(CODIGO), eliminar_olor_caucho_quemado_motor(CODIGO), eliminar_calienta_motor(CODIGO),
eliminar_puchon_motor(CODIGO), eliminar_olor_madera_quemada(CODIGO),eliminar_ruidos_querer_encender_motor(CODIGO), eliminar_pedal_no_regresa_motor(CODIGO),
eliminar_no_hace_ruido_motor(CODIGO),eliminar_chispa_motor(CODIGO),limpiar_culebrea_motor(CODIGO), limpiar_hace_ruido_motor(CODIGO),
limpiar_tuberias_tapadas(CODIGO),limpiar_engranajes_pegados(CODIGO),limpiar_puntada_inferior_floja(CODIGO),limpiar_puntada_superior_floja(CODIGO),
limpiar_puntada_inferior_nudos(CODIGO),limpiar_puntada_superior_nudos(CODIGO),limpiar_salta_puntada(CODIGO),limpiar_rompe_hilo(CODIGO),
limpiar_quiebra_aguja(CODIGO),limpiar_material(CODIGO),limpiar_arrastre_irregular(CODIGO).

%%limpiar hechos especificos
eliminar_funciona(CODIGO):-retractall(funciona_motor(CODIGO)); true.
eliminar_no_funciona(CODIGO):-retractall(no_funciona_motor(CODIGO)); true.
eliminar_poca_fuerza_motor(CODIGO):-retractall(poca_fuerza_motor(CODIGO)); true.
eliminar_consumo_diferente_motor(CODIGO):-retractall(consumo_diferente_motor(CODIGO)); true.
eliminar_facil_frenar_motor(CODIGO):-retractall(facil_frenar_motor(CODIGO)); true.
eliminar_olor_caucho_quemado_motor(CODIGO):-retractall(olor_caucho_quemado_motor(CODIGO)); true.
eliminar_calienta_motor(CODIGO):-retractall(calienta_motor(CODIGO)); true.
eliminar_puchon_motor(CODIGO):-retractall(puchon_motor(CODIGO)); true.
eliminar_olor_madera_quemada(CODIGO):-retractall(olor_madera_quemada_motor(CODIGO)); true.
eliminar_ruidos_querer_encender_motor(CODIGO):-retractall(ruidos_querer_encender_motor(CODIGO)); true.
eliminar_pedal_no_regresa_motor(CODIGO):-retractall(pedal_no_regresa_motor(CODIGO)); true.
eliminar_no_hace_ruido_motor(CODIGO):-retractall(no_hace_ruido_motor(CODIGO)); true.
eliminar_chispa_motor(CODIGO):- retractall(chispa_motor(CODIGO)); true.
limpiar_culebrea_motor(CODIGO):- retractall(culebrea_motor(CODIGO)); true.
limpiar_hace_ruido_motor(CODIGO):-retractall(hace_ruido_motor(CODIGO)); true.
limpiar_tuberias_tapadas(CODIGO):-retractall(tuberias_tapadas(CODIGO)); true.
limpiar_engranajes_pegados(CODIGO):-retractall(engranajes_pegados(CODIGO)); true.
limpiar_puntada_inferior_floja(CODIGO):-retractall(puntada_inferior_floja(CODIGO)); true.
limpiar_puntada_superior_floja(CODIGO):-retractall(puntada_superior_floja(CODIGO)); true.
limpiar_puntada_inferior_nudos(CODIGO):-retractall(puntada_inferior_nudos(CODIGO)); true.
limpiar_puntada_superior_nudos(CODIGO):-retractall(puntada_superior_nudos(CODIGO)); true.
limpiar_salta_puntada(CODIGO):-retractall(salta_puntada(CODIGO)); true.
limpiar_rompe_hilo(CODIGO):-retractall(rompe_hilo(CODIGO)); true.
limpiar_quiebra_aguja(CODIGO):-retractall(quiebra_aguja(CODIGO)); true.
limpiar_material(CODIGO):-retractall(material(CODIGO)); true.
limpiar_arrastre_irregular(CODIGO):-retractall(arrastre_irregular(CODIGO)); true.

inicio:-cargar_base_hechos,
        pregunta(1, _).
