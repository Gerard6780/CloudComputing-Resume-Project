# CV Infrastructure - Terraform

Infraestructura como código (IaC) para el portfolio CV usando Terraform y AWS.

## 🚀 Características

- **DynamoDB**: Tabla para almacenar datos del CV con PAY_PER_REQUEST
- **Lambda**: Función Python 3.12 para API backend
- **API Gateway**: REST API con endpoint /cv
- **IAM**: Roles y políticas con principio de mínimo privilegio
- **CloudWatch**: Logs automáticos para Lambda
- **S3 Backend**: Estado de Terraform almacenado remotamente
- **CI/CD**: Validación automática con GitHub Actions

## 📋 Requisitos

- Terraform >= 1.0
- AWS CLI configurado
- Cuenta AWS Learner Lab
- Bucket S3 `terraform-state-leonilo` creado previamente
- Archivo `lambda.zip` del backend

## 🛠️ Configuración Inicial

### 1. Clonar el repositorio

```bash
git clone <tu-repo-url>
cd cv-infra
```

### 2. Crear el paquete Lambda

```bash
# Desde el directorio cv-backend
cd ../cv-backend/lambda
zip -r ../../cv-infra/lambda.zip handler.py

# Volver a cv-infra
cd ../../cv-infra
```

### 3. Verificar que existe lambda.zip

```bash
ls -lh lambda.zip
```

## 🚀 Despliegue

### Inicializar Terraform

```bash
terraform init
```

Esto configurará:
- Backend S3 para el estado
- Providers de AWS
- Módulos necesarios

### Validar configuración

```bash
terraform validate
terraform fmt -check
```

### Ver el plan de ejecución

```bash
terraform plan
```

Revisa cuidadosamente los recursos que se crearán:
- 1 DynamoDB table
- 1 Lambda function (usando LabRole existente)
- 1 API Gateway REST API
- 1 CloudWatch log group
- Permisos de API Gateway para invocar Lambda

### Aplicar la infraestructura

```bash
terraform apply
```

Escribe `yes` cuando se te solicite confirmación.

### Ver outputs

```bash
terraform output
```

Obtendrás:
- `api_url`: URL completa del endpoint
- `lambda_function_name`: Nombre de la función Lambda
- `dynamodb_table_name`: Nombre de la tabla DynamoDB

## 📊 Recursos Creados

### DynamoDB Table

```hcl
Nombre: curriculums
Partition Key: id (String)
Billing Mode: PAY_PER_REQUEST
Features:
  - Point-in-time recovery
  - Server-side encryption
```

### Lambda Function

```hcl
Nombre: cv-portfolio-function
Runtime: Python 3.12
Memory: 256 MB
Timeout: 30 segundos
Environment Variables:
  - TABLE_NAME: curriculums
```

### API Gateway

```hcl
Nombre: cv-portfolio-api
Type: REST API
Endpoint: Regional
Routes:
  - GET /cv?id={id}
  - OPTIONS /cv (CORS)
Stage: prod
```

### IAM Role

```hcl
Nombre: LabRole (existente en Learner Lab)
Nota: No se crean roles personalizados
Permisos incluidos:
  - Lambda execution (CloudWatch Logs)
  - DynamoDB full access
  - API Gateway invocation
```

## 🔧 Configuración de Variables

Puedes personalizar las variables en `terraform.tfvars`:

```hcl
aws_region           = "us-east-1"
environment          = "prod"
dynamodb_table_name  = "curriculums"
lambda_function_name = "cv-portfolio-function"
api_gateway_name     = "cv-portfolio-api"
api_stage_name       = "prod"
```

## 📝 Insertar Datos de Prueba

Después del despliegue, inserta un item de prueba en DynamoDB:

```bash
aws dynamodb put-item \
  --table-name curriculums \
  --item '{
    "id": {"S": "portfolio1"},
    "name": {"S": "Desarrollador Profesional"},
    "views": {"N": "0"},
    "skills": {"L": [
      {"S": "AWS"},
      {"S": "Python"},
      {"S": "Terraform"}
    ]},
    "experience": {"S": "5 años de experiencia en cloud computing"}
  }'
```

## 🧪 Probar la API

```bash
# Obtener la URL de la API
API_URL=$(terraform output -raw api_url)

# Hacer una petición de prueba
curl "${API_URL}?id=portfolio1"
```

Respuesta esperada:
```json
{
  "id": "portfolio1",
  "name": "Desarrollador Profesional",
  "views": 1,
  "skills": ["AWS", "Python", "Terraform"],
  "experience": "5 años de experiencia en cloud computing"
}
```

## 🔄 Actualizar Infraestructura

```bash
# Ver cambios
terraform plan

# Aplicar cambios
terraform apply
```

## 🗑️ Destruir Infraestructura

```bash
terraform destroy
```

⚠️ **Advertencia**: Esto eliminará todos los recursos y datos.

## 📂 Estructura del Proyecto

```
cv-infra/
├── backend.tf           # Configuración del backend S3
├── provider.tf          # Provider AWS
├── main.tf              # Configuración principal
├── variables.tf         # Variables de entrada
├── outputs.tf           # Outputs
├── dynamodb.tf          # Tabla DynamoDB
├── lambda.tf            # Función Lambda
├── api_gateway.tf       # API Gateway REST
├── iam.tf               # Roles y políticas IAM
├── .github/
│   └── workflows/
│       └── terraform.yml # CI/CD workflow
├── lambda.zip           # Paquete Lambda (generado)
└── README.md
```

## 🔐 Seguridad

### AWS Learner Lab

Este proyecto está diseñado para AWS Learner Lab:
- Usa el rol `LabRole` predefinido (no crea roles nuevos)
- LabRole tiene permisos para Lambda, DynamoDB, API Gateway, CloudWatch
- No requiere configuración de credenciales adicionales
- Compatible con las limitaciones de Learner Lab (no se pueden crear roles IAM)

### Mejores Prácticas

✅ Estado remoto en S3  
✅ Encriptación de DynamoDB habilitada  
✅ Logs de Lambda en CloudWatch  
✅ Principio de mínimo privilegio en IAM  
✅ CORS configurado correctamente  
✅ Point-in-time recovery en DynamoDB  

## 🐛 Troubleshooting

### Error: lambda.zip not found

```bash
cd ../cv-backend/lambda
zip -r ../../cv-infra/lambda.zip handler.py
cd ../../cv-infra
```

### Error: Backend bucket doesn't exist

Crea el bucket manualmente:

```bash
aws s3 mb s3://terraform-state-leonilo --region us-east-1
```

### Error: Insufficient permissions

Verifica que estás usando AWS Learner Lab con `LabRole` activo.

## 📚 Recursos

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Lambda](https://docs.aws.amazon.com/lambda/)
- [AWS API Gateway](https://docs.aws.amazon.com/apigateway/)
- [AWS DynamoDB](https://docs.aws.amazon.com/dynamodb/)

## 🔄 CI/CD

GitHub Actions ejecuta automáticamente:

1. ✅ `terraform fmt -check`
2. ✅ `terraform init`
3. ✅ `terraform validate`
4. ✅ `terraform plan`

No ejecuta `terraform apply` automáticamente por seguridad.

## 📄 Licencia

MIT License
