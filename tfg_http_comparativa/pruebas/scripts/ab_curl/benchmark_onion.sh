#!/bin/bash

# CONFIG
ITERACIONES=1
PETICIONES=1
CONCURRENCIA=1
CSV="../../../resultados/datos/resultados_onion.csv"
GNUPLOT_SCRIPT="../gnuplot/grafica_onion.gp"

# PRUEBAS
PRUEBAS=(
  "Apache;http://tynnisy6sdu5vdebxowexe7j4sqdsnj4mryqy6kodgpe26gra7mbkoqd.onion/get"
  "NGINX;http://5n72jkg5pumhthnfrt23u53sgh6xtl2xrljw4ngobm5a4qj65doqvoyd.onion/get"
  "Caddy;http://uzexzv4f622lsxi6j75fbbz2itbfh2xkg7semp6ax6gqdrgz4zcbq5qd.onion/get"
  "Apache;http://tynnisy6sdu5vdebxowexe7j4sqdsnj4mryqy6kodgpe26gra7mbkoqd.onion/download"
  "NGINX;http://5n72jkg5pumhthnfrt23u53sgh6xtl2xrljw4ngobm5a4qj65doqvoyd.onion/download"
  "Caddy;http://uzexzv4f622lsxi6j75fbbz2itbfh2xkg7semp6ax6gqdrgz4zcbq5qd.onion/download"
)

echo "tipo,servidor,url,iteracion,tiempo_s,rps,bytes,concurrencia" > "$CSV"

function medir_curl {
  local servidor="$1" url="$2" iter="$3"
  tiempo=$( { /usr/bin/time -f "%e" curl --socks5-hostname 127.0.0.1:9050 -s -o /dev/null "$url"; } 2>&1 )
  bytes=$(curl --socks5-hostname 127.0.0.1:9050 -s -o /dev/null -w "%{size_download}" "$url")
  echo "curl-$servidor,$servidor,$url,$iter,$tiempo,NA,$bytes,$CONCURRENCIA" >> "$CSV"
}

function medir_ab {
  local servidor="$1" url="$2" iter="$3"
  ab_out=$(torsocks ab -n "$PETICIONES" -c "$CONCURRENCIA" "$url" 2>&1)
  tiempo=$(echo "$ab_out" | grep "Time taken for tests" | awk '{print $5}')
  rps=$(echo "$ab_out" | grep "Requests per second" | awk '{print $4}')
  bytes=$(echo "$ab_out" | grep "Total transferred" | awk '{print $3}')
  [[ -z "$tiempo" ]] && tiempo="ERROR"
  [[ -z "$rps" ]] && rps="ERROR"
  [[ -z "$bytes" ]] && bytes="0"
  echo "ab-$servidor,$servidor,$url,$iter,$tiempo,$rps,$bytes,$CONCURRENCIA" >> "$CSV"
}

for entrada in "${PRUEBAS[@]}"; do
  IFS=';' read -r servidor url <<< "$entrada"
  echo "Onion: $servidor - $url"
  for ((i=1; i<=ITERACIONES; i++)); do
    medir_curl "$servidor" "$url" "$i"
    medir_ab "$servidor" "$url" "$i"
  done
done

# Gnuplot
cat > "$GNUPLOT_SCRIPT" <<EOF
  set terminal png size 1200,700
  set output '../../../resultados/graficas/grafica_onion.png'
  set datafile separator ","
  set title "Benchmark de Servidores .onion"
  set xlabel "Tipo de prueba"
  set ylabel "Tiempo de respuesta (s)"
  set style data histograms
  set style fill solid
  set boxwidth 0.9
  set xtic rotate by -45
  set key outside
  plot \
    '$CSV' using 5:xtic(1) title 'Tiempo de respuesta (s)' lc rgb "#FF8C00"
EOF

gnuplot "$GNUPLOT_SCRIPT"

echo "Resultados en $CSV | Gráfica: grafica_onion.png"