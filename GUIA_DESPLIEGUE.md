# 🚀 Guía de Despliegue en AWS Learner Lab

## 📋 Checklist Pre-Despliegue

### ✅ Requisitos Previos

- [ ] AWS Learner Lab iniciado y activo
- [ ] AWS CLI instalado y configurado
- [ ] Terraform instalado (>= 1.0)
- [ ] Python 3.12+ instalado
- [ ] Git instalado

---

## 🔧 Paso 1: Configurar AWS CLI

### Obtener Credenciales de Learner Lab

1. Inicia tu sesión de AWS Learner Lab
2. Haz clic en **"AWS Details"**
3. Copia las credenciales (Access Key, Secret Key, Session Token)

### Configurar en tu máquina

```bash
# Opción 1: Configurar manualmente
aws configure set aws_access_key_id YOUR_ACCESS_KEY
aws configure set aws_secret_access_key YOUR_SECRET_KEY
aws configure set aws_session_token YOUR_SESSION_TOKEN
aws configure set region us-east-1

# Opción 2: Usar variables de entorno
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"
export AWS_SESSION_TOKEN="YOUR_SESSION_TOKEN"
export AWS_DEFAULT_REGION="us-east-1"
```

### Verificar configuración

```bash
aws sts get-caller-identity
```

**Salida esperada:**
```json
{
    "UserId": "...",
    "Account": "...",
    "Arn": "arn:aws:sts::...:assumed-role/LabRole/..."
}
```

---

## 📦 Paso 2: Crear Bucket S3 para Terraform State

```bash
# Crear el bucket
aws s3 mb s3://terraform-state-leonilo --region us-east-1

# Verificar que se creó
aws s3 ls | grep terraform-state-leonilo

# Habilitar versionado (recomendado)
aws s3api put-bucket-versioning \
  --bucket terraform-state-leonilo \
  --versioning-configuration Status=Enabled
```

---

## 📂 Paso 3: Preparar los Repositorios

### Estructura de directorios recomendada

```bash
mkdir -p ~/aws-cv-project
cd ~/aws-cv-project

# Crear los 3 directorios
mkdir cv-frontend cv-backend cv-infra
```

### Copiar archivos

Copia todos los archivos generados a sus respectivos directorios:

```
~/aws-cv-project/
├── cv-frontend/
│   ├── .amplify.yml
│   ├── config.toml
│   ├── README.md
│   ├── archetypes/default.md
│   ├── content/_index.md
│   ├── content/projects/_index.md
│   └── static/js/api.js
├── cv-backend/
│   ├── lambda/handler.py
│   ├── lambda/requirements.txt
│   ├── tests/test_handler.py
│   ├── .github/workflows/backend-ci.yml
│   └── README.md
└── cv-infra/
    ├── backend.tf
    ├── provider.tf
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── dynamodb.tf
    ├── lambda.tf
    ├── api_gateway.tf
    ├── iam.tf
    ├── .github/workflows/terraform.yml
    └── README.md
```

---

## 🔨 Paso 4: Crear el Paquete Lambda

```bash
cd ~/aws-cv-project/cv-backend/lambda

# Crear el zip
zip -r ../../cv-infra/lambda.zip handler.py

# Verificar el contenido
unzip -l ../../cv-infra/lambda.zip

# Volver al directorio de infraestructura
cd ../../cv-infra
```

**Verificar que lambda.zip existe:**
```bash
ls -lh lambda.zip
```

---

## 🏗️ Paso 5: Desplegar Infraestructura con Terraform

### Inicializar Terraform

```bash
cd ~/aws-cv-project/cv-infra

# Inicializar (descarga providers y configura backend)
terraform init
```

**Salida esperada:**
```
Initializing the backend...
Successfully configured the backend "s3"!
Initializing provider plugins...
Terraform has been successfully initialized!
```

### Validar configuración

```bash
# Verificar formato
terraform fmt -check

# Validar sintaxis
terraform validate
```

### Ver el plan de ejecución

```bash
terraform plan
```

**Revisa que se crearán:**
- 1 DynamoDB table (`curriculums`)
- 1 Lambda function (`cv-portfolio-function`)
- 1 API Gateway REST API (`cv-portfolio-api`)
- 1 CloudWatch log group
- Permisos para API Gateway

### Aplicar la infraestructura

```bash
terraform apply
```

Escribe `yes` cuando se te solicite.

**Tiempo estimado:** 2-3 minutos

### Guardar los outputs

```bash
# Ver todos los outputs
terraform output

# Guardar API URL
terraform output -raw api_url > api_url.txt
cat api_url.txt
```

---

## 📊 Paso 6: Insertar Datos de Prueba en DynamoDB

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
      {"S": "Terraform"},
      {"S": "Hugo"},
      {"S": "DynamoDB"}
    ]},
    "experience": {"S": "Especialista en arquitecturas serverless y cloud computing"},
    "email": {"S": "contact@example.com"},
    "github": {"S": "https://github.com"},
    "linkedin": {"S": "https://linkedin.com"}
  }'
```

### Verificar que se insertó

```bash
aws dynamodb get-item \
  --table-name curriculums \
  --key '{"id": {"S": "portfolio1"}}'
```

---

## 🧪 Paso 7: Probar la API

```bash
# Obtener la URL de la API
API_URL=$(terraform output -raw api_url)

# Hacer una petición de prueba
curl "${API_URL}?id=portfolio1"
```

**Respuesta esperada:**
```json
{
  "id": "portfolio1",
  "name": "Desarrollador Profesional",
  "views": 1,
  "skills": ["AWS", "Python", "Terraform", "Hugo", "DynamoDB"],
  "experience": "Especialista en arquitecturas serverless y cloud computing",
  "email": "contact@example.com",
  "github": "https://github.com",
  "linkedin": "https://linkedin.com"
}
```

### Probar incremento de vistas

```bash
# Llamar varias veces
curl "${API_URL}?id=portfolio1"
curl "${API_URL}?id=portfolio1"
curl "${API_URL}?id=portfolio1"

# El campo "views" debe incrementarse: 1, 2, 3, 4...
```

---

## 🌐 Paso 8: Actualizar Frontend con API URL

```bash
cd ~/aws-cv-project/cv-frontend

# Editar api.js
nano static/js/api.js
```

**Reemplaza esta línea:**
```javascript
const API_URL = 'https://YOUR-API-ID.execute-api.us-east-1.amazonaws.com/prod/cv';
```

**Por tu API URL real:**
```javascript
const API_URL = 'https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/cv';
```

---

## 📝 Paso 9: (Opcional) Desplegar Frontend en Amplify

### Opción A: Desde GitHub

1. Sube el código a GitHub:
```bash
cd ~/aws-cv-project/cv-frontend
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/TU_USUARIO/cv-frontend.git
git push -u origin main
```

2. En AWS Console:
   - Ve a **AWS Amplify**
   - Click **"New app" > "Host web app"**
   - Conecta tu repositorio de GitHub
   - Amplify detectará automáticamente `.amplify.yml`
   - Click **"Save and deploy"**

### Opción B: Probar localmente con Hugo

```bash
cd ~/aws-cv-project/cv-frontend

# Instalar tema
git submodule add https://github.com/kishaningithub/hugo-creative-portfolio-theme.git themes/hugo-creative-portfolio-theme

# Ejecutar servidor local
hugo server -D

# Visita: http://localhost:1313
```

---

## 🔍 Paso 10: Verificación Final

### Verificar recursos en AWS

```bash
# DynamoDB
aws dynamodb list-tables

# Lambda
aws lambda list-functions --query 'Functions[?FunctionName==`cv-portfolio-function`]'

# API Gateway
aws apigateway get-rest-apis --query 'items[?name==`cv-portfolio-api`].{Name:name,ID:id}'

# CloudWatch Logs
aws logs describe-log-groups --log-group-name-prefix /aws/lambda/cv-portfolio-function
```

### Ver logs de Lambda

```bash
# Ver últimos logs
aws logs tail /aws/lambda/cv-portfolio-function --follow
```

### Probar desde navegador

Abre tu navegador y visita:
```
https://TU-API-ID.execute-api.us-east-1.amazonaws.com/prod/cv?id=portfolio1
```

---

## 🗑️ Limpieza (Cuando termines)

```bash
cd ~/aws-cv-project/cv-infra

# Destruir toda la infraestructura
terraform destroy

# Eliminar bucket S3 (si quieres)
aws s3 rb s3://terraform-state-leonilo --force
```

---

## ⚠️ Troubleshooting

### Error: "NoSuchBucket" al hacer terraform init

**Solución:**
```bash
aws s3 mb s3://terraform-state-leonilo --region us-east-1
terraform init
```

### Error: "lambda.zip not found"

**Solución:**
```bash
cd ~/aws-cv-project/cv-backend/lambda
zip -r ../../cv-infra/lambda.zip handler.py
cd ../../cv-infra
```

### Error: "AccessDenied" en Terraform

**Solución:**
- Verifica que tu sesión de Learner Lab esté activa
- Reconfigura las credenciales AWS
- Verifica con: `aws sts get-caller-identity`

### Lambda no tiene permisos para DynamoDB

**Solución:**
- El LabRole ya tiene permisos de DynamoDB
- Verifica que la Lambda use LabRole:
```bash
aws lambda get-function-configuration \
  --function-name cv-portfolio-function \
  --query 'Role'
```

### API Gateway devuelve error 500

**Solución:**
```bash
# Ver logs de Lambda
aws logs tail /aws/lambda/cv-portfolio-function --follow

# Probar Lambda directamente
aws lambda invoke \
  --function-name cv-portfolio-function \
  --payload '{"queryStringParameters":{"id":"portfolio1"}}' \
  response.json

cat response.json
```

---

## 📚 Comandos Útiles

```bash
# Ver estado de Terraform
terraform show

# Ver outputs
terraform output

# Refrescar estado
terraform refresh

# Ver recursos creados
terraform state list

# Formatear archivos .tf
terraform fmt

# Ver plan sin aplicar
terraform plan -out=tfplan

# Aplicar plan guardado
terraform apply tfplan
```

---

## ✅ Checklist Final

- [ ] Bucket S3 creado
- [ ] Lambda.zip generado
- [ ] Terraform init exitoso
- [ ] Terraform apply completado
- [ ] API URL obtenida
- [ ] Datos de prueba insertados en DynamoDB
- [ ] API probada con curl
- [ ] Frontend actualizado con API URL
- [ ] (Opcional) Frontend desplegado en Amplify

---

## 🎯 Próximos Pasos

1. **Personalizar contenido**: Edita `content/_index.md` y `content/projects/_index.md`
2. **Añadir más datos**: Inserta más items en DynamoDB
3. **Configurar dominio**: Añade un dominio personalizado en Amplify
4. **Monitoreo**: Configura alarmas en CloudWatch
5. **CI/CD**: Configura GitHub Actions para despliegue automático

---

**¡Listo para desplegar!** 🚀
