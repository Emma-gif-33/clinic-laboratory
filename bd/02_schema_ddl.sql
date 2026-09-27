SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

-- 1. ELIMINACIÓN DE TABLAS PREVIAS (ORDEN INVERSO DE DEPENDENCIAS)
DROP TABLE IF EXISTS auditoria_repeticiones CASCADE;
DROP TABLE IF EXISTS resultados CASCADE;
DROP TABLE IF EXISTS procesamientos_analiticos CASCADE;
DROP TABLE IF EXISTS muestras_detalles_solicitud CASCADE;
DROP TABLE IF EXISTS muestras CASCADE;
DROP TABLE IF EXISTS detalles_solicitudes_estudios CASCADE;
DROP TABLE IF EXISTS solicitudes CASCADE;
DROP TABLE IF EXISTS valores_referencia CASCADE;
DROP TABLE IF EXISTS parametros_estudio CASCADE;
DROP TABLE IF EXISTS estudios_tipos_muestra CASCADE;
DROP TABLE IF EXISTS estudios_equipos_compatibles CASCADE;
DROP TABLE IF EXISTS catalogo_estudios CASCADE;
DROP TABLE IF EXISTS catalogo_tipos_muestra CASCADE;
DROP TABLE IF EXISTS equipos CASCADE;
DROP TABLE IF EXISTS personal_laboratorio CASCADE;
DROP TABLE IF EXISTS medicos CASCADE;
DROP TABLE IF EXISTS antecedentes_clinicos CASCADE;
DROP TABLE IF EXISTS pacientes CASCADE;

-- 2. TABLAS DE CATÁLOGOS BASE Y ENTIDADES PRINCIPALES
-- Tabla: pacientes
-- Descripción: Almacena los datos generales e identificación del paciente.
CREATE TABLE pacientes (
    id_paciente BIGSERIAL PRIMARY KEY,
    codigo_expediente VARCHAR(20) NOT NULL UNIQUE,
    curp VARCHAR(18) UNIQUE,
    nombre VARCHAR(60) NOT NULL,
    primer_apellido VARCHAR(60) NOT NULL,
    segundo_apellido VARCHAR(60),
    fecha_nacimiento DATE NOT NULL,
    sexo CHAR(1) NOT NULL,
    telefono VARCHAR(10),
    email VARCHAR(100),
    direccion TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_paciente_fecha_nac CHECK (fecha_nacimiento <= CURRENT_DATE),
    CONSTRAINT chk_paciente_sexo CHECK (sexo IN ('M', 'F', 'O'))
);

COMMENT ON TABLE pacientes IS 'Expediente principal demográfico y de contacto de pacientes atendidos.';
COMMENT ON COLUMN pacientes.sexo IS 'Sexo biológico: M=Masculino, F=Femenino, O=Otro.';
COMMENT ON COLUMN pacientes.activo IS 'Permite borrado lógico para preservar el historial clínico permanente.';

-- Tabla: antecedentes_clinicos
-- Descripción: Condiciones médicas relevantes para la toma e interpretación analítica.
CREATE TABLE antecedentes_clinicos (
    id_antecedente BIGSERIAL PRIMARY KEY,
    id_paciente BIGINT NOT NULL,
    tipo_antecedente VARCHAR(40) NOT NULL,
    descripcion TEXT NOT NULL,
    fecha_diagnostico DATE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    registrado_en TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_antecedente_paciente FOREIGN KEY (id_paciente)
        REFERENCES pacientes (id_paciente) ON DELETE RESTRICT,
    CONSTRAINT chk_antecedente_tipo CHECK (tipo_antecedente IN (
        'ENFERMEDAD_CRONICA', 'ALERGIA', 'MEDICACION_ACTUAL', 
        'EMBARAZO', 'DIETA_ESPECIAL', 'OTRO'
    ))
);

COMMENT ON TABLE antecedentes_clinicos IS 'Antecedentes clínicos relevantes del paciente (diabetes, ayuno, alergias, fármacos).';

-- Tabla: medicos
-- Descripción: Información de los médicos que solicitan estudios de laboratorio.
CREATE TABLE medicos (
    id_medico SERIAL PRIMARY KEY,
    cedula_profesional VARCHAR(8) NOT NULL UNIQUE,
    nombre VARCHAR(60) NOT NULL,
    primer_apellido VARCHAR(60) NOT NULL,
    segundo_apellido VARCHAR(60),
    especialidad VARCHAR(80) NOT NULL,
    institucion_procedencia VARCHAR(120),
    telefono VARCHAR(10),
    email VARCHAR(100),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

COMMENT ON TABLE medicos IS 'Directorio de médicos prescriptores externos facultados.';
COMMENT ON COLUMN medicos.cedula_profesional IS 'Cédula profesional limitada a 8 dígitos/caracteres oficiales.';
COMMENT ON COLUMN medicos.telefono IS 'Teléfono de contacto a 10 dígitos.';

-- Tabla: personal_laboratorio
-- Descripción: Técnicos flebotomistas, analistas y químicos del laboratorio.
CREATE TABLE personal_laboratorio (
    id_personal SERIAL PRIMARY KEY,
    numero_empleado VARCHAR(20) NOT NULL UNIQUE,
    cedula_profesional VARCHAR(8),
    nombre VARCHAR(60) NOT NULL,
    primer_apellido VARCHAR(60) NOT NULL,
    segundo_apellido VARCHAR(60),
    rol VARCHAR(30) NOT NULL,
    telefono VARCHAR(10),
    email VARCHAR(100),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_personal_rol CHECK (rol IN (
        'ADMINISTRADOR', 'RECEPCION', 'FLEBOTOMISTA', 
        'TECNICO_ANALISTA', 'QUIMICO_RESPONSABLE'
    ))
);

COMMENT ON TABLE personal_laboratorio IS 'Personal operativo interno para control de roles y actividades.';
COMMENT ON COLUMN personal_laboratorio.cedula_profesional IS 'Cédula oficial sanitaria requerida para químicos responsables.';

-- Tabla: equipos
-- Descripción: Analizadores clínicos utilizados para procesar estudios.
CREATE TABLE equipos (
    id_equipo SERIAL PRIMARY KEY,
    codigo_equipo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    numero_serie VARCHAR(50) NOT NULL UNIQUE,
    fecha_instalacion DATE NOT NULL,
    estado_operativo VARCHAR(25) NOT NULL DEFAULT 'ACTIVO',
    motivo_inactividad TEXT,
    ultima_calibracion TIMESTAMPTZ,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_equipo_estado CHECK (estado_operativo IN (
        'ACTIVO', 'FUERA_DE_SERVICIO', 'EN_MANTENIMIENTO', 'EN_CALIBRACION'
    ))
);

COMMENT ON TABLE equipos IS 'Catálogo y estado operativo de equipos y analizadores clínicos.';
COMMENT ON COLUMN equipos.estado_operativo IS 'Permite bloquear corridas cuando el equipo está fuera de servicio.';

-- Tabla: catalogo_tipos_muestra
-- Descripción: Tipos de muestras biológicas recolectadas (sangre, orina, etc.).
CREATE TABLE catalogo_tipos_muestra (
    id_tipo_muestra SMALLSERIAL PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(150),
    condiciones_conservacion VARCHAR(60),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

COMMENT ON TABLE catalogo_tipos_muestra IS 'Catálogo de especímenes biológicos (Sangre Total, Suero, Orina, etc.).';

-- Tabla: catalogo_estudios
-- Descripción: Catálogo maestro de análisis clínicos que ofrece el laboratorio.
CREATE TABLE catalogo_estudios (
    id_estudio SERIAL PRIMARY KEY,
    codigo_estudio VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    area_laboratorio VARCHAR(50) NOT NULL,
    metodologia VARCHAR(80),
    tiempo_entrega_horas SMALLINT NOT NULL DEFAULT 24,
    indicaciones_preanaliticas TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_estudio_tiempo CHECK (tiempo_entrega_horas > 0)
);

COMMENT ON TABLE catalogo_estudios IS 'Catálogo de análisis clínicos ofrecidos por el laboratorio.';

-- Tabla: estudios_equipos_compatibles (Asociativa M:N)
-- Descripción: Homologación de qué equipos pueden realizar cada estudio.
CREATE TABLE estudios_equipos_compatibles (
    id_estudio INT NOT NULL,
    id_equipo INT NOT NULL,
    es_equipo_principal BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_estudio, id_equipo),
    CONSTRAINT fk_eec_estudio FOREIGN KEY (id_estudio)
        REFERENCES catalogo_estudios (id_estudio) ON DELETE RESTRICT,
    CONSTRAINT fk_eec_equipo FOREIGN KEY (id_equipo)
        REFERENCES equipos (id_equipo) ON DELETE RESTRICT
);

COMMENT ON TABLE estudios_equipos_compatibles IS 'Compatibilidad M:N entre estudios y analizadores homologados.';

-- Tabla: estudios_tipos_muestra (Asociativa M:N)
-- Descripción: Especifica una o más muestras biológicas requeridas por estudio.
CREATE TABLE estudios_tipos_muestra (
    id_estudio INT NOT NULL,
    id_tipo_muestra SMALLINT NOT NULL,
    contenedor_tubo VARCHAR(50) NOT NULL,
    volumen_minimo_ml NUMERIC(5,2),
    es_obligatoria BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_estudio, id_tipo_muestra),
    CONSTRAINT fk_etm_estudio FOREIGN KEY (id_estudio)
        REFERENCES catalogo_estudios (id_estudio) ON DELETE RESTRICT,
    CONSTRAINT fk_etm_tipo_muestra FOREIGN KEY (id_tipo_muestra)
        REFERENCES catalogo_tipos_muestra (id_tipo_muestra) ON DELETE RESTRICT,
    CONSTRAINT chk_etm_volumen CHECK (volumen_minimo_ml IS NULL OR volumen_minimo_ml > 0)
);

COMMENT ON TABLE estudios_tipos_muestra IS 'Muestras biológicas y tubos requeridos por cada estudio.';

-- Tabla: parametros_estudio
-- Descripción: Componentes o analitos individuales que componen un estudio.
CREATE TABLE parametros_estudio (
    id_parametro SERIAL PRIMARY KEY,
    id_estudio INT NOT NULL,
    codigo_parametro VARCHAR(20) NOT NULL,
    nombre VARCHAR(80) NOT NULL,
    unidad_medida VARCHAR(30),
    tipo_dato_resultado VARCHAR(15) NOT NULL,
    orden_impresion SMALLINT NOT NULL DEFAULT 1,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_estudio_parametro UNIQUE (id_estudio, codigo_parametro),
    CONSTRAINT fk_parametro_estudio FOREIGN KEY (id_estudio)
        REFERENCES catalogo_estudios (id_estudio) ON DELETE RESTRICT,
    CONSTRAINT chk_parametro_tipo_dato CHECK (tipo_dato_resultado IN (
        'NUMERICO', 'TEXTO', 'CUALITATIVO'
    )),
    CONSTRAINT chk_parametro_orden CHECK (orden_impresion > 0)
);

COMMENT ON TABLE parametros_estudio IS 'Analitos o componentes medibles que conforman cada estudio.';

-- Tabla: valores_referencia
-- Descripción: Rangos de normalidad parametrizados por edad y sexo.
CREATE TABLE valores_referencia (
    id_valor_referencia SERIAL PRIMARY KEY,
    id_parametro INT NOT NULL,
    sexo_aplicable CHAR(1) NOT NULL DEFAULT 'I',
    edad_minima_dias INT NOT NULL DEFAULT 0,
    edad_maxima_dias INT NOT NULL DEFAULT 43800,
    limite_inferior NUMERIC(10,4),
    limite_superior NUMERIC(10,4),
    valor_referencia_cualitativo VARCHAR(100),
    notas_interpretativas TEXT,
    CONSTRAINT fk_valref_parametro FOREIGN KEY (id_parametro)
        REFERENCES parametros_estudio (id_parametro) ON DELETE RESTRICT,
    CONSTRAINT chk_valref_sexo CHECK (sexo_aplicable IN ('M', 'F', 'I')),
    CONSTRAINT chk_valref_edades CHECK (edad_minima_dias >= 0 AND edad_maxima_dias >= edad_minima_dias),
    CONSTRAINT chk_valref_limites CHECK (
        limite_inferior IS NULL OR limite_superior IS NULL OR limite_superior >= limite_inferior
    )
);

COMMENT ON TABLE valores_referencia IS 'Rangos de referencia normales y cualitativos por sexo y edad en días.';
COMMENT ON COLUMN valores_referencia.sexo_aplicable IS 'M=Masculino, F=Femenino, I=Indistinto.';

-- 3. TABLAS DE SOLICITUDES, MUESTRAS Y PROCESAMIENTO ANALÍTICO
-- Tabla: solicitudes
-- Descripción: Orden de servicio que vincula al paciente con los estudios.
CREATE TABLE solicitudes (
    id_solicitud BIGSERIAL PRIMARY KEY,
    folio_solicitud VARCHAR(25) NOT NULL UNIQUE,
    id_paciente BIGINT NOT NULL,
    id_medico INT,
    id_personal_registro INT NOT NULL,
    fecha_hora_solicitud TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_solicitud VARCHAR(25) NOT NULL DEFAULT 'REGISTRADA',
    observaciones_clinicas TEXT,
    CONSTRAINT fk_solicitud_paciente FOREIGN KEY (id_paciente)
        REFERENCES pacientes (id_paciente) ON DELETE RESTRICT,
    CONSTRAINT fk_solicitud_medico FOREIGN KEY (id_medico)
        REFERENCES medicos (id_medico) ON DELETE RESTRICT,
    CONSTRAINT fk_solicitud_personal FOREIGN KEY (id_personal_registro)
        REFERENCES personal_laboratorio (id_personal) ON DELETE RESTRICT,
    CONSTRAINT chk_solicitud_estado CHECK (estado_solicitud IN (
        'REGISTRADA', 'MUESTRAS_TOMADAS', 'EN_PROCESAMIENTO', 
        'PARCIALMENTE_COMPLETADA', 'CONCLUIDA', 'ENTREGADA', 'CANCELADA'
    ))
);

COMMENT ON TABLE solicitudes IS 'Órdenes de servicio solicitadas por o para un paciente.';

-- Tabla: detalles_solicitudes_estudios
-- Descripción: Desglose individual de cada estudio dentro de una solicitud.
CREATE TABLE detalles_solicitudes_estudios (
    id_detalle_solicitud BIGSERIAL PRIMARY KEY,
    id_solicitud BIGINT NOT NULL,
    id_estudio INT NOT NULL,
    estado_estudio VARCHAR(35) NOT NULL DEFAULT 'PENDIENTE_MUESTRA',
    fecha_hora_inicio_proceso TIMESTAMPTZ,
    fecha_hora_finalizacion TIMESTAMPTZ,
    urgente BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT uq_solicitud_estudio UNIQUE (id_solicitud, id_estudio),
    CONSTRAINT fk_dse_solicitud FOREIGN KEY (id_solicitud)
        REFERENCES solicitudes (id_solicitud) ON DELETE RESTRICT,
    CONSTRAINT fk_dse_estudio FOREIGN KEY (id_estudio)
        REFERENCES catalogo_estudios (id_estudio) ON DELETE RESTRICT,
    CONSTRAINT chk_dse_estado CHECK (estado_estudio IN (
        'PENDIENTE_MUESTRA', 'MUESTRA_TOMADA_PENDIENTE_ANALISIS', 
        'EN_PROCESAMIENTO', 'RESULTADO_CAPTURADO', 'EN_REPETICION', 
        'VALIDADO_LIBERADO', 'CANCELADO'
    )),
    CONSTRAINT chk_dse_fechas CHECK (
        fecha_hora_finalizacion IS NULL OR 
        fecha_hora_inicio_proceso IS NULL OR 
        fecha_hora_finalizacion >= fecha_hora_inicio_proceso
    )
);

COMMENT ON TABLE detalles_solicitudes_estudios IS 'Estudios individuales contenidos en una orden y su avance.';
COMMENT ON COLUMN detalles_solicitudes_estudios.estado_estudio IS 'Permite filtrar estudios pendientes con muestra ya tomada.';

-- Tabla: muestras
-- Descripción: Muestras biológicas extraídas físicamente al paciente.
CREATE TABLE muestras (
    id_muestra BIGSERIAL PRIMARY KEY,
    codigo_barras_tubo VARCHAR(30) NOT NULL UNIQUE,
    id_solicitud BIGINT NOT NULL,
    id_paciente BIGINT NOT NULL,
    id_tipo_muestra SMALLINT NOT NULL,
    id_personal_flebotomista INT NOT NULL,
    fecha_hora_toma TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_muestra VARCHAR(25) NOT NULL DEFAULT 'TOMADA',
    condiciones_transporte VARCHAR(50),
    observaciones_toma TEXT,
    CONSTRAINT fk_muestra_solicitud FOREIGN KEY (id_solicitud)
        REFERENCES solicitudes (id_solicitud) ON DELETE RESTRICT,
    CONSTRAINT fk_muestra_paciente FOREIGN KEY (id_paciente)
        REFERENCES pacientes (id_paciente) ON DELETE RESTRICT,
    CONSTRAINT fk_muestra_tipo FOREIGN KEY (id_tipo_muestra)
        REFERENCES catalogo_tipos_muestra (id_tipo_muestra) ON DELETE RESTRICT,
    CONSTRAINT fk_muestra_flebotomista FOREIGN KEY (id_personal_flebotomista)
        REFERENCES personal_laboratorio (id_personal) ON DELETE RESTRICT,
    CONSTRAINT chk_muestra_estado CHECK (estado_muestra IN (
        'TOMADA', 'RECIBIDA_EN_LAB', 'EN_ANALISIS', 
        'PROCESADA', 'RECHAZADA_INADECUADA', 'AGOTADA'
    ))
);

COMMENT ON TABLE muestras IS 'Muestras biológicas recolectadas y etiquetadas con código de barras.';
COMMENT ON COLUMN muestras.estado_muestra IS 'Permite monitorear muestras pendientes de análisis en laboratorio.';

-- Tabla: muestras_detalles_solicitud (Asociativa M:N)
-- Descripción: Vincula muestras físicas con los estudios que las aprovechan.

CREATE TABLE muestras_detalles_solicitud (
    id_muestra BIGINT NOT NULL,
    id_detalle_solicitud BIGINT NOT NULL,
    momento_toma VARCHAR(20) NOT NULL DEFAULT 'BASAL',
    PRIMARY KEY (id_muestra, id_detalle_solicitud),
    CONSTRAINT fk_mds_muestra FOREIGN KEY (id_muestra)
        REFERENCES muestras (id_muestra) ON DELETE RESTRICT,
    CONSTRAINT fk_mds_detalle FOREIGN KEY (id_detalle_solicitud)
        REFERENCES detalles_solicitudes_estudios (id_detalle_solicitud) ON DELETE RESTRICT
);

COMMENT ON TABLE muestras_detalles_solicitud IS 'Distribución M:N de muestras entre estudios solicitados (unificación o series).';

-- Tabla: procesamientos_analiticos
-- Descripción: Bitácora de ejecución de análisis en un equipo y por un técnico.
CREATE TABLE procesamientos_analiticos (
    id_procesamiento BIGSERIAL PRIMARY KEY,
    id_detalle_solicitud BIGINT NOT NULL,
    id_muestra BIGINT NOT NULL,
    id_equipo INT NOT NULL,
    id_personal_analista INT NOT NULL,
    numero_corrida SMALLINT NOT NULL DEFAULT 1,
    fecha_hora_inicio TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_hora_fin TIMESTAMPTZ,
    lote_reactivo VARCHAR(40),
    observaciones_tecnicas TEXT,
    CONSTRAINT fk_proceso_detalle FOREIGN KEY (id_detalle_solicitud)
        REFERENCES detalles_solicitudes_estudios (id_detalle_solicitud) ON DELETE RESTRICT,
    CONSTRAINT fk_proceso_muestra FOREIGN KEY (id_muestra)
        REFERENCES muestras (id_muestra) ON DELETE RESTRICT,
    CONSTRAINT fk_proceso_equipo FOREIGN KEY (id_equipo)
        REFERENCES equipos (id_equipo) ON DELETE RESTRICT,
    CONSTRAINT fk_proceso_analista FOREIGN KEY (id_personal_analista)
        REFERENCES personal_laboratorio (id_personal) ON DELETE RESTRICT,
    CONSTRAINT chk_proceso_corrida CHECK (numero_corrida >= 1),
    CONSTRAINT chk_proceso_fechas CHECK (fecha_hora_fin IS NULL OR fecha_hora_fin >= fecha_hora_inicio)
);

COMMENT ON TABLE procesamientos_analiticos IS 'Registro de corridas analíticas en analizadores clínicos.';
COMMENT ON COLUMN procesamientos_analiticos.numero_corrida IS '1 para corrida inicial, 2 o más para reanálisis/repeticiones.';

-- 4. TABLAS DE RESULTADOS, VALIDACIÓN Y AUDITORÍA DE REPETICIONES
-- Tabla: resultados
-- Descripción: Valores medidos obtenidos del análisis y contrastados con rangos.
CREATE TABLE resultados (
    id_resultado BIGSERIAL PRIMARY KEY,
    id_procesamiento BIGINT NOT NULL,
    id_parametro INT NOT NULL,
    id_valor_referencia INT,
    valor_medido_numerico NUMERIC(12,4),
    valor_medido_texto VARCHAR(150),
    estado_interpretacion VARCHAR(20) NOT NULL,
    es_resultado_vigente BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_hora_captura TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_personal_capturo INT NOT NULL,
    id_personal_valido INT,
    fecha_hora_validacion TIMESTAMPTZ,
    CONSTRAINT fk_resultado_proceso FOREIGN KEY (id_procesamiento)
        REFERENCES procesamientos_analiticos (id_procesamiento) ON DELETE RESTRICT,
    CONSTRAINT fk_resultado_parametro FOREIGN KEY (id_parametro)
        REFERENCES parametros_estudio (id_parametro) ON DELETE RESTRICT,
    CONSTRAINT fk_resultado_valref FOREIGN KEY (id_valor_referencia)
        REFERENCES valores_referencia (id_valor_referencia) ON DELETE RESTRICT,
    CONSTRAINT fk_resultado_capturo FOREIGN KEY (id_personal_capturo)
        REFERENCES personal_laboratorio (id_personal) ON DELETE RESTRICT,
    CONSTRAINT fk_resultado_valido FOREIGN KEY (id_personal_valido)
        REFERENCES personal_laboratorio (id_personal) ON DELETE RESTRICT,
    CONSTRAINT chk_resultado_interpretacion CHECK (estado_interpretacion IN (
        'NORMAL', 'BAJO', 'ALTO', 'CRITICO_PANICO', 'NO_APLICA'
    )),
    CONSTRAINT chk_resultado_fechas CHECK (
        fecha_hora_validacion IS NULL OR fecha_hora_validacion >= fecha_hora_captura
    )
);

COMMENT ON TABLE resultados IS 'Mediciones y resultados emitidos para cada parámetro analizado.';
COMMENT ON COLUMN resultados.es_resultado_vigente IS 'TRUE si es el resultado activo; FALSE si fue reemplazado por repetición.';

-- Tabla: auditoria_repeticiones
-- Descripción: Bitácora inmutable de justificación de repeticiones e inconsistencias.
CREATE TABLE auditoria_repeticiones (
    id_auditoria BIGSERIAL PRIMARY KEY,
    id_resultado_original BIGINT NOT NULL,
    id_resultado_nuevo BIGINT,
    id_personal_autorizo INT NOT NULL,
    tipo_accion VARCHAR(35) NOT NULL,
    motivo_inconsistencia TEXT NOT NULL,
    valor_anterior_numerico NUMERIC(12,4),
    valor_anterior_texto VARCHAR(150),
    fecha_hora_evento TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_auditoria_res_orig FOREIGN KEY (id_resultado_original)
        REFERENCES resultados (id_resultado) ON DELETE RESTRICT,
    CONSTRAINT fk_auditoria_res_nuevo FOREIGN KEY (id_resultado_nuevo)
        REFERENCES resultados (id_resultado) ON DELETE RESTRICT,
    CONSTRAINT fk_auditoria_personal FOREIGN KEY (id_personal_autorizo)
        REFERENCES personal_laboratorio (id_personal) ON DELETE RESTRICT,
    CONSTRAINT chk_auditoria_tipo CHECK (tipo_accion IN (
        'REPETICION_POR_INCONSISTENCIA', 
        'MODIFICACION_PREVIA_LIBERACION', 
        'REANALISIS_CALIBRACION', 
        'REANALISIS_NUEVA_MUESTRA'
    ))
);

COMMENT ON TABLE auditoria_repeticiones IS 'Bitácora inalterable de auditoría técnica por inconsistencias y reanálisis.';

-- 5. ÍNDICES B-TREE ESTRATÉGICOS PARA CONSULTAS DE ALTO RENDIMIENTO
-- Índices en Pacientes y Solicitudes (Historial clínico y consultas por fecha)
CREATE INDEX idx_pacientes_expediente ON pacientes (codigo_expediente);
CREATE INDEX idx_pacientes_curp ON pacientes (curp);
CREATE INDEX idx_solicitudes_paciente_fecha ON solicitudes (id_paciente, fecha_hora_solicitud DESC);
CREATE INDEX idx_solicitudes_medico ON solicitudes (id_medico, fecha_hora_solicitud DESC);
CREATE INDEX idx_solicitudes_estado ON solicitudes (estado_solicitud);

-- Índices en Muestras y Monitores de Pendientes
CREATE INDEX idx_muestras_estado_fecha ON muestras (estado_muestra, fecha_hora_toma);
CREATE INDEX idx_muestras_solicitud ON muestras (id_solicitud);
CREATE INDEX idx_muestras_codigo_barras ON muestras (codigo_barras_tubo);

-- Índices en Detalles de Solicitud (Identificar pendientes con muestra tomada)
CREATE INDEX idx_detalles_estado_estudio ON detalles_solicitudes_estudios (estado_estudio);
CREATE INDEX idx_detalles_solicitud_estudio ON detalles_solicitudes_estudios (id_solicitud, id_estudio);

-- Índices en Procesamientos y Equipos (Productividad y trazabilidad)
CREATE INDEX idx_procesamientos_equipo_fecha ON procesamientos_analiticos (id_equipo, fecha_hora_inicio);
CREATE INDEX idx_procesamientos_detalle ON procesamientos_analiticos (id_detalle_solicitud);

-- Índices en Resultados (Consultas frecuentes y vigencia)
CREATE INDEX idx_resultados_proceso ON resultados (id_procesamiento);
CREATE INDEX idx_resultados_parametro_vigente ON resultados (id_parametro, es_resultado_vigente);
CREATE INDEX idx_resultados_vigente ON resultados (es_resultado_vigente);

-- Índices en Auditoría
CREATE INDEX idx_auditoria_resultado_orig ON auditoria_repeticiones (id_resultado_original);

-- 6. TRIGGERS Y FUNCIONES DE CONTROL DE NEGOCIO Y REGLAS OPERATIVAS
--Bloquear asignación de análisis en equipos fuera de servicio
CREATE OR REPLACE FUNCTION fn_validar_equipo_operativo()
RETURNS TRIGGER AS $$
DECLARE
    v_estado VARCHAR(25);
    v_nombre VARCHAR(80);
BEGIN
    SELECT estado_operativo, nombre INTO v_estado, v_nombre
    FROM equipos
    WHERE id_equipo = NEW.id_equipo;

    IF v_estado <> 'ACTIVO' THEN
        RAISE EXCEPTION 'No es posible procesar en el equipo "%" (ID: %): Su estado actual es "%". Redireccione a un equipo compatible alternativo.',
            v_nombre, NEW.id_equipo, v_estado;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_equipo_operativo ON procesamientos_analiticos;
CREATE TRIGGER trg_validar_equipo_operativo
BEFORE INSERT OR UPDATE OF id_equipo ON procesamientos_analiticos
FOR EACH ROW
EXECUTE FUNCTION fn_validar_equipo_operativo();

COMMENT ON FUNCTION fn_validar_equipo_operativo() IS 'Impide registrar corridas analíticas en equipos fuera de servicio o en mantenimiento.';