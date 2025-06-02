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
plot "../../../resultados/datos/latencia_get.jmx" using 2:xtic(1) linecolor rgb "#4682B4"
