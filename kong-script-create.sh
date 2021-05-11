#! /bin/bash
# ${1}.- consumer name
# ${2}.- service name
# ${3}.- Upstream Host
# ${4}.- Upstream Path
# ${5}.- Route (exposed) path

usage() {
  cat <<EOF

Uso: $(basename "${BASH_SOURCE[0]}") "{consumer name}" "{service name}" "{Upstream Host}" "{Upstream Path}" "{route path}"

Ejemplo: $(basename "${BASH_SOURCE[0]}") "test-consumer-1" "test-service-1" "http://test.com" "/api/v1" "/test-route-path"

EOF
  exit
}

if [ "$1" == "" ]; then
    echo "ERROR: Debe especificar el nombre del consumer"
    usage
    exit 1
fi

if [ "$2" == "" ]; then
    echo "ERROR: Debe especificar el nombre del service"
    usage
    exit 1
fi

if [ "$3" == "" ]; then
    echo "ERROR: Debe especificar el nombre del Upstream Host"
    usage
    exit 1
fi

if [ "$4" == "" ]; then
    echo "ERROR: Debe especificar el nombre del Upstream Path"
    usage
    exit 1
fi

if [ "$5" == "" ]; then
    echo "ERROR: Debe especificar el nombre del Exposed Path"
    usage
    exit 1
fi

# Crear el consumer
export CONSUMER_NAME=$1
export SERVICE_NAME=$2
export UPSTREAM_HOST=$3
export UPSTREAM_PATH=$4
export ROUTE_PATH=$5

#export CONSUMER_NAME=test-1a
#export SERVICE_NAME=test-service-1a
#export UPSTREAM_HOST=http://test.com
#export UPSTREAM_PATH=/api/v1
#export ROUTE_PATH=/test-route-path

export CONSUMER_CREATION_JSON="username="${CONSUMER_NAME}
export SERVICE_CREATION_JSON_NAME="name="${SERVICE_NAME}
export SERVICE_CREATION_JSON_URL="url="${UPSTREAM_HOST}${UPSTREAM_PATH}
export ROUTE_CREATION_JSON="paths[]="${ROUTE_PATH}

# --------------------------------------------------------
echo "Creando consumer "$CONSUMER_NAME
curl -s -X POST http://localhost:8001/consumers/ -d "$CONSUMER_CREATION_JSON"
echo

# # Crear api-key para el consumer
echo
echo "Creando API KEY"
export PKEY=$(curl -s -X POST "http://localhost:8001/consumers/${CONSUMER_NAME}/key-auth/")

# # Muestra la KEY
echo API_KEY=$(echo $PKEY | jq -r ".key" )

# # Crear el servicio y guarda respuesta en variable SERVICE_CREATION_RESPONSE
echo
echo "Creando servicio "$SERVICE_NAME
export SERVICE_CREATION_RESPONSE=$(curl -s -X POST http://localhost:8001/services/ -d "$SERVICE_CREATION_JSON_NAME" -d "$SERVICE_CREATION_JSON_URL")

# # Extrae ID del Service desde RESP
export SERVICE_ID=$(echo ${SERVICE_CREATION_RESPONSE} | jq -r ".id")
echo SERVICE_ID=$SERVICE_ID

export SERVICE_ID_ROUTE_CREATION_JSON="service.id="${SERVICE_ID}
echo

# # Crear el Route
echo "Creando route "$ROUTE_PATH
export ROUTE_CREATION_RESPONSE=$(curl -s -X POST http://localhost:8001/routes/ -d "$ROUTE_CREATION_JSON" -d "$SERVICE_ID_ROUTE_CREATION_JSON")
export ROUTE_ID=$(echo ${ROUTE_CREATION_RESPONSE} | jq -r ".id")
echo ROUTE_ID=$ROUTE_ID

## ------------------------------------------------------------
## Cleanup
#curl -i -X DELETE http://localhost:8001/routes/${route_id}

#curl -i -X DELETE http://localhost:8001/services/{service_id}

#curl -i -X DELETE http://localhost:8001/consumers/{consumer_id}/key-auth/{key-auth_id}/

#curl -i -X DELETE http://localhost:8001/consumers/{consumer_id}
