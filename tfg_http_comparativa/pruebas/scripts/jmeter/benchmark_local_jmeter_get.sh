#!/bin/bash

# ARCHIVO CSV ORIGINAL
ORIGINAL_JMX="../../../resultados/datos/comparativa_http_get.jmx"
# ARCHIVO INTERMEDIO
DATOS_FILTRADOS="../../../resultados/datos/latencia_get.jmx"
# ARCHIVO PARA GNUPLOT
GNUPLOT_SCRIPT="../gnuplot/grafica_latencia_get.gp"

#Extraer solo primeras 6 líneas útiles y columnas necesarias
#Campos: label,Latency
echo "label,latency" > "$DATOS_FILTRADOS"
head -n 7 "$ORIGINAL_JMX" | tail -n 6 | cut -d',' -f1,13 >> "$DATOS_FILTRADOS"

#Crear script de Gnuplot
cat > "$GNUPLOT_SCRIPT" <<EOF
set terminal png size 1200,700
set output "../../../resultados/graficas/grafica_latencia_get.png"
set datafile separator ","
set title "Latencia por Petición (primeras 6 muestras)"
set xlabel "Servidor"
set ylabel "Latencia (ms)"
set style data histograms
set style fill solid border -1
set boxwidth 0.6
set xtics rotate by -45
set key off
plot "$DATOS_FILTRADOS" using 2:xtic(1) linecolor rgb "#4682B4"
EOF

gnuplot "$GNUPLOT_SCRIPT"

echo "Gráfica generada: grafica_latencia_get.png"