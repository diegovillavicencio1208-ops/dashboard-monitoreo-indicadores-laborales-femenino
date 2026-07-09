# Modelo de Datos

![Modelo de Datos - Estrella](https://github.com/diegovillavicencio1208-ops/dashboard-monitoreo-indicadores-laborales-femenino/blob/b5a630f52b2e318163fdfdca7eba5e63028ff223/Imagenes/7.%20Modelo.png)

# 📊 Medidas DAX — Mercado Laboral Femenino

> **Proyecto:** Dashboard de situación del mercado laboral femenino en Ecuador  
> **Autor:** Diego L. Villavicecnio Merino 
> **Fuente de datos:** SQL Server `ecos_ec` (ENEMDU - INEC)  
> **Herramienta:** Power BI Desktop  

---


## 🔢 Medidas Base (auxiliares)

Estas medidas son la base sobre la que se construyen todos los indicadores. Siempre se calculan primero.

---

### `Numero de filas`
> Cuenta el número de registros en la tabla de hechos. Equivalente a `COUNT(*)` en SQL.

```dax
Numero de filas =
COUNTROWS(
    fct_participacionLaboral
)
```
- **Tabla:** `Medidas`
- **Tipo:** `Integer`
- **Formato:** `0`
- **Nota:** Trabaja sobre la muestra encuestada, **no** sobre la población expandida.

---

### `SUM fexp`
> Suma el factor de expansión (`fexp`) de cada registro. Este valor es el **peso estadístico** que transforma la muestra en estimaciones de la población real ecuatoriana.

```dax
SUM fexp =
SUM(fct_participacionLaboral[fexp])
```
- **Tabla:** `Medidas`
- **Tipo:** `Double`
- **Formato:** `0`
- **Nota crítica:** La mayoría de indicadores usan `[SUM fexp]` en lugar de `[Numero de filas]` para representar correctamente a la población.

---

### `Sum fext all`
> Calcula el total de la población para un conjunto de dimensiones específicas, ignorando filtros externos. Se usa como denominador en la medida `% Personas`.

```dax
Sum fext all =
VAR tablafiltrada =
    SUMMARIZE(
        ALL(fct_participacionLaboral),
        dim_Sexo[Sexo],
        dim_Sexo[Sexo e icono],
        dim_estadocivil[Estado_civil],
        dim_condicionActividad[Condicion_actividad_laboral],
        dim_educacion[Nivel_instruccion_Compuesto],
        dim_educacion[Nivel_instruccion_Simple],
        dim_locacion[Region],
        dim_categoriaOcupacional[Rama_actividad]
    )
VAR resultado =
    CALCULATE(
        [SUM fexp],
        tablafiltrada
    )
RETURN resultado
```
- **Tabla:** `Medidas`
- **Tipo:** `Double`
- **Nota:** Usa `SUMMARIZE` + `ALL` para crear un contexto limpio con los filtros de las dimensiones clave, sin heredar filtros del visual.

---

## 📈 Indicadores Principales

---

### `PET` — Población en Edad de Trabajar
> Personas de 15 años o más que forman parte de la fuerza laboral potencial (zona urbana). Usa el factor de expansión.

```dax
PET =
/* Población en edad de trabajar */
CALCULATE(
    [SUM fexp],
    fct_participacionLaboral[Edad] >= 15
)
```
- **Carpeta:** `indicadores`
- **Formato:** `0`
- **Nota:** La medida avanzada `Tasa de Participación Laboral (TPL)` diferencia entre zona rural (≥10 años) y urbana (≥15 años) según metodología INEC.

---

### `PEA` — Población Económicamente Activa
> Personas en edad de trabajar que están empleadas o buscan activamente empleo (excluye a la PEI).

```dax
PEA =
/* Población Económicamente Activa */
CALCULATE(
    [SUM fexp],
    dim_condicionActividad[Condicion_actividad_laboral] IN {
        "Empleado Adecuado/Pleno",
        "Subempleo por insuficiencia de tiempo de trabajo",
        "Subempleo por insuficiencia de ingreso",
        "Otro empleo no pleno",
        "Empleo no remunerado",
        "Empleo no clasificado",
        "Desempleo abierto",
        "Desempleo oculto"
    }
)
```
- **Carpeta:** `indicadores`
- **Tipo:** `Double`

---

### `PEI (Nro. Personas)` — Población Económicamente Inactiva
> Personas en edad de trabajar que no participan en el mercado laboral (estudiantes, amas de casa, jubilados, etc.).

```dax
PEI (Nro. Personas) =
/* Población económicamente inactiva */
CALCULATE(
    [SUM fexp],
    dim_condicionActividad[Condicion_actividad_laboral] = "Población económicamente inactiva"
)
```
- **Carpeta:** `indicadores`
- **Formato:** `#,0`

---

### `Tasa de Participación Laboral (TPL)`
> Indicador oficial INEC. Mide qué porcentaje de la PET está económicamente activa. Diferencia entre área rural (≥10 años) y urbana (≥15 años).

```dax
Tasa de Participación Laboral (TPL) =
-- Población en Edad de Trabajar (PET)
VAR PETRural =
    CALCULATE(
        [Numero de filas],
        dim_locacion[Area] = "Rural",
        fct_participacionLaboral[Edad] >= 10
    )
VAR PETUrbana =
    CALCULATE(
        [Numero de filas],
        dim_locacion[Area] = "Urbana",
        fct_participacionLaboral[Edad] >= 15
    )
VAR PET = PETRural + PETUrbana
-- Población Económicamente Activa (PEA)
VAR PEARural =
    CALCULATE(
        [Numero de filas],
        dim_locacion[Area] = "Rural",
        fct_participacionLaboral[Edad] >= 10,
        dim_condicionActividad[Condicion_actividad_laboral]
            <> "Población económicamente inactiva"
    )
VAR PEAUrbana =
    CALCULATE(
        [Numero de filas],
        dim_locacion[Area] = "Urbana",
        fct_participacionLaboral[Edad] >= 15,
        dim_condicionActividad[Condicion_actividad_laboral]
            <> "Población económicamente inactiva"
    )
VAR PEA = PEARural + PEAUrbana
-- Resultado
RETURN
DIVIDE(
    PEA,
    PET
)
```
- **Carpeta:** `Indicadores`
- **Formato:** `0 %;-0 %;0 %`
- **Fórmula:** `PEA / PET`

---

### `Tasa de inactividad`
> Porcentaje de la PET que no participa en el mercado laboral.

```dax
Tasa de inactividad =
DIVIDE(
    [PEI (Nro. Personas)],
    CALCULATE(
        [PET],
        REMOVEFILTERS(dim_condicionActividad[Condicion_actividad_laboral])
    )
)
```
- **Carpeta:** `Indicadores`
- **Formato:** `0 %;-0 %;0 %`
- **Fórmula:** `PEI / PET`
- **Nota:** Usa `REMOVEFILTERS` para calcular el PET total, sin que el filtro de condición de actividad afecte el denominador.

---

### `Participación Laboral (General %)`
> Tasa de participación laboral usando factor de expansión. Ignora el filtro de sexo para calcular el denominador (PET total).

```dax
Participación Laboral (General %) =
DIVIDE(
    [PEA],
    CALCULATE(
        [PET],
        ALL(dim_condicionActividad[Condicion_actividad_laboral]),
        ALL(dim_Sexo[Sexo e icono])
    )
)
```
- **Carpeta:** `Indicadores`
- **Formato:** `0.00 %;-0.00 %;0.00 %`
- **Nota:** `ALL()` sobre sexo y condición garantiza que el denominador siempre sea el PET de toda la población, no solo del grupo filtrado.

---

### `Participación Laboral - Mujer (%)`
> Tasa de participación laboral específica para mujeres.

```dax
Participación Laboral - Mujer (%) =
CALCULATE(
    [Participación Laboral (General %)],
    dim_Sexo[Sexo e icono] = "Mujer ♀️"
)
```
- **Formato:** `0.00 %;-0.00 %;0.00 %`

---

### `Participacion laboral (Nro. Personas)`
> Número absoluto de personas que participan en el mercado laboral, calculado como PET × tasa de participación.

```dax
Participacion laboral (Nro. Personas) =
VAR sumALL =
    CALCULATE(
        [PET],
        ALL(dim_Sexo[Sexo e icono])
    )
VAR calculo =
    CALCULATE(
        sumALL * [Participación Laboral (General %)]
    )
RETURN calculo
```
- **Formato:** `0`

---

### `Participacion Laboral (Nro. Mujer)`
> Número de mujeres que participan laboralmente.

```dax
Participacion Laboral (Nro. Mujer) =
CALCULATE(
    [Participacion laboral (Nro. Personas)],
    dim_Sexo[Sexo e icono] = "Mujer ♀️"
)
```
- **Formato:** `#,0`

---

### `Participación Laboral` *(etiqueta combinada)*
> Texto formateado para tarjeta: muestra `%` y número de personas entre paréntesis.

```dax
Participación Laboral =
FORMAT([Participación Laboral (General %)], "0.00%") &
" (" &
FORMAT([Participacion laboral (Nro. Personas)], "#,##") &
")"
```
- **Tipo:** `String`

---

## 🔴 Desempleo

---

### `Numero de personas desempleadas`
> Medida base. Cuenta (con expansión) a quienes están en desempleo abierto u oculto.

```dax
Numero de personas desempleadas =
CALCULATE(
    [SUM fexp],
    dim_condicionActividad[Condicion_actividad_laboral] IN {
        "Desempleo abierto",
        "Desempleo oculto"
    }
)
```

---

### `Desempleo % (General)`
> Tasa de desempleo general: desempleados / PEA total (ignora filtro de sexo en denominador).

```dax
Desempleo % (General) =
DIVIDE(
    [Numero de personas desempleadas],
    CALCULATE(
        [PEA],
        ALL(dim_Sexo[Sexo e icono])
    )
)
```
- **Carpeta:** `Indicadores`
- **Formato:** `0.00 %;-0.00 %;0.00 %`

---

### `Desempleo (Nro. Personas)`
> Alias con formato numérico para mostrar en tarjetas.

```dax
Desempleo (Nro. Personas) =
[Numero de personas desempleadas]
```
- **Formato:** `#,0`

---

### `Desempleo (Nro. Mujeres)`

```dax
Desempleo (Nro. Mujeres) =
CALCULATE(
    [Desempleo (Nro. Personas)],
    dim_Sexo[Sexo e icono] = "Mujer ♀️"
)
```
- **Formato:** `#,0`

---

## ✅ Empleo Adecuado

---

### `Empleo adecuado (General %)`
> Porcentaje de la población ocupada con empleo adecuado/pleno. El denominador es la Población Ocupada (excluye desempleo).

```dax
Empleo adecuado (General %) =
VAR EmpleoAdecuado =
    CALCULATE(
        [SUM fexp],
        dim_condicionActividad[Condicion_actividad_laboral] = "Empleado Adecuado/Pleno"
    )
VAR PO =
    /* Población Ocupada */
    CALCULATE(
        [SUM fexp],
        ALL(dim_Sexo[Sexo], dim_Sexo[Sexo e icono]),
        dim_condicionActividad[Condicion_actividad_laboral] IN {
            "Empleado Adecuado/Pleno",
            "Subempleo por insuficiencia de tiempo de trabajo",
            "Subempleo por insuficiencia de ingreso",
            "Otro empleo no pleno",
            "Empleo no remunerado"
        }
    )
RETURN
DIVIDE(
    EmpleoAdecuado,
    PO
)
```
- **Formato:** `0.00 %;-0.00 %;0.00 %`
- **Nota:** El denominador usa `ALL(dim_Sexo)` para que el % siempre se calcule sobre la Población Ocupada total, sin que el slicer de sexo distorsione el denominador.

---

### `Empleo adecuado (% Mujeres)`

```dax
Empleo adecuado (% Mujeres) =
CALCULATE(
    [Empleo adecuado (General %)],
    dim_Sexo[Sexo e icono] = "Mujer ♀️"
)
```
- **Formato:** `0.00 %;-0.00 %;0.00 %`

---

### `Empleo adecuado (% Hombres)`

```dax
Empleo adecuado (% Hombres) =
CALCULATE(
    [Empleo adecuado (General %)],
    dim_Sexo[Sexo e icono] = "Hombre ♂️"
)
```
- **Formato:** `0.00 %;-0.00 %;0.00 %`

---

### `Empleo adecuado (Nro. Personas)`
> Número absoluto estimado de personas con empleo adecuado: PEA × tasa de empleo adecuado.

```dax
Empleo adecuado (Nro. Personas) =
VAR sumALL =
    CALCULATE(
        [PEA],
        SUMMARIZE(dim_Sexo, dim_Sexo[Sexo e icono])
    )
VAR calculo =
    CALCULATE(
        sumALL * [Empleo adecuado (General %)]
    )
RETURN calculo
```
- **Formato:** `#,0`

---

### `Empleo adecuado (Nro. Mujeres)`

```dax
Empleo adecuado (Nro. Mujeres) =
CALCULATE(
    [Empleo adecuado (Nro. Personas)],
    dim_Sexo[Sexo e icono] = "Mujer ♀️"
)
```
- **Formato:** `#,0`

---

### `Empleo adecuado (△ % Mujeres - Hombres)`
> Brecha de empleo adecuado entre mujeres y hombres (diferencia porcentual). Valor negativo = mujeres en desventaja.

```dax
Empleo adecuado (△ % Mujeres - Hombres) =
VAR Mujeres =
    CALCULATE(
        [Empleo adecuado (General %)],
        dim_Sexo[Sexo e icono] = "Mujer ♀️"
    )
VAR Hombres =
    CALCULATE(
        [Empleo adecuado (General %)],
        dim_Sexo[Sexo e icono] = "Hombre ♂️"
    )
VAR variacion = Mujeres - Hombres
RETURN variacion
```
- **Formato:** `0.00 %;-0.00 %;0.00 %`

---

### `Empleo adecuado (△ Nro. Mujeres - Hombres)`
> Diferencia en número absoluto de personas con empleo adecuado: Hombres - Mujeres.

```dax
Empleo adecuado (△ Nro. Mujeres - Hombres) =
VAR Mujeres =
    CALCULATE(
        [Empleo adecuado (Nro. Personas)],
        dim_Sexo[Sexo e icono] = "Mujer ♀️"
    )
VAR Hombres1 =
    CALCULATE(
        [Empleo adecuado (Nro. Personas)],
        dim_Sexo[Sexo e icono] = "Hombre ♂️"
    )
VAR variacion = Hombres1 - Mujeres
RETURN variacion
```
- **Formato:** `#,0`

---

## 💰 Brecha Salarial

---

### `Ingreso Laboral Promedio`
> Promedio simple del ingreso laboral de la muestra.

```dax
Ingreso Laboral Promedio =
AVERAGE(fct_participacionLaboral[Ingreso_laboral])
```
- **Carpeta:** `Matirz`
- **Formato:** `$#,0`

---

### `Ingreso Per Cápita Promedio`

```dax
Ingreso Per Cápita Promedio =
AVERAGE(fct_participacionLaboral[Ingreso_per_capita])
```
- **Carpeta:** `Matirz`
- **Formato:** `$#,0`

---

### `Promedio salario hombres` / `Promedio salario mujeres`

```dax
Promedio salario hombres =
CALCULATE(
    [Promedio ingreso laboral],
    dim_Sexo[Sexo e icono] = "Hombre ♂️"
)

Promedio salario mujeres =
CALCULATE(
    [Promedio ingreso laboral],
    dim_Sexo[Sexo e icono] = "Mujer ♀️"
)
```

---

### `Brecha Salarial (% General)`
> Porcentaje de la brecha salarial de género: cuánto menos gana la mujer respecto al hombre.

```dax
Brecha Salarial (% General) =
VAR IngresoMujeres =
    CALCULATE(
        [Ingreso Laboral Promedio],
        dim_Sexo[Sexo e icono] = "Mujer ♀️"
    )
VAR IngresoHombres =
    CALCULATE(
        [Ingreso Laboral Promedio],
        dim_Sexo[Sexo e icono] = "Hombre ♂️"
    )
RETURN
DIVIDE(
    IngresoHombres - IngresoMujeres,
    IngresoHombres
)
```
- **Carpeta:** `Indicadores`
- **Formato:** `0 %;-0 %;0 %`
- **Fórmula:** `(Salario Hombre - Salario Mujer) / Salario Hombre`

---

### `Brecha Salarial - (Diferencia salario promedio hombres y mujeres)`
> Diferencia monetaria absoluta en dólares, formateada como texto para tarjetas.

```dax
Brecha Salarial - (Diferencia salario promedio hombres y mujeres) =
VAR hombres = [Promedio salario hombres]
VAR Mujeres = [Promedio salario mujeres]
VAR diferencia = hombres - Mujeres
RETURN FORMAT(diferencia, "$#.##")
```
- **Tipo:** `String`

---

### `Ingreso Laboral Promedio (Educacion - Sexo)`
> Ingreso promedio filtrado por combinaciones de educación y sexo. Usado en la matriz comparativa.

```dax
Ingreso Laboral Promedio (Educacion - Sexo) =
CALCULATE(
    [Ingreso Laboral Promedio],
    SUMMARIZE(
        fct_participacionLaboral,
        dim_Sexo[Sexo e icono],
        dim_educacion[Nivel_instruccion_Compuesto],
        dim_estadocivil[Estado_civil],
        dim_educacion[Nivel_instruccion_Simple],
        dim_condicionActividad[Condicion_actividad_laboral]
    )
)
```
- **Formato:** `$#,0`
- **Nota:** `SUMMARIZE` limpia el contexto para evitar doble conteo cuando la matriz tiene múltiples dimensiones activas.

---

## ⏱️ Brecha en Horas de Trabajo

---

### `Promedio Horas Trabajo`

```dax
Promedio Horas Trabajo =
AVERAGE(fct_participacionLaboral[Horas_trabajo_semana_pasada])
```
- **Carpeta:** `Matirz`
- **Formato:** `0`

---

### `Promedio horas trabajadas hombres` / `Promedio horas trabajadas mujeres`

```dax
Promedio horas trabajadas hombres =
CALCULATE(
    [Promedio Horas Trabajo],
    dim_Sexo[Sexo e icono] = "Hombre ♂️"
)

Promedio horas trabajadas mujeres =
CALCULATE(
    [Promedio Horas Trabajo],
    dim_Sexo[Sexo e icono] = "Mujer ♀️"
)
```
- **Formato:** `0`

---

### `Brecha Salarial (HH de trabajo)`
> Diferencia en horas trabajadas semanalmente entre hombres y mujeres.

```dax
Brecha Salarial (HH de trabajo) =
VAR hombre = [Promedio horas trabajadas hombres]
VAR mujer  = [Promedio horas trabajadas mujeres]
VAR diferencia = hombre - mujer
RETURN diferencia
```
- **Formato:** `0`

---

## 😴 Inactividad (PEI)

---

### `PEI (% General)`
> Porcentaje de la PET que es inactiva. Usa `SUMMARIZE` para calcular con contexto limpio de múltiples dimensiones.

```dax
PEI (% General) =
DIVIDE(
    CALCULATE(
        [PEI (Nro. Personas)],
        VAR tablaSINALL =
            SUMMARIZE(
                fct_participacionLaboral,
                dim_Sexo[Sexo e icono],
                dim_locacion[Region],
                dim_locacion[Provincia],
                dim_estadocivil[Estado_civil]
            )
        RETURN tablaSINALL
    ),
    CALCULATE(
        [SUM fexp],
        VAR tablaALL =
            SUMMARIZE(
                ALL(fct_participacionLaboral),
                dim_Sexo[Sexo e icono],
                dim_locacion[Provincia],
                dim_locacion[Region],
                dim_estadocivil[Estado_civil]
            )
        RETURN tablaALL
    )
)
```
- **Formato:** `0.00 %;-0.00 %;0.00 %`

---

### `PEI (% Mujer)`

```dax
PEI (% Mujer) =
CALCULATE(
    [PEI (% General)],
    dim_Sexo[Sexo e icono] = "Mujer ♀️"
)
```
- **Formato:** `0.00 %;-0.00 %;0.00 %`

---

### `PEI (Nro Mujer)`

```dax
PEI (Nro Mujer) =
CALCULATE(
    [PEI (Nro. Personas)],
    dim_Sexo[Sexo e icono] = "Mujer ♀️"
)
```
- **Formato:** `#,0`

---

## 🎨 Formato Condicional

Estas medidas devuelven colores HEX o íconos de Power BI para dar retroalimentación visual inmediata.

---

### `ColorSexo`
> Asigna color rosado a Mujer y azul a Hombre para consistencia visual en todos los gráficos.

```dax
ColorSexo =
SWITCH(
    SELECTEDVALUE(dim_Sexo[Sexo e icono]),
    "Mujer ♀️",  "#d27d93",
    "Hombre ♂️", "#6e8ecd",
    "#ffffff"   // color neutro por defecto
)
```

---

### `IconoPorSexo - Ingreso laboral Promedio`
> Devuelve `TriangleHigh` o `TriangleLow` según si el grupo seleccionado tiene ingreso mayor o menor que el otro sexo.

```dax
IconoPorSexo - Ingreso laboral Promedio =
VAR S = SELECTEDVALUE(dim_Sexo[Sexo e icono])
VAR M = CALCULATE([Ingreso Laboral Promedio], dim_Sexo[Sexo e icono] = "Mujer ♀️")
VAR H = CALCULATE([Ingreso Laboral Promedio], dim_Sexo[Sexo e icono] = "Hombre ♂️")
RETURN
IF(
    ISBLANK(S) || ISBLANK(M) || ISBLANK(H),
    BLANK(),
    IF(
        (S = "Mujer ♀️" && M > H) || (S = "Hombre ♂️" && H > M),
        "TriangleHigh",
        "TriangleLow"
    )
)
```
- **Carpeta:** `Formato_Condicional`
- **Patrón reutilizado en:** `IconoPorSexo - Ingreso Per Capita Promedio`, `IconoPorSexo - Horas Promedio`, `IconoPorSexo - Participacion Laboral`, `IconoPorSexo - Empleo adecuado`

---

### `Color etiqueta - Desempleo`
> Rojo si la tasa de desempleo femenina es mayor, verde si es menor o igual.

```dax
Color etiqueta - Desempleo =
VAR Condicion =
    [Desempleo % Mujeres] > [Desempleo % Hombres]
RETURN
IF(Condicion, "#FF0000", "#00bb2d")
```
> **Mismo patrón:** `Color etiqueta - Participacion laboral`, `Color etiqueta - Empleo Adecuado`, `PEI - Color barra título`

---

### `Color mapa`
> Genera un color HEX interpolado entre azul → blanco → rojo según la posición relativa de la brecha de empleo adecuado entre mujeres y hombres. Usado en el mapa coroplético.

```dax
Color mapa =
VAR valor   = [Empleo adecuado (△ % Mujeres - Hombres)]
VAR maximo  = MAXX(ALLSELECTED(dim_educacion), [Empleo adecuado (△ % Mujeres - Hombres)])
VAR minimo  = MINX(ALLSELECTED(dim_educacion), [Empleo adecuado (△ % Mujeres - Hombres)])
VAR rango   = maximo - minimo
VAR porcentaje = DIVIDE(valor - minimo, rango, 0)
-- Interpolación RGB: azul (#0000FF) → blanco (#FFFFFF) → rojo (#FF0000)
VAR rojo  = ROUND(IF(porcentaje < 0.5, 255 * (porcentaje * 2), 255), 0)
VAR verde = ROUND(IF(porcentaje < 0.5, 255 * (porcentaje * 2), 255 * (2 - porcentaje * 2)), 0)
VAR azul  = ROUND(IF(porcentaje < 0.5, 255, 255 * (2 - porcentaje * 2)), 0)
RETURN
"#" & FORMAT(rojo, "X2") & FORMAT(verde, "X2") & FORMAT(azul, "X2")
```
- **Tipo:** `String`
- **Nota:** Técnica de interpolación RGB manual en DAX — sin dependencias externas.

---

### `Ubicacion Seleccionada`
> Devuelve el nombre de provincia o región según el slicer de ubicación seleccionado. Usado para títulos dinámicos.

```dax
Ubicacion Seleccionada =
SWITCH(
    SELECTEDVALUE('Filtro Ubicacion '[Filtro Ubicacion ]),
    "Provincia", MAX(dim_locacion[Provincia]),
    "Region",    MAX(dim_locacion[Region]),
    BLANK()
)
```

---

## 📊 Porcentajes de Distribución

---

### `% Personas`
> Participación porcentual de cada categoría respecto al total expandido del contexto actual.

```dax
% Personas =
DIVIDE(
    [SUM fexp],
    [Sum fext all]
)
```
- **Carpeta:** `indicadores`
- **Formato:** `0.00 %;-0.00 %;0.00 %`

---

## 🗺️ Tabla de dependencias entre medidas

```
SUM fexp ──────────────┬──► PEA ──────────────┬──► Participación Laboral (General %)
Numero de filas ────── │                       ├──► Desempleo % (General)
                       │                       └──► Empleo adecuado (General %)
                       ├──► PEI (Nro. Personas) ──► Tasa de inactividad
                       │                            PEI (% General/Mujer)
                       └──► PET ─────────────────► Tasa de Participación Laboral (TPL)

AVERAGE(Ingreso_laboral) ──► Ingreso Laboral Promedio ──► Brecha Salarial (% General)
                                                          Brecha Salarial (Diferencia $)

AVERAGE(Horas_trabajo) ───► Promedio Horas Trabajo ────► Brecha Salarial (HH de trabajo)
```

---

*Documentación generada automáticamente desde el modelo semántico de Power BI Desktop — Abril 2026*
