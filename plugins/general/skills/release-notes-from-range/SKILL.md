---
name: release-notes-from-range
summary: Genera release notes desde un range commit base hasta HEAD usando commits + PRs asociados.
scope: workspace
---

# release-notes-from-range

Skill para resumir cambios entre un commit base (normalmente un merge commit) y el commit más reciente, con foco en:
- commits incluidos en el rango
- PRs asociados
- impacto funcional/técnico
- output de release notes listo para compartir

## Cuándo usarlo

Usar cuando se pida algo como:
- "resumir cambios desde el merge X"
- "armar release notes desde commit A hasta HEAD"
- "qué entró en esta versión"

## Inputs requeridos

1. **baselineCommit**: hash o texto identificador del commit base.
2. **endRef**: por defecto `HEAD`.
3. **includePRs**: `true|false` (default `true`).
4. **language**: `es|en` (default `es`).

## Flujo

1. **Resolver baseline real**
   - Buscar commit exacto por hash o por mensaje.
   - Confirmar que existe localmente.

2. **Construir rango**
   - Rango: `baselineCommit..endRef`.
   - Listar commits en orden cronológico inverso.

3. **Mapear PRs asociados (si includePRs=true)**
   - Prioridad de fuentes:
     1. metadata del commit (`(#123)` en subject)
     2. merge commit messages (`Merge pull request #123`)
     3. API/CLI del proveedor (si está disponible)
   - Si un commit no tiene PR, marcarlo como "sin PR detectado".

4. **Agrupar cambios por tema**
   - Categorías sugeridas:
     - Features
     - Fixes
     - CI/CD
     - Infra/Deployment
     - Docs/Chore

5. **Generar release notes**
   - Incluir:
     - periodo/rango
     - resumen ejecutivo
     - detalle por categoría
     - lista de commits + PRs
     - riesgos/notas de validación

## Reglas de decisión

- **Si el rango está vacío** (0 commits):
  - No inventar cambios.
  - Emitir release notes explícito de "sin cambios".

- **Si hay commits pero sin PRs detectables**:
  - Mantener lista de commits igualmente.
  - Señalar limitación de trazabilidad.

- **Si baseline coincide con HEAD**:
  - Tratar como rango vacío.

## Criterios de calidad

Checklist antes de cerrar:
- [ ] Baseline confirmado y mostrado explícitamente.
- [ ] Rango exacto documentado (`base..head`).
- [ ] Conteo de commits consistente con la lista.
- [ ] PRs asociados listados o justificación de ausencia.
- [ ] Resumen ejecutivo + detalle técnico.
- [ ] Sin suposiciones no verificables.

## Formato de salida recomendado

1. **Resumen ejecutivo** (3-6 líneas)
2. **Rango analizado** (base, head, total commits)
3. **Cambios por categoría**
4. **Trazabilidad** (tabla commit → PR)
5. **Release notes final**

## Prompt de ejemplo

-- "Usa `release-notes-from-range` con baseline `0225889ef409c7f40545dcee8840944b5e6f0525` y end `HEAD`, en español, incluyendo PRs."
-- "Genera release notes desde `Merge remote-tracking branch 'digital-commerse/main'` al último commit."