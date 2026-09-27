BEGIN;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

TRUNCATE TABLE auditoria_repeticiones CASCADE;
TRUNCATE TABLE resultados CASCADE;
TRUNCATE TABLE procesamientos_analiticos CASCADE;
TRUNCATE TABLE muestras_detalles_solicitud CASCADE;
TRUNCATE TABLE muestras CASCADE;
TRUNCATE TABLE detalles_solicitudes_estudios CASCADE;
TRUNCATE TABLE solicitudes CASCADE;
TRUNCATE TABLE valores_referencia CASCADE;
TRUNCATE TABLE parametros_estudio CASCADE;
TRUNCATE TABLE estudios_tipos_muestra CASCADE;
TRUNCATE TABLE estudios_equipos_compatibles CASCADE;
TRUNCATE TABLE catalogo_estudios CASCADE;
TRUNCATE TABLE catalogo_tipos_muestra CASCADE;
TRUNCATE TABLE equipos CASCADE;
TRUNCATE TABLE personal_laboratorio CASCADE;
TRUNCATE TABLE medicos CASCADE;
TRUNCATE TABLE antecedentes_clinicos CASCADE;
TRUNCATE TABLE pacientes CASCADE;

-- Reinicio de secuencias de llaves auto-incrementales
ALTER SEQUENCE IF EXISTS pacientes_id_paciente_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS antecedentes_clinicos_id_antecedente_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS medicos_id_medico_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS personal_laboratorio_id_personal_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS equipos_id_equipo_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS catalogo_tipos_muestra_id_tipo_muestra_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS catalogo_estudios_id_estudio_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS parametros_estudio_id_parametro_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS valores_referencia_id_valor_referencia_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS solicitudes_id_solicitud_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS detalles_solicitudes_estudios_id_detalle_solicitud_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS muestras_id_muestra_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS procesamientos_analiticos_id_procesamiento_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS resultados_id_resultado_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS auditoria_repeticiones_id_auditoria_seq RESTART WITH 1;

-- 2.1 Tipos de Muestra Biológica
INSERT INTO catalogo_tipos_muestra (nombre_tipo, descripcion, condiciones_conservacion, activo) VALUES
('Sangre Total EDTA', 'Sangre venosa anticoagulada con K2/K3 EDTA', 'Ambiente 18-25°C máx 4h, luego 2-8°C', true),
('Suero Sanguíneo', 'Fracción líquida de sangre coagulada', 'Centrifugar y refrigerar a 2-8°C', true),
('Plasma Citratado', 'Plasma obtenido con citrato de sodio 3.2%', 'Centrifugar de inmediato; procesar <4h', true),
('Orina Espontánea', 'Primera micción matutina en frasco estéril', 'Refrigerar 2-8°C hasta su análisis', true),
('Orina de 24 Horas', 'Recolección completa de orina emitida', 'Refrigeración obligatoria a 2-8°C', true),
('Materia Fecal', 'Muestra reciente en frasco limpio hermético', 'Procesar en <2h o refrigerar a 4°C', true),
('Exudado Faríngeo', 'Frotis de mucosa con hisopo estéril', 'Transporte inmediato a temp. ambiente', true),
('Líquido Cefalorraquídeo', 'Punción lumbar procesada en tubos estériles', 'Procesamiento estat urgente inmediato', true);

-- 2.2 Catálogo de Equipos Analíticos (15 equipos iniciales)
--     12 Activos, 1 Fuera de Servicio, 1 En Mantenimiento, 1 En Calibración
INSERT INTO equipos (codigo_equipo, nombre, marca, modelo, numero_serie, fecha_instalacion, estado_operativo, motivo_inactividad, ultima_calibracion, activo) VALUES
('EQ-HEM-01', 'Analizador Hematológico Automatizado 5 Diff', 'Sysmex', 'XN-550', 'SN-SYS-001091', '2023-01-15', 'ACTIVO', NULL, CURRENT_TIMESTAMP - INTERVAL '10 days', true),
('EQ-HEM-02', 'Analizador Hematológico Automatizado 5 Diff (Respaldo)', 'Sysmex', 'XN-550', 'SN-SYS-001092', '2023-01-15', 'ACTIVO', NULL, CURRENT_TIMESTAMP - INTERVAL '12 days', true),
('EQ-QUI-01', 'Analizador Químico Clínico de Alta Productividad', 'Roche Diagnostics', 'Cobas c311', 'SN-ROC-778201', '2023-02-10', 'ACTIVO', NULL, CURRENT_TIMESTAMP - INTERVAL '5 days', true),
('EQ-QUI-02', 'Analizador Químico Clínico Modular', 'Roche Diagnostics', 'Cobas 6000', 'SN-ROC-778202', '2023-02-10', 'ACTIVO', NULL, CURRENT_TIMESTAMP - INTERVAL '6 days', true),
('EQ-QUI-03', 'Analizador Químico Seco Multiparamétrico', 'Ortho Clinical', 'Vitros 350', 'SN-ORT-449101', '2023-03-01', 'ACTIVO', NULL, CURRENT_TIMESTAMP - INTERVAL '8 days', true),
('EQ-INM-01', 'Analizador por Quimioluminiscencia (CLIA)', 'Abbott Diagnostics', 'Architect i1000SR', 'SN-ABB-991201', '2023-03-15', 'ACTIVO', NULL, CURRENT_TIMESTAMP - INTERVAL '7 days', true),
('EQ-INM-02', 'Analizador Quimioluminiscencia Inmunología', 'Beckman Coulter', 'Access 2', 'SN-BEC-334101', '2023-04-01', 'ACTIVO', NULL, CURRENT_TIMESTAMP - INTERVAL '14 days', true),
('EQ-COA-01', 'Coagulómetro Automatizado de 4 Canales', 'Stago', 'STA Compact Max', 'SN-STA-665101', '2023-04-10', 'ACTIVO', NULL, CURRENT_TIMESTAMP - INTERVAL '15 days', true),
('EQ-COA-02', 'Coagulómetro Óptico-Mecánico de Respaldo', 'Instrumentation Lab', 'ACL TOP 300', 'SN-IL-112301', '2023-04-15', 'ACTIVO', NULL, CURRENT_TIMESTAMP - INTERVAL '20 days', true),
('EQ-URI-01', 'Analizador Automatizado de Sedimento y Tiras Urinarias', 'Sysmex', 'UC-3500 + UF-4000', 'SN-SYS-882101', '2023-05-01', 'ACTIVO', NULL, CURRENT_TIMESTAMP - INTERVAL '4 days', true),
('EQ-MIC-01', 'Sistema de Hemocultivos Automatizado', 'bioMérieux', 'BacT/ALERT 3D', 'SN-BMX-551011', '2023-05-15', 'ACTIVO', NULL, CURRENT_TIMESTAMP - INTERVAL '9 days', true),
('EQ-MIC-02', 'Sistema de Identificación Bacteriana y Antibiogramas', 'bioMérieux', 'VITEK 2 Compact', 'SN-BMX-551012', '2023-05-15', 'ACTIVO', NULL, CURRENT_TIMESTAMP - INTERVAL '11 days', true),
('EQ-QUI-04', 'Analizador Bioquímico Secundario', 'Biosystems', 'BA400', 'SN-BIO-229101', '2023-06-01', 'FUERA_DE_SERVICIO', 'Falla en celda de lectura fotométrica y bomba peristáltica; en espera de refacciones de fábrica.', CURRENT_TIMESTAMP - INTERVAL '45 days', true),
('EQ-HEM-03', 'Contador Celular de 3 Diff para Urgencias', 'Mindray', 'BC-30s', 'SN-MIN-441093', '2023-06-15', 'EN_MANTENIMIENTO', 'Servicio preventivo trimestral y reemplazo de tuberías de reactivo.', CURRENT_TIMESTAMP - INTERVAL '3 days', true),
('EQ-INM-03', 'Lector de Microplacas ELISA Automatizado', 'Bio-Rad', 'iMark', 'SN-BR-990111', '2023-07-01', 'EN_CALIBRACION', 'Protocolo de validación analítica con estándares de calibración certificados.', CURRENT_TIMESTAMP - INTERVAL '1 days', true);

-- 2.3 Catálogo de Personal de Laboratorio (15 integrantes)
INSERT INTO personal_laboratorio (numero_empleado, cedula_profesional, nombre, primer_apellido, segundo_apellido, rol, telefono, email, activo) VALUES
('EMP-ADM-001', NULL, 'Carlos', 'Villanueva', 'Paredes', 'ADMINISTRADOR', '5511223344', 'admin1@laboratorio.com', true),
('EMP-ADM-002', NULL, 'Sofía', 'Montalvo', 'Guzmán', 'ADMINISTRADOR', '5511223345', 'admin2@laboratorio.com', true),
('EMP-REC-001', NULL, 'Lucía', 'Morales', 'Pérez', 'RECEPCION', '5522334455', 'lucia.morales@laboratorio.com', true),
('EMP-REC-002', NULL, 'Javier', 'Ramírez', 'Cruz', 'RECEPCION', '5522334456', 'javier.ramirez@laboratorio.com', true),
('EMP-REC-003', NULL, 'Fernanda', 'Castro', 'Soto', 'RECEPCION', '5522334457', 'fernanda.castro@laboratorio.com', true),
('EMP-FLE-001', NULL, 'Raúl', 'Hernández', 'Jiménez', 'FLEBOTOMISTA', '5533445566', 'raul.flebo@laboratorio.com', true),
('EMP-FLE-002', NULL, 'Karla', 'Méndez', 'Reyes', 'FLEBOTOMISTA', '5533445567', 'karla.flebo@laboratorio.com', true),
('EMP-FLE-003', NULL, 'Esteban', 'Ortega', 'Salazar', 'FLEBOTOMISTA', '5533445568', 'esteban.flebo@laboratorio.com', true),
('EMP-FLE-004', NULL, 'Valeria', 'Rios', 'Delgado', 'FLEBOTOMISTA', '5533445569', 'valeria.flebo@laboratorio.com', true),
('EMP-ANA-001', '10982341', 'Guillermo', 'Sánchez', 'Navarro', 'TECNICO_ANALISTA', '5544556677', 'guillermo.analista@laboratorio.com', true),
('EMP-ANA-002', '10982342', 'Daniela', 'Flores', 'Vargas', 'TECNICO_ANALISTA', '5544556678', 'daniela.analista@laboratorio.com', true),
('EMP-ANA-003', '10982343', 'Alejandro', 'Torres', 'Ponce', 'TECNICO_ANALISTA', '5544556679', 'alejandro.analista@laboratorio.com', true),
('EMP-ANA-004', '10982344', 'Marisol', 'López', 'Guerrero', 'TECNICO_ANALISTA', '5544556680', 'marisol.analista@laboratorio.com', true),
('EMP-RES-001', '12456789', 'Dra. Patricia', 'García', 'Lozano', 'QUIMICO_RESPONSABLE', '5555667788', 'patricia.responsable@laboratorio.com', true),
('EMP-RES-002', '12456790', 'Dr. Roberto', 'Medina', 'Campos', 'QUIMICO_RESPONSABLE', '5555667789', 'roberto.responsable@laboratorio.com', true);

INSERT INTO medicos (cedula_profesional, nombre, primer_apellido, segundo_apellido, especialidad, institucion_procedencia, telefono, email, activo)
SELECT 
    lpad((20000000 + i)::text, 8, '0'),
    (ARRAY['Alejandro', 'Beatriz', 'Carlos', 'Diana', 'Eduardo', 'Gabriela', 'Hugo', 'Irma', 'Jorge', 'Lorena'])[1 + (i % 10)],
    (ARRAY['González', 'Martínez', 'Rodríguez', 'López', 'Hernández', 'Pérez', 'Sánchez', 'Ramírez', 'Flores', 'Gómez'])[1 + (i % 10)],
    (ARRAY['Díaz', 'Vázquez', 'Castro', 'Ruiz', 'Álvarez', 'Romero', 'Herrera', 'Medina', 'Aguilar', 'Jiménez'])[1 + ((i * 3) % 10)],
    (ARRAY['Medicina Interna', 'Pediatría', 'Ginecología y Obstetricia', 'Cardiología', 'Endocrinología', 'Nefrología', 'Hematología', 'Gastroenterología', 'Traumatología', 'Medicina General'])[1 + (i % 10)],
    (ARRAY['Hospital General de México', 'Instituto Nacional de Nutrición', 'Hospital Ángeles', 'Centro Médico ABC', 'Hospital Español', 'Clínica San Rafael', 'Consultorio Médico Privado'])[1 + (i % 7)],
    '55' || lpad((70000000 + i)::text, 8, '0'),
    'dr.medico' || i || '@hospital.com',
    true
FROM generate_series(1, 50) AS i;

INSERT INTO catalogo_estudios (codigo_estudio, nombre, area_laboratorio, metodologia, tiempo_entrega_horas, indicaciones_preanaliticas, activo) VALUES
('EST-BH01', 'Biometría Hemática Completa (5 Diff)', 'Hematología', 'Citometría de Flujo e Impedancia Eléctrica', 12, 'Ayuno voluntario de 4 horas recomendado.', true),
('EST-QS06', 'Química Sanguínea 6 Elementos (QS6)', 'Bioquímica Clínica', 'Espectrofotometría y Enzimático Colorimétrico', 12, 'Ayuno estricto de 8 a 12 horas previo a la toma.', true),
('EST-QS24', 'Química Sanguínea 24 Elementos (QS24)', 'Bioquímica Clínica', 'Espectrofotometría Automatizada', 24, 'Ayuno de 12 horas. Evitar ingesta de alcohol 24h previas.', true),
('EST-EGO1', 'Examen General de Orina (EGO)', 'Uroanálisis', 'Química Seca y Microscopía de Sedimento Urinario', 12, 'Primera orina de la mañana, chorro medio en frasco estéril.', true),
('EST-PLIP', 'Perfil Lipídico Completo', 'Bioquímica Clínica', 'Colorimetría Enzimática Automatizada', 12, 'Ayuno obligatorio de 12 a 14 horas continuas.', true),
('EST-PHEP', 'Perfil Hepático Completo', 'Bioquímica Clínica', 'Cinética Enzimática UV', 24, 'Ayuno de 8 a 12 horas.', true),
('EST-COAG', 'Tiempos de Coagulación (TP/TTPa)', 'Coagulación', 'Coagulometría Coagulométrica y Cromogénica', 12, 'Ayuno de 4 horas. Informar si toma anticoagulantes.', true),
('EST-HBA1', 'Hemoglobina Glicosilada (HbA1c)', 'Hematología / Endocrinología', 'HPLC Cromatografía Líquida de Alta Resolución', 24, 'No requiere ayuno estricto.', true),
('EST-PTIR', 'Perfil Tiroideo Básico', 'Inmunología', 'Quimioluminiscencia (CLIA)', 24, 'Ayuno de 8 horas. No tomar levotiroxina antes de la extracción.', true),
('EST-PSA1', 'Antígeno Prostático Total (PSA)', 'Inmunología', 'Quimioluminiscencia (CLIA)', 24, 'Abstinencia sexual de 48h y sin tacto rectal reciente.', true),
('EST-VDLR', 'Prueba Inmunológica VDRL/RPR', 'Inmunología', 'Floculación en Látex', 12, 'Ayuno de 4 horas.', true),
('EST-VIH1', 'Detección Anticuerpos VIH 1 y 2', 'Inmunología', 'ELISA / Quimioluminiscencia', 24, 'Ayuno de 4 horas.', true),
('EST-COPR', 'Coproparasitoscópico en Serie', 'Parasitología', 'Faust y Sedimentación', 48, 'Muestras de 3 días consecutivos en frasco con formol.', true),
('EST-UROC', 'Urocultivo con Antibiograma', 'Microbiología', 'Cultivo en Medios Cromogénicos y Sistema VITEK 2', 72, 'Aseo genital previo. Sin tratamiento antibiótico 72h antes.', true),
('EST-EXUD', 'Cultivo de Exudado Faríngeo', 'Microbiología', 'Agar Sangre y Determinación Sensibilidad', 72, 'Sin enjuague bucal matutino y sin antibióticos.', true),
('EST-ELEC', 'Electrólitos Séricos (Na, K, Cl)', 'Bioquímica Clínica', 'Electrodo Selectivo de Iones (ISE)', 12, 'Ayuno de 6 a 8 horas.', true),
('EST-PCRU', 'Proteína C Reactiva Ultrasensible', 'Inmunología', 'Inmunoturbidimetría', 12, 'Ayuno de 4 horas.', true),
('EST-VIID', 'Vitamina D 25-Hidroxi Total', 'Inmunología', 'Quimioluminiscencia (CLIA)', 48, 'Ayuno de 8 horas.', true),
('EST-CURV', 'Curva de Tolerancia Glucosa 75g', 'Endocrinología', 'Espectrofotometría Hexoquinasa', 24, 'Ayuno de 10 a 12 horas. Permanecer en reposo 2 horas.', true),
('EST-HEMO', 'Hemocultivo Automatizado', 'Microbiología', 'Monitoreo Colorimétrico Continuo BacT/ALERT', 120, 'Toma con técnica aséptica en pico febril.', true);

INSERT INTO estudios_equipos_compatibles (id_estudio, id_equipo, es_equipo_principal) VALUES
(1, 1, true),  -- Biometría Hemática en Sysmex XN-550 (Principal)
(1, 2, false), -- Biometría Hemática en Sysmex XN-550 #2 (Respaldo)
(2, 3, true),  -- QS6 en Cobas c311
(2, 4, false), -- QS6 en Cobas 6000 (Respaldo)
(2, 5, false), -- QS6 en Vitros 350 (Respaldo)
(3, 4, true),  -- QS24 en Cobas 6000
(3, 3, false), -- QS24 en Cobas c311 (Respaldo)
(4, 10, true), -- EGO en Sysmex UC-3500 + UF-4000
(5, 3, true),  -- Perfil Lipídico en Cobas c311
(5, 4, false), -- Perfil Lipídico en Cobas 6000
(6, 3, true),  -- Perfil Hepático en Cobas c311
(6, 4, false), -- Perfil Hepático en Cobas 6000
(7, 8, true),  -- Tiempos de Coagulación en Stago STA Compact
(7, 9, false), -- Coagulación en IL ACL TOP 300
(8, 1, true),  -- HbA1c en Sysmex
(9, 6, true),  -- Perfil Tiroideo en Architect i1000SR
(9, 7, false), -- Perfil Tiroideo en Beckman Access 2
(10, 6, true), -- PSA en Architect i1000SR
(10, 7, false),-- PSA en Beckman Access 2
(11, 6, true), -- VDRL en Architect
(12, 6, true), -- VIH en Architect i1000SR
(14, 12, true),-- Urocultivo en VITEK 2
(15, 12, true),-- Exudado en VITEK 2
(16, 3, true), -- Electrólitos en Cobas ISE
(17, 6, true), -- PCR en Architect
(18, 6, true), -- Vitamina D en Architect
(19, 3, true), -- Curva Glucosa en Cobas c311
(20, 11, true);-- Hemocultivo en BacT/ALERT

INSERT INTO estudios_tipos_muestra (id_estudio, id_tipo_muestra, contenedor_tubo, volumen_minimo_ml, es_obligatoria) VALUES
(1, 1, 'Tubo tapón lila con EDTA K2', 3.00, true),
(2, 2, 'Tubo tapón oro con gel separador', 4.00, true),
(3, 2, 'Tubo tapón oro con gel separador', 5.00, true),
(4, 4, 'Frasco estéril para orina 100 mL', 30.00, true),
(5, 2, 'Tubo tapón oro con gel separador', 4.00, true),
(6, 2, 'Tubo tapón oro con gel separador', 4.00, true),
(7, 3, 'Tubo tapón celeste con citrato 3.2%', 2.70, true),
(8, 1, 'Tubo tapón lila con EDTA K2', 2.00, true),
(9, 2, 'Tubo tapón oro con gel separador', 4.00, true),
(10, 2, 'Tubo tapón oro con gel separador', 3.00, true),
(11, 2, 'Tubo tapón oro con gel separador', 2.00, true),
(12, 2, 'Tubo tapón oro con gel separador', 3.00, true),
(13, 6, 'Frasco limpio hermético', 10.00, true),
(14, 4, 'Frasco estéril para urocultivo', 20.00, true),
(15, 7, 'Hisopo estéril en medio de transporte Stuart', 1.00, true),
(16, 2, 'Tubo tapón oro con gel separador', 2.00, true),
(17, 2, 'Tubo tapón oro con gel separador', 2.00, true),
(18, 2, 'Tubo tapón oro con gel separador', 3.00, true),
(19, 2, 'Tubos tapón gris/oro seriados', 12.00, true),
(20, 8, 'Botellas de hemocultivo Aerobia + Anaerobia', 16.00, true);

INSERT INTO parametros_estudio (id_estudio, codigo_parametro, nombre, unidad_medida, tipo_dato_resultado, orden_impresion, activo) VALUES
-- Estudio 1: Biometría Hemática
(1, 'LEUC', 'Leucocitos Totales', 'x10^3/uL', 'NUMERICO', 1, true),
(1, 'ERIT', 'Eritrocitos Totales', 'x10^6/uL', 'NUMERICO', 2, true),
(1, 'HEMO', 'Hemoglobina', 'g/dL', 'NUMERICO', 3, true),
(1, 'HTO', 'Hematocrito', '%', 'NUMERICO', 4, true),
(1, 'PLAQ', 'Plaquetas', 'x10^3/uL', 'NUMERICO', 5, true),
-- Estudio 2: Química Sanguínea 6 Elementos
(2, 'GLUC', 'Glucosa en Suero', 'mg/dL', 'NUMERICO', 1, true),
(2, 'UREA', 'Urea', 'mg/dL', 'NUMERICO', 2, true),
(2, 'BUN', 'Nitrógeno Ureico (BUN)', 'mg/dL', 'NUMERICO', 3, true),
(2, 'CREA', 'Creatinina', 'mg/dL', 'NUMERICO', 4, true),
(2, 'ACUR', 'Ácido Úrico', 'mg/dL', 'NUMERICO', 5, true),
(2, 'COLT', 'Colesterol Total', 'mg/dL', 'NUMERICO', 6, true),
-- Estudio 4: EGO
(4, 'ASPE', 'Aspecto Físico', NULL, 'CUALITATIVO', 1, true),
(4, 'COLR', 'Color', NULL, 'CUALITATIVO', 2, true),
(4, 'PH', 'Potencial de Hidrógeno (pH)', 'Unidades', 'NUMERICO', 3, true),
(4, 'DENS', 'Densidad Específica', 'g/mL', 'NUMERICO', 4, true),
(4, 'PROT', 'Proteínas en Orina', 'mg/dL', 'CUALITATIVO', 5, true),
(4, 'GLUO', 'Glucosa en Orina', 'mg/dL', 'CUALITATIVO', 6, true),
-- Estudio 5: Perfil Lipídico
(5, 'TRIG', 'Triglicéridos', 'mg/dL', 'NUMERICO', 1, true),
(5, 'CHDL', 'Colesterol HDL', 'mg/dL', 'NUMERICO', 2, true),
(5, 'CLDL', 'Colesterol LDL', 'mg/dL', 'NUMERICO', 3, true),
-- Estudio 7: Coagulación
(7, 'TP', 'Tiempo de Protrombina (TP)', 'segundos', 'NUMERICO', 1, true),
(7, 'INR', 'Razón Normalizada Internacional (INR)', 'Ratio', 'NUMERICO', 2, true),
(7, 'TTPA', 'Tiempo de Tromboplastina Parcial (TTPa)', 'segundos', 'NUMERICO', 3, true),
-- Estudio 8: HbA1c
(8, 'HBA1', 'Hemoglobina Glicosilada A1c', '%', 'NUMERICO', 1, true),
-- Estudio 9: Perfil Tiroideo
(9, 'TSH', 'Hormona Estimulante de Tiroides (TSH)', 'uUI/mL', 'NUMERICO', 1, true),
(9, 'T4L', 'Tiroxina Libre (T4L)', 'ng/dL', 'NUMERICO', 2, true),
-- Estudio 10: PSA
(10, 'PSAT', 'Antígeno Prostático Total (PSA)', 'ng/mL', 'NUMERICO', 1, true),
-- Estudio 11: VDRL
(11, 'VDRL', 'Reactividad VDRL/RPR', NULL, 'CUALITATIVO', 1, true),
-- Estudio 12: VIH
(12, 'VIH', 'Detección Anticuerpos VIH 1 y 2', NULL, 'CUALITATIVO', 1, true);

INSERT INTO valores_referencia (id_parametro, sexo_aplicable, edad_minima_dias, edad_maxima_dias, limite_inferior, limite_superior, valor_referencia_cualitativo, notas_interpretativas) VALUES
-- Leucocitos (id_parametro: 1)
(1, 'I', 4380, 43800, 4.5000, 11.0000, NULL, 'Adultos de 12 a 120 años'),
-- Eritrocitos (id_parametro: 2)
(2, 'M', 4380, 43800, 4.5000, 5.9000, NULL, 'Hombres adultos'),
(2, 'F', 4380, 43800, 4.0000, 5.2000, NULL, 'Mujeres adultas'),
-- Hemoglobina (id_parametro: 3)
(3, 'M', 4380, 43800, 13.8000, 17.2000, NULL, 'Varones a nivel del mar / moderada altitud'),
(3, 'F', 4380, 43800, 12.0000, 15.5000, NULL, 'Mujeres no gestantes'),
-- Hematocrito (id_parametro: 4)
(4, 'M', 4380, 43800, 40.0000, 50.0000, NULL, 'Hombres adultos'),
(4, 'F', 4380, 43800, 36.0000, 46.0000, NULL, 'Mujeres adultas'),
-- Plaquetas (id_parametro: 5)
(5, 'I', 0, 43800, 150.0000, 450.0000, NULL, 'Población general'),
-- Glucosa en Suero (id_parametro: 6)
(6, 'I', 4380, 43800, 70.0000, 99.0000, NULL, 'Ayuno normal de 8 a 12h. >126 mg/dL criterio diabetes.'),
-- Urea (id_parametro: 7)
(7, 'I', 4380, 43800, 15.0000, 45.0000, NULL, 'Función renal'),
-- BUN (id_parametro: 8)
(8, 'I', 4380, 43800, 7.0000, 20.0000, NULL, 'Nitrógeno ureico'),
-- Creatinina (id_parametro: 9)
(9, 'M', 4380, 43800, 0.7000, 1.3000, NULL, 'Hombres adultos'),
(9, 'F', 4380, 43800, 0.5000, 1.1000, NULL, 'Mujeres adultas'),
-- Ácido Úrico (id_parametro: 10)
(10, 'M', 4380, 43800, 3.4000, 7.0000, NULL, 'Hombres adultos'),
(10, 'F', 4380, 43800, 2.4000, 6.0000, NULL, 'Mujeres adultas'),
-- Colesterol Total (id_parametro: 11)
(11, 'I', 4380, 43800, 0.0000, 200.0000, NULL, '<200 Deseable; 200-239 Límite; >=240 Elevado'),
-- Triglicéridos (id_parametro: 18)
(18, 'I', 4380, 43800, 0.0000, 150.0000, NULL, '<150 Deseable; 150-199 Limítrofe alto; >=200 Alto'),
-- Colesterol HDL (id_parametro: 19)
(19, 'M', 4380, 43800, 40.0000, 60.0000, NULL, '>40 mg/dL protector'),
(19, 'F', 4380, 43800, 50.0000, 70.0000, NULL, '>50 mg/dL protector'),
-- Tiempo de Protrombina (id_parametro: 21)
(21, 'I', 0, 43800, 10.5000, 13.5000, NULL, 'Control normal de coagulación'),
-- INR (id_parametro: 22)
(22, 'I', 0, 43800, 0.8500, 1.1500, NULL, 'Sin anticoagulante oral'),
-- HbA1c (id_parametro: 24)
(24, 'I', 0, 43800, 4.0000, 5.6000, NULL, '<5.7% Normal; 5.7-6.4% Prediabetes; >=6.5% Diabetes'),
-- TSH (id_parametro: 25)
(25, 'I', 4380, 43800, 0.4500, 4.5000, NULL, 'Eutiroideo'),
-- PSA Total (id_parametro: 27)
(27, 'M', 14600, 43800, 0.0000, 4.0000, NULL, 'Hombres mayores de 40 años'),
-- VDRL (id_parametro: 28)
(28, 'I', 0, 43800, NULL, NULL, 'NO REACTIVO', 'Ausencia de reaginas luéticas'),
-- VIH (id_parametro: 29)
(29, 'I', 0, 43800, NULL, NULL, 'NO REACTIVO', 'Ausencia de anticuerpos y antígeno p24');

INSERT INTO pacientes (
    codigo_expediente, curp, nombre, primer_apellido, segundo_apellido,
    fecha_nacimiento, sexo, telefono, email, direccion, activo, creado_en
)
SELECT
    'PAC-' || lpad(i::text, 8, '0'),
    -- Generación de CURP sintética válida de 18 caracteres
    chr(65 + (i % 26)) || chr(65 + ((i * 3) % 26)) || chr(65 + ((i * 7) % 26)) || chr(65 + ((i * 11) % 26)) ||
    lpad((70 + (i % 30))::text, 2, '0') || lpad((1 + (i % 12))::text, 2, '0') || lpad((1 + (i % 28))::text, 2, '0') ||
    CASE WHEN (i % 2 = 0) THEN 'H' ELSE 'M' END ||
    'DF' || chr(65 + ((i * 5) % 26)) || chr(65 + ((i * 9) % 26)) || chr(65 + ((i * 13) % 26)) ||
    lpad((i % 99)::text, 2, '0'),
    (ARRAY['Juan', 'María', 'José', 'Ana', 'Luis', 'Laura', 'Pedro', 'Rosa', 'Miguel', 'Carmen', 'David', 'Elena', 'Fernando', 'Patricia', 'Roberto', 'Adriana', 'Manuel', 'Verónica', 'Francisco', 'Claudia'])[1 + (i % 20)],
    (ARRAY['Hernández', 'García', 'Martínez', 'López', 'González', 'Pérez', 'Rodríguez', 'Sánchez', 'Ramírez', 'Cruz', 'Flores', 'Gómez', 'Morales', 'Vázquez', 'Reyes', 'Jiménez', 'Torres', 'Díaz', 'Gutiérrez', 'Mendoza'])[1 + (i % 20)],
    (ARRAY['Aguilar', 'Ortiz', 'Castillo', 'Moreno', 'Chávez', 'Rivera', 'Ramos', 'Romero', 'Juárez', 'Alonso', 'Mejía', 'Campos', 'Vega', 'Soto', 'Silva', 'Delgado', 'Pacheco', 'Cervantes', 'Salazar', 'Maldonado'])[1 + ((i * 3) % 20)],
    DATE '1950-01-01' + ((i * 37) % 25000)::integer,
    CASE WHEN (i % 2 = 0) THEN 'M' ELSE 'F' END,
    '55' || lpad((10000000 + i)::text, 8, '0'),
    'paciente' || i || '@correo.com',
    'Calle ' || (1 + (i % 150)) || ' #' || (10 + (i % 900)) || ', Col. Centro, CP ' || (10000 + (i % 8000)),
    true,
    CURRENT_TIMESTAMP - (INTERVAL '1 day' * (500 - (i % 500)))
FROM generate_series(1, 5000) AS i;

-- ----------------------------------------------------------------------------
-- 3.1 Antecedentes Clínicos para ~1,500 Pacientes
-- ----------------------------------------------------------------------------
INSERT INTO antecedentes_clinicos (id_paciente, tipo_antecedente, descripcion, fecha_diagnostico, activo, registrado_en)
SELECT
    p.id_paciente,
    (ARRAY['ENFERMEDAD_CRONICA', 'ALERGIA', 'MEDICACION_ACTUAL', 'DIETA_ESPECIAL', 'OTRO'])[1 + ((p.num) % 5)],
    (ARRAY[
        'Diabetes Mellitus Tipo 2 en tratamiento con Metformina 850mg',
        'Hipertensión Arterial Sistémica controlada con Losartán 50mg',
        'Alergia documentada a la Penicilina y derivados betalactámicos',
        'Hipotiroidismo primario en sustitución con Levotiroxina 100mcg',
        'Dislipidemia mixta con prescripción de Atorvastatina 20mg',
        'Insuficiencia Renal Crónica Estadio 3b',
        'Ayuno prolongado mayor a 14 horas por instrucción médica previa'
    ])[1 + ((p.num) % 7)],
    DATE '2015-01-01' + (((p.num) * 41) % 3600)::integer,
    true,
    CURRENT_TIMESTAMP - INTERVAL '30 days'
FROM (
    SELECT id_paciente, row_number() OVER (ORDER BY id_paciente) AS num
    FROM pacientes
    LIMIT 1500
) p;

INSERT INTO solicitudes (
    folio_solicitud, id_paciente, id_medico, id_personal_registro,
    fecha_hora_solicitud, estado_solicitud, observaciones_clinicas
)
SELECT
    'SOL-2026-' || lpad(i::text, 6, '0'),
    -- Asignación a pacientes existentes (1 a 5000)
    1 + (i % 4900),
    -- Asignación a médicos (1 a 50) o NULL si particular
    CASE WHEN (i % 10 = 0) THEN NULL ELSE 1 + (i % 50) END,
    -- Personal de recepción (id 3 a 5)
    3 + (i % 3),
    -- Fechas escalonadas en los últimos 90 días
    CURRENT_TIMESTAMP - (INTERVAL '1 minute' * ((1200 - i) * 105)),
    -- Diversidad de estados de la orden
    CASE 
        WHEN i > 1170 THEN 'REGISTRADA'
        WHEN i > 1140 THEN 'MUESTRAS_TOMADAS'
        WHEN i > 1100 THEN 'EN_PROCESAMIENTO'
        WHEN i > 1080 THEN 'PARCIALMENTE_COMPLETADA'
        ELSE 'CONCLUIDA'
    END,
    (ARRAY[
        'Chequeo médico de rutina anual',
        'Control glucémico y metabólico semestral',
        'Evaluación preoperatoria para cirugía programada',
        'Seguimiento de cuadro infeccioso agudo',
        'Paciente acude por fatiga crónica y pérdida de peso',
        'Revisión preventiva solicitada por médico tratante'
    ])[1 + (i % 6)]
FROM generate_series(1, 1200) AS i;

INSERT INTO detalles_solicitudes_estudios (
    id_solicitud, id_estudio, estado_estudio,
    fecha_hora_inicio_proceso, fecha_hora_finalizacion, urgente
)
SELECT
    s.id_solicitud,
    e.id_estudio,
    CASE 
        WHEN s.estado_solicitud = 'REGISTRADA' THEN 'PENDIENTE_MUESTRA'
        WHEN s.estado_solicitud = 'MUESTRAS_TOMADAS' THEN 'MUESTRA_TOMADA_PENDIENTE_ANALISIS'
        WHEN s.estado_solicitud = 'EN_PROCESAMIENTO' THEN 'EN_PROCESAMIENTO'
        WHEN s.id_solicitud % 40 = 0 THEN 'EN_REPETICION'
        ELSE 'VALIDADO_LIBERADO'
    END,
    CASE 
        WHEN s.estado_solicitud IN ('EN_PROCESAMIENTO', 'PARCIALMENTE_COMPLETADA', 'CONCLUIDA') 
        THEN s.fecha_hora_solicitud + INTERVAL '30 minutes'
        ELSE NULL
    END,
    CASE 
        WHEN s.estado_solicitud = 'CONCLUIDA' 
        THEN s.fecha_hora_solicitud + INTERVAL '3 hours'
        ELSE NULL
    END,
    (s.id_solicitud % 15 = 0) -- 1 de cada 15 es Urgente
FROM solicitudes s
CROSS JOIN LATERAL (
    -- Asigna 2 o 3 estudios según el ID de solicitud
    SELECT id_estudio FROM catalogo_estudios 
    WHERE id_estudio IN (
        1 + (s.id_solicitud % 5),
        2 + ((s.id_solicitud * 2) % 6),
        CASE WHEN (s.id_solicitud % 2 = 0) THEN 4 + ((s.id_solicitud * 3) % 5) ELSE 1 END
    )
) e;

INSERT INTO muestras (
    codigo_barras_tubo, id_solicitud, id_paciente, id_tipo_muestra,
    id_personal_flebotomista, fecha_hora_toma, estado_muestra,
    condiciones_transporte, observaciones_toma
)
SELECT
    'BAR-' || to_char(s.fecha_hora_solicitud, 'YYYYMM') || '-' || lpad(row_number() OVER ()::text, 7, '0'),
    s.id_solicitud,
    s.id_paciente,
    tm.id_tipo_muestra,
    -- Flebotomistas (id 6 a 9)
    6 + (s.id_solicitud % 4),
    s.fecha_hora_solicitud + INTERVAL '15 minutes',
    CASE 
        WHEN s.estado_solicitud = 'REGISTRADA' THEN 'TOMADA'
        WHEN s.estado_solicitud = 'MUESTRAS_TOMADAS' THEN 'RECIBIDA_EN_LAB'
        WHEN s.estado_solicitud = 'EN_PROCESAMIENTO' THEN 'EN_ANALISIS'
        ELSE 'PROCESADA'
    END,
    'Refrigeración 2-8°C con geles térmicos',
    'Toma limpia en vena cefálica sin complicaciones'
FROM solicitudes s
CROSS JOIN LATERAL (
    -- Deduce tipos de muestra requeridos a partir de los estudios de la orden
    SELECT DISTINCT etm.id_tipo_muestra
    FROM detalles_solicitudes_estudios dse
    JOIN estudios_tipos_muestra etm ON dse.id_estudio = etm.id_estudio
    WHERE dse.id_solicitud = s.id_solicitud
) tm
WHERE s.estado_solicitud <> 'REGISTRADA' OR s.id_solicitud > 1190;

-- ----------------------------------------------------------------------------
-- 5.1 Relación Asociativa: Muestras con Detalles de Solicitud
-- ----------------------------------------------------------------------------
INSERT INTO muestras_detalles_solicitud (id_muestra, id_detalle_solicitud, momento_toma)
SELECT DISTINCT
    m.id_muestra,
    dse.id_detalle_solicitud,
    'BASAL'
FROM muestras m
JOIN detalles_solicitudes_estudios dse ON m.id_solicitud = dse.id_solicitud
JOIN estudios_tipos_muestra etm ON dse.id_estudio = etm.id_estudio AND m.id_tipo_muestra = etm.id_tipo_muestra
ON CONFLICT (id_muestra, id_detalle_solicitud) DO NOTHING;

INSERT INTO procesamientos_analiticos (
    id_detalle_solicitud, id_muestra, id_equipo, id_personal_analista,
    numero_corrida, fecha_hora_inicio, fecha_hora_fin, lote_reactivo, observaciones_tecnicas
)
SELECT
    dse.id_detalle_solicitud,
    mds.id_muestra,
    -- Asigna únicamente equipos homologados y que estén en estado ACTIVO (id 1 a 12)
    eec.id_equipo,
    -- Analistas de laboratorio (id 10 a 13)
    10 + (dse.id_detalle_solicitud % 4),
    -- Número de corrida (1 normalmente; 2 si estuvo en repetición)
    CASE WHEN dse.estado_estudio = 'EN_REPETICION' THEN 2 ELSE 1 END,
    dse.fecha_hora_inicio_proceso,
    COALESCE(dse.fecha_hora_finalizacion, dse.fecha_hora_inicio_proceso + INTERVAL '45 minutes'),
    'LOTE-2026-X' || (10 + (dse.id_estudio % 90)),
    'Corrida automatizada dentro de especificaciones de control de calidad'
FROM detalles_solicitudes_estudios dse
JOIN muestras_detalles_solicitud mds ON dse.id_detalle_solicitud = mds.id_detalle_solicitud
JOIN LATERAL (
    SELECT id_equipo FROM estudios_equipos_compatibles 
    WHERE id_estudio = dse.id_estudio AND id_equipo <= 12 -- Solo equipos activos
    ORDER BY es_equipo_principal DESC
    LIMIT 1
) eec ON true
WHERE dse.estado_estudio IN ('EN_PROCESAMIENTO', 'RESULTADO_CAPTURADO', 'EN_REPETICION', 'VALIDADO_LIBERADO');

INSERT INTO resultados (
    id_procesamiento, id_parametro, id_valor_referencia,
    valor_medido_numerico, valor_medido_texto, estado_interpretacion,
    es_resultado_vigente, fecha_hora_captura, id_personal_capturo,
    id_personal_valido, fecha_hora_validacion
)
SELECT
    p.id_procesamiento,
    param.id_parametro,
    vr.id_valor_referencia,
    -- Generación de valores numéricos realistas según el parámetro
    CASE 
        WHEN param.codigo_parametro = 'GLUC' THEN round((75.0 + ((p.id_procesamiento * 7) % 65))::numeric, 2)
        WHEN param.codigo_parametro = 'UREA' THEN round((18.0 + ((p.id_procesamiento * 3) % 35))::numeric, 2)
        WHEN param.codigo_parametro = 'CREA' THEN round((0.65 + (((p.id_procesamiento % 20))::numeric * 0.05)), 2)
        WHEN param.codigo_parametro = 'COLT' THEN round((150.0 + ((p.id_procesamiento * 11) % 110))::numeric, 2)
        WHEN param.codigo_parametro = 'TRIG' THEN round((90.0 + ((p.id_procesamiento * 13) % 160))::numeric, 2)
        WHEN param.codigo_parametro = 'LEUC' THEN round((5.0 + (((p.id_procesamiento % 15))::numeric * 0.4)), 2)
        WHEN param.codigo_parametro = 'HEMO' THEN round((12.5 + (((p.id_procesamiento % 10))::numeric * 0.35)), 2)
        WHEN param.codigo_parametro = 'PLAQ' THEN round((180.0 + ((p.id_procesamiento * 17) % 190))::numeric, 2)
        WHEN param.codigo_parametro = 'TSH'  THEN round((0.8 + (((p.id_procesamiento % 12))::numeric * 0.3)), 2)
        WHEN param.codigo_parametro = 'TP'   THEN round((11.2 + (((p.id_procesamiento % 8))::numeric * 0.2)), 2)
        ELSE NULL
    END,
    -- Generación de valores cualitativos
    CASE 
        WHEN param.tipo_dato_resultado = 'CUALITATIVO' AND param.codigo_parametro IN ('VDRL', 'VIH') THEN 'NO REACTIVO'
        WHEN param.tipo_dato_resultado = 'CUALITATIVO' AND param.codigo_parametro = 'ASPE' THEN 'LÍMPIDO'
        WHEN param.tipo_dato_resultado = 'CUALITATIVO' AND param.codigo_parametro = 'COLR' THEN 'AMARILLO'
        ELSE NULL
    END,
    -- Clasificación de interpretación
    CASE 
        WHEN (p.id_procesamiento % 17 = 0) THEN 'ALTO'
        WHEN (p.id_procesamiento % 31 = 0) THEN 'BAJO'
        WHEN (p.id_procesamiento % 73 = 0) THEN 'CRITICO_PANICO'
        ELSE 'NORMAL'
    END,
    -- Vigencia del resultado (si es una corrida previa de repetición, queda no vigente)
    CASE WHEN p.numero_corrida > 1 AND (p.id_procesamiento % 2 = 1) THEN false ELSE true END,
    p.fecha_hora_inicio + INTERVAL '35 minutes',
    p.id_personal_analista,
    -- Químicos Responsables (id 14 o 15)
    14 + (p.id_procesamiento % 2),
    p.fecha_hora_inicio + INTERVAL '2 hours'
FROM procesamientos_analiticos p
JOIN detalles_solicitudes_estudios dse ON p.id_detalle_solicitud = dse.id_detalle_solicitud
JOIN parametros_estudio param ON dse.id_estudio = param.id_estudio
LEFT JOIN LATERAL (
    SELECT id_valor_referencia FROM valores_referencia 
    WHERE id_parametro = param.id_parametro 
    LIMIT 1
) vr ON true;

INSERT INTO auditoria_repeticiones (
    id_resultado_original, id_resultado_nuevo, id_personal_autorizo,
    tipo_accion, motivo_inconsistencia, valor_anterior_numerico,
    valor_anterior_texto, fecha_hora_evento
)
SELECT
    r.id_resultado,
    NULL,
    COALESCE(r.id_personal_valido, 14),
    'REPETICION_POR_INCONSISTENCIA',
    (ARRAY[
        'Inconsistencia analítica: Discrepancia con delta check histórico del paciente.',
        'Valor crítico inesperado: Sospecha de microcoágulo o interferencia por lipemia.',
        'Falla puntual de calibración en celda fotométrica detectada en corrida de control.',
        'Resultado biológicamente implausible; se solicita repetición en analizador de respaldo.'
    ])[1 + (r.id_resultado % 4)],
    r.valor_medido_numerico,
    r.valor_medido_texto,
    r.fecha_hora_captura + INTERVAL '25 minutes'
FROM resultados r
WHERE r.estado_interpretacion = 'CRITICO_PANICO' OR r.es_resultado_vigente = false
LIMIT 120;

COMMIT;

DO $$
DECLARE
    cnt_pacientes INT;
    cnt_medicos INT;
    cnt_personal INT;
    cnt_equipos INT;
    cnt_estudios INT;
    cnt_solicitudes INT;
    cnt_detalles INT;
    cnt_muestras INT;
    cnt_procesos INT;
    cnt_resultados INT;
    cnt_auditorias INT;
BEGIN
    SELECT count(*) INTO cnt_pacientes FROM pacientes;
    SELECT count(*) INTO cnt_medicos FROM medicos;
    SELECT count(*) INTO cnt_personal FROM personal_laboratorio;
    SELECT count(*) INTO cnt_equipos FROM equipos;
    SELECT count(*) INTO cnt_estudios FROM catalogo_estudios;
    SELECT count(*) INTO cnt_solicitudes FROM solicitudes;
    SELECT count(*) INTO cnt_detalles FROM detalles_solicitudes_estudios;
    SELECT count(*) INTO cnt_muestras FROM muestras;
    SELECT count(*) INTO cnt_procesos FROM procesamientos_analiticos;
    SELECT count(*) INTO cnt_resultados FROM resultados;
    SELECT count(*) INTO cnt_auditorias FROM auditoria_repeticiones;

    RAISE NOTICE '=======================================================';
    RAISE NOTICE 'POBLACIÓN DE DATOS (SEEDER) COMPLETADA EXITOSAMENTE:';
    RAISE NOTICE '=======================================================';
    RAISE NOTICE '  - Pacientes registrados:           %', cnt_pacientes;
    RAISE NOTICE '  - Médicos prescriptores:           %', cnt_medicos;
    RAISE NOTICE '  - Personal operativo:              %', cnt_personal;
    RAISE NOTICE '  - Equipos analizadores:            %', cnt_equipos;
    RAISE NOTICE '  - Estudios en catálogo:            %', cnt_estudios;
    RAISE NOTICE '  - Solicitudes generadas:           %', cnt_solicitudes;
    RAISE NOTICE '  - Detalles de estudios pedidos:    %', cnt_detalles;
    RAISE NOTICE '  - Muestras biológicas tomadas:     %', cnt_muestras;
    RAISE NOTICE '  - Procesamientos en equipos:       %', cnt_procesos;
    RAISE NOTICE '  - Resultados analíticos medidos:   %', cnt_resultados;
    RAISE NOTICE '  - Auditorías y repeticiones:       %', cnt_auditorias;
    RAISE NOTICE '=======================================================';
END $$;