#! /bin/bash
# ${1}.- consumer name
# ${2}.- api key
# ${3}.- service name
# ${4}.- Route (exposed) path

usage() {
  cat <<EOF

Uso: $(basename "${BASH_SOURCE[0]}") "{consumer name}" "{api key}" "{service name}" "{route path}"

Ejemplo: $(basename "${BASH_SOURCE[0]}") "test-consumer-1" "AtumDYA1ZSzqtTqUku5moEeCMOuRBr2d" "test-service-1" "/test-route-path"

EOF
  exit 
}

if [ "$1" == "" ]; then
    echo "ERROR: Debe especificar el nombre del consumer"
    usage
    exit 1
fi

if [ "$2" == "" ]; then
    echo "ERROR: Debe especificar API Key"
    usage
    exit 1
fi

if [ "$3" == "" ]; then
    echo "ERROR: Debe especificar el nombre del service"
    usage
    exit 1
fi

if [ "$4" == "" ]; then
    echo "ERROR: Debe especificar el nombre del Route Path"
    usage
    exit 1
fi

# Crear el consumer
export CONSUMER_NAME=$1
export API_KEY=$2
export SERVICE_NAME=$3
export ROUTE_PATH=$4

# --------------------------------------------------------
# Buscando route
echo "Borrando route "$ROUTE_PATH
export ROUTE_ID=$(curl -s -X GET http://localhost:8001/routes | jq -r '.data[] | select(.paths[] | index("'${ROUTE_PATH}'")).id')
echo ROUTE_ID=${ROUTE_ID}
curl -i -X DELETE http://localhost:8001/routes/${ROUTE_ID}

# Buscando service
echo
echo "Borrando service name "$SERVICE_NAME
export SERVICE_ID=$(curl -s -X GET http://localhost:8001/services/${SERVICE_NAME} | jq -r .id)
echo SERVICE_ID=${SERVICE_ID}
curl -i -X DELETE http://localhost:8001/services/${SERVICE_ID}

# Buscando Key
echo
echo "Borrando Key "$API_KEY
export KEY_ID=$(curl -s -X GET http://localhost:8001/consumers/${CONSUMER_NAME}/key-auth | jq -r '.data[] | select(.key | index("'${API_KEY}'")).id')
echo KEY_ID=${KEY_ID}
curl -i -X DELETE http://localhost:8001/consumers/${CONSUMER_NAME}/key-auth/${KEY_ID}

# Buscando consumer
echo
export CONSUMER_ID=$(curl -s -X GET http://localhost:8001/consumers/${CONSUMER_NAME} | jq -r .id)
echo CONSUMER_ID=${CONSUMER_ID}
curl -i -X DELETE http://localhost:8001/consumers/${CONSUMER_ID}
