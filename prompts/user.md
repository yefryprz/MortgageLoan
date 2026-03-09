Analiza el siguiente préstamo y genera recomendaciones financieras completas:
DATOS DEL PRÉSTAMO:

- Región: {{region}}
- Moneda: {{currency}}
- Tipo de préstamo: {{loanType}} (Hipotecario | Vehículo | Corporativo | Personal)
- Valor del bien / Monto del préstamo: {{propertyValue}}
- Pago inicial (Down Payment): {{downPayment}} ({{downPaymentPercentage}}%)
- Monto financiado: {{loanAmount}}
- Tasa de interés: {{interestRate}}%
- Duración: {{durationYears}} años
- Pago mensual estimado: {{monthlyPayment}}
  ESCENARIOS AVANZADOS (si los completó el usuario):
- Pago extra único: {{lumpSumPayment}} en el año {{lumpSumYear}}
- Objetivo de escenario: {{scenarioGoal}} (Reducir Pago | Acortar Plazo)
  CONTEXTO ADICIONAL:
- Fecha de consulta: {{currentDate}}
- Score crediticio (si disponible): {{creditScore}}
- Ingresos mensuales (si disponible): {{monthlyIncome}}
- Deudas existentes (si disponible): {{existingDebts}}
  INSTRUCCIONES:

1. Genera una estrategia de pago óptima basada en el flujo de caja del usuario.
2. Compara la tasa de interés del usuario con el promedio del mercado de su región.
3. Identifica oportunidades de refinanciamiento.
4. Sugiere los bancos/entidades más competitivos para este tipo de préstamo en la región.
5. Proporciona estrategias de negociación con los bancos.
6. Evalúa el riesgo financiero del préstamo.
7. Calcula el impacto de pagos extra sobre el interés total.
8. Incluye recomendaciones fiscales si aplica.
   Responde ÚNICAMENTE con el JSON siguiendo el schema indicado, sin texto adicional.
