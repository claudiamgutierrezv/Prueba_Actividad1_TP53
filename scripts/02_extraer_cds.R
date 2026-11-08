# ------------------------------------------------------------------
# 02_extraer_cds.R
# Lee los registros GenBank de datos/, extrae la región
# codificante (CDS) de cada especie y su proteína.
#
# Salida:
#   resultados/tp53_cds.fasta        (nucleótidos)
#   resultados/tp53_proteinas.fasta  (aminoácidos)
#
# Uso: abrir el proyecto .Rproj en RStudio y ejecutar
#      source("scripts/02_extraer_cds.R")
# Requiere: Biostrings (ver scripts/00_instalar_paquetes.R)
# ------------------------------------------------------------------
suppressPackageStartupMessages(library(Biostrings))
source("scripts/funciones_genbank.R")

archivos <- sort(list.files("datos", pattern = "\\.gb$", full.names = TRUE))
if (length(archivos) == 0) stop("No hay archivos .gb en datos")

dir.create("resultados", showWarnings = FALSE, recursive = TRUE)

registros <- lapply(archivos, leer_genbank)

nombres <- sapply(registros, function(r) paste0(nombre_corto(r$especie), "|", r$accesion))

# Secuencias codificantes en nucleótidos
cds <- DNAStringSet(sapply(registros, `[[`, "cds"))
names(cds) <- nombres

# Proteínas: se usa la traducción anotada; si falta, se traduce la CDS
proteinas <- sapply(seq_along(registros), function(i) {
  p <- registros[[i]]$proteina
  if (is.na(p)) p <- as.character(translate(cds[[i]]))
  sub("\\*$", "", p)   # quita el símbolo de parada final si lo hubiera
})
proteinas <- AAStringSet(proteinas)
names(proteinas) <- nombres

writeXStringSet(cds,       "resultados/tp53_cds.fasta")
writeXStringSet(proteinas, "resultados/tp53_proteinas.fasta")

resumen <- data.frame(
  secuencia   = nombres,
  CDS_nt      = width(cds),
  proteina_aa = width(proteinas)
)
print(resumen, row.names = FALSE)
message("Archivos generados en resultados/")
