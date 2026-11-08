# ------------------------------------------------------------------
# 00_instalar_paquetes.R
# Instala los paquetes que necesita el proyecto. Solo hay que
# ejecutarlo una vez en cada ordenador.
#
#   - Biostrings: manejo de secuencias de ADN y proteínas (Bioconductor)
#   - msa: alineamiento múltiple con ClustalW (Bioconductor)
#
# Uso: source("scripts/00_instalar_paquetes.R")
# ------------------------------------------------------------------
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

paquetes <- c("Biostrings", "msa")
faltan <- paquetes[!sapply(paquetes, requireNamespace, quietly = TRUE)]

if (length(faltan) > 0) {
  BiocManager::install(faltan, update = FALSE, ask = FALSE)
} else {
  message("Todos los paquetes ya están instalados.")
}

for (p in paquetes) {
  message(p, " versión ", as.character(packageVersion(p)))
}
