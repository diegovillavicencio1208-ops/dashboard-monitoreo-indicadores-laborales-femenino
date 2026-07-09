/* =========================================================

PROYECTO     : Dashboard-Mercado-Laboral-Femenino-2024
AUTOR		 : Diego L. Villavicencio Merino
BASE DE DATOS: ENEMDU ANUAL 2024
AUTOR        : Diego L. Villavicencio
FECHA        : 2026-01-15

============================================================
	SCRIPT 2: Selección de variables para el análisis
-------------------------------------------------------------
Descripción : A partir de la tabla tipada ENEMDU_2024_Personas,
			  se seleccionan únicamente las variables necesarias
			  para el dashboard de situación laboral femenina.
			  Se aplica un filtro inicial para eliminar registros
			  con nulos en variables críticas para el análisis.
-- Resultado : Tabla ENEMDU_2024_Participacion (~320.973 filas)
-- Base de datos: ecos_ec
-- ============================================================ */
Use ecos_ec;
go

-- ============================================================
-- PASO 1: Crear tabla con las variables seleccionadas
-- ------------------------------------------------------------
-- Solo se extraen las columnas que se usarán en el modelo.
-- Las columnas conservan sus códigos originales ENEMDU;
-- la decodificación a etiquetas legibles se realiza en el
-- script de limpieza Python (script 3).
-- El filtro WHERE descarta registros con nulos en variables
-- indispensables para los indicadores del dashboard.
-- ============================================================
drop table ENEMDU_2024_Participacion;
select
    -- Tiempo
    mes,
    periodo,

    -- Categoría ocupacional (empleo principal y secundario)
    p54,     -- Categoría ocupacional secundaria
    grupo1,  -- Grupo de ocupación CIUO-8
    p42,     -- Categoría ocupacional principal
    rama1,   -- Rama de actividad económica

    -- Condición de actividad laboral
    p36,     -- Condición de inactividad (solo aplica a la PEI)
    condact, -- Condición de actividad (PEA / PEI / menores)

    -- Condiciones laborales (horas y disponibilidad)
    p23,     -- Razón por la que no trabajó la semana pasada
    p25,     -- Razón por la que trabajó menos de 40 horas
    p26,     -- Razón por la que trabajó más de 40 horas
    p27,     -- Desea trabajar más horas
    p28,     -- Disponible para trabajar horas adicionales

    -- Educación
    p07,     -- Asiste a clases
    p09,     -- Razón por la que no asiste a clases
    p10a,    -- Nivel de instrucción compuesto (detallado)
    nnivins, -- Nivel de instrucción simple (agrupado)

    -- Estado civil
    p06,

    -- Formalidad laboral (cobertura de seguridad social)
    p05a,    -- Seguro social - primera afiliación
    p05b,    -- Seguro social - segunda afiliación

    -- Ubicación geográfica
    ciudad,
    area,    -- 1=Urbana, 2=Rural
    prov,    -- Código de provincia

    -- Características demográficas
    p02,     -- Sexo (1=Hombre, 2=Mujer)
    p03,     -- Edad

    -- Variables de análisis cuantitativo
    fexp,    -- Factor de expansión (peso estadístico de la observación)
    pobreza, -- Indicador de pobreza por ingresos
    ingrl,   -- Ingreso laboral mensual
    ingpc,   -- Ingreso per cápita del hogar
    p24,     -- Horas trabajadas la semana pasada

    id_persona  -- Identificador único de persona (clave primaria futura)

INTO ENEMDU_2024_Participacion
FROM ENEMDU_2024_Personas
WHERE
    -- Se descartan registros sin información en variables clave
    -- para garantizar la integridad de los indicadores del dashboard
    id_persona IS NOT NULL AND   -- identidad de la observación
    p06        IS NOT NULL AND   -- estado civil (dimensión del modelo)
    p42        IS NOT NULL AND   -- categoría ocupacional (dimensión)
    ingpc      IS NOT NULL AND   -- ingreso per cápita (métrica)
    p24        IS NOT NULL AND   -- horas trabajadas (métrica)
    condact    IS NOT NULL AND   -- condición de actividad (eje central del análisis)
    p02        IS NOT NULL AND   -- sexo (variable de corte principal)
    p10a       IS NOT NULL AND   -- nivel de instrucción (dimensión)
    nnivins    IS NOT NULL;      -- nivel instrucción simple (dimensión)


-- ============================================================
-- Verificaciones post-carga
-- ============================================================

-- Número total de filas resultantes (esperado: ~320.973)
select COUNT(*)
from ENEMDU_2024_Participacion;

-- Número de columnas de la tabla resultante (esperado: 29)
SELECT COUNT(*) AS NumeroColumnas
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ENEMDU_2024_Participacion';
