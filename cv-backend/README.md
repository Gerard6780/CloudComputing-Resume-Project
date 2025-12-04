# CV Backend - Lambda Function

Backend serverless para el portfolio, implementado con AWS Lambda y Python.

## 🚀 Características

- Función Lambda en Python 3.12
- Integración con DynamoDB para almacenamiento de datos
- API REST con AWS API Gateway
- Contador de visitas automático
- Tests unitarios con pytest
- CI/CD con GitHub Actions
- Gestión de errores robusta
- CORS habilitado

## 📋 Requisitos

- Python 3.12+
- AWS CLI configurado
- Cuenta de AWS (AWS Learner Lab compatible)
- pytest para testing

## 🛠️ Instalación Local

### 1. Clonar el repositorio

```bash
git clone <tu-repo-url>
cd cv-backend
```

### 2. Crear entorno virtual

```bash
python -m venv venv

# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate
```

### 3. Instalar dependencias

```bash
pip install -r lambda/requirements.txt
pip install pytest pytest-cov boto3
```

## 🧪 Testing

### Ejecutar todos los tests

```bash
pytest tests/ -v
```

### Ejecutar tests con cobertura

```bash
pytest tests/ -v --cov=lambda --cov-report=html
```

### Ejecutar un test específico

```bash
pytest tests/test_handler.py::TestLambdaHandler::test_successful_cv_retrieval -v
```

## 📦 Estructura del Proyecto

```
cv-backend/
├── lambda/
│   ├── handler.py          # Función Lambda principal
│   └── requirements.txt    # Dependencias Python
├── tests/
│   └── test_handler.py     # Tests unitarios
├── .github/
│   └── workflows/
│       └── backend-ci.yml  # GitHub Actions CI
└── README.md
```

## 🔧 Función Lambda

### Handler Principal

La función `lambda_handler` en `handler.py` maneja:

- **GET /cv?id=portfolio1**: Obtiene datos del CV y incrementa contador
- Validación de parámetros
- Gestión de errores de DynamoDB
- Respuestas con CORS habilitado

### Variables de Entorno

La función Lambda requiere:

```
TABLE_NAME=curriculums
```

Esta variable se configura automáticamente por Terraform.

### Formato de Respuesta

```json
{
  "id": "portfolio1",
  "name": "Desarrollador Profesional",
  "views": 42,
  "skills": ["AWS", "Python", "Terraform"],
  "experience": "..."
}
```

## 📊 DynamoDB Schema

Tabla: `curriculums`

```
{
  "id": "portfolio1",           // Partition Key (String)
  "name": "...",                 // String
  "views": 0,                    // Number
  "skills": [...],               // List
  "experience": "...",           // String
  // ... otros campos
}
```

## 🚀 Despliegue

### Crear paquete de despliegue

```bash
cd lambda
zip -r ../lambda.zip handler.py
cd ..
```

### Desplegar con Terraform

El despliegue se realiza desde el repositorio `cv-infra`:

```bash
cd ../cv-infra
terraform init
terraform plan
terraform apply
```

## 🔄 CI/CD Pipeline

GitHub Actions ejecuta automáticamente en cada push/PR:

1. ✅ Instalación de dependencias
2. ✅ Ejecución de tests con pytest
3. ✅ Análisis de cobertura de código
4. ✅ Verificación de calidad con flake8

### Estado del Build

![CI Status](https://github.com/usuario/cv-backend/workflows/Backend%20CI/badge.svg)

## 🐛 Debugging

### Logs de CloudWatch

```bash
aws logs tail /aws/lambda/cv-portfolio-function --follow
```

### Test local con evento simulado

```python
from lambda.handler import lambda_handler

event = {
    'queryStringParameters': {'id': 'portfolio1'}
}
context = {}

response = lambda_handler(event, context)
print(response)
```

## 📝 Ejemplos de Uso

### Request exitoso

```bash
curl "https://api-id.execute-api.us-east-1.amazonaws.com/prod/cv?id=portfolio1"
```

Response:
```json
{
  "id": "portfolio1",
  "views": 15,
  "name": "Portfolio Profesional"
}
```

### Request con ID inválido

```bash
curl "https://api-id.execute-api.us-east-1.amazonaws.com/prod/cv?id=invalid"
```

Response:
```json
{
  "error": "CV not found",
  "message": "No CV found with id: invalid"
}
```

## 🔐 Seguridad

- ✅ Principio de mínimo privilegio en IAM
- ✅ CORS configurado correctamente
- ✅ Validación de parámetros de entrada
- ✅ Gestión de errores sin exponer información sensible

## 📚 Recursos

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [Boto3 DynamoDB](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb.html)
- [pytest Documentation](https://docs.pytest.org/)

## 📄 Licencia

MIT License
