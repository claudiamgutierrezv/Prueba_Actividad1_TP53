# ------------------------------------------------------------------
# funciones_genbank.R
# Funciones para leer un archivo GenBank (.gb) descargado de NCBI y
# obtener la información que necesita el proyecto.
#
# Se usa desde otros scripts con:  source("scripts/funciones_genbank.R")
# Solo usa R base (no necesita paquetes).
# ------------------------------------------------------------------

# Lee un archivo GenBank y devuelve una lista con:
#   especie, accesion, secuencia (ARNm completo), cds_inicio, cds_fin,
#   cds (nucleótidos de la región codificante) y proteina (aminoácidos)
leer_genbank <- function(archivo) {
  lineas <- readLines(archivo, warn = FALSE)

  # Accesión con versión, por ejemplo "NM_000546.6" (línea VERSION)
  linea_version <- grep("^VERSION", lineas, value = TRUE)[1]
  accesion <- strsplit(trimws(sub("^VERSION", "", linea_version)), "\\s+")[[1]][1]

  # Especie (línea ORGANISM)
  linea_organismo <- grep("^\\s+ORGANISM", lineas, value = TRUE)[1]
  especie <- trimws(sub("^\\s+ORGANISM", "", linea_organismo))

  # Secuencia completa: líneas entre ORIGIN y //
  inicio_origen <- grep("^ORIGIN", lineas)[1]
  fin_registro  <- grep("^//", lineas)[1]
  bloque <- lineas[(inicio_origen + 1):(fin_registro - 1)]
  secuencia <- toupper(gsub("[^a-zA-Z]", "", paste(bloque, collapse = "")))

  # Posiciones de la CDS, por ejemplo "     CDS             143..1324"
  linea_cds <- grep("^\\s{5}CDS\\s+", lineas)[1]
  if (is.na(linea_cds)) stop("El archivo ", archivo, " no tiene CDS anotada")
  ubicacion <- trimws(sub("^\\s{5}CDS\\s+", "", lineas[linea_cds]))
  numeros <- as.integer(regmatches(ubicacion, gregexpr("[0-9]+", ubicacion))[[1]])

  # Si la CDS está partida (join(a..b,c..d)), se unen los tramos en orden
  tramos <- matrix(numeros, ncol = 2, byrow = TRUE)
  cds <- paste(apply(tramos, 1, function(t) substr(secuencia, t[1], t[2])), collapse = "")

  # Traducción anotada (/translation="..."), que puede ocupar varias líneas
  proteina <- NA
  inicio_trad <- grep('/translation="', lineas)
  inicio_trad <- inicio_trad[inicio_trad > linea_cds][1]
  if (!is.na(inicio_trad)) {
    # Se juntan líneas hasta encontrar las dos comillas (apertura y cierre)
    texto <- ""
    i <- inicio_trad
    repeat {
      texto <- paste0(texto, trimws(lineas[i]))
      if (lengths(regmatches(texto, gregexpr('"', texto))) >= 2) break
      i <- i + 1
    }
    proteina <- gsub('/translation=|"', "", texto)
  }

  list(
    especie    = especie,
    accesion   = accesion,
    secuencia  = secuencia,
    cds_inicio = min(numeros),
    cds_fin    = max(numeros),
    cds        = cds,
    proteina   = proteina
  )
}

# Convierte "Homo sapiens" en "Homo_sapiens" para usarlo como nombre
nombre_corto <- function(especie) {
  gsub("\\s+", "_", especie)
}
