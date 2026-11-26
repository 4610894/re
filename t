/* === COMPONENTES RV (VISÃO B ADAPTADA AO PADRÃO A) === */
.rv-section-title {
  font-size: 15px;
  font-weight: 700;
  color: #ffffff;
  margin: 22px 0 12px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
}
.rv-section-title:first-child { margin-top: 0; }

.rv-chart-controls {
  display: flex;
  align-items: center;
  gap: 14px;
  flex-wrap: wrap;
  margin-top: 8px;
}
.rv-chk-label {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 11.5px;
  color: #cbd5e1;
  cursor: pointer;
  user-select: none;
}
.rv-chk-label input {
  accent-color: #18e4ff;
  cursor: pointer;
}

.rv-grid-2 {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
  margin-bottom: 18px;
}
@media (max-width: 950px) {
  .rv-grid-2 { grid-template-columns: 1fr; }
}

.rv-rank-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: 12px;
}
.rv-rank-item {
  display: grid;
  grid-template-columns: 28px 130px 1fr 78px;
  align-items: center;
  gap: 10px;
  font-size: 11.5px;
}
.rv-rank-pos {
  color: #94a3b8;
  font-weight: 700;
  font-size: 11px;
}
.rv-rank-name {
  font-weight: 600;
  color: #e2e8f0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.rv-rank-track {
  height: 9px;
  border-radius: 99px;
  background: rgba(148, 163, 184, 0.14);
  overflow: hidden;
}
.rv-rank-fill {
  height: 100%;
  border-radius: 99px;
  background: linear-gradient(90deg, #18e4ff 0%, #34d399 100%);
  transition: width 0.35s ease;
}
.rv-rank-fill.amber {
  background: linear-gradient(90deg, #fde047 0%, #ffa63b 100%);
}
.rv-rank-val {
  text-align: right;
  font-weight: 700;
  color: #ffffff;
  font-variant-numeric: tabular-nums;
  white-space: nowrap;
}

.rv-table-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
  margin-bottom: 12px;
}
.rv-search-input {
  background: rgba(5, 14, 28, 0.85);
  border: 1px solid rgba(148, 163, 184, 0.25);
  border-radius: 8px;
  color: #f8fafc;
  padding: 7px 12px;
  font-size: 12px;
  width: 260px;
  outline: none;
  font-family: inherit;
}
.rv-search-input:focus { border-color: #18e4ff; }

.rv-st-badge {
  display: inline-flex;
  align-items: center;
  padding: 3px 9px;
  border-radius: 999px;
  font-size: 10.5px;
  font-weight: 700;
  white-space: nowrap;
}
.rv-st-ok   { background: rgba(52, 211, 153, 0.16); color: #34d399; border: 1px solid rgba(52, 211, 153, 0.35); }
.rv-st-warn { background: rgba(251, 191, 36, 0.16); color: #fbbf24; border: 1px solid rgba(251, 191, 36, 0.35); }
.rv-st-err  { background: rgba(251, 113, 133, 0.16); color: #fda4af; border: 1px solid rgba(251, 113, 133, 0.35); }
.rv-st-info { background: rgba(56, 189, 248, 0.16); color: #7dd3fc; border: 1px solid rgba(56, 189, 248, 0.35); }
.rv-empty   { text-align: center; padding: 28px 12px; color: #94a3b8; font-size: 12px; }
