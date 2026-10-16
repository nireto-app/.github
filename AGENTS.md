# AGENTS.md — repo

> Instrucciones para agentes de código (Codex, opencode, agy/Gemini) en este repo.
> La fuente de verdad del ecosistema es `MarimbasHome/.claude/CLAUDE.md`.

---

<!-- BEGIN REGLA-ATRIBUCION sha=3599b24c89e2 · generado por Codigo/scripts/sync-regla-atribucion.py · NO editar a mano -->
## 🧾 Bitácora con autor — regla dura de todos los repos

Todo cambio deja rastro, y **el rastro dice quién lo hizo**, distinguiendo una IA de una persona.
Existe para poder auditar hacia atrás: quién tocó qué, cuándo, con permiso de quién y cómo se deshace.
Aplica a Claude, Codex, Gemini/agy, opencode y a cualquier carril que entre después.

### 1. El commit dice quién ESCRIBIÓ, no quién commiteó

El autor de git es **siempre** `enrique.miceli@gmail.com` (si no, Vercel rechaza el despliegue),
así que el autor no identifica a nadie. La atribución real viaja en los trailers del mensaje:

```
Co-Authored-By: <actor que escribió el cambio> <noreply+<slug del actor>@marimbashome.com>
X-Revisado-Por: <actor que lo revisó>      # obligatorio en identidad de huéspedes y en dinero
X-Sesion: ses-AAAA-MM-DD-<tema>            # el mismo id en TODO lo que escriba esa sesión
```

**Un correo por actor, nunca uno compartido (2026-09-29).** GitHub distingue a los co-autores por el
correo: al hacer squash deja uno por correo, y con un correo común el segundo actor de un PR desaparece
de `main` (medido: `nireto#702` perdió a Gemini). El slug es el actor sin `ia:`, en minúsculas y con
`/`, `.`, `:` y espacios cambiados por `-`: `ia:gemini-3.7-flash` → `noreply+gemini-3-7-flash@marimbashome.com`,
`sistema:autofix-clases` → `noreply+sistema-autofix-clases@marimbashome.com`; una persona firma con su
propio correo. En código lo arma `research_common.trailer_de_coautor(actor)`. **El trailer que Claude
Code propone por omisión (`Claude … <noreply@anthropic.com>`) se sustituye por este**: todos los
modelos de Claude comparten ese correo.

**El id de sesión se fija al ARRANCAR, no al cerrar.** Cada sesión de cualquier agente elige UN id `ses-AAAA-MM-DD-<tema>` en su
primer minuto y lo estampa en todo lo que escribe: el trailer `X-Sesion` de cada commit; `p_actor => 'ia:<modelo real>'` (nunca
`claude`, `ia:claude` ni `agente` a secas) y `p_source_path => 'Registros/YYYY-WNN/session_YYYY-MM-DD_<tema>.md'` en
`fn_decision_log_write`; y `p_actor` con el modelo real en `fn_tablero_create_task` / `fn_tablero_set_status` /
`fn_tablero_add_comment`. Una tarea programada sin modelo firma `sistema:<script>`; una corrida única, `migracion:<nombre>`; el
worker de encargos, `ses-encargo-<id>`. Al cerrar, `wrapup-derivar.py --sesion <id> --actor ia:<modelo>` separa lo propio de lo ajeno
— sin el id, la bitácora mezcla el trabajo de las otras licencias (medido 2026-09-01: 19 decisiones en la ventana, 2 propias).

Si el cambio lo produjo un carril delegado (opencode, agy/Gemini, Codex, un modelo por token) y
otro lo commiteó, **se nombran los dos**. Atribuir a quien no lo escribió es peor que no atribuir.

### 2. Vocabulario único de actor — cuatro prefijos, y nada más

| Prefijo | Cuándo | Ejemplos |
|---|---|---|
| `humano:` | una persona lo hizo | `humano:enrique@marimbashome.com` |
| `ia:` | un modelo lo produjo | `ia:claude-opus-5` · `ia:gemini-3.7-flash` · `ia:codex` · `ia:opencode/nemotron-3.5-lightning-free` |
| `sistema:` | tarea programada o disparador | `sistema:cron-watchdog` — **nunca `system` a secas** |
| `migracion:` | corrida única de reacomodo | `migracion:reconstruccion-desenlaces-ago16` |

Es el mismo vocabulario en los trailers del commit y en las columnas de actor de la base
(`audit_log.changed_by`, `decision_log.actor`, `cron_change_log.actor`). Sin vocabulario único no
se puede agrupar, y sin agrupar no hay auditoría: se midió «claude» escrito de 10 formas distintas.

🔒 **En la bitácora de decisiones ya es candado, no recomendación (2026-09-01).**
`fn_decision_log_write` **rechaza** la llamada sin `p_actor` y rechaza cualquier valor que no
empiece con uno de los cuatro prefijos; una restricción `CHECK` en `decision_log` cierra las
demás vías. Antes el parámetro existía pero tenía valor por omisión `'claude'`, y 207 decisiones
quedaron sin autor real — **un candado con valor por omisión permisivo no es un candado**, la
misma forma que `Deno.env.get('MH_ADMIN_TOKEN') || ''`.

✅ **Cerrado también en las COLUMNAS (2026-09-01).** Las trece funciones con actor ya rechazan la
llamada sin firma, y las columnas de actor de las tablas vigiladas normalizan en la puerta con
`fn_actor_normalizar` — que traduce en vez de rechazar, para no tumbar la pantalla que escribe ni
la operación que la bitácora venía a registrar. Aun así **pásale el actor a mano siempre**: lo que
la puerta puede normalizar es la forma, no adivinar quién fuiste. Lo que se vigila y desde cuándo
vive en `actor_vigilancia`; el detector `actor-fuera-de-vocabulario` avisa si una columna nueva
nace sin su disparador.

### 3. Qué más lleva cada entrada

- **Quién APROBÓ, separado de quién ejecutó.** Una persona (`humano:…`) o los candados que
  sustituyen su firma (`candado:prebuild+vercel+revision:<modelo>`). En identidad de huéspedes y en
  dinero, nombrar al modelo revisor es la prueba de que la revisión adversarial sí ocurrió.
- **Cómo se deshace:** el PR que revierte, la migración de bajada o el valor anterior.
- **Lo revertido y lo fallido también se asienta** — es el registro que impide repetirlo.

### 4. Lo que NUNCA entra a la bitácora

Contraseñas, códigos de puerta, CLABEs, tokens, cookies, ni datos de identidad de huéspedes.
Lista **blanca** de campos, jamás lista negra: auditar «todo menos X» filtra secretos en cuanto
alguien agrega una columna.

### 5. Un cambio sin rastro es un defecto

Lo vigilan el candado `commit-atribucion-guard` (bloquea el commit sin trailer o con un correo
compartido) y los detectores `commit-sin-atribucion` y `coautor-perdido-en-squash` (un squash en `main`
con menos co-autores que su rama). Especificación completa: `Vault/Sistemas/Bitacora_De_Cambios.md`.
<!-- END REGLA-ATRIBUCION -->

---

<!-- BEGIN REGLA-VETO-MODELOS-CHINOS sha=730397e37818 · generado por Codigo/scripts/sync-regla-atribucion.py · NO editar a mano -->
## 🚫 Modelos chinos fuera del litigio vetado — regla dura

Regla de Enrique (2026-09-02): los modelos chinos **bajo ninguna circunstancia** trabajan en nada
relacionado con el litigio vetado, y es regla dura. La cita textual vive en el verificador
(`reglas/veto_*.py`); aquí no se copia porque nombra a la contraparte.

**Por qué.** La contraparte del litigio es una empresa china. Mandar el expediente —o cualquier
material derivado que lo describa— a un modelo alojado por un proveedor de esa misma jurisdicción es
exponerlo a la contraparte. No es un juicio de calidad: es exposición.

**Por qué este texto no nombra el caso.** Estas instrucciones las leen también modelos de la
jurisdicción vetada —dsh, Hermes con su titular y sus respaldos, el carril de código de la puerta de
encargos—, y el nombre de la contraparte ya es material del caso. Por eso aquí se dice «el litigio
vetado» y todo archivo cuyo nombre lo lleva se cita con comodín (`reglas/veto_*.py`). Una prueba de
los candados falla si un bloque vuelve a traerlo, y el vigilante del veto revisa cada caja de agente.

**Qué es un modelo de origen chino.** DeepSeek (y su harness `dsh`), Kimi/Moonshot, GLM/Zhipu
(`z-ai`), Qwen/Alibaba, Yi (01.AI), MiniMax, Baichuan, InternLM, Hunyuan/Tencent, Ernie/Baidu,
Doubao/ByteDance, StepFun, y **cualquier alias que resuelva a uno de ellos** — incluido Composer, el
modelo propio de Cursor (Composer 2 se construyó sobre Kimi K2.5), y el modo Auto de Cursor, que
puede elegirlo. La lista viva de patrones está en `reglas/veto_*.json` (`modelos_de_origen_chino`).

**Carriles que SÍ pueden ver material del caso.** Son pocos y su lista exacta vive en
`reglas/veto_*.json` (`carriles_permitidos_para_el_caso`), su hogar único: se consulta ahí, no de
memoria, porque cambia (el 2026-09-27 entró Cursor Pro con Grok Bot). Los fijos son la licencia de
Claude, `agy` (Gemini, de Google) y Codex (OpenAI); dentro de Cursor, siempre con el modelo nombrado y
de casa no china —Grok, Claude, GPT o Gemini—, nunca Auto ni Composer. La lista es corta por una
medición, no por prudencia: de los alias del repartidor solo entran los que fijan el proveedor de
verdad (con `only:`). Pedirlo con `order:` no obliga a nada —ya está medido que un alias que pedía
DeepSeek lo terminó sirviendo Alibaba—, así que **un alias de modelo no chino puede acabar corriendo
en infraestructura china sin que nada avise**. Para este material eso no alcanza.

**Qué es material del caso.** El expediente y todo lo derivado de él: el nombre de la contraparte, el
número del juicio, la carpeta de investigación, los modelos financieros del caso, los entregables
para el abogado, y los resúmenes, borradores o instrucciones que hablen de cualquiera de esos. Los
términos exactos viven SOLO en `reglas/veto_*.json` (`material_del_caso`) y no se copian a ningún
otro lado: para saber si un texto o un archivo lo es no se adivina, se le pregunta al verificador,
que contesta la categoría y el renglón, nunca el término.

**No hay bandera para saltarlo.** No existe variable de entorno ni opción que lo apague, y no se
inventa una. Si un trabajo legítimo queda bloqueado, la salida es correrlo en un carril no chino
—siempre hay uno disponible—, nunca desactivar el candado.

**Cómo se comprueba antes de mandar nada.** `python3 ~/.local/share/marimbas/scripts-prod/reglas/veto_*.py
--modelo <alias> --texto-de <archivo>` (o `--texto "<contenido>"`); sale `0` si pasa y `3` si
bloquea, y con `--donde` dice en qué renglones está el material sin repetirlo. Las listas de modelos,
de carriles y de material del caso viven en `reglas/veto_*.json`, su hogar único: se corrigen ahí y
nadie las vuelve a escribir en otro lado. El veto ya está instalado en los carriles de la casa (el
mismo catálogo declara cuáles, en `consumidores_del_veto`) y en el enganche `veto-*-guard.sh` de las
sesiones de Claude, y **falla cerrada**: si el verificador no se puede correr, no se manda nada.
<!-- END REGLA-VETO-MODELOS-CHINOS -->

---

<!-- BEGIN REGLA-ACTO sha=406bcbdf4dcd · generado por Codigo/scripts/sync-regla-atribucion.py · NO editar a mano -->
## 🧭 Las reglas de la casa se consultan por el ACTO, antes de ejecutarlo

**Antes de borrar, publicar, mandarle un mensaje a una persona, retirar un carril o una tarea
programada, o reportar un hallazgo como nuevo**, pregunta qué se decidió ya sobre ese acto:

```bash
bash ~/.local/share/marimbas/scripts-prod/reglas-del-acto.sh "<lo que vas a hacer>"
cat brief.md | bash ~/.local/share/marimbas/scripts-prod/reglas-del-acto.sh -
```

Contesta en menos de un segundo, sin red, y si no aplica nada lo dice. **No bloquea: informa.**

**Por qué existe.** Se reconstruyeron 12 casos reales en los que una sesión contradijo o duplicó
algo ya resuelto. En **6 de 12** el conocimiento estaba escrito, indexado y vigente y **nada lo
trajo**: el buscador va por el TEMA de la pregunta, y el daño lo hace el ACTO que el agente decide
ejecutar por su cuenta. En el peor caso la pregunta era «prepara el texto del aviso de privacidad»
y lo que se rompió fue un borrado de datos de huéspedes.

En las sesiones de Claude Code esto llega solo, por enganche. **Los demás carriles no ejecutan
enganches**, así que aquí está la misma tabla detrás de un comando: si no se pregunta, no llega.

**Las reglas vivas están en** `~/Documents/MarimbasHome/.auto-memory/RESTRICCIONES.md` (negocio) y
`TRAMPAS.md` (técnicas). Al escribir una regla nueva ahí, **empieza por el acto con SUS palabras**
—«Al borrar, purgar o depurar (DELETE, DROP, TRUNCATE)…»— o el enrutador no la entrega nunca.

**Y para lo ya platicado sobre un TEMA** (que es otra pregunta):

```bash
bash ~/.local/share/marimbas/scripts-prod/corpus-search.sh "<tema>"
```

Si vuelve vacío **te lo dice y busca por palabras**; un resultado vacío ya no significa «no existe».
<!-- END REGLA-ACTO -->

---

<!-- BEGIN REGLA-LECTURAS sha=07b864db28ab · generado por Codigo/scripts/sync-regla-atribucion.py · NO editar a mano -->
## 📖 Lee un modelo barato — los archivos grandes no entran a la ventana

**Antes de leer archivos grandes** (más de 400 líneas o 16,000 caracteres — el umbral
vivo está en `~/.local/share/marimbas/scripts-prod/reglas/lecturas-lee-un-modelo-barato.json`), la lectura
completa **no pasa por la ventana**: se manda a `lector-bulk.sh`, que le da los archivos
a un modelo barato del proxy y regresa SOLO la respuesta.

```bash
bash ~/.local/share/marimbas/scripts-prod/lector-bulk.sh \
  --pregunta "¿Qué hace este servicio y quién lo llama?" \
  --rutas src/Service.ts src/Handler.ts   # también acepta carpetas
```

**Por qué.** La ventana del modelo caro (licencia de Claude, o cualquier titular) es el
recurso escaso de la casa. Spotify midió ~90% de ahorro de tokens con el mismo principio
(`shunt`/bulk-reader, sep-2026); aquí el equivalente corre sobre `consenso-ask.sh` —
con catálogo del proxy, medición y degradación ya resueltos. Lo que el modelo caro
necesita son las RESPUESTAS, no el contenido crudo de los archivos.

**Reglas del mecanismo:**
- **Umbrales y carril son PARAMÉTRICOS** — viven en
  `~/.local/share/marimbas/scripts-prod/reglas/lecturas-lee-un-modelo-barato.json`. Cambiar el modelo barato
  o el umbral = editar ese JSON; se propaga a todos los carriles.
- **Secretos JAMÁS salen**: `.env`, `*.pem`, `*.key`, `config*` los excluye el ejecutor
  y avisa. La exclusión es obligatoria, no opcional.
- **Veto de jurisdicción primero**: el carril se comprueba con `reglas/veto_*.py` antes de cada
  envío — falla cerrada. Si el material toca el litigio vetado, el carril es uno de la lista
  permitida de `reglas/veto_*.json` (la licencia, `agy`, Codex y los alias que clavan su
  proveedor) y ya.
- **Lecturas CHICAS van directas**: debajo del umbral, delegar cuesta más que leer.
- **Editar/exigir línea exacta va directo a la ventana**: el resumen no conserva líneas
  confiables; para editar, se lee el tramo puntual (offset/limit), no el archivo entero.
- **No sustituye al medidor de carga**: el `medidor-de-carga` vigila la RACHA de
  lecturas de la sesión; esta regla se aplica ARCHIVO POR ARCHIVO. Se complementan.
<!-- END REGLA-LECTURAS -->

---

<!-- BEGIN REGLA-ETA sha=dcb1a5dc0fc1 · generado por Codigo/scripts/sync-regla-atribucion.py · NO editar a mano -->
## ⏱️ Toda actividad dice cuánto va a tardar (ETA) — regla de la casa

**Al arrancar, encargar, delegar o lanzar cualquier actividad que vaya a tardar más de 2 minutos**
(umbral vivo en `~/.local/share/marimbas/scripts-prod/reglas/eta.json`) —un encargo a otro carril, un lote, un script
largo, una búsqueda a fondo, un workflow, una tarea programada disparada a mano—, **se dice de
entrada cuánto va a tardar**: en la misma respuesta en que se arranca y antes de cualquier otra cosa.

**Por qué.** El tiempo de Enrique es el recurso más escaso de la casa. Con el ETA decide si espera
o se pasa a otra cosa; sin él, espera a ciegas o interrumpe algo que estaba por terminar.
Instrucción suya del 2026-09-05: «eso ayuda a ver si espero una actividad o me paso a hacer otras
cosas para optimizar tiempo, nuestro recurso más escaso».

**Cómo se dice** (los valores exactos viven en `eta.json`; el bloque los cita):

- **Un número con unidad:** «ETA: unos 40 minutos», «entre 60 y 75 minutos», «unas 2 horas». Si de
  verdad no se puede estimar, se da el peor caso y cuándo se va a saber más: «no antes de las
  14:30; a las 13:00 te digo si va a tardar más». «Pronto», «en un momento» y «ya casi» **no son
  un ETA**.
- **Varias actividades, varios ETA**, y la más larga primero: es la que decide si se va a hacer
  otra cosa.
- **Se actualiza sin que pregunten** si se desvía más del 50 % o más de 10 minutos, lo que ocurra
  primero.
- **El número se SUMA por bloques medidos, no se estima de un vistazo**, y cubre la actividad
  COMPLETA hasta la entrega — no solo la parte delegada. Los minutos de cada bloque viven en
  `eta.json` §`sumandos_medidos`; hoy: preparar briefs y lanzar 1.5 · una ronda de carriles en
  paralelo 2.5 (el más lento, **no** la suma) · reintento por carril caído 2.5 y ocurre el 37% de
  las veces · verificar una página primaria 1 · escribir un entregable 1.2 · síntesis final 4.
  Al final se multiplica por el sesgo del carril (`eta.py sesgo`).
  Medido el 2026-09-05: seis carriles de API entregaron en 9 minutos —lo más rápido y predecible de
  toda la actividad— mientras verificar y escribir se llevó 10 minutos y no estaba en el número.
- 🪤 **En un abanico se espera al MÁS LENTO, así que la mediana no sirve para estimarlo.** Con N
  carriles el cuantil que aplica es 1−1/N (con seis, el p83). Medido sobre 290,392 llamadas de 30
  días: p50 = 2 s, p83 = 14 s, p95 = 60 s, p99 = 186 s — la cola va de 7x a 90x la mediana, y
  `kimi-k3` llega a p50 38 s contra p90 607 s. Estimar un abanico con la mediana es estimar el caso
  que casi nunca ocurre.
- **Al terminar se dice lo real contra lo estimado**, y ese número se MIDE, no se recuerda:
  ```bash
  ID=$(python3 ~/.local/share/marimbas/scripts-prod/eta.py abrir --actividad "<qué>" --eta-min <n>)   # al arrancar
  python3 ~/.local/share/marimbas/scripts-prod/eta.py cerrar --id "$ID"   # → "tardó 23 min; el ETA era 15 (+53%)"
  ```
  🔴 **Sin el reloj, el «tardó N minutos» del cierre también es una suposición** — y con más error
  que la estimación: el 2026-09-05 el ETA dijo 15, lo real fueron 23, y el cierre reportó 55.
  El sesgo acumulado del carril se consulta con `python3 ~/.local/share/marimbas/scripts-prod/eta.py sesgo`: si la
  mediana real/ETA es ≥1.5x, el carril estima corto y el siguiente ETA se multiplica por ese factor.
- **Los encargos por API devuelven su ETA en la aceptación** (`a2a_encargar`, el worker de
  encargos, `consenso-ask`, `agy`, `dsh`, Codex), y quien los lanza lo repite a Enrique. Las tareas
  programadas que avisan por Slack incluyen la duración esperada cuando arrancan algo largo.
- Aplica a Claude, Hermes, Codex, dsh, opencode, agy y a cualquier carril que entre después.
<!-- END REGLA-ETA -->

---

<!-- BEGIN REGLA-REPARTO-MODELOS sha=959d432467ca · generado por Codigo/scripts/sync-regla-atribucion.py · NO editar a mano -->
## 🧠 El orquestador reparte sus modelos — el caro solo juzga y sintetiza

**Al lanzar sub-agentes, workflows, lotes o encargos**, quien orquesta decide el modelo de CADA pieza
antes de lanzarla. Nunca «todo en el modelo titular». Regla de Enrique del 2026-09-05: «no todos
vayan sobre Fable, si no te vas a quemar toda la ventana de uso; tú eres el orquestador pero debes
decidir también cómo delegar tus recursos, con calidad; tienes muchos recursos en LLMs por API».

**Tres niveles** (los nombres vivos están en `~/.local/share/marimbas/scripts-prod/reglas/reparto-de-modelos.json`):

- **Caro** (el titular de la ventana, hoy Fable 5.1): juzgar entre alternativas, sintetizar la versión
  final, decidir alcance, la verificación adversarial de dinero e identidad de huéspedes y la
  consistencia cruzada final. **Nunca** leer en volumen, redactar borradores, construir ni investigar.
- **Medio** (Sonnet 5.5 en la licencia; por API `or-gpt-5.6-terra`, `or-gemini-3.7-flash`,
  `or-glm-5.3-flash`): investigar en la web, redactar borradores, construir archivos, revisar con
  lentes definidos, mirar imágenes o PDF, trabajo de navegador.
- **Barato** (Haiku 4.5 en la licencia; por API `gpt-oss-120b` y `opencode`): extraer, clasificar,
  contar, exportar, comprobar formato, lecturas mecánicas.

**Cómo se aplica.** En `Agent` o `Workflow`, `model:` explícito en cada llamada según el nivel —
omitirlo es elegir el caro—; por API, el alias del nivel. Meta: no más del 20 % de las piezas en el
caro. Y **una línea de transparencia al lanzar**: cuántas piezas van a cada nivel. Si el trabajo ya
arrancó en el caro, se reparte desde el siguiente corte; lo hecho no se tira.

**Por tipo de trabajo, el carril** (orden, carriles y desempate viven en el mismo JSON,
`carriles_por_tipo_de_trabajo`; «delega a Cursor» funciona igual que «delega a Codex»):

| Tipo | Orden |
|---|---|
| Necesita manos (muchos archivos, comandos, el repo) | Codex → `dsh` con el MaaS gratis → Cursor → por uso |
| Escribir pruebas | igual; Cursor sube antes de lo gratis solo si su examen le gana por más de 0.5 |
| Solo texto (resumir, redactar, clasificar, analizar) | gratis (MaaS, `opencode`) → suscripción → por uso |
| Internet o visión | `agy` → Grok Bot a mano, si es X |
| Juicio, decisión, versión final | la licencia de Claude; no se delega |

Desempate: (1) si Enrique nombra el carril, ese; (2) úsalo o piérdelo: una suscripción cuyo cupo
por perderse se lee EN VIVO cuenta como gratis, y entre suscripciones va primero la que más pierde;
(3) sin lectura viva de cupo (hoy Cursor), no se elige por cupo: va después de lo gratis; (4) en
empate (±0.5 en el examen) gana lo gratis; (5) el material del caso vetado solo va por sus carriles.

**Lo que manda sobre esta tabla:** la revisión adversarial bloqueante de identidad de huéspedes y
dinero (segundo modelo de otra familia), el veto de jurisdicción (solo carriles con ruta garantizada) y el
enganche `delegation-gate` (lo delegable por palabras o cifras sale a LiteLLM, no a un sub-agente).
<!-- END REGLA-REPARTO-MODELOS -->

---

<!-- BEGIN REGLA-REPARTO-MAQUINAS sha=3560c5de1da9 · generado por Codigo/scripts/sync-regla-atribucion.py · NO editar a mano -->
## 🖥️ Se aprovechan TODAS las máquinas — ninguna se satura mientras otra está ociosa

**Al lanzar, correr, encargar o repartir trabajo que consume máquina** —una sesión de código
(`start_session`, `claude`, `codex`, `agent`, `agy`), una compilación (`next build`, `go build`,
`xcodebuild`), pruebas, `docker`, un lote o un abanico de encargos—, **se decide en qué máquina corre
antes de lanzarlo.** Regla de Enrique del 2026-10-14: «la maximización de equipos, pcs, mac y las que
pone Eduardo y otras siempre debe de ser regla, optimizar todos los recursos, si no se desaprovechan y
saturan por no delegar y optimizar bien». Aplica a todo agente y a las máquinas que se sumen después.

**Quién recibe qué** (la tabla viva está en `~/.local/share/marimbas/scripts-prod/reglas/reparto-de-maquinas.json`):

| Máquina | Recibe |
|---|---|
| **La PC** `marimbas-pc` (16 núcleos) | compilaciones, pruebas, Docker de desarrollo, lotes y sesiones de código sin accesos de la Mac |
| **La Mac** (10 núcleos) | solo lo que solo ella puede: simulador del iPhone, navegador y Chrome, llavero, teléfono, WhatsApp y la app de Claude que orquesta |
| **Las máquinas de Eduardo** (`nireto-ci`) | el CI de Nireto |
| Máquinas nuevas | entran a esa tabla el día que se suman; hasta entonces no reciben nada |

**El principio de fondo (Enrique, 2026-10-14): la ventana de la licencia de Claude es el recurso más
escaso de la casa.** Todo lo que se pueda hacer fuera de ella se hace fuera, y se gasta antes lo que
se renueva o se vence: primero las cuotas que se renuevan (Codex) y los créditos que vencen, luego lo
gratis (`opencode`, el MaaS); la ventana queda para decidir y verificar, no para construir ni redactar.

**Cómo se mide.** Antes de lanzar algo pesado se corre `python3 ~/.local/share/marimbas/scripts-prod/reparto-maquinas.py`
(carga de las dos y a cuál mandar; o `uptime` en la Mac y `ssh marimbas-pc uptime`) y se manda a la que
tenga margen. Cada 10 minutos los latidos de las dos suben su carga, memoria e intercambio a la
base (tabla `maquina_carga`). **Saturada** es carga de 5 min mayor que 1.2 por núcleo, o intercambio
usado arriba de 75 % con carga arriba de 0.8; **ociosa**, menos de 0.5 por núcleo con memoria libre. Una
máquina sin muestra reciente es «sin dato», nunca «ociosa». Medido el 2026-10-14: la Mac en carga 18
sobre 10 núcleos con cinco sesiones y una compilación de Next encima; la PC en 1.4 sobre 16.

**Si una pieza no puede ir a la máquina libre porque falta algo** (un repo sin clonar, una herramienta
sin instalar, una conexión sin dar de alta), eso se arregla o se deja escrito como pendiente con su
dueño; no se resuelve saturando la otra. El detector `maquina-saturada-otra-ociosa` grita cuando una
pasa de su capacidad media hora en horario de trabajo mientras la otra sigue libre.

**Lo que no se cruza:** el Docker normal de la PC es producción (el de desarrollo va solo por la
envoltura `~/.local/bin/docker`); `~/Documents/MarimbasHome` en la PC es el espejo nocturno y no se escribe;
el CI de Nireto no regresa a las cajas de la PC ni se manda a GitHub «para no encolar»; y prender o pagar
máquinas por hora lo deciden Enrique o el vigilante que él autorizó, nunca una sesión a mano. El
material del litigio vetado no cambia de carril por cambiar de máquina.
<!-- END REGLA-REPARTO-MAQUINAS -->

---

<!-- BEGIN REGLA-CONSUMO sha=683b289bdf27 · generado por Codigo/scripts/sync-regla-atribucion.py · NO editar a mano -->
## 📊 El orquestador rinde cuentas — qué modelos usó, cuánto y cómo (regla de la casa)

**Al lanzar cualquier trabajo delegado** (sub-agente, workflow, encargo, lote, carril por API) **y al
cerrarlo, junto con el ETA**, se dice qué modelos se usaron, cuánto y cómo se consumió. Instrucción
de Enrique del 2026-09-14: «así como tenemos el ETA… es importante que digas qué LLMs estás usando,
cuánto y cómo se consumió; al final tú eres el orquestador pero necesitamos tener analítica y otras
cosas al detalle cuando trabajamos».

**Por qué.** La ventana de la licencia es el recurso escaso y los carriles por API cuestan dinero.
Sin la cuenta, ni el reparto de modelos ni el gasto se calibran, y el «gasté poco» sale de memoria
— la misma falla que tenía el ETA antes del reloj.

**Tres momentos** (los parámetros viven en `~/.local/share/marimbas/scripts-prod/reglas/consumo.json`; el bloque los cita):

- **Al lanzar:** una línea con el reparto — cuántas piezas van a cada nivel (caro / medio / barato),
  por qué carril, y **cuáles se miden por estimación** (`agy` y Codex: por caracteres, no por
  tokens reales) **o por ventana de tiempo** (`dsh`: llama con llave propia). Un encargo por A2A
  lleva `opciones: {sesion: "<id>"}`; sin eso su gasto queda sin dueño.
- **Al cerrar cada actividad delegada** (el mismo momento de `eta.py cerrar`): la línea de consumo
  **medida, nunca recordada**:
  ```bash
  python3 ~/.local/share/marimbas/scripts-prod/consumo-sesion.py --registrar
  ```
  Dice, por API: llamadas, **la tienda real que sirvió** (el alias no la garantiza), tokens, costo,
  latencia, fallas y reintentos; de la licencia: turnos, tokens, % de caché leída y precio sombra;
  el reparto real de piezas contra la meta; el ETA real contra el estimado; y **lo que quedó sin
  medir**, para que el total nunca parezca completo cuando no lo es.
  Al nombrar el consumo se dice la herramienta o tienda, el plan y la **CUENTA exacta** (correo),
  leídos de `reglas/codex-cuentas.json`, `reglas/cursor-grokbot.json` o
  `Vault/Sistemas/Antigravity_CLI.md` para agy; no se adivinan por el alias.
- **Al cerrar la sesión:** la sección «Costos LLM» de la bitácora la deriva `wrapup-derivar.py` del
  mismo guion. No se redacta.

**Lo que hace posible medirlo** — sin esto el guion imprime «sin etiqueta de sesión»:

- La sesión se abre con **`bash ~/.local/share/marimbas/scripts-prod/sesion.sh abrir ses-AAAA-MM-DD-<tema> --actor
  ia:<modelo> --tema "…" --proyecto <slug>`** en el primer minuto. Guarda el id por sesión de
  Claude Code y lo abre en la base. 🔴 `export MARIMBAS_SESION=…` **no sirve**: en Claude Code cada
  llamada de Bash es un shell nuevo y la variable muere ahí mismo (medido: 1 sesión etiquetada en
  14 días, y era una prueba).
- Los guiones de la casa que llaman al proxy (`consenso-ask.sh`, `lector-bulk.sh`,
  `litellm-web.sh`) etiquetan cada llamada con esa sesión; el registro de gasto la copia a
  `llm_usage_log.sesion`, y `fn_sesion_rastro('<id>')` la devuelve junto con todo lo demás que la
  sesión tocó. La licencia se liga sola: el minado diario de transcripciones escribe la misma columna.
- Lo que no pasa por el proxy entra por `medir-carril.py`, la única puerta para asentar una llamada
  fuera de él: las envolturas `agy` y `codex` de la Mac la llaman solas, el servidor A2A la llama
  por sus carriles `opencode`, `agy` y `codex`, y `dsh.sh` deja su ventana de tiempo para que el
  reloj le atribuya las llamadas del proxy que cayeron dentro.
- **Todo encargo por API termina con su firma** (regla 6 del preludio): modelo real que lo sirvió,
  tokens y tiempo. Quien lo lanza la repite en su línea de consumo.

**Prohibido:** «gasté poco», «casi nada», «unos cuantos tokens», un costo sin decir qué modelo y
qué tienda, y un total que oculte lo que no se midió.

**Vigilancia:** detector `consumo-sin-medir` — grita si la bitácora
`~/.local/state/marimbas/consumo-log.jsonl` deja de escribirse 14 días mientras sí hay cierres de
ETA, si el etiquetado de sesión se cae en el proxy, o si hay sesiones con ETA y sin consumo.
Aplica a Claude, Hermes, Codex, dsh, opencode, agy, el worker de encargos y a cualquier carril que
entre después.
<!-- END REGLA-CONSUMO -->

---

<!-- BEGIN REGLA-REDTEAM-ADVERSARIAL sha=7c1bc0a293c7 · generado por Codigo/scripts/sync-regla-atribucion.py · NO editar a mano -->
## 🛡️ Red team y revisión adversarial por defecto — todo trabajo, todo proyecto (regla de la casa)

**Todo lo que se construye o se cambia entra solo, sin que nadie lo pida, a dos revisiones:** la
**adversarial** (un modelo de OTRA familia que la del autor intenta tumbarlo citando el código) y el
**red team** (un adversario que intenta romperlo, robarlo o abusarlo). Vale para Marimbas, Nireto,
Facturea, MetroGuia y todo proyecto, y para Claude, Codex, Cursor, dsh, Hermes, agy, opencode y
cualquier carril que entre después. Regla de Enrique del 2026-10-04: «siempre que estemos
trabajando en algo por default debe entrar redteam y adversariales para todos los projects… y
siempre se aplique como regla».

**Lo que ya corre solo** (parámetros en `~/.local/share/marimbas/scripts-prod/reglas/redteam-adversarial.json`):

- **Cada PR de cualquier repo de la casa** pasa por la puerta adversarial —dos jueces de familias
  distintas, ya no solo lo de identidad o dinero— y, si toca superficie de ataque (rutas, funciones
  públicas, webhooks, autenticación, pantallas con parámetros, manejadores de Go), el primer juez lo
  ataca además con los lentes del red team. Su estado en GitHub: `revision-adversarial-sensible`.
- **Al abrir el PR desde Claude Code**, el enganche `redteam-por-defecto.sh` despacha esa puerta en el
  momento y la reintenta si GitHub frena por su límite. Desde otro carril la recoge la corrida
  programada de la PC: arranca cada 30 minutos, pero llegar a un PR recién abierto le toma una
  mediana de 34 minutos y hasta una hora en un día cargado (medido del 28-sep al 5-oct sobre 347
  corridas; el peor caso, 4 horas). Si a la hora el PR sigue sin `revision-adversarial-sensible`,
  se despacha a mano: `pr-adversarial-gate.py --solo <dueño>/<repo>#<n>`.
- **Cada noche** el red team ataca los repos de todas las cuentas de la casa, primero lo cambiado en
  las últimas 30 horas.

**Lo que le toca a quien trabaja:**

- **Ningún cambio se declara terminado sin leer el veredicto de su PR**
  (`gh api repos/<dueño>/<repo>/commits/<sha>/status`). Un hallazgo confirmado se arregla en la misma
  sesión; uno falso se refuta con evidencia, no se ignora.
- **Lo que no pasa por un PR también entra:** una migración aplicada directo a la base, una función
  desplegada, un cambio de permisos o de configuración, un texto que sale a un tercero, o un análisis
  o una cifra que decide algo. Antes de entregarlo, un modelo de otra familia intenta refutarlo; si
  toca acceso, datos personales o dinero, además lo ataca el red team (`/redteam` en Claude Code).
- **El revisor siempre es de otra familia que el autor**, y el material del litigio vetado solo va
  por sus carriles permitidos.
<!-- END REGLA-REDTEAM-ADVERSARIAL -->
