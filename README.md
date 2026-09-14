# ASOGASINGA — Taller de Base de Datos Avanzadas

Sistema de base de datos para una asociación ganadera ficticia (ASOGASINGA), desarrollado como taller práctico del curso de Base de Datos Avanzadas en Campuslands. Implementa el esquema relacional completo junto con procedimientos almacenados, funciones, seguridad basada en roles, triggers y eventos programados en MySQL.

## Estructura del proyecto

| Archivo | Contenido |
|---|---|
| `1_Estructura_Base_Inserts.sql` | Las 12 tablas del esquema (socios, fincas, ganado, vacunación, producción de leche, empleados, alimentación, etc.) y los inserts de ejemplo |
| `2_Procedimientos_Almacenados.sql` | 4 procedimientos almacenados con validaciones y pruebas |
| `3_Funciones.sql` | 4 funciones (UDF) con pruebas |
| `4_Usuarios_Privilegios.sql` | 4 usuarios con roles y privilegios diferenciados (`GRANT`) |
| `5_Triggers_Eventos.sql` | Tablas de auditoría, 4 triggers y 2 eventos programados |

## Orden de ejecución

Los archivos deben correrse en orden, ya que cada uno depende del anterior (procedimientos y funciones antes que los `GRANT`, tablas base antes que las llaves foráneas de auditoría):

```bash
mysql -u root < 1_Estructura_Base_Inserts.sql
mysql -u root < 2_Procedimientos_Almacenados.sql
mysql -u root < 3_Funciones.sql
mysql -u root < 4_Usuarios_Privilegios.sql
mysql -u root < 5_Triggers_Eventos.sql
```

## Qué incluye

- **Procedimientos:** registro de producción de leche (con validación de tipo/sexo), actualización de salario, traslado de ganado entre fincas, registro de vacunación.
- **Funciones:** edad en meses del animal, litros totales por finca en un rango de fechas, peso promedio por raza, conteo de ganado por socio.
- **Seguridad:** `usuario_admin`, `usuario_veterinario`, `usuario_operador` y `usuario_rrhh`, cada uno con acceso limitado solo a lo que su rol necesita.
- **Triggers:** validación de peso biológico (1–1500 kg), auditoría automática de cambios salariales, bloqueo de revacunación antes de 30 días.
- **Eventos:** depuración mensual de la auditoría de salarios (>6 meses), cierre semanal de producción de leche por finca.

Cada archivo trae su propia sección de pruebas al final, con el resultado esperado indicado en comentarios.

## Tecnologías

MySQL / DBeaver CE


Eidan Alexander Carreño Cuadros — [GitHub](https://github.com/Eidan210)
