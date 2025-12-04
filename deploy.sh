#!/bin/bash

# Script de despliegue automatizado para AWS Learner Lab
# Autor: CV Portfolio Project
# Fecha: 2024-12-04

set -e  # Salir si hay algún error

echo "🚀 Iniciando despliegue de CV Portfolio en AWS..."
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_step() {
    echo -e "${GREEN}[PASO $1]${NC} $2"
}

print_warning() {
    echo -e "${YELLOW}[ADVERTENCIA]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que estamos en el directorio correcto
if [ ! -d "cv-infra" ]; then
    print_error "No se encuentra el directorio cv-infra. Ejecuta este script desde la raíz del proyecto."
    exit 1
fi

# PASO 1: Verificar AWS CLI
print_step "1" "Verificando configuración de AWS CLI..."
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI no está instalado. Instálalo con: sudo apt install awscli"
    exit 1
fi

# Verificar credenciales
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS CLI no está configurado correctamente."
    echo "Configura tus credenciales de Learner Lab con:"
    echo "  export AWS_ACCESS_KEY_ID='...'"
    echo "  export AWS_SECRET_ACCESS_KEY='...'"
    echo "  export AWS_SESSION_TOKEN='...'"
    exit 1
fi

echo "✅ AWS CLI configurado correctamente"
aws sts get-caller-identity
echo ""

# PASO 2: Verificar Terraform
print_step "2" "Verificando instalación de Terraform..."
if ! command -v terraform &> /dev/null; then
    print_error "Terraform no está instalado."
    echo "Instálalo con:"
    echo "  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg"
    echo "  echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com \$(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list"
    echo "  sudo apt update && sudo apt install terraform"
    exit 1
fi

echo "✅ Terraform instalado: $(terraform version | head -n1)"
echo ""

# PASO 3: Crear bucket S3 para Terraform state
print_step "3" "Verificando bucket S3 para Terraform state..."
BUCKET_NAME="terraform-state-leonilo"

if aws s3 ls "s3://${BUCKET_NAME}" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "Creando bucket S3: ${BUCKET_NAME}..."
    aws s3 mb "s3://${BUCKET_NAME}" --region us-east-1
    
    # Habilitar versionado
    aws s3api put-bucket-versioning \
        --bucket "${BUCKET_NAME}" \
        --versioning-configuration Status=Enabled
    
    echo "✅ Bucket S3 creado y versionado habilitado"
else
    echo "✅ Bucket S3 ya existe"
fi
echo ""

# PASO 4: Crear lambda.zip
print_step "4" "Creando paquete Lambda (lambda.zip)..."
cd cv-backend/lambda

if [ ! -f "handler.py" ]; then
    print_error "No se encuentra handler.py en cv-backend/lambda/"
    exit 1
fi

# Crear zip
zip -q -r ../../cv-infra/lambda.zip handler.py

cd ../../cv-infra

if [ -f "lambda.zip" ]; then
    echo "✅ lambda.zip creado ($(du -h lambda.zip | cut -f1))"
else
    print_error "No se pudo crear lambda.zip"
    exit 1
fi
echo ""

# PASO 5: Inicializar Terraform
print_step "5" "Inicializando Terraform..."
terraform init

if [ $? -eq 0 ]; then
    echo "✅ Terraform inicializado correctamente"
else
    print_error "Error al inicializar Terraform"
    exit 1
fi
echo ""

# PASO 6: Validar configuración
print_step "6" "Validando configuración de Terraform..."
terraform validate

if [ $? -eq 0 ]; then
    echo "✅ Configuración válida"
else
    print_error "Error en la configuración de Terraform"
    exit 1
fi
echo ""

# PASO 7: Mostrar plan
print_step "7" "Generando plan de ejecución..."
terraform plan -out=tfplan

echo ""
print_warning "Revisa el plan anterior cuidadosamente."
read -p "¿Deseas continuar con el despliegue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Despliegue cancelado por el usuario."
    rm -f tfplan
    exit 0
fi
echo ""

# PASO 8: Aplicar infraestructura
print_step "8" "Desplegando infraestructura en AWS..."
terraform apply tfplan

if [ $? -eq 0 ]; then
    echo "✅ Infraestructura desplegada correctamente"
else
    print_error "Error al desplegar infraestructura"
    exit 1
fi

rm -f tfplan
echo ""

# PASO 9: Obtener outputs
print_step "9" "Obteniendo información de despliegue..."
echo ""
terraform output

# Guardar API URL
API_URL=$(terraform output -raw api_url)
echo ""
echo "📝 API URL guardada: ${API_URL}"
echo "${API_URL}" > api_url.txt
echo ""

# PASO 10: Insertar datos de prueba
print_step "10" "¿Deseas insertar datos de prueba en DynamoDB? (yes/no): "
read -p "" INSERT_DATA

if [ "$INSERT_DATA" = "yes" ]; then
    echo "Insertando datos de prueba..."
    
    aws dynamodb put-item \
        --table-name curriculums \
        --item '{
            "id": {"S": "portfolio1"},
            "name": {"S": "Desarrollador Profesional"},
            "views": {"N": "0"},
            "skills": {"L": [
                {"S": "AWS"},
                {"S": "Python"},
                {"S": "Terraform"},
                {"S": "Hugo"},
                {"S": "DynamoDB"}
            ]},
            "experience": {"S": "Especialista en arquitecturas serverless y cloud computing"},
            "email": {"S": "contact@example.com"},
            "github": {"S": "https://github.com"},
            "linkedin": {"S": "https://linkedin.com"}
        }'
    
    echo "✅ Datos de prueba insertados"
    echo ""
fi

# PASO 11: Probar API
print_step "11" "Probando API..."
echo "Realizando petición a: ${API_URL}?id=portfolio1"
echo ""

RESPONSE=$(curl -s "${API_URL}?id=portfolio1")
echo "Respuesta:"
echo "${RESPONSE}" | python3 -m json.tool 2>/dev/null || echo "${RESPONSE}"
echo ""

# PASO 12: Instrucciones finales
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ¡DESPLIEGUE COMPLETADO!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Próximos pasos:"
echo ""
echo "1. Actualizar frontend con la API URL:"
echo "   cd ../cv-frontend"
echo "   nano static/js/api.js"
echo "   # Reemplaza: const API_URL = '${API_URL}'"
echo ""
echo "2. Probar la API en tu navegador:"
echo "   ${API_URL}?id=portfolio1"
echo ""
echo "3. Ver logs de Lambda:"
echo "   aws logs tail /aws/lambda/cv-portfolio-function --follow"
echo ""
echo "4. Ver recursos creados:"
echo "   cd cv-infra"
echo "   terraform state list"
echo ""
echo "5. Para destruir la infraestructura:"
echo "   cd cv-infra"
echo "   terraform destroy"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📄 API URL guardada en: cv-infra/api_url.txt"
echo ""
