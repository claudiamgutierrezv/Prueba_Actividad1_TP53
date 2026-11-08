# ------------------------------------------------------------------
# 01_descargar_secuencias.R
# Descarga desde NCBI los registros GenBank del gen TP53 listados en
# datos/accesiones.tsv y los guarda en datos/.
#
# Si los archivos ya están (porque se subieron a GitHub), no hace nada.
#
# Uso: source("scripts/01_descargar_secuencias.R")
# Requiere: conexión a Internet. Solo usa R base.
# ------------------------------------------------------------------
url_base <- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"

if (!file.exists("datos/accesiones.tsv")) {
  stop("No se encuentra datos/accesiones.tsv. Abre el proyecto .Rproj para que la carpeta de trabajo sea la raíz.")
}

accesiones <- read.delim("datos/accesiones.tsv", encoding = "UTF-8")
dir.create("datos", showWarnings = FALSE, recursive = TRUE)

for (i in seq_len(nrow(accesiones))) {
  accesion <- accesiones$accesion[i]
  archivo  <- file.path("datos", paste0(accesion, ".gb"))

  if (file.exists(archivo) && file.size(archivo) > 0) {
    message("Ya existe ", archivo, ", se omite.")
    next
  }

  message("Descargando ", accesion, " (", accesiones$nombre_comun[i], ")...")
  url <- paste0(url_base, "?db=nuccore&id=", accesion, "&rettype=gb&retmode=text")
  download.file(url, archivo, quiet = TRUE, mode = "wb")

  # NCBI permite como máximo 3 peticiones por segundo sin clave de API
  Sys.sleep(0.5)
}

message("Archivos en datos: ", paste(list.files("datos", pattern = "\\.gb$"), collapse = ", "))
