library(rgee)
library(sf)
library(raster)
library(rayshader)

# Initialize Earth Engine and Google Drive, both credentials must come from the same account google account.
ee_Initialize(user = "ndef", drive = TRUE)

# Download the WorldPop Global Project Population Data. Each EE spatial data
# structure (ee$Image, ee$ImageCollection, and ee$FeatureCollection) have a
# special attribute called "Dataset". Users can use it along with the
# auto-completation to quickly find the desired dataset.
population_data <- ee$ImageCollection$Dataset$CIESIN_GPWv411_GPW_Population_Density
population_data_max <- population_data$max()

# rgee offers several function to help the sync with smoother
population_data %>% ee_utils_dataset_display()

# rgee provides a lot of different ready-to-use functions to
# retrieve data from Google Earth Engine to your local system
sa_extent <- ee$Geometry$Rectangle(c(-100, -50, -20, 12), geodesic = TRUE, proj = "EPSG:4326")
population_data_ly_local <- ee_as_raster(
  image = population_data_max,
  region = sa_extent,
  dsn = "/home/barja/Descargas/population.tif",
  scale = 5000
)

# Lectura del raster density population
pop <- raster("population.tif")

# De raster a una matriz para manejar de forma adecuada en rayshader
pop_matrix <- raster_to_matrix(pop)

# sphere_shade: selección de colores para cada punto y textura de la superficie
# create_texture: Crea un mapa de textura basado en 5 colores
# plot_3d: Muestra el mapa sombreado en 3D
pop_matrix %>%
  sphere_shade(
    texture = create_texture("#FFFFFF", "#0800F0", "#FFFFFF", "#FFFFFF", "#FFFFFF")
  ) %>%
  plot_3d(
    elmat,
    zoom = 0.55, theta = 0, zscale = 100, soliddepth = -24,
    solidcolor = "#525252", shadowdepth = -40, shadowcolor = "black",
    shadowwidth = 25, windowsize = c(800, 720)
  )

# User defined title and subtitle
text <- paste0(
  "South America\npopulation density",
  strrep("\n", 27),
  "Source:GPWv411: Population Density (Gridded Population of the World Version 4.11)"
)

# Captura la vista actual de rgl y lo export en png
render_snapshot(
  filename = "30_poblacionsudamerica.png",
  title_text = text,
  title_size = 40,
  title_color = "black",
  tipefont = "bold",
  title_font = "Erban Poulentis",
  clear = T
)