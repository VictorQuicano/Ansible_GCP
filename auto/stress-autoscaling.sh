#!/usr/bin/env bash
set -u

LB_IP="34.13.121.214"
ENDPOINT="/algoritmo?n=1000000"
URL="http://${LB_IP}${ENDPOINT}"

# Concurrencia
START_C=50
STEP_C=50
MAX_C=500
REQUESTS_PER_ROUND=2000


COOLDOWN_SEC=75
TARGET_INSTANCES=5

# Opcional: Para comprobar con gcloud el número de instancias:
USE_GCLOUD_CHECK=true
MIG_BASE_NAME="fastapi-app"
ZONE="northamerica-south1-b"
PROJECT="secret-epsilon-474011-m4"
# ============================

echo "Objetivo URL: $URL"
echo "Objetivo instancias: $TARGET_INSTANCES"
echo "Inicio ramp-up: ${START_C} concurrencia, paso ${STEP_C}, hasta ${MAX_C}"
echo

cur_c=${START_C}

check_instances() {
  if [ "${USE_GCLOUD_CHECK}" != "true" ]; then
    echo "(gcloud check deshabilitado)"
    return 1
  fi

  # Comprueba que gcloud exista
  if ! command -v gcloud >/dev/null 2>&1; then
    echo "gcloud no encontrado en PATH. No se puede comprobar instancias."
    return 1
  fi

  # Contar instancias que coincidan con el prefijo en la zona
  count=$(gcloud compute instances list \
    --project="${PROJECT}" \
    --zones="${ZONE}" \
    --filter="name~'^${MIG_BASE_NAME}-.*'" \
    --format="value(name)" 2>/dev/null | wc -l)

  # Si comando falla, devolvemos error
  if [ -z "${count}" ]; then
    echo "Error leyendo instancias con gcloud."
    return 1
  fi

  echo "Número de instancias reportadas por gcloud: ${count}"
  return 0
}

while [ "${cur_c}" -le "${MAX_C}" ]; do
  echo "=========="
  echo "Ronda: concurrencia = ${cur_c}, peticiones = ${REQUESTS_PER_ROUND}"
  echo "Comando: ab -n ${REQUESTS_PER_ROUND} -c ${cur_c} \"${URL}\""
  echo "Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "=========="

  # Ejecuta ab y guarda salida en archivo por ronda
  rundir="ab_runs"
  mkdir -p "${rundir}"
  outfile="${rundir}/ab_c${cur_c}_$(date +%s).log"

  # Ejecutar ab
  ab -n "${REQUESTS_PER_ROUND}" -c "${cur_c}" "${URL}" > "${outfile}" 2>&1 || true

  echo "Ronda completada. Salida guardada en: ${outfile}"
  echo

  # Chequeo opcional con gcloud
  if [ "${USE_GCLOUD_CHECK}" = "true" ]; then
    if check_instances; then
      # obtener valor de count dentro de la función resultante:
      count=$(gcloud compute instances list \
        --project="${PROJECT}" \
        --zones="${ZONE}" \
        --filter="name~'^${MIG_BASE_NAME}.*'" \
        --format="value(name)" 2>/dev/null | wc -l)
      echo "Instancias encontradas: ${count}"
      if [ "${count}" -ge "${TARGET_INSTANCES}" ]; then
        echo "✓ Objetivo alcanzado: ${count} instancias (>= ${TARGET_INSTANCES}). Parando test."
        exit 0
      fi
    else
      echo "No se pudo comprobar instancias con gcloud. Continuando sin comprobación."
    fi
  fi

  echo "Esperando ${COOLDOWN_SEC}s antes de siguiente ronda (dejar al autoscaler reaccionar)..."
  sleep "${COOLDOWN_SEC}"

  # incrementar concurrencia
  cur_c=$((cur_c + STEP_C))
done

echo "RAMP-UP completado (llegó a ${MAX_C} concurrencia). Si no alcanzaste ${TARGET_INSTANC
