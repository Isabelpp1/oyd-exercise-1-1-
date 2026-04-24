# oyd-exercise-1-1-
The file below is a complete Terraform configuration. You did not write it. Your job is to run it and understand exactly what it does — without applying it.
Aquí tienes el bloque listo para pegar en tu `README.md`:


## Task 1 — Initialize and Validate

### Output de `terraform validate`

```
Success! The configuration is valid.
```

### Explicación

El comando `terraform validate` verificó la sintaxis y estructura del archivo `main.tf` sin necesidad de conectarse a AWS. El resultado `Success! The configuration is valid.` confirma que:

- No hay errores de sintaxis en el archivo
- Los tipos de recursos utilizados son válidos para el provider de AWS
- La configuración está lista para ejecutar `terraform plan`
```
## Task 2 — Read the Plan

### Full `terraform plan` output


Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.exercise will be created
  + resource "aws_s3_bucket" "exercise" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "oyd-exercise-bucket-2026"
      + bucket_domain_name          = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
        }
      + tags_all                    = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)
      + cors_rule                        (known after apply)
      + grant                            (known after apply)
      + lifecycle_rule                   (known after apply)
      + logging                          (known after apply)
      + object_lock_configuration        (known after apply)
      + replication_configuration        (known after apply)
      + server_side_encryption_configuration (known after apply)
      + versioning                       (known after apply)
      + website                          (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.


### Preguntas

**1. ¿Cuántos recursos se crearán, cambiarán o destruirán?**

Se creará **1 recurso** (`aws_s3_bucket.exercise`), no se modificará ninguno y no se destruirá ninguno, tal como indica la línea final del plan: `Plan: 1 to add, 0 to change, 0 to destroy.`

**2. ¿Qué significa el símbolo `+` junto a cada atributo?**

El símbolo `+` indica que ese atributo **será creado por primera vez**. Como el bucket aún no existe en AWS, todos sus atributos son nuevos. En otros escenarios, `~` indicaría una modificación a un recurso existente y `-` indicaría eliminación.

**3. Atributo `(known after apply)` — ¿por qué Terraform no puede conocerlo antes?**

El atributo `arn` está marcado como `(known after apply)`. Terraform no puede conocer ese valor antes de ejecutar `apply` porque el ARN es **generado por AWS en el momento en que el bucket es creado**. Es un identificador único que AWS asigna internamente y que solo existe una vez que la API de AWS responde durante el apply.

## Task 3 — Predict a Change

### Diff del bloque `aws_s3_bucket` tras agregar el tag `Owner`

```hcl
  # aws_s3_bucket.exercise will be created
  + resource "aws_s3_bucket" "exercise" {
      + tags                        = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Owner"       = "Isabel Paiz"
        }
      + tags_all                    = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Owner"       = "Isabel Paiz"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.


### Preguntas

**1. ¿Terraform propone destruir y recrear el bucket, o actualizarlo en su lugar?**

Terraform propone **crearlo directamente con el nuevo tag incluido** (`+ create`), ya que nunca se ha ejecutado `terraform apply` y el bucket no existe aún en AWS. Si el bucket ya hubiera existido, agregar un tag produciría una **actualización en su lugar** (`~ update in-place`), porque modificar tags en S3 es una operación no destructiva que no requiere eliminar ni recrear el recurso.

**2. ¿Por qué importa esa distinción?**

La distinción entre **update in-place** (`~`) y **destroy + recreate** (`-/+`) es crítica en entornos de producción. Cuando Terraform destruye y recrea un recurso, **todos los datos que contenía se pierden permanentemente**. En el caso de un bucket S3, eso significaría perder todos los archivos almacenados. En cambio, una actualización in-place solo modifica la propiedad indicada sin interrumpir el recurso ni sus datos. Por eso Terraform siempre señala explícitamente cuándo una acción es destructiva, para que el equipo pueda tomar una decisión informada antes de ejecutar `apply`.


## Task 4 — State Reasoning

### Output de `ls -la`

```
total 32
drwxr-xr-x@  7 isabelpaiz  staff   224 Apr 23 20:25 .
drwxr-xr-x@ 15 isabelpaiz  staff   480 Apr 23 20:25 ..
drwxr-xr-x@ 15 isabelpaiz  staff   480 Apr 23 20:14 .git
drwxr-xr-x@  3 isabelpaiz  staff    96 Apr 23 20:22 .terraform
-rw-r--r--@  1 isabelpaiz  staff  1407 Apr 23 20:17 .terraform.lock.hcl
-rw-r--r--@  1 isabelpaiz  staff  5035 Apr 23 20:27 README.md
-rw-r--r--@  1 isabelpaiz  staff   364 Apr 23 20:24 main.tf
```

### Pregunta: ¿Qué indica la ausencia del archivo de estado sobre la relación entre plan y state?

El archivo `terraform.tfstate` **no existe** en el directorio porque nunca se ha ejecutado `terraform apply`. Esto confirma una distinción fundamental en Terraform:

- **`terraform plan`** es una operación de solo lectura. Compara la configuración declarada en los archivos `.tf` con el estado actual registrado en `terraform.tfstate`. No crea recursos reales en AWS ni escribe ningún archivo de estado.
- **`terraform apply`** es la operación de escritura. Es el único comando que crea los recursos reales en AWS y, como consecuencia, genera o actualiza el archivo `terraform.tfstate` para registrar lo que existe.

La ausencia del `.tfstate` demuestra que **el plan y el estado son dos cosas separadas**: el plan es una *predicción* de lo que pasaría, mientras que el estado es un *registro* de lo que realmente existe. Sin apply no hay recursos reales, y sin recursos reales no hay estado que registrar.
```