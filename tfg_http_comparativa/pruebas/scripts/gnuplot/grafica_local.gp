set terminal png size 1200,700
set output '../../../resultados/graficas/grafica_local.png'
set datafile separator ","
set title "Benchmark de Servidores Locales"
set xlabel "Tipo de prueba"
set ylabel "Tiempo de respuesta (s)"
set style data histograms
set style fill solid
set boxwidth 0.9
set xtic rotate by -45
set key outside
plot '../../../resultados/datos/resultados_local.csv' using 5:xtic(1) title 'Tiempo de respuesta (s)' lc rgb "#32CD32"
