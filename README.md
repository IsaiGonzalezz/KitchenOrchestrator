# kitchen_orchestrator

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# **Contexto del proyecto**



Este proyecto consiste en el desarrollo de una plataforma móvil en Flutter destinada a chefs y gerentes de cocina en las dark kitchens que guía recetas, muestra métricas operativas en tiempo real y conecta con automatizaciones.



**Objetivos principales**



* Guiar al personal de cocina mediante recetas interactivas paso a paso.
* Visualizar métricas operativas en tiempo real (ej. tiempos de preparación, consumo de insumos, productividad).
* Integrar automatizaciones de procesos con n8n (pedidos automáticos, control de inventario, compras).
* Conectar con sistemas externos:

&nbsp;		\* Chatbot en WhatsApp (comunicación rápida con proveedores/equipo).

&nbsp;		\* CRM (gestión de clientes y proveedores).

&nbsp;		\* POS (ventas y pedidos).

&nbsp;		\* IoT (sensores, balanzas, control de temperatura).



**Supuestos de diseño**



**Fuentes:**



* Firestore/Firebase para sincronización en tiempo real.
* n8n para automatización de flujos de trabajo.
* Integraciones con servicios externos (WhatsApp API, CRM, POS, dispositivos IoT).



**Necesidad de uso offline:**



* La app debe funcionar obligatoriamente con internet.



**Notificaciones críticas:**



* Alertas sobre insumos faltantes, tiempos límite o fallos en sensores IoT.



**Crecimiento esperado:**



* Fase 1: MVP con recetas y panel de métricas.
* Fase 2: Integración con IoT, IA para predicciones y supply chain inteligente.



**Equipo de desarrollo:**



* 2 desarrolladores con experiencia intermedia en Flutter.
* Conocimientos básicos de Clean Architecture y Firebase.



# **Estructura de carpeta**

lib/
  core/          # configuraciones de Firebase, APIs,
  error          # manejo de errores y excepciones   
  config         # configuraciones de Firebase, APIs etc.
  domain/
    entities/    # clases de negocio puras(Receta, Pedido, Inventario)
    repositories/# interfaces (abstracciones)
    usecases/    # casos de uso (ValidarPasoReceta, GenerarOrdenCompra)
  data/
    datasources/ # remoto/local (implementaciones de fuentes de datos: Firestore, n8n, IoT)
    models/      # DTO + mappers
    repositories_impl/ #implementaciones de los repositorios
  presentation/
    providers/   # con Riverpod para gestionar el estado y ViewModels
    pages/       # widgets/pantallas
    widgets/     # componentes reutilizables de la UI











# **Riesgos y pruebas**



## **Riesgos y mitigaciones**



* **Complejidad inicial:** mayor esfuerzo en configurar capas.

&nbsp;		Mitigación: uso de plantillas de carpetas, casos de uso base y capacitación en Clean 			Architecture.

* **Acoplamiento accidental UI–Firestore:** tentación de hacer llamadas directas en Widgets.

&nbsp;		Mitigación: centralizar accesos en repositorios, exponer solo interfaces en Domain.

* **Manejo de estados complejos**: riesgo de inconsistencias.

&nbsp;		Mitigación: Riverpod para estado global, providers jerárquicos y pruebas de 				sincronización.

* **Dependencia de múltiples integraciones externas (CRM, POS, IoT):** riesgo de fallos en cadena.

&nbsp;		Mitigación: manejar adaptadores en Data, fallback offline y mecanismos de retry.

* **Escalabilidad de notificaciones:** saturación si no se filtran adecuadamente.

&nbsp;		Mitigación: reglas de negocio en Domain para priorización y throttling de alertas.



## Pruebas previstas



**En casos de uso (Domain) se probará:**

* Validación paso a paso de recetas.
* Generación automática de pedidos de compra.
* Lógica de notificaciones (alerta crítica vs. alerta informativa).
* Manejo de inventario (disponibilidad mínima, consumos).



**En repositorios (Data) se probará:**



* Integración con Firestore (lectura/escritura).
* Manejo de fallos en IoT (ej. sensor desconectado).
* Comunicación con n8n (ejecución de flujos automáticos).
* Adaptadores para CRM, POS y chatbot (respuestas esperadas ante inputs simulados).
* Mecanismos de retry y reconexión.
