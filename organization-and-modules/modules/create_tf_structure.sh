#!/bin/bash

# Lista de módulos
modules=("alb" "ec2" "network" "rds" "route53" "s3" "security")

# Archivos Terraform a crear
files=("main.tf" "variables.tf" "outputs.tf")

# Crear carpetas y archivos
for module in "${modules[@]}"; do
  echo "�� Creando carpeta: $module"
  mkdir -p "$module"
  for file in "${files[@]}"; do
    filepath="$module/$file"
    if [ ! -f "$filepath" ]; then
      echo "  � Creando archivo: $filepath"
      touch "$filepath"
      echo "# Terraform file: $file for module $module" > "$filepath"
    else
      echo "  ⚠️ El archivo $filepath ya existe, se omite."
    fi
  done
done

echo "✅ Estructura creada correctamente."

