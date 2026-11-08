# ------------------------------------------------------------------
# 03_estadisticas_gc.R
# Calcula para cada especie la longitud del ARNm, de la CDS y de la
# proteína, y el contenido GC (%) del ARNm y de la CDS.
#
# Entrada: datos/*.gb
# Salida:  resultados/resumen_secuencias.tsv
#
# Uso: source("scripts/03_estadisticas_gc.R")
# Requiere: Biostrings
# ------------------------------------------------------------------
suppressPackageStartupMessages(library(Biostrings))
source("scripts/funciones_genbank.R")

# Porcentaje de G + C en una secuencia de nucleótidos
contenido_gc <- function(secuencia) {
  if (nchar(secuencia) == 0) return(NA)
  frecuencia <- letterFrequency(DNAString(secuencia), letters = "GC", as.prob = TRUE)
  round(100 * as.numeric(frecuencia), 2)
}

archivos <- sort(list.files("datos", pattern = "\\.gb$", full.names = TRUE))
if (length(archivos) == 0) stop("No hay archivos .gb en datos")

registros <- lapply(archivos, leer_genbank)

tabla <- data.frame(
  especie          = sapply(registros, `[[`, "especie"),
  accesion         = sapply(registros, `[[`, "accesion"),
  long_ARNm_nt     = sapply(registros, function(r) nchar(r$secuencia)),
  GC_ARNm_pct      = sapply(registros, function(r) contenido_gc(r$secuencia)),
  long_CDS_nt      = sapply(registros, function(r) nchar(r$cds)),
  GC_CDS_pct       = sapply(registros, function(r) contenido_gc(r$cds)),
  long_proteina_aa = sapply(registros, function(r) nchar(r$proteina))
)

dir.create("resultados", showWarnings = FALSE, recursive = TRUE)
write.table(tabla, "resultados/resumen_secuencias.tsv",
            sep = "\t", quote = FALSE, row.names = FALSE)

print(tabla, row.names = FALSE)
message("Tabla generada: resultados/resumen_secuencias.tsv")
