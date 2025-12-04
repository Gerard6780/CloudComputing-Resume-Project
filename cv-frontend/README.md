# CV Frontend - Hugo Portfolio

Portfolio web estático generado con Hugo y desplegado en AWS Amplify.

## 🚀 Características

- Sitio estático generado con Hugo
- Tema: hugo-creative-portfolio-theme
- Despliegue automático en AWS Amplify
- Integración con API REST en AWS API Gateway
- Contador de visitas dinámico

## 📋 Requisitos

- Hugo Extended v0.121.0 o superior
- Git

## 🛠️ Instalación Local

### 1. Clonar el repositorio

```bash
git clone <tu-repo-url>
cd cv-frontend
```

### 2. Instalar el tema

```bash
git submodule add https://github.com/kishaningithub/hugo-creative-portfolio-theme.git themes/hugo-creative-portfolio-theme
git submodule update --init --recursive
```

### 3. Ejecutar el servidor de desarrollo

```bash
hugo server -D
```

El sitio estará disponible en `http://localhost:1313`

## 📦 Estructura del Proyecto

```
cv-frontend/
├── .amplify.yml          # Configuración de build para AWS Amplify
├── config.toml           # Configuración de Hugo
├── archetypes/           # Plantillas para nuevo contenido
├── content/              # Contenido del sitio
│   ├── _index.md        # Página principal
│   └── projects/        # Sección de proyectos
├── layouts/              # Layouts personalizados (opcional)
├── static/               # Archivos estáticos
│   ├── css/             # Estilos personalizados
│   ├── js/              # JavaScript (incluye api.js)
│   └── img/             # Imágenes
└── themes/               # Temas de Hugo
```

## 🌐 Despliegue en AWS Amplify

### Configuración Inicial

1. Conecta tu repositorio de GitHub a AWS Amplify
2. Amplify detectará automáticamente el archivo `.amplify.yml`
3. El build se ejecutará automáticamente en cada push

### Variables de Entorno (Opcional)

Si necesitas configurar variables de entorno:

```
HUGO_VERSION=0.121.0
```

## 🔌 Integración con API

El archivo `static/js/api.js` contiene la lógica para:
- Llamar a la API REST en AWS API Gateway
- Obtener datos del CV desde DynamoDB
- Incrementar el contador de visitas

**Importante:** Actualiza la URL de la API en `api.js` después de desplegar la infraestructura:

```javascript
const API_URL = 'https://tu-api-id.execute-api.us-east-1.amazonaws.com/prod/cv';
```

## 📝 Crear Nuevo Contenido

```bash
# Crear nueva página
hugo new nombre-pagina.md

# Crear nuevo proyecto
hugo new projects/mi-proyecto.md
```

## 🏗️ Build de Producción

```bash
hugo --minify
```

Los archivos generados estarán en el directorio `public/`

## 🔧 Personalización

### Modificar el tema

Edita `config.toml` para personalizar:
- Título del sitio
- Descripción
- Enlaces de navegación
- Redes sociales
- Información del autor

### Añadir estilos personalizados

Crea archivos CSS en `static/css/` y referéncialos en tus layouts.

## 📚 Recursos

- [Documentación de Hugo](https://gohugo.io/documentation/)
- [Hugo Creative Portfolio Theme](https://github.com/kishaningithub/hugo-creative-portfolio-theme)
- [AWS Amplify Hosting](https://docs.aws.amazon.com/amplify/latest/userguide/welcome.html)

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.
