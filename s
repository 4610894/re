/* === ESTILOS COMPLEMENTARES DAS DEMAIS VISÕES RV === */
.rv-rank-fill.coral {
  background: linear-gradient(90deg, #fb7185 0%, #f59e0b 100%);
}

.rv-toggle-group {
  display: inline-flex;
  background: rgba(5, 14, 28, 0.85);
  border: 1px solid rgba(56, 189, 248, 0.25);
  border-radius: 999px;
  padding: 3px;
  gap: 3px;
}
.rv-toggle-btn {
  border: none;
  background: transparent;
  color: #94a3b8;
  font-size: 11px;
  font-weight: 600;
  padding: 5px 11px;
  border-radius: 999px;
  cursor: pointer;
  font-family: inherit;
  transition: all 0.15s ease;
}
.rv-toggle-btn:hover { color: #ffffff; }
.rv-toggle-btn.active {
  background: rgba(24, 228, 255, 0.22);
  color: #ffffff;
}

.rv-heatmap-wrap { overflow-x: auto; margin-top: 8px; }
.rv-heatmap-table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 3px;
  font-size: 10.5px;
}
.rv-heatmap-table th {
  color: #94a3b8;
  font-weight: 600;
  padding: 6px 4px;
  text-align: center;
}
.rv-heatmap-table th.rv-row-lbl {
  text-align: left;
  padding-right: 10px;
  color: #e2e8f0;
  white-space: nowrap;
  max-width: 140px;
  overflow: hidden;
  text-overflow: ellipsis;
}
.rv-hm-cell {
  text-align: center;
  padding: 8px 4px;
  border-radius: 6px;
  font-weight: 700;
  font-variant-numeric: tabular-nums;
  transition: transform 0.12s;
  min-width: 44px;
}
.rv-hm-cell:hover {
  transform: scale(1.07);
  outline: 1px solid #ffffff;
  position: relative;
  z-index: 2;
}

.rv-score-wrap {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 120px;
}
.rv-score-track {
  flex: 1;
  height: 8px;
  background: rgba(148, 163, 184, 0.16);
  border-radius: 99px;
  overflow: hidden;
}
.rv-score-fill {
  height: 100%;
  border-radius: 99px;
}

.rv-placeholder-box {
  text-align: center;
  padding: 42px 24px;
  border: 1px dashed rgba(56, 189, 248, 0.35);
  border-radius: 14px;
  background: rgba(8, 20, 38, 0.55);
}
.rv-placeholder-box h3 {
  font-size: 17px;
  color: #ffffff;
  margin-bottom: 8px;
}
.rv-placeholder-box p {
  font-size: 12.5px;
  color: #94a3b8;
  max-width: 620px;
  margin: 0 auto 14px;
  line-height: 1.55;
}
