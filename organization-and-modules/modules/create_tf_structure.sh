#!/bin/bash

# Lista de m√≥dulos
modules=("alb" "ec2" "network" "rds" "route53" "s3" "security")

# Archivos Terraform a crear
files=("main.tf" "variables.tf" "outputs.tf")

# Crear carpetas y archivos
for module in "${modules[@]}"; do
  echo "ÔøΩÔøΩ Creando carpeta: $module"
  mkdir -p "$module"
  for file in "${files[@]}"; do
    filepath="$module/$file"
    if [ ! -f "$filepath" ]; then
      echo "  Ì≥ù Creando archivo: $filepath"
      touch "$filepath"
      echo "# Terraform file: $file for module $module" > "$filepath"
    else
      echo "  ‚ö†Ô∏è El archivo $filepath ya existe, se omite."
    fi
  done
done

echo "‚úÖ Estructura creada correctamente."

