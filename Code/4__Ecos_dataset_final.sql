/* =========================================================

PROYECTO     : Dashboard-Mercado-Laboral-Femenino-2024
AUTOR		 : Diego L. Villavicencio Merino
BASE DE DATOS: ENEMDU ANUAL 2024
AUTOR        : Diego L. Villavicencio
FECHA        : 2026-01-15
============================================================
	SCRIPT 4: Carga del dataset limpio y estandarizado
--------------------------------------------------------------
Descripción : Crea la tabla final de análisis con variables
              ya decodificadas y limpias, generada en el
              script de limpieza Python (script 3).
              Se carga desde el CSV exportado por Python y
              se estandarizan los valores NULL de columnas
              de texto a 'Desconocido' para consistencia
              en el modelo dimensional.
-- Fuente      : Enedu_2024_Participacion_limpia_Wins.csv
--               (salida del notebook 3__Limpieza.ipynb)
-- Base de datos: ecos_ec
-- ============================================================ */
use ecos_ec;
go
-- ============================================================
-- PASO 1: Crear tabla con columnas ya tipadas y nombradas
-- ------------------------------------------------------------
-- A diferencia de las tablas anteriores, aquí las columnas
-- ya tienen nombres descriptivos (no códigos ENEMDU) y los
-- tipos de datos reflejan el contenido real tras la limpieza.
-- id_persona es la clave primaria de la tabla.
-- ============================================================
drop table ENEMDU_2024_Participacion_Limpia;
CREATE TABLE ENEMDU_2024_Participacion_Limpia(
    Mes INT,
    Periodo INT,
    Categoria_ocupacion_secundaria NVARCHAR(100),
    Grupo_ocupacion_CIUO8 NVARCHAR(100),
    Categoria_ocupacion NVARCHAR(100),
    Rama_actividad NVARCHAR(100),
    Condicion_inactividad NVARCHAR(100),
    Condicion_actividad_laboral NVARCHAR(100),
    Razon_no_trabajo NVARCHAR(200),
    Razon_trabajo_menos_40_horas NVARCHAR(200),
    Razon_trabajo_mas_40_horas NVARCHAR(200),
    Desea_trabajar_mas_horas NVARCHAR(50),
    Disponible_trabajar_horas_adicionales NVARCHAR(50),
    Asiste_a_clases NVARCHAR(50),
    Razon_no_asiste_clases NVARCHAR(200),
    Nivel_instruccion_Compuesto NVARCHAR(100),
    Nivel_instruccion_Simple NVARCHAR(100),
    Estado_civil NVARCHAR(50),
    Seguro_Social_Alternativa_1 NVARCHAR(100),
    Seguro_Social_Alternativa_2 NVARCHAR(100),
    Ciudad INT,
    Area NVARCHAR(50),
    Provincia NVARCHAR(100),
    Sexo NVARCHAR(20),
    Edad INT,
    fexp FLOAT,                      -- Factor de expansión
    Pobreza NVARCHAR(50),
    Ingreso_laboral FLOAT,           -- Con winsorización aplicada (p1–p99)
    Ingreso_per_capita FLOAT,        -- Con winsorización aplicada (p1–p99)
    Horas_trabajo_semana_pasada INT,
    id_persona NVARCHAR(50),
    Mes_nombre NVARCHAR(50),         -- Columna derivada: nombre del mes
    Mes_abreviado NVARCHAR(20),      -- Columna derivada: abreviatura del mes
    Mes_cuartil NVARCHAR(20),        -- Columna derivada: Q1/Q2/Q3/Q4
    Region NVARCHAR(50),             -- Columna derivada: región geográfica
    CONSTRAINT PK_DatosENEMDU PRIMARY KEY (id_persona)
);


-- ============================================================
-- PASO 2: Carga masiva desde el CSV limpio generado por Python
-- ============================================================
BULK INSERT ENEMDU_2024_Participacion_Limpia
FROM 'C:\Users\Usuario iTC\Desktop\SQL Curso\Proyectos\2. ecos_ec\base de datos\2024\Enemdu personas\Enedu_2024_Participacion_limpia_Wins.csv'
WITH (
    FIRSTROW = 2,          -- omite la fila del encabezado
    FIELDTERMINATOR = ';', -- separador de columnas
    ROWTERMINATOR = '\n',  -- separador de filas
    TABLOCK,               -- mejora el rendimiento
    CODEPAGE = '65001'     -- UTF-8
);

-- Verificación: total de filas cargadas
select COUNT(*) FROM ENEMDU_2024_Participacion_Limpia;

-- Verificación: estructura de columnas (nombre, tipo y longitud)
SELECT
    COLUMN_NAME AS Nombre_Columna,
    DATA_TYPE AS Tipo_Dato,
    CHARACTER_MAXIMUM_LENGTH AS Longitud_Maxima
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ENEMDU_2024_Participacion_Limpia'
ORDER BY ORDINAL_POSITION;


-- ============================================================
-- PASO 3: Estandarizar NULLs en columnas de texto
-- ------------------------------------------------------------
-- Las columnas categóricas pueden quedar en NULL cuando la
-- pregunta del cuestionario no aplica a la persona encuestada
-- (p. ej., razón de inactividad para alguien empleado).
-- Se reemplazan por 'Desconocido' para mantener consistencia
-- en el modelo dimensional y evitar filas sin dimensión.
-- El bloque genera y ejecuta dinámicamente un UPDATE por
-- cada columna de texto de la tabla.
-- ============================================================
DECLARE @sql NVARCHAR(MAX);

SELECT @sql = STRING_AGG(
    'UPDATE ENEMDU_2024_Participacion_Limpia
     SET [' + COLUMN_NAME + '] = ''Desconocido''
     WHERE [' + COLUMN_NAME + '] IS NULL;',
    CHAR(13) + CHAR(10)
)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ENEMDU_2024_Participacion_Limpia'
  AND DATA_TYPE IN ('varchar', 'nvarchar', 'char', 'nchar');

EXEC sp_executesql @sql;


-- ============================================================
-- PASO 4: Verificación de nulos en columnas críticas
-- ------------------------------------------------------------
-- Se comprueba que las 4 variables más importantes del análisis
-- no tengan valores nulos tras la estandarización.
-- Resultado esperado: 0 nulos en todas las columnas.
-- ============================================================
SELECT
    SUM(CASE WHEN Categoria_ocupacion        IS NULL THEN 1 ELSE 0 END) AS Nulos_Categoria_ocupacion,
    SUM(CASE WHEN Condicion_actividad_laboral IS NULL THEN 1 ELSE 0 END) AS Nulos_Condicion_actividad,
    SUM(CASE WHEN Estado_civil               IS NULL THEN 1 ELSE 0 END) AS Nulos_Estado_civil,
    SUM(CASE WHEN Sexo                       IS NULL THEN 1 ELSE 0 END) AS Nulos_Sexo
FROM ENEMDU_2024_Participacion_Limpia;
