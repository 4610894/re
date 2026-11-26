<div id="tab-rv-vol-intradiario" class="tab-content active">
  <!-- BLOCO 1: VOLUME INTRADAY GERAL (RV) -->
  <div class="rv-section-title">
    <span>Volume de Operações Recepcionadas — Renda Variável</span>
  </div>

  <div class="kpi-grid">
    <div class="kpi-card kpi-card-status-green" id="card-rv-vol-pico">
      <div class="kpi-title">Pico de Recepção (Vol)</div>
      <div class="kpi-value" id="kpiRvVolPico">--:--</div>
      <div class="kpi-sub" id="kpiRvVolPicoSub">0 ops/dia na média</div>
    </div>
    <div class="kpi-card kpi-card-status-green" id="card-rv-vol-volatil">
      <div class="kpi-title">Horário Mais Volátil</div>
      <div class="kpi-value" id="kpiRvVolVolatil">--:--</div>
      <div class="kpi-sub" id="kpiRvVolVolatilSub">Dispersão P25–P75: 0</div>
    </div>
    <div class="kpi-card kpi-card-status-green" id="card-rv-vol-media">
      <div class="kpi-title">Média Diária (Operações)</div>
      <div class="kpi-value" id="kpiRvVolMedia">0</div>
      <div class="kpi-sub" id="kpiRvVolMediaSub">Ticket: R$ 0,00</div>
    </div>
    <div class="kpi-card" id="card-rv-vol-total">
      <div class="kpi-title">Total no Período</div>
      <div class="kpi-value" id="kpiRvVolTotal">0</div>
      <div class="kpi-sub" id="kpiRvVolTotalSub">0 dias úteis</div>
    </div>
  </div>

  <div class="chart-container" style="margin-bottom: 20px;">
    <div style="display:flex; justify-content:space-between; align-items:flex-start; flex-wrap:wrap; gap:10px; margin-bottom:12px;">
      <div>
        <div class="title" style="margin-bottom:0;">Distribuição Intraday — Recepção de Boletas RV</div>
        <div class="rv-chart-controls">
          <label class="rv-chk-label">
            <input type="checkbox" id="toggleRvVolP75" checked onchange="toggleChartLinesRV()"> P75/P25
          </label>
          <label class="rv-chk-label">
            <input type="checkbox" id="toggleRvVolBase" checked onchange="toggleChartLinesRV()"> Recepção Base
          </label>
          <label class="rv-chk-label">
            <input type="checkbox" id="toggleRvVolComp" checked onchange="toggleChartLinesRV()"> Período Comparação
          </label>
        </div>
      </div>
      <span class="tag">VOLUME PATTERN</span>
    </div>
    <div style="position:relative; height:280px; width:100%;">
      <canvas id="chartRvVolIntradiario"></canvas>
    </div>
  </div>

  <!-- BLOCO 2: RANKINGS CONSOLIDADOS (TOP 10 GESTORES + PÓS-18H) -->
  <div class="rv-section-title">
    <span>Visão Consolidada de Recepção e Liquidação</span>
  </div>

  <div class="rv-grid-2">
    <div class="chart-container" style="margin-bottom:0;">
      <div style="display:flex; justify-content:space-between; align-items:center; gap:8px;">
        <div class="title" style="margin-bottom:0;">Top 10 Gestores</div>
        <span class="tag">VOLUME</span>
      </div>
      <div id="rvRankTopGestores"></div>
    </div>

    <div class="chart-container" style="margin-bottom:0;">
      <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:8px;">
        <div>
          <div class="title" style="margin-bottom:2px;">Gestores que mais boletam após 18h</div>
          <div id="rvAfter18Sub" style="font-size:11px; color:#94a3b8;">0 operações após 18h</div>
        </div>
        <span class="tag">PÓS-18H</span>
      </div>
      <div id="rvRankAfter18"></div>
    </div>
  </div>

  <!-- BLOCO 3: AMOSTRA DE PENDÊNCIAS E BOLETAS (TOP 100) -->
  <div class="table-container">
    <div class="rv-table-toolbar">
      <div class="title" style="margin-bottom:0;">Amostra de Pendências e Boletas (Top 100)</div>
      <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap;">
        <input
          type="text"
          id="rvSampleSearch"
          class="rv-search-input"
          placeholder="Buscar boleta, gestor, título, situação..."
          oninput="filtrarTabelaAmostraRV(this.value)"
        />
        <span class="tag">SMART SAMPLE</span>
      </div>
    </div>
    <div class="tableWrap" style="max-height: 420px; overflow-y: auto;">
      <table>
        <thead>
          <tr>
            <th>Cód. Boleta</th>
            <th>Gestor</th>
            <th>Corretora</th>
            <th>Cliente</th>
            <th>Título</th>
            <th>Origem</th>
            <th>Valor (R$)</th>
            <th>Situação</th>
            <th>Recepção</th>
          </tr>
        </thead>
        <tbody id="rvSampleTbody"></tbody>
      </table>
    </div>
  </div>
</div>
