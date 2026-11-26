.rv-kpi-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 14px;
  margin-bottom: 18px;
}
@media (max-width: 1100px) {
  .rv-kpi-grid { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 650px) {
  .rv-kpi-grid { grid-template-columns: 1fr; }
}

.rv-chart-box {
  height: auto !important;
  min-height: 0 !important;
  overflow: visible !important;
  padding-bottom: 18px !important;
}
