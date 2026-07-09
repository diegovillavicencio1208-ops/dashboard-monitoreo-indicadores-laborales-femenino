/* =========================================================

PROYECTO     : Dashboard-Mercado-Laboral-Femenino-2024
AUTOR		 : Diego L. Villavicencio Merino
BASE DE DATOS: ENEMDU ANUAL 2024
AUTOR        : Diego L. Villavicencio
FECHA        : 2026-01-15

-- ============================================================
-- SCRIPT 5: Construcción del modelo dimensional (esquema estrella)
-- ------------------------------------------------------------
-- Descripción : A partir de la tabla plana limpia
--               ENEMDU_2024_Participacion_Limpia, se crean las
--               tablas de dimensiones y la tabla de hechos del
--               modelo estrella que se exporta a Power BI.
-- Patrón      : SELECT DISTINCT + ROW_NUMBER() para generar
--               surrogates keys (IDs) en cada dimensión.
-- Base de datos: ecos_ec
-- ============================================================ */
use ecos_ec;
go
-- ============================================================
-- REFERENCIA: Exploración inicial
-- ------------------------------------------------------------
-- Consulta de ejemplo para inspeccionar combinaciones únicas
-- antes de crear una dimensión. Se ejecuta manualmente para
-- validar que la granularidad sea la correcta.
-- ============================================================
SELECT
    ROW_NUMBER() OVER (ORDER BY Asiste_a_clases) AS id_educacion,
    combinaciones.Asiste_a_clases,
    combinaciones.Razon_no_asiste_clases,
    combinaciones.Nivel_instruccion_Compuesto,
    combinaciones.Nivel_instruccion_Simple
FROM (
    SELECT DISTINCT
        Asiste_a_clases,
        Razon_no_asiste_clases,
        Nivel_instruccion_Compuesto,
        Nivel_instruccion_Simple
    FROM ENEMDU_2024_Participacion_Limpia
) AS combinaciones;


-- ============================================================
-- DIMENSIONES
-- ============================================================


-- ------------------------------------------------------------
-- DIM 1: dim_educacion
-- Atributos de educación formal de la persona encuestada.
-- Clave natural: combinación de asistencia + razón + nivel.
-- ------------------------------------------------------------
drop table dim_educacion;
go
SELECT
    ROW_NUMBER() OVER (ORDER BY Asiste_a_clases) AS id_educacion,
    combinaciones.Asiste_a_clases,
    combinaciones.Razon_no_asiste_clases,
    combinaciones.Nivel_instruccion_Compuesto,
    combinaciones.Nivel_instruccion_Simple
INTO dim_educacion
FROM (
    SELECT DISTINCT
        Asiste_a_clases,
        Razon_no_asiste_clases,
        Nivel_instruccion_Compuesto,
        Nivel_instruccion_Simple
    FROM ENEMDU_2024_Participacion_Limpia
) AS combinaciones;


-- ------------------------------------------------------------
-- DIM 2: dim_locacion
-- Ubicación geográfica: región, provincia y área (urbana/rural).
-- Permite analizar indicadores por territorio.
-- ------------------------------------------------------------
drop table dim_locacion;
SELECT
    ROW_NUMBER() OVER (ORDER BY Provincia) AS id_locacion,
    combinaciones.Region,
    combinaciones.Provincia,
    combinaciones.Area
INTO dim_locacion
FROM (
    SELECT DISTINCT
        Region,
        Provincia,
        Area
    FROM ENEMDU_2024_Participacion_Limpia
) AS combinaciones;


-- ------------------------------------------------------------
-- DIM 3: dim_estadocivil
-- Estado civil de la persona (casada, soltera, unión libre, etc.)
-- ------------------------------------------------------------
drop table dim_estadocivil;
Select
    ROW_NUMBER() OVER (ORDER BY Estado_civil) AS id_estadocivil,
    combinaciones.Estado_civil
INTO dim_estadocivil
FROM (
    SELECT DISTINCT Estado_civil
    FROM ENEMDU_2024_Participacion_Limpia
) AS combinaciones;


-- ------------------------------------------------------------
-- DIM 4: dim_condicionesLaborales
-- Agrupa las razones y disponibilidad relacionadas con las
-- horas de trabajo (por qué no trabajó, por qué trabajó más
-- o menos de 40h, si desea o puede trabajar más horas).
-- ------------------------------------------------------------
drop table dim_condicionesLaborales;
Select
    ROW_NUMBER() OVER (ORDER BY Razon_trabajo_menos_40_horas) AS id_condicionesLaborales,
    combinaciones.Razon_no_trabajo,
    combinaciones.Razon_trabajo_menos_40_horas,
    combinaciones.Razon_trabajo_mas_40_horas,
    combinaciones.Desea_trabajar_mas_horas,
    combinaciones.Disponible_trabajar_horas_adicionales
INTO dim_condicionesLaborales
FROM (
    SELECT DISTINCT
        Razon_no_trabajo,
        Razon_trabajo_menos_40_horas,
        Razon_trabajo_mas_40_horas,
        Desea_trabajar_mas_horas,
        Disponible_trabajar_horas_adicionales
    FROM ENEMDU_2024_Participacion_Limpia
) AS combinaciones;


-- ------------------------------------------------------------
-- DIM 5: dim_calendario
-- Dimensión de tiempo: mes numérico, nombre, abreviatura,
-- cuartil y año (periodo). Permite análisis temporal.
-- ------------------------------------------------------------
drop table dim_calendario;
Select
    ROW_NUMBER() OVER (ORDER BY mes) AS id_calendario,
    combinaciones.mes,
    combinaciones.Mes_nombre,
    combinaciones.Mes_abreviado,
    combinaciones.Mes_cuartil,
    combinaciones.Periodo
INTO dim_calendario
FROM (
    SELECT DISTINCT
        mes,
        Mes_nombre,
        Mes_abreviado,
        Mes_cuartil,
        Periodo
    FROM ENEMDU_2024_Participacion_Limpia
) AS combinaciones;


-- ------------------------------------------------------------
-- DIM 6: dim_Sexo
-- Variable de corte principal del análisis (Hombre / Mujer).
-- ------------------------------------------------------------
drop table dim_Sexo;
Select
    ROW_NUMBER() OVER (ORDER BY Sexo) AS id_Sexo,
    combinaciones.Sexo
INTO dim_Sexo
FROM (
    SELECT DISTINCT Sexo
    FROM ENEMDU_2024_Participacion_Limpia
) AS combinaciones;


-- ------------------------------------------------------------
-- DIM 7: dim_condicionActividad
-- Condición de actividad laboral (PEA, PEI, subempleo, etc.)
-- y la razón de inactividad cuando aplica.
-- Es la dimensión central del análisis laboral.
-- ------------------------------------------------------------
drop table dim_condicionActividad;
Select
    ROW_NUMBER() OVER (ORDER BY Condicion_actividad_laboral) AS id_condicionActividad,
    combinaciones.Condicion_actividad_laboral,
    combinaciones.Condicion_inactividad
INTO dim_condicionActividad
FROM (
    SELECT DISTINCT
        Condicion_actividad_laboral,
        Condicion_inactividad
    FROM ENEMDU_2024_Participacion_Limpia
) AS combinaciones;


-- ------------------------------------------------------------
-- DIM 8: dim_categoriaOcupacional
-- Tipo de empleo (cuenta propia, asalariado, etc.),
-- grupo ocupacional CIUO-8 y rama de actividad económica.
-- ------------------------------------------------------------
drop table dim_categoriaOcupacional;
Select
    ROW_NUMBER() OVER (ORDER BY Categoria_ocupacion) AS id_categoriaOcupacional,
    combinaciones.Categoria_ocupacion,
    combinaciones.Grupo_ocupacion_CIUO8,
    combinaciones.Rama_actividad
INTO dim_categoriaOcupacional
FROM (
    SELECT DISTINCT
        Categoria_ocupacion,
        Grupo_ocupacion_CIUO8,
        Rama_actividad
    FROM ENEMDU_2024_Participacion_Limpia
) AS combinaciones;


-- ------------------------------------------------------------
-- DIM 9: dim_formalidad
-- Tipo de cobertura de seguridad social (IESS, ISSFA, ninguno,
-- etc.). Proxy de la formalidad laboral de la persona.
-- ------------------------------------------------------------
drop table dim_formalidad;
Select
    ROW_NUMBER() OVER (ORDER BY Seguro_Social_Alternativa_1) AS id_formalidad,
    combinaciones.Seguro_Social_Alternativa_1,
    combinaciones.Seguro_Social_Alternativa_2
INTO dim_formalidad
FROM (
    SELECT DISTINCT
        Seguro_Social_Alternativa_1,
        Seguro_Social_Alternativa_2
    FROM ENEMDU_2024_Participacion_Limpia
) AS combinaciones;


-- ------------------------------------------------------------
-- DIM 10: dim_pobreza
-- Clasificación de pobreza por ingresos (pobre / no pobre).
-- ------------------------------------------------------------
drop table dim_pobreza;
select
    ROW_NUMBER() OVER (ORDER BY pobreza) AS id_pobreza,
    combinaciones.Pobreza
INTO dim_Pobreza
FROM (
    SELECT DISTINCT Pobreza
    FROM ENEMDU_2024_Participacion_Limpia
) AS combinaciones;


-- ============================================================
-- TABLA DE HECHOS: fct_participacionLaboral
-- ------------------------------------------------------------
-- Contiene una fila por persona encuestada (granularidad
-- individual). Almacena las métricas cuantitativas y las
-- claves foráneas hacia cada dimensión.
-- Métricas : Edad, Ingreso_laboral, Ingreso_per_capita,
--            Horas_trabajo_semana_pasada, fexp
-- El JOIN se realiza por combinación de atributos (clave
-- natural) porque las dimensiones no tienen un código único
-- proveniente del cuestionario, sino surrogates generados.
-- ============================================================
drop table fct_participacionLaboral;
SELECT
    -- Medidas (hechos cuantitativos)
    p.id_persona,
    p.Edad,
    p.Ingreso_laboral,
    p.Ingreso_per_capita,
    p.Horas_trabajo_semana_pasada,
    p.fexp,              -- Factor de expansión: convierte la muestra en población

    -- Claves foráneas hacia las dimensiones
    e.id_educacion,
    l.id_locacion,
    ec.id_estadocivil,
    cl.id_condicionesLaborales,
    ca.id_calendario,
    s.id_sexo,
    a.id_condicionActividad,
    co.id_categoriaOcupacional,
    f.id_formalidad,
    po.id_pobreza

INTO fct_participacionLaboral
FROM ENEMDU_2024_Participacion_Limpia AS p

-- JOIN por combinación de atributos de educación
LEFT JOIN dim_educacion AS e
    ON p.Asiste_a_clases              = e.Asiste_a_clases
   AND p.Razon_no_asiste_clases       = e.Razon_no_asiste_clases
   AND p.Nivel_instruccion_Compuesto  = e.Nivel_instruccion_Compuesto
   AND p.Nivel_instruccion_Simple     = e.Nivel_instruccion_Simple

-- JOIN por combinación de atributos de ubicación
LEFT JOIN dim_locacion AS l
    ON p.Region   = l.Region
   AND p.Provincia = l.Provincia
   AND p.Area      = l.Area

LEFT JOIN dim_estadocivil AS ec
    ON p.Estado_civil = ec.Estado_civil

-- JOIN por combinación de atributos de condiciones laborales
LEFT JOIN dim_condicionesLaborales AS cl
    ON p.Razon_no_trabajo                    = cl.Razon_no_trabajo
   AND p.Razon_trabajo_menos_40_horas        = cl.Razon_trabajo_menos_40_horas
   AND p.Razon_trabajo_mas_40_horas          = cl.Razon_trabajo_mas_40_horas
   AND p.Desea_trabajar_mas_horas            = cl.Desea_trabajar_mas_horas
   AND p.Disponible_trabajar_horas_adicionales = cl.Disponible_trabajar_horas_adicionales

-- JOIN por mes y periodo (clave compuesta del calendario)
LEFT JOIN dim_calendario AS ca
    ON p.mes     = ca.mes
   AND p.Periodo = ca.Periodo

LEFT JOIN dim_sexo AS s
    ON p.Sexo = s.Sexo

-- JOIN por combinación de condición de actividad e inactividad
LEFT JOIN dim_condicionActividad AS a
    ON p.Condicion_actividad_laboral = a.Condicion_actividad_laboral
   AND p.Condicion_inactividad       = a.Condicion_inactividad

-- JOIN por combinación de categoría, rama y grupo CIUO-8
LEFT JOIN dim_categoriaOcupacional AS co
    ON p.Categoria_ocupacion    = co.Categoria_ocupacion
   AND p.Rama_actividad         = co.Rama_actividad
   AND p.Grupo_ocupacion_CIUO8  = co.Grupo_ocupacion_CIUO8

-- JOIN por combinación de ambas alternativas de seguro social
LEFT JOIN dim_formalidad AS f
    ON p.Seguro_Social_Alternativa_1 = f.Seguro_Social_Alternativa_1
   AND p.Seguro_Social_Alternativa_2 = f.Seguro_Social_Alternativa_2

LEFT JOIN dim_Pobreza AS po
    ON p.Pobreza = po.Pobreza;
