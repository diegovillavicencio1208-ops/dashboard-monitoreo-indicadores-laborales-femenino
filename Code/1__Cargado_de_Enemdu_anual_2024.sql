/* =========================================================

PROYECTO     : Dashboard-Mercado-Laboral-Femenino-2024
AUTOR		 : Diego L. Villavicencio Merino
BASE DE DATOS: ENEMDU ANUAL 2024
AUTOR        : Diego L. Villavicencio
FECHA        : 2026-01-15

============================================================
SCRIPT 1: Carga de datos brutos ENEMDU 2024
------------------------------------------------------------
 Descripción : Crea la base de datos del proyecto, carga el
               archivo CSV original de la ENEMDU (encuesta de
               personas) en una tabla RAW con todas las
               columnas en VARCHAR, y luego las migra a una
               tabla tipada con los tipos de datos correctos.
Fuente      : BDDenemdu_personas_2024_anual.csv (INEC)
Base de datos: ecos_ec
============================================================ */
--PASO 1: Crear la base de datos del proyecto
--============================================================
Create database ecos_ec;
Use ecos_ec;
Go
/*============================================================
	PASO 2: Tabla RAW — recibe el CSV tal como viene
-------------------------------------------------------------
	Todas las columnas son VARCHAR(MAX) para evitar errores de
	tipo durante la carga masiva. La conversión de tipos se
	realiza en el PASO 4, a través de TRY_CAST.
	Nomenclatura de columnas: códigos originales del cuestionario
	ENEMDU (p01, p02, … p78, sd01…, condact, ingrl, fexp, etc.)
-- ============================================================*/
drop table ENEMDU_2024_Personas_Raw;
CREATE TABLE ENEMDU_2024_Personas_Raw (
    area VARCHAR(MAX),
    ciudad VARCHAR(MAX),
    conglomerado VARCHAR(MAX),
    panelm VARCHAR(MAX),
    vivienda VARCHAR(MAX),
    hogar VARCHAR(MAX),
    p01 VARCHAR(MAX),
    p02 VARCHAR(MAX),    -- Sexo
    p03 VARCHAR(MAX),    -- Edad
    p04 VARCHAR(MAX),
    p05a VARCHAR(MAX),   -- Seguro social (alternativa 1)
    p05b VARCHAR(MAX),   -- Seguro social (alternativa 2)
    p06 VARCHAR(MAX),    -- Estado civil
    p07 VARCHAR(MAX),    -- Asiste a clases
    p08 VARCHAR(MAX),
    p09 VARCHAR(MAX),    -- Razón por la que no asiste a clases
    p10a VARCHAR(MAX),   -- Nivel de instrucción compuesto
    p10b VARCHAR(MAX),
    p11 VARCHAR(MAX),
    p12a VARCHAR(MAX),
    p12b VARCHAR(MAX),
    p15 VARCHAR(MAX),
    p15aa VARCHAR(MAX),
    p15ab VARCHAR(MAX),
    cod_inf VARCHAR(MAX),
    p20 VARCHAR(MAX),
    p21 VARCHAR(MAX),
    p22 VARCHAR(MAX),
    p23 VARCHAR(MAX),    -- Razón por la que no trabajó
    p24 VARCHAR(MAX),    -- Horas trabajadas la semana pasada
    p25 VARCHAR(MAX),    -- Razón trabajó menos de 40 horas
    p26 VARCHAR(MAX),    -- Razón trabajó más de 40 horas
    p27 VARCHAR(MAX),    -- Desea trabajar más horas
    p28 VARCHAR(MAX),    -- Disponible para trabajar horas adicionales
    p29 VARCHAR(MAX),
    p30 VARCHAR(MAX),
    p31 VARCHAR(MAX),
    p32 VARCHAR(MAX),
    p33 VARCHAR(MAX),
    p34 VARCHAR(MAX),
    p35 VARCHAR(MAX),
    p36 VARCHAR(MAX),    -- Condición de inactividad
    p37 VARCHAR(MAX),
    p38 VARCHAR(MAX),
    p39 VARCHAR(MAX),
    p40 VARCHAR(MAX),
    p41 VARCHAR(MAX),
    p42 VARCHAR(MAX),    -- Categoría ocupacional (empleo principal)
    p42a VARCHAR(MAX),
    p43 VARCHAR(MAX),
    p44a VARCHAR(MAX),
    p44b VARCHAR(MAX),
    p44c VARCHAR(MAX),
    p44d VARCHAR(MAX),
    p44e VARCHAR(MAX),
    p44f VARCHAR(MAX),
    p44g VARCHAR(MAX),
    p44h VARCHAR(MAX),
    p44i VARCHAR(MAX),
    p44j VARCHAR(MAX),
    p44k VARCHAR(MAX),
    p45 VARCHAR(MAX),
    p46 VARCHAR(MAX),
    p47a VARCHAR(MAX),
    p47b VARCHAR(MAX),
    p48 VARCHAR(MAX),
    p49 VARCHAR(MAX),
    p50 VARCHAR(MAX),
    p51a VARCHAR(MAX),
    p51b VARCHAR(MAX),
    p51c VARCHAR(MAX),
    p52 VARCHAR(MAX),
    p53 VARCHAR(MAX),
    p54 VARCHAR(MAX),    -- Categoría ocupacional (empleo secundario)
    p54a VARCHAR(MAX),
    p55 VARCHAR(MAX),
    p56a VARCHAR(MAX),
    p56b VARCHAR(MAX),
    p57 VARCHAR(MAX),
    p58 VARCHAR(MAX),
    p61b1 VARCHAR(MAX),
    p63 VARCHAR(MAX),
    p64a VARCHAR(MAX),
    p64b VARCHAR(MAX),
    p65 VARCHAR(MAX),
    p66 VARCHAR(MAX),
    p67 VARCHAR(MAX),
    p68a VARCHAR(MAX),
    p68b VARCHAR(MAX),
    p69 VARCHAR(MAX),
    p70a VARCHAR(MAX),
    p70b VARCHAR(MAX),
    p71a VARCHAR(MAX),
    p71b VARCHAR(MAX),
    p72a VARCHAR(MAX),
    p72b VARCHAR(MAX),
    p73a VARCHAR(MAX),
    p73b VARCHAR(MAX),
    p74a VARCHAR(MAX),
    p74b VARCHAR(MAX),
    p75 VARCHAR(MAX),
    p76 VARCHAR(MAX),
    p77 VARCHAR(MAX),
    p78 VARCHAR(MAX),
    sd01 VARCHAR(MAX),
    sd021 VARCHAR(MAX),
    sd022 VARCHAR(MAX),
    sd023 VARCHAR(MAX),
    sd024 VARCHAR(MAX),
    sd025 VARCHAR(MAX),
    sd026 VARCHAR(MAX),
    sd027 VARCHAR(MAX),
    sd028 VARCHAR(MAX),
    sd029 VARCHAR(MAX),
    sd0210 VARCHAR(MAX),
    sd0211 VARCHAR(MAX),
    sd03 VARCHAR(MAX),
    ced01a VARCHAR(MAX),
    estrato VARCHAR(MAX),
    fexp VARCHAR(MAX),       -- Factor de expansión (peso estadístico)
    nnivins VARCHAR(MAX),    -- Nivel de instrucción simple
    ingrl VARCHAR(MAX),      -- Ingreso laboral
    ingpc VARCHAR(MAX),      -- Ingreso per cápita
    condact VARCHAR(MAX),    -- Condición de actividad laboral
    empleo VARCHAR(MAX),
    desempleo VARCHAR(MAX),
    secemp VARCHAR(MAX),
    grupo1 VARCHAR(MAX),     -- Grupo de ocupación CIUO-8
    rama1 VARCHAR(MAX),      -- Rama de actividad económica
    prov VARCHAR(MAX),       -- Código de provincia
    dominio VARCHAR(MAX),
    pobreza VARCHAR(MAX),    -- Indicador de pobreza
    epobreza VARCHAR(MAX),
    upm VARCHAR(MAX),
    id_vivienda VARCHAR(MAX),
    id_hogar VARCHAR(MAX),
    id_persona VARCHAR(MAX), -- Identificador único de persona
    periodo VARCHAR(MAX),
    mes VARCHAR(MAX)
);


-- ============================================================
-- PASO 3: Carga masiva desde el CSV original
-- ------------------------------------------------------------
-- Separador de campo : punto y coma (;)
-- Codificación       : UTF-8 (65001)
-- Primera fila       : encabezado (se omite con FIRSTROW = 2)
-- ============================================================
BULK INSERT ENEMDU_2024_Personas_Raw
FROM 'C:\Users\Usuario iTC\Desktop\SQL Curso\Proyectos\2. ecos_ec\base de datos\2024\Enemdu personas\BDDenemdu_personas_2024_anual.csv'
WITH (
    FIRSTROW = 2,          -- omite la fila del encabezado
    FIELDTERMINATOR = ';', -- separador de columnas
    ROWTERMINATOR = '\n',  -- separador de filas
    TABLOCK,               -- mejora el rendimiento en cargas grandes
    CODEPAGE = '65001'     -- UTF-8 para caracteres especiales (tildes, ñ)
);


-- ============================================================
-- PASO 4: Tabla tipada — conversión de VARCHAR a tipos finales
-- ------------------------------------------------------------
-- TRY_CAST convierte sin interrumpir la carga: si un valor no
-- puede castearse devuelve NULL en lugar de lanzar un error.
-- REPLACE(',', '.') normaliza el separador decimal europeo
-- antes del cast en columnas numéricas con decimales.
-- ============================================================
CREATE TABLE ENEMDU_2024_Personas (
    area INT,
    ciudad INT,
    conglomerado VARCHAR(MAX),
    panelm VARCHAR(MAX),
    vivienda VARCHAR(MAX),
    hogar VARCHAR(MAX),
    p01 VARCHAR(MAX),
    p02 INT,         -- Sexo
    p03 INT,         -- Edad
    p04 INT,
    p05a INT,        -- Seguro social (alternativa 1)
    p05b INT,        -- Seguro social (alternativa 2)
    p06 INT,         -- Estado civil
    p07 INT,         -- Asiste a clases
    p08 INT,
    p09 INT,         -- Razón no asiste a clases
    p10a INT,        -- Nivel instrucción compuesto
    p10b INT,
    p11 INT,
    p12a INT,
    p12b INT,
    p15 INT,
    p15aa INT,
    p15ab INT,
    cod_inf INT,
    p20 INT,
    p21 INT,
    p22 INT,
    p23 INT,         -- Razón no trabajó
    p24 INT,         -- Horas trabajadas semana pasada
    p25 INT,         -- Razón trabajó menos de 40 horas
    p26 INT,         -- Razón trabajó más de 40 horas
    p27 INT,         -- Desea trabajar más horas
    p28 INT,         -- Disponible para horas adicionales
    p29 INT,
    p30 INT,
    p31 INT,
    p32 INT,
    p33 INT,
    p34 INT,
    p35 INT,
    p36 INT,         -- Condición de inactividad
    p37 INT,
    p38 INT,
    p39 INT,
    p40 INT,
    p41 INT,
    p42 INT,         -- Categoría ocupacional principal
    p42a INT,
    p43 INT,
    p44a INT,
    p44b INT,
    p44c INT,
    p44d INT,
    p44e INT,
    p44f INT,
    p44g INT,
    p44h INT,
    p44i INT,
    p44j INT,
    p44k INT,
    p45 INT,
    p46 INT,
    p47a INT,
    p47b INT,
    p48 INT,
    p49 INT,
    p50 INT,
    p51a INT,
    p51b INT,
    p51c INT,
    p52 INT,
    p53 INT,
    p54 INT,         -- Categoría ocupacional secundaria
    p54a INT,
    p55 INT,
    p56a INT,
    p56b INT,
    p57 INT,
    p58 INT,
    p61b1 INT,
    p63 INT,
    p64a INT,
    p64b INT,
    p65 INT,
    p66 INT,
    p67 INT,
    p68a INT,
    p68b INT,
    p69 INT,
    p70a INT,
    p70b INT,
    p71a INT,
    p71b INT,
    p72a INT,
    p72b INT,
    p73a INT,
    p73b INT,
    p74a INT,
    p74b INT,
    p75 INT,
    p76 INT,
    p77 INT,
    p78 INT,
    sd01 INT,
    sd021 INT,
    sd022 INT,
    sd023 INT,
    sd024 INT,
    sd025 INT,
    sd026 INT,
    sd027 INT,
    sd028 INT,
    sd029 INT,
    sd0210 INT,
    sd0211 INT,
    sd03 INT,
    ced01a INT,
    estrato VARCHAR(MAX),
    fexp NUMERIC(8,2),       -- Factor de expansión
    nnivins NUMERIC(8,2),    -- Nivel instrucción simple (código numérico)
    ingrl NUMERIC(8,2),      -- Ingreso laboral
    ingpc NUMERIC(6,2),      -- Ingreso per cápita
    condact NUMERIC(8,2),    -- Condición actividad laboral (código)
    empleo NUMERIC(8,2),
    desempleo NUMERIC(8,2),
    secemp NUMERIC(8,2),
    grupo1 NUMERIC(8,2),     -- Grupo ocupación CIUO-8
    rama1 NUMERIC(8,2),      -- Rama de actividad
    prov NUMERIC(8,2),       -- Código de provincia
    dominio NUMERIC(2,0),
    pobreza NUMERIC(8,2),
    epobreza NUMERIC(8,2),
    upm VARCHAR(MAX),
    id_vivienda VARCHAR(MAX),
    id_hogar VARCHAR(MAX),
    id_persona VARCHAR(MAX),
    periodo NUMERIC(6,0),
    mes VARCHAR(MAX)
);

INSERT INTO ENEMDU_2024_Personas (
    area, ciudad, conglomerado, panelm, vivienda, hogar,
    p01, p02, p03, p04, p05a, p05b, p06, p07, p08, p09, p10a, p10b, p11, p12a, p12b,
    p15, p15aa, p15ab, cod_inf, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, p30,
    p31, p32, p33, p34, p35, p36, p37, p38, p39, p40, p41, p42, p42a, p43,
    p44a, p44b, p44c, p44d, p44e, p44f, p44g, p44h, p44i, p44j, p44k,
    p45, p46, p47a, p47b, p48, p49, p50, p51a, p51b, p51c,
    p52, p53, p54, p54a, p55, p56a, p56b, p57, p58, p61b1,
    p63, p64a, p64b, p65, p66, p67, p68a, p68b, p69, p70a, p70b,
    p71a, p71b, p72a, p72b, p73a, p73b, p74a, p74b, p75, p76, p77, p78,
    sd01, sd021, sd022, sd023, sd024, sd025, sd026, sd027, sd028, sd029,
    sd0210, sd0211, sd03, ced01a, estrato,
    fexp, nnivins, ingrl, ingpc, condact, empleo, desempleo, secemp,
    grupo1, rama1, prov, dominio, pobreza, epobreza,
    upm, id_vivienda, id_hogar, id_persona, periodo, mes
)
SELECT
    TRY_CAST(area AS INT),
    TRY_CAST(ciudad AS INT),
    conglomerado, panelm, vivienda, hogar,
    p01,
    TRY_CAST(p02 AS INT),
    TRY_CAST(p03 AS INT),
    TRY_CAST(p04 AS INT),
    TRY_CAST(p05a AS INT),
    TRY_CAST(p05b AS INT),
    TRY_CAST(p06 AS INT),
    TRY_CAST(p07 AS INT),
    TRY_CAST(p08 AS INT),
    TRY_CAST(p09 AS INT),
    TRY_CAST(p10a AS INT),
    TRY_CAST(p10b AS INT),
    TRY_CAST(p11 AS INT),
    TRY_CAST(p12a AS INT),
    TRY_CAST(p12b AS INT),
    TRY_CAST(p15 AS INT),
    TRY_CAST(p15aa AS INT),
    TRY_CAST(p15ab AS INT),
    TRY_CAST(cod_inf AS INT),
    TRY_CAST(p20 AS INT),
    TRY_CAST(p21 AS INT),
    TRY_CAST(p22 AS INT),
    TRY_CAST(p23 AS INT),
    TRY_CAST(p24 AS INT),
    TRY_CAST(p25 AS INT),
    TRY_CAST(p26 AS INT),
    TRY_CAST(p27 AS INT),
    TRY_CAST(p28 AS INT),
    TRY_CAST(p29 AS INT),
    TRY_CAST(p30 AS INT),
    TRY_CAST(p31 AS INT),
    TRY_CAST(p32 AS INT),
    TRY_CAST(p33 AS INT),
    TRY_CAST(p34 AS INT),
    TRY_CAST(p35 AS INT),
    TRY_CAST(p36 AS INT),
    TRY_CAST(p37 AS INT),
    TRY_CAST(p38 AS INT),
    TRY_CAST(p39 AS INT),
    TRY_CAST(p40 AS INT),
    TRY_CAST(p41 AS INT),
    TRY_CAST(p42 AS INT),
    TRY_CAST(p42a AS INT),
    TRY_CAST(p43 AS INT),
    TRY_CAST(p44a AS INT),
    TRY_CAST(p44b AS INT),
    TRY_CAST(p44c AS INT),
    TRY_CAST(p44d AS INT),
    TRY_CAST(p44e AS INT),
    TRY_CAST(p44f AS INT),
    TRY_CAST(p44g AS INT),
    TRY_CAST(p44h AS INT),
    TRY_CAST(p44i AS INT),
    TRY_CAST(p44j AS INT),
    TRY_CAST(p44k AS INT),
    TRY_CAST(p45 AS INT),
    TRY_CAST(p46 AS INT),
    TRY_CAST(p47a AS INT),
    TRY_CAST(p47b AS INT),
    TRY_CAST(p48 AS INT),
    TRY_CAST(p49 AS INT),
    TRY_CAST(p50 AS INT),
    TRY_CAST(p51a AS INT),
    TRY_CAST(p51b AS INT),
    TRY_CAST(p51c AS INT),
    TRY_CAST(p52 AS INT),
    TRY_CAST(p53 AS INT),
    TRY_CAST(p54 AS INT),
    TRY_CAST(p54a AS INT),
    TRY_CAST(p55 AS INT),
    TRY_CAST(p56a AS INT),
    TRY_CAST(p56b AS INT),
    TRY_CAST(p57 AS INT),
    TRY_CAST(p58 AS INT),
    TRY_CAST(p61b1 AS INT),
    TRY_CAST(p63 AS INT),
    TRY_CAST(p64a AS INT),
    TRY_CAST(REPLACE(p64b, ',', '.') AS INT),
    TRY_CAST(REPLACE(p65, ',', '.') AS INT),
    TRY_CAST(REPLACE(p66, ',', '.') AS INT),
    TRY_CAST(REPLACE(p67, ',', '.') AS INT),
    TRY_CAST(p68a AS INT),
    TRY_CAST(REPLACE(p68b, ',', '.') AS INT),
    TRY_CAST(REPLACE(p69, ',', '.') AS INT),
    TRY_CAST(p70a AS INT),
    TRY_CAST(REPLACE(p70b, ',', '.') AS INT),
    TRY_CAST(p71a AS INT),
    TRY_CAST(REPLACE(p71b, ',', '.') AS INT),
    TRY_CAST(p72a AS INT),
    TRY_CAST(REPLACE(p72b, ',', '.') AS INT),
    TRY_CAST(p73a AS INT),
    TRY_CAST(REPLACE(p73b, ',', '.') AS INT),
    TRY_CAST(p74a AS INT),
    TRY_CAST(REPLACE(p74b, ',', '.') AS INT),
    TRY_CAST(p75 AS INT),
    TRY_CAST(REPLACE(p76, ',', '.') AS INT),
    TRY_CAST(p77 AS INT),
    TRY_CAST(REPLACE(p78, ',', '.') AS INT),
    TRY_CAST(sd01 AS INT),
    TRY_CAST(sd021 AS INT),
    TRY_CAST(sd022 AS INT),
    TRY_CAST(sd023 AS INT),
    TRY_CAST(sd024 AS INT),
    TRY_CAST(sd025 AS INT),
    TRY_CAST(sd026 AS INT),
    TRY_CAST(sd027 AS INT),
    TRY_CAST(sd028 AS INT),
    TRY_CAST(sd029 AS INT),
    TRY_CAST(sd0210 AS INT),
    TRY_CAST(sd0211 AS INT),
    TRY_CAST(sd03 AS INT),
    TRY_CAST(ced01a AS INT),
    estrato,
    TRY_CAST(REPLACE(fexp, ',', '.') AS NUMERIC(8,2)),
    TRY_CAST(REPLACE(nnivins, ',', '.') AS NUMERIC(8,2)),
    TRY_CAST(REPLACE(ingrl, ',', '.') AS NUMERIC(8,2)),
    TRY_CAST(REPLACE(ingpc, ',', '.') AS NUMERIC(6,2)),
    TRY_CAST(REPLACE(condact, ',', '.') AS NUMERIC(8,2)),
    TRY_CAST(REPLACE(empleo, ',', '.') AS NUMERIC(8,2)),
    TRY_CAST(REPLACE(desempleo, ',', '.') AS NUMERIC(8,2)),
    TRY_CAST(REPLACE(secemp, ',', '.') AS NUMERIC(8,2)),
    TRY_CAST(REPLACE(grupo1, ',', '.') AS NUMERIC(8,2)),
    TRY_CAST(REPLACE(rama1, ',', '.') AS NUMERIC(8,2)),
    TRY_CAST(REPLACE(prov, ',', '.') AS NUMERIC(8,2)),
    TRY_CAST(REPLACE(dominio, ',', '.') AS NUMERIC(2,0)),
    TRY_CAST(REPLACE(pobreza, ',', '.') AS NUMERIC(8,2)),
    TRY_CAST(REPLACE(epobreza, ',', '.') AS NUMERIC(8,2)),
    upm,
    id_vivienda,
    id_hogar,
    id_persona,
    TRY_CAST(REPLACE(periodo, ',', '.') AS NUMERIC(6,0)),
    mes
FROM ENEMDU_2024_Personas_Raw;

-- Verificación: revisar los primeros registros de la tabla tipada
select * from ENEMDU_2024_Personas;
