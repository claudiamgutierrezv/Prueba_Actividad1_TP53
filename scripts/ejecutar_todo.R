# ------------------------------------------------------------------
# ejecutar_todo.R
# Ejecuta el análisis completo, en orden:
#   1. Descarga de secuencias (solo las que falten)
#   2. Extracción de CDS y proteínas
#   3. Estadísticas de longitud y contenido GC
#   4. Alineamiento de proteínas e identidad entre especies
#   5. Gráficos
#
# Uso: abrir analisis-comparativo-tp53.Rproj en RStudio, abrir este
#      archivo y pulsar "Source" (o Ctrl + Shift + S).
# ------------------------------------------------------------------
pasos <- c(
  "scripts/01_descargar_secuencias.R",
  "scripts/02_extraer_cds.R",
  "scripts/03_estadisticas_gc.R",
  "scripts/04_alinear.R",
  "scripts/05_graficos.R"
)

for (i in seq_along(pasos)) {
  cat("\n== Paso", i, "de", length(pasos), ":", pasos[i], "==\n")
  if (!file.exists(pasos[i])) stop("Falta el script ", pasos[i])
  source(pasos[i], encoding = "UTF-8")
}

cat("\nAnálisis terminado. Resultados:\n")
print(list.files("resultados", recursive = TRUE))
