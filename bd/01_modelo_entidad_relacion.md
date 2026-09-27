erDiagram
    PACIENTES ||--o{ ANTECEDENTES_CLINICOS : "posee"
    PACIENTES ||--o{ SOLICITUDES : "genera"
    PACIENTES ||--o{ MUESTRAS : "provee"
    MEDICOS ||--o{ SOLICITUDES : "prescribe"
    PERSONAL_LABORATORIO ||--o{ SOLICITUDES : "registra_orden"
    PERSONAL_LABORATORIO ||--o{ MUESTRAS : "flebotomia"
    PERSONAL_LABORATORIO ||--o{ PROCESAMIENTOS_ANALITICOS : "analista"
    PERSONAL_LABORATORIO ||--o{ RESULTADOS : "captura"
    PERSONAL_LABORATORIO ||--o{ RESULTADOS : "valida_libera"
    PERSONAL_LABORATORIO ||--o{ AUDITORIA_REPETICIONES : "autoriza"

    CATALOGO_ESTUDIOS ||--|{ PARAMETROS_ESTUDIO : "compuesto_por"
    CATALOGO_ESTUDIOS ||--|{ ESTUDIOS_EQUIPOS_COMPATIBLES : "homologado_en"
    EQUIPOS ||--|{ ESTUDIOS_EQUIPOS_COMPATIBLES : "soporta"
    CATALOGO_ESTUDIOS ||--|{ ESTUDIOS_TIPOS_MUESTRA : "especifica"
    CATALOGO_TIPOS_MUESTRA ||--|{ ESTUDIOS_TIPOS_MUESTRA : "utilizado_por"
    CATALOGO_TIPOS_MUESTRA ||--o{ MUESTRAS : "clasifica"

    PARAMETROS_ESTUDIO ||--o{ VALORES_REFERENCIA : "define_rangos"

    SOLICITUDES ||--|{ DETALLES_SOLICITUDES_ESTUDIOS : "contiene"
    CATALOGO_ESTUDIOS ||--|{ DETALLES_SOLICITUDES_ESTUDIOS : "solicitado_en"

    SOLICITUDES ||--|{ MUESTRAS : "recolecta_para"
    MUESTRAS ||--|{ MUESTRAS_DETALLES_SOLICITUD : "asociada_a"
    DETALLES_SOLICITUDES_ESTUDIOS ||--|{ MUESTRAS_DETALLES_SOLICITUD : "emplea"

    DETALLES_SOLICITUDES_ESTUDIOS ||--o{ PROCESAMIENTOS_ANALITICOS : "ejecuta"
    MUESTRAS ||--o{ PROCESAMIENTOS_ANALITICOS : "muestra_analizada"
    EQUIPOS ||--o{ PROCESAMIENTOS_ANALITICOS : "equipo_utilizado"

    PROCESAMIENTOS_ANALITICOS ||--|{ RESULTADOS : "produce"
    PARAMETROS_ESTUDIO ||--|{ RESULTADOS : "corresponde_a"
    VALORES_REFERENCIA ||--o{ RESULTADOS : "evaluado_con"

    RESULTADOS ||--o{ AUDITORIA_REPETICIONES : "audita_cambio"

    PACIENTES {
        bigint id_paciente PK
        varchar codigo_expediente
        varchar curp
        varchar nombre
        varchar primer_apellido
        varchar segundo_apellido
        date fecha_nacimiento
        char sexo
        varchar telefono
        varchar email
        text direccion
        boolean activo
        timestamptz creado_en
    }

    ANTECEDENTES_CLINICOS {
        bigserial id_antecedente PK
        bigint id_paciente FK
        varchar tipo_antecedente
        text descripcion
        date fecha_diagnostico
        boolean activo
        timestamptz registrado_en
    }

    MEDICOS {
        serial id_medico PK
        varchar(8) cedula_profesional
        varchar nombre
        varchar primer_apellido
        varchar segundo_apellido
        varchar especialidad
        varchar institucion_procedencia
        varchar(10) telefono
        varchar email
        boolean activo
    }

    PERSONAL_LABORATORIO {
        serial id_personal PK
        varchar numero_empleado UK
        varchar(8) cedula_profesional
        varchar nombre
        varchar primer_apellido
        varchar segundo_apellido
        varchar rol
        varchar(10) telefono
        varchar email
        boolean activo
    }

    EQUIPOS {
        serial id_equipo PK
        varchar codigo_equipo
        varchar nombre
        varchar marca
        varchar modelo
        varchar numero_serie
        date fecha_instalacion
        varchar estado_operativo
        text motivo_inactividad
        timestamptz ultima_calibracion
        boolean activo
    }

    CATALOGO_TIPOS_MUESTRA {
        smallserial id_tipo_muestra PK
        varchar nombre_tipo UK
        varchar descripcion
        varchar condiciones_conservacion
        boolean activo
    }

    CATALOGO_ESTUDIOS {
        serial id_estudio PK
        varchar codigo_estudio UK
        varchar nombre
        varchar area_laboratorio
        varchar metodologia
        smallint tiempo_entrega_horas
        text indicaciones_preanaliticas
        boolean activo
    }

    ESTUDIOS_EQUIPOS_COMPATIBLES {
        int id_estudio PK,FK
        int id_equipo PK,FK
        boolean es_equipo_principal
    }

    ESTUDIOS_TIPOS_MUESTRA {
        int id_estudio PK,FK
        smallint id_tipo_muestra PK,FK
        varchar contenedor_tubo
        numeric volumen_minimo_ml
        boolean es_obligatoria
    }

    PARAMETROS_ESTUDIO {
        serial id_parametro PK
        int id_estudio FK
        varchar codigo_parametro
        varchar nombre
        varchar unidad_medida
        varchar tipo_dato_resultado
        smallint orden_impresion
        boolean activo
    }

    VALORES_REFERENCIA {
        serial id_valor_referencia PK
        int id_parametro FK
        char sexo_aplicable
        int edad_minima_dias
        int edad_maxima_dias
        numeric limite_inferior
        numeric limite_superior
        varchar valor_referencia_cualitativo
        text notas_interpretativas
    }

    SOLICITUDES {
        bigserial id_solicitud PK
        varchar folio_solicitud UK
        bigint id_paciente FK
        int id_medico FK
        int id_personal_registro FK
        timestamptz fecha_hora_solicitud
        varchar estado_solicitud
        text observaciones_clinicas
    }

    DETALLES_SOLICITUDES_ESTUDIOS {
        bigserial id_detalle_solicitud PK
        bigint id_solicitud FK
        int id_estudio FK
        varchar estado_estudio
        timestamptz fecha_hora_inicio_proceso
        timestamptz fecha_hora_finalizacion
        boolean urgente
    }

    MUESTRAS {
        bigserial id_muestra PK
        varchar codigo_barras_tubo UK
        bigint id_solicitud FK
        bigint id_paciente FK
        smallint id_tipo_muestra FK
        int id_personal_flebotomista FK
        timestamptz fecha_hora_toma
        varchar estado_muestra
        varchar condiciones_transporte
        text observaciones_toma
    }

    MUESTRAS_DETALLES_SOLICITUD {
        bigint id_muestra PK,FK
        bigint id_detalle_solicitud PK,FK
        varchar momento_toma
    }

    PROCESAMIENTOS_ANALITICOS {
        bigserial id_procesamiento PK
        bigint id_detalle_solicitud FK
        bigint id_muestra FK
        int id_equipo FK
        int id_personal_analista FK
        smallint numero_corrida
        timestamptz fecha_hora_inicio
        timestamptz fecha_hora_fin
        varchar lote_reactivo
        text observaciones_tecnicas
    }

    RESULTADOS {
        bigserial id_resultado PK
        bigint id_procesamiento FK
        int id_parametro FK
        int id_valor_referencia FK
        numeric valor_medido_numerico
        varchar valor_medido_texto
        varchar estado_interpretacion
        boolean es_resultado_vigente
        timestamptz fecha_hora_captura
        int id_personal_capturo FK
        int id_personal_valido FK
        timestamptz fecha_hora_validacion
    }

    AUDITORIA_REPETICIONES {
        bigserial id_auditoria PK
        bigint id_resultado_original FK
        bigint id_resultado_nuevo FK
        int id_personal_autorizo FK
        varchar tipo_accion
        text motivo_inconsistencia
        numeric valor_anterior_numerico
        varchar valor_anterior_texto
        timestamptz fecha_hora_evento
    }
