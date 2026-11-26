function isCanceladaRV(sit) {
  return String(sit || '').toLowerCase().includes('cancel');
}
function isEmAprovacaoRV(sit) {
  const s = String(sit || '').toLowerCase();
  return s.includes('em aprova') || s.includes('em aprov');
}
function isControleDocRV(sit) {
  const s = String(sit || '').toLowerCase();
  return s.includes('controle doc') || s.includes('doc');
}
function isAprovadaRV(sit) {
  const s = String(sit || '').toLowerCase();
  return s.includes('aprovad') && !isEmAprovacaoRV(s);
}

function statusBadgeClassRV(sit) {
  if (isCanceladaRV(sit)) return 'rv-st-err';
  if (isAprovadaRV(sit)) return 'rv-st-ok';
  if (isEmAprovacaoRV(sit)) return 'rv-st-warn';
  if (isControleDocRV(sit)) return 'rv-st-info';
  return 'rv-st-info';
}

function atualizarDashboardRV() {
  if (!rawDataRV.length) return;
  const activeEl = document.querySelector('#area-rv .tab-content.active');
  const activeTabId = activeEl ? activeEl.id : 'tab-rv-vol-intradiario';
  renderActiveTabRV(activeTabId);
  console.log('✅ Dashboard RV atualizado (' + activeTabId + ')');
}


















// =========================================================================
// MÓDULO RV — DEMAIS 10 VISÕES (PADRÃO B ADAPTADO À BASE REAL DE RV)
// =========================================================================
const rvCharts = {};
const rvState = {
  finFlags: { p75: true, base: true, comp: true },
  cancelStatusFilter: 'Cancelada', // 'Cancelada' | 'Em Aprovação' | 'Controle DOC'
  heatmapMetric: 'volume',         // 'volume' | 'financeiro'
  clientesMetric: 'volume',        // 'volume' | 'financeiro'
  rankingEntity: 'gestor',         // 'gestor' | 'corretora' | 'cliente'
  entitySearch: { gestor: '', corretora: '' }
};

const fmtPctRV = (n) => fmtDecRV(n, 1) + '%';

function shortOrigemRV(orig) {
  const s = String(orig || '').toLowerCase();
  if (s.includes('ok4')) return 'OK4 Web 3';
  if (s.includes('pesc')) return 'Arquivo PESC';
  if (s.includes('ot5') || s.includes('etf')) return 'ETF OT5';
  return orig || 'N/D';
}

function normMercadoRV(m) {
  const s = String(m || '').toLowerCase();
  if (s.includes('op')) return 'Opção';
  if (s.includes('vista')) return 'Vista';
  return m || 'N/D';
}

function createChartRV(key, canvasId, config) {
  if (rvCharts[key]) {
    try { rvCharts[key].destroy(); } catch (e) {}
    delete rvCharts[key];
  }
  const canvas = document.getElementById(canvasId);
  if (!canvas) return null;
  rvCharts[key] = new Chart(canvas.getContext('2d'), config);
  return rvCharts[key];
}

function rvBaseChartOptions(yFmt) {
  return {
    responsive: true,
    maintainAspectRatio: false,
    interaction: { mode: 'index', intersect: false },
    animation: { duration: 450, easing: 'easeOutQuart' },
    plugins: {
      legend: {
        labels: { color: '#cbd5e1', usePointStyle: true, boxWidth: 8, font: { size: 11 } }
      },
      tooltip: {
        backgroundColor: 'rgba(6, 17, 33, 0.94)',
        borderColor: 'rgba(24, 228, 255, 0.35)',
        borderWidth: 1,
        callbacks: yFmt ? { label: (ctx) => `${ctx.dataset.label}: ${yFmt(ctx.parsed.y)}` } : {}
      }
    },
    scales: {
      x: { grid: { color: 'rgba(255,255,255,.05)' }, ticks: { color: '#94a3b8' } },
      y: {
        beginAtZero: true,
        grid: { color: 'rgba(255,255,255,.05)' },
        ticks: { color: '#94a3b8', callback: yFmt || ((v) => fmtIntRV(v)) }
      }
    }
  };
}

function setRvStateAndRender(prop, val, tabId) {
  rvState[prop] = val;
  renderActiveTabRV(tabId);
}

function renderActiveTabRV(tabId) {
  if (!rawDataRV.length) return;
  if (tabId === 'tab-rv-vol-intradiario') {
    updateTabRvVolIntradiario();
    return;
  }

  const el = document.getElementById(tabId);
  if (!el) return;

  const base = getFilteredDataRV(1);
  const comp = getFilteredDataRV(2);

  if (tabId === 'tab-rv-leadtime') {
    renderTabRvLeadtime(el, base);
    return;
  }

  if (!base.length) {
    el.innerHTML = `<div class="chart-container rv-chart-box"><div class="rv-empty">Nenhuma boleta de RV encontrada no Período Base com os filtros selecionados.</div></div>`;
    return;
  }

  switch (tabId) {
    case 'tab-rv-financeiro': renderTabRvFinanceiro(el, base, comp); break;
    case 'tab-rv-gestores':   renderTabRvEntity(el, base, 'gestor', 'Gestores', 'Gestor'); break;
    case 'tab-rv-corretoras': renderTabRvEntity(el, base, 'corretora', 'Corretoras', 'Corretora'); break;
    case 'tab-rv-canceladas': renderTabRvCanceladas(el, base); break;
    case 'tab-rv-natureza':   renderTabRvNatureza(el, base); break;
    case 'tab-rv-heatmap':    renderTabRvHeatmap(el, base); break;
    case 'tab-rv-clientes':   renderTabRvClientes(el, base); break;
    case 'tab-rv-qualidade':  renderTabRvQualidade(el, base); break;
    case 'tab-rv-ranking':    renderTabRvRanking(el, base); break;
  }
}

// -------------------------------------------------------------------------
// TAB 2: FINANCEIRO POR HORÁRIO
// -------------------------------------------------------------------------
function renderTabRvFinanceiro(el, base, comp) {
  const totalFin = base.reduce((a, b) => a + b.valor_operacao, 0);
  const compFin  = comp.reduce((a, b) => a + b.valor_operacao, 0);
  const varPct   = compFin > 0 ? ((totalFin - compFin) / compFin) * 100 : 0;
  const ticket   = base.length ? totalFin / base.length : 0;

  const stB = computeIntradayStatsRV(base, r => r.valor_operacao);
  const stC = computeIntradayStatsRV(comp, r => r.valor_operacao);

  const byOrigem  = groupTopRV(base, r => shortOrigemRV(r.origem_boleta), r => r.valor_operacao, 10);
  const byMercado = groupTopRV(base, r => normMercadoRV(r.tipo_mercado), r => r.valor_operacao, 10);
  const top20     = [...base].sort((a, b) => b.valor_operacao - a.valor_operacao).slice(0, 20);

  el.innerHTML = `
    <div class="rv-section-title"><span>Volume Financeiro por Horário — Renda Variável</span></div>
    <div class="rv-kpi-grid">
      <div class="kpi-card kpi-card-status-green">
        <div class="kpi-title">Volume Financeiro Total</div>
        <div class="kpi-value">${fmtBRLShortRV(totalFin)}</div>
        <div class="kpi-sub">${fmtIntRV(base.length)} boletas no período</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-title">Ticket Médio</div>
        <div class="kpi-value">${fmtBRLShortRV(ticket)}</div>
        <div class="kpi-sub">Valor médio por operação</div>
      </div>
      <div class="kpi-card kpi-card-status-green">
        <div class="kpi-title">Pico Financeiro Intraday</div>
        <div class="kpi-value">${stB.peakHour}</div>
        <div class="kpi-sub">${fmtBRLShortRV(stB.peakVal)}/dia na média</div>
      </div>
      <div class="kpi-card ${compFin > 0 ? (varPct >= 0 ? 'kpi-card-status-green' : 'kpi-card-status-red') : ''}">
        <div class="kpi-title">Variação vs Comparação</div>
        <div class="kpi-value">${compFin > 0 ? (varPct >= 0 ? '+' : '') + fmtPctRV(varPct) : '—'}</div>
        <div class="kpi-sub">Comp: ${fmtBRLShortRV(compFin)}</div>
      </div>
    </div>

    <div class="chart-container rv-chart-box" style="margin-bottom:20px;">
      <div style="display:flex; justify-content:space-between; align-items:flex-start; flex-wrap:wrap; gap:10px; margin-bottom:12px;">
        <div>
          <div class="title" style="margin-bottom:0;">Volume Financeiro Intraday (Média Diária por Horário)</div>
          <div class="rv-chart-controls">
            <label class="rv-chk-label"><input type="checkbox" id="toggleRvFinP75" ${rvState.finFlags.p75 ? 'checked' : ''} onchange="toggleChartLinesRvFin()"> P75/P25</label>
            <label class="rv-chk-label"><input type="checkbox" id="toggleRvFinBase" ${rvState.finFlags.base ? 'checked' : ''} onchange="toggleChartLinesRvFin()"> Recepção Base</label>
            <label class="rv-chk-label"><input type="checkbox" id="toggleRvFinComp" ${rvState.finFlags.comp ? 'checked' : ''} onchange="toggleChartLinesRvFin()"> Período Comparação</label>
          </div>
        </div>
        <span class="tag">FINANCIAL FLOW</span>
      </div>
      <div style="position:relative; height:280px; width:100%;"><canvas id="chartRvFinIntraday"></canvas></div>
    </div>

    <div class="rv-grid-2">
      <div class="chart-container rv-chart-box" style="margin-bottom:0;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
          <div class="title" style="margin-bottom:0;">Financeiro por Origem</div>
          <span class="tag">ORIGEM</span>
        </div>
        <div style="position:relative; height:235px; width:100%;"><canvas id="chartRvFinOrigem"></canvas></div>
      </div>
      <div class="chart-container rv-chart-box" style="margin-bottom:0;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
          <div class="title" style="margin-bottom:0;">Financeiro por Tipo de Mercado</div>
          <span class="tag">VISTA × OPÇÃO</span>
        </div>
        <div style="position:relative; height:235px; width:100%;"><canvas id="chartRvFinMercado"></canvas></div>
      </div>
    </div>

    <div class="table-container">
      <div class="rv-table-toolbar">
        <div class="title" style="margin-bottom:0;">Top 20 Maiores Boletas Financeiras</div>
        <span class="tag">HIGH VALUE</span>
      </div>
      <div class="tableWrap" style="max-height:420px; overflow-y:auto;">
        <table>
          <thead>
            <tr><th>Boleta</th><th>Gestor</th><th>Corretora</th><th>Cliente</th><th>Título</th><th>Mercado</th><th>Origem</th><th>Valor (R$)</th><th>Situação</th></tr>
          </thead>
          <tbody>
            ${top20.map(r => `
              <tr>
                <td style="font-weight:700; color:#7dd3fc;">${r.codigo_boleta}</td>
                <td>${r.gestor}</td><td>${r.corretora}</td><td>${r.cliente}</td><td>${r.codigo_titulo}</td>
                <td>${normMercadoRV(r.tipo_mercado)}</td><td>${shortOrigemRV(r.origem_boleta)}</td>
                <td style="font-weight:700; color:#fbbf24;">${fmtBRLRV(r.valor_operacao)}</td>
                <td><span class="rv-st-badge ${statusBadgeClassRV(r.situacao_boleta)}">${r.situacao_boleta}</span></td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      </div>
    </div>
  `;

  const hasComp = comp.length > 0;
  createChartRV('finIntraday', 'chartRvFinIntraday', {
    type: 'line',
    data: {
      labels: RV_HOUR_LABELS,
      datasets: [
        { label: 'P75 (Base)', data: stB.p75, borderColor: 'transparent', backgroundColor: 'rgba(56, 189, 248, 0.13)', fill: '+1', pointRadius: 0, tension: 0.4 },
        { label: 'P25 (Base)', data: stB.p25, borderColor: 'transparent', fill: false, pointRadius: 0, tension: 0.4 },
        { label: 'Financeiro - Período Base', data: stB.mean, borderColor: '#38bdf8', backgroundColor: '#38bdf8', borderWidth: 3, pointRadius: 4, tension: 0.4, fill: false },
        { label: 'Financeiro - Período Comparação', data: hasComp ? stC.mean : [], borderColor: '#ffa63b', backgroundColor: '#ffa63b', borderWidth: 2, borderDash: [6, 4], pointRadius: 3, tension: 0.4, fill: false }
      ]
    },
    options: rvBaseChartOptions(fmtBRLShortRV)
  });
  toggleChartLinesRvFin();

  createChartRV('finOrigem', 'chartRvFinOrigem', {
    type: 'bar',
    data: {
      labels: byOrigem.map(x => x.name),
      datasets: [{ label: 'Financeiro', data: byOrigem.map(x => x.val), backgroundColor: ['#18e4ff', '#34d399', '#fbbf24', '#a78bfa'], borderRadius: 8 }]
    },
    options: rvBaseChartOptions(fmtBRLShortRV)
  });

  createChartRV('finMercado', 'chartRvFinMercado', {
    type: 'doughnut',
    data: {
      labels: byMercado.map(x => x.name),
      datasets: [{ data: byMercado.map(x => x.val), backgroundColor: ['#0ea5e9', '#a78bfa', '#14b8a6', '#fbbf24'], borderWidth: 0 }]
    },
    options: {
      responsive: true, maintainAspectRatio: false,
      plugins: {
        legend: { position: 'right', labels: { color: '#cbd5e1', font: { size: 11.5 } } },
        tooltip: { callbacks: { label: (ctx) => `${ctx.label}: ${fmtBRLShortRV(ctx.parsed)}` } }
      }
    }
  });
}

function toggleChartLinesRvFin() {
  const c = rvCharts.finIntraday;
  if (!c) return;
  rvState.finFlags.p75  = document.getElementById('toggleRvFinP75')?.checked ?? true;
  rvState.finFlags.base = document.getElementById('toggleRvFinBase')?.checked ?? true;
  rvState.finFlags.comp = document.getElementById('toggleRvFinComp')?.checked ?? true;
  const ds = c.data.datasets;
  if (ds[0]) ds[0].hidden = !rvState.finFlags.p75;
  if (ds[1]) ds[1].hidden = !rvState.finFlags.p75;
  if (ds[2]) ds[2].hidden = !rvState.finFlags.base;
  if (ds[3]) ds[3].hidden = !rvState.finFlags.comp || !(ds[3].data && ds[3].data.length > 0);
  c.update();
}

// -------------------------------------------------------------------------
// TAB 3 & TAB 4: TOP GESTORES / TOP CORRETORAS
// -------------------------------------------------------------------------
function renderTabRvEntity(el, base, field, plural, singular) {
  const map = new Map();
  base.forEach(r => {
    const k = r[field] || 'N/D';
    if (!map.has(k)) map.set(k, { name: k, vol: 0, fin: 0, aprov: 0, emAprov: 0, doc: 0, canc: 0, after18: 0 });
    const o = map.get(k);
    o.vol++;
    o.fin += r.valor_operacao;
    if (isCanceladaRV(r.situacao_boleta)) o.canc++;
    else if (isEmAprovacaoRV(r.situacao_boleta)) o.emAprov++;
    else if (isAprovadaRV(r.situacao_boleta)) o.aprov++;
    else if (isControleDocRV(r.situacao_boleta)) o.doc++;
    if (r.after18) o.after18++;
  });

  const list = [...map.values()].map(o => ({
    ...o,
    ticket:     o.vol ? o.fin / o.vol : 0,
    aprovPct:   o.vol ? (o.aprov / o.vol) * 100 : 0,
    emAprovPct: o.vol ? (o.emAprov / o.vol) * 100 : 0,
    cancPct:    o.vol ? (o.canc / o.vol) * 100 : 0,
    after18Pct: o.vol ? (o.after18 / o.vol) * 100 : 0
  }));

  const byVol  = [...list].sort((a, b) => b.vol - a.vol);
  const byFin  = [...list].sort((a, b) => b.fin - a.fin);
  const byCanc = [...list].sort((a, b) => b.cancPct - a.cancPct || b.canc - a.canc);
  const top5Vol = byVol.slice(0, 5).reduce((a, b) => a + b.vol, 0);
  const concTop5 = base.length ? (top5Vol / base.length) * 100 : 0;

  const tbodyId  = `rvEntityTbody_${field}`;
  const searchId = `rvEntitySearch_${field}`;
  const savedQ   = rvState.entitySearch[field] || '';

  el.innerHTML = `
    <div class="rv-section-title"><span>Ranking Analítico de ${plural}</span></div>
    <div class="rv-kpi-grid">
      <div class="kpi-card">
        <div class="kpi-title">${plural} Ativos</div>
        <div class="kpi-value">${fmtIntRV(list.length)}</div>
        <div class="kpi-sub">Com operação no período</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-title">Concentração Top 5</div>
        <div class="kpi-value">${fmtPctRV(concTop5)}</div>
        <div class="kpi-sub">${fmtIntRV(top5Vol)} de ${fmtIntRV(base.length)} boletas</div>
      </div>
      <div class="kpi-card kpi-card-status-green">
        <div class="kpi-title">Líder em Volume</div>
        <div class="kpi-value" style="font-size:18px;">${byVol[0]?.name || '-'}</div>
        <div class="kpi-sub">${fmtIntRV(byVol[0]?.vol || 0)} operações</div>
      </div>
      <div class="kpi-card ${field === 'corretora' && (byCanc[0]?.cancPct || 0) > 5 ? 'kpi-card-status-red' : ''}">
        <div class="kpi-title">${field === 'corretora' ? 'Maior Taxa Cancelamento' : 'Líder em Financeiro'}</div>
        <div class="kpi-value" style="font-size:18px;">${field === 'corretora' ? (byCanc[0]?.name || '-') : (byFin[0]?.name || '-')}</div>
        <div class="kpi-sub">${field === 'corretora' ? fmtPctRV(byCanc[0]?.cancPct || 0) + ` (${fmtIntRV(byCanc[0]?.canc || 0)} ops)` : fmtBRLShortRV(byFin[0]?.fin || 0)}</div>
      </div>
    </div>

    <div class="rv-grid-2">
      <div class="chart-container rv-chart-box" style="margin-bottom:0;">
        <div style="display:flex; justify-content:space-between; align-items:center;">
          <div class="title" style="margin-bottom:0;">Top 10 ${plural} — Volume</div>
          <span class="tag">VOLUME</span>
        </div>
        ${renderRankingRVHTML(byVol.slice(0, 10).map(x => ({ name: x.name, val: x.vol })), byVol[0]?.vol || 1, fmtIntRV)}
      </div>
      <div class="chart-container rv-chart-box" style="margin-bottom:0;">
        <div style="display:flex; justify-content:space-between; align-items:center;">
          <div class="title" style="margin-bottom:0;">Top 10 ${plural} — Financeiro</div>
          <span class="tag">FINANCEIRO</span>
        </div>
        ${renderRankingRVHTML(byFin.slice(0, 10).map(x => ({ name: x.name, val: x.fin })), byFin[0]?.fin || 1, fmtBRLShortRV, 'amber')}
      </div>
    </div>

    <div class="table-container">
      <div class="rv-table-toolbar">
        <div class="title" style="margin-bottom:0;">Detalhamento Analítico de ${plural}</div>
        <div style="display:flex; align-items:center; gap:10px;">
          <input type="text" id="${searchId}" class="rv-search-input" placeholder="Filtrar ${singular.toLowerCase()}..." value="${savedQ}" />
          <span class="tag">FULL TABLE</span>
        </div>
      </div>
      <div class="tableWrap" style="max-height:440px; overflow-y:auto;">
        <table>
          <thead>
            <tr>
              <th>${singular}</th><th>Volume</th><th>Financeiro</th><th>Ticket Médio</th>
              <th>% Aprovada</th><th>% Em Aprov.</th><th>% Pós-18h</th><th>% Cancelada</th>
            </tr>
          </thead>
          <tbody id="${tbodyId}"></tbody>
        </table>
      </div>
    </div>
  `;

  const drawTable = (q) => {
    const term = String(q || '').trim().toLowerCase();
    const filtered = byVol.filter(x => !term || x.name.toLowerCase().includes(term));
    document.getElementById(tbodyId).innerHTML = filtered.length ? filtered.map(x => `
      <tr>
        <td style="font-weight:700; color:#fff;">${x.name}</td>
        <td>${fmtIntRV(x.vol)}</td>
        <td style="color:#18e4ff; font-weight:600;">${fmtBRLShortRV(x.fin)}</td>
        <td>${fmtBRLShortRV(x.ticket)}</td>
        <td>${fmtPctRV(x.aprovPct)}</td>
        <td>${fmtPctRV(x.emAprovPct)}</td>
        <td>${fmtPctRV(x.after18Pct)}</td>
        <td><span class="rv-st-badge ${x.cancPct > 10 ? 'rv-st-err' : x.cancPct > 3 ? 'rv-st-warn' : 'rv-st-ok'}">${fmtPctRV(x.cancPct)}</span></td>
      </tr>
    `).join('') : '<tr><td colspan="8" class="rv-empty">Nenhum registro encontrado.</td></tr>';
  };

  drawTable(savedQ);
  document.getElementById(searchId).addEventListener('input', (e) => {
    rvState.entitySearch[field] = e.target.value;
    drawTable(e.target.value);
  });
}

// -------------------------------------------------------------------------
// TAB 5: LEADTIME (SLA) — AGUARDANDO DADOS DE HORÁRIO NA DATA DE OPERAÇÃO
// -------------------------------------------------------------------------
function renderTabRvLeadtime(el, base) {
  el.innerHTML = `
    <div class="rv-section-title"><span>Leadtime &amp; Monitoramento de SLA — Renda Variável</span></div>
    <div class="chart-container rv-chart-box">
      <div class="rv-placeholder-box">
        <span class="tag" style="margin-bottom:12px; display:inline-block;">EM IMPLANTAÇÃO • AGUARDANDO DADOS</span>
        <h3>Visão de Leadtime (SLA) pronta para integração</h3>
        <p>
          A base atual de Renda Variável (<code>data/resultado.csv</code>) traz a coluna <code>data_operacao</code> apenas com a data (sem horário), o que impede o cálculo preciso em minutos até <code>data_recepcao</code>.
        </p>
        <p style="color:#cbd5e1; margin-bottom:0;">
          Assim que o timestamp de negociação for incluído na extração, esta aba passará a exibir automaticamente: <b>Leadtime Médio</b>, <b>Horário Gargalo</b>, <b>Aderência SLA (&le; 15 min)</b>, <b>Curva Intraday</b> e <b>Top Atrasos por Gestor/Corretora</b>.<br/>
          <span style="color:#38bdf8; font-size:11.5px;">Base filtrada atualmente conectada: ${fmtIntRV(base.length)} boletas no Período Base.</span>
        </p>
      </div>
    </div>
  `;
}

// -------------------------------------------------------------------------
// TAB 6: OPERAÇÕES CANCELADAS & ANÁLISE DE SITUAÇÃO DA BOLETA
// -------------------------------------------------------------------------
function renderTabRvCanceladas(el, base) {
  const cancRows    = base.filter(r => isCanceladaRV(r.situacao_boleta));
  const emAprovRows = base.filter(r => isEmAprovacaoRV(r.situacao_boleta));
  const docRows     = base.filter(r => isControleDocRV(r.situacao_boleta));
  const aprovRows   = base.filter(r => isAprovadaRV(r.situacao_boleta));

  const totalFin = base.reduce((a, b) => a + b.valor_operacao, 0);
  const cancFin  = cancRows.reduce((a, b) => a + b.valor_operacao, 0);

  const cancPct    = base.length ? (cancRows.length / base.length) * 100 : 0;
  const aprovPct   = base.length ? (aprovRows.length / base.length) * 100 : 0;
  const pendCount  = emAprovRows.length + docRows.length;
  const cancFinPct = totalFin > 0 ? (cancFin / totalFin) * 100 : 0;

  const stCanc    = computeIntradayStatsRV(cancRows);
  const stEmAprov = computeIntradayStatsRV(emAprovRows);

  const sitFocus = rvState.cancelStatusFilter;
  const focusRows = sitFocus === 'Cancelada'
    ? cancRows
    : sitFocus === 'Em Aprovação'
      ? emAprovRows
      : docRows;

  const topGest = groupTopRV(focusRows, r => r.gestor, () => 1, 10);
  const topCorr = groupTopRV(focusRows, r => r.corretora, () => 1, 10);
  const barStyle = sitFocus === 'Cancelada' ? 'coral' : sitFocus === 'Em Aprovação' ? 'amber' : '';

  const sitCounts = [
    { name: 'Aprovada',     val: aprovRows.length,   color: '#34d399' },
    { name: 'Controle DOC', val: docRows.length,     color: '#38bdf8' },
    { name: 'Em Aprovação', val: emAprovRows.length, color: '#fbbf24' },
    { name: 'Cancelada',    val: cancRows.length,    color: '#fb7185' }
  ];

  el.innerHTML = `
    <div class="rv-section-title"><span>Análise de Situação das Boletas &amp; Cancelamentos</span></div>
    <div class="rv-kpi-grid">
      <div class="kpi-card ${cancPct > 5 ? 'kpi-card-status-red' : cancPct > 2 ? 'kpi-card-status-yellow' : 'kpi-card-status-green'}">
        <div class="kpi-title">Taxa de Cancelamento</div>
        <div class="kpi-value">${fmtPctRV(cancPct)}</div>
        <div class="kpi-sub">${fmtIntRV(cancRows.length)} boletas canceladas</div>
      </div>
      <div class="kpi-card ${emAprovRows.length > 0 ? 'kpi-card-status-yellow' : ''}">
        <div class="kpi-title">Fluxo Pendente (DOC + Aprov.)</div>
        <div class="kpi-value">${fmtIntRV(pendCount)}</div>
        <div class="kpi-sub">Em Aprov.: ${fmtIntRV(emAprovRows.length)} | DOC: ${fmtIntRV(docRows.length)}</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-title">Financeiro Cancelado</div>
        <div class="kpi-value">${fmtBRLShortRV(cancFin)}</div>
        <div class="kpi-sub">${fmtPctRV(cancFinPct)} do financeiro total</div>
      </div>
      <div class="kpi-card kpi-card-status-green">
        <div class="kpi-title">Taxa de Aprovação</div>
        <div class="kpi-value">${fmtPctRV(aprovPct)}</div>
        <div class="kpi-sub">${fmtIntRV(aprovRows.length)} boletas aprovadas</div>
      </div>
    </div>

    <div class="rv-grid-2">
      <div class="chart-container rv-chart-box" style="margin-bottom:0;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
          <div class="title" style="margin-bottom:0;">Distribuição por Situação da Boleta</div>
          <span class="tag">STATUS MIX</span>
        </div>
        <div style="position:relative; height:235px; width:100%;"><canvas id="chartRvSitMix"></canvas></div>
      </div>
      <div class="chart-container rv-chart-box" style="margin-bottom:0;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
          <div class="title" style="margin-bottom:0;">Incidência Intraday (Canceladas vs Em Aprovação)</div>
          <span class="tag">INTRADAY</span>
        </div>
        <div style="position:relative; height:235px; width:100%;"><canvas id="chartRvCancIntra"></canvas></div>
      </div>
    </div>

    <div class="chart-container rv-chart-box" style="margin-bottom:16px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px;">
      <div>
        <div class="title" style="margin-bottom:2px;">Detalhamento por Situação — ${sitFocus}</div>
        <div style="font-size:11px; color:#94a3b8;">${fmtIntRV(focusRows.length)} boletas nesta situação no Período Base</div>
      </div>
      <div class="rv-toggle-group">
        <button class="rv-toggle-btn ${sitFocus === 'Cancelada' ? 'active' : ''}" onclick="setRvStateAndRender('cancelStatusFilter','Cancelada','tab-rv-canceladas')">Cancelada (${fmtIntRV(cancRows.length)})</button>
        <button class="rv-toggle-btn ${sitFocus === 'Em Aprovação' ? 'active' : ''}" onclick="setRvStateAndRender('cancelStatusFilter','Em Aprovação','tab-rv-canceladas')">Em Aprovação (${fmtIntRV(emAprovRows.length)})</button>
        <button class="rv-toggle-btn ${sitFocus === 'Controle DOC' ? 'active' : ''}" onclick="setRvStateAndRender('cancelStatusFilter','Controle DOC','tab-rv-canceladas')">Controle DOC (${fmtIntRV(docRows.length)})</button>
      </div>
    </div>

    <div class="rv-grid-2">
      <div class="chart-container rv-chart-box" style="margin-bottom:0;">
        <div style="display:flex; justify-content:space-between; align-items:center;">
          <div class="title" style="margin-bottom:0;">Top 10 Gestores — ${sitFocus}</div>
          <span class="tag">GESTOR</span>
        </div>
        ${renderRankingRVHTML(topGest, topGest[0]?.val || 1, fmtIntRV, barStyle)}
      </div>
      <div class="chart-container rv-chart-box" style="margin-bottom:0;">
        <div style="display:flex; justify-content:space-between; align-items:center;">
          <div class="title" style="margin-bottom:0;">Top 10 Corretoras — ${sitFocus}</div>
          <span class="tag">CONTRAPARTE</span>
        </div>
        ${renderRankingRVHTML(topCorr, topCorr[0]?.val || 1, fmtIntRV, barStyle)}
      </div>
    </div>

    <div class="table-container">
      <div class="rv-table-toolbar">
        <div class="title" style="margin-bottom:0;">Boletas em "${sitFocus}" (Top 80 por Valor)</div>
        <span class="tag">AUDITORIA STATUS</span>
      </div>
      <div class="tableWrap" style="max-height:420px; overflow-y:auto;">
        <table>
          <thead>
            <tr><th>Boleta</th><th>Gestor</th><th>Corretora</th><th>Título</th><th>Mercado</th><th>Origem</th><th>Valor (R$)</th><th>Situação</th><th>Recepção</th></tr>
          </thead>
          <tbody>
            ${[...focusRows].sort((a, b) => b.valor_operacao - a.valor_operacao).slice(0, 80).map(r => `
              <tr>
                <td style="font-weight:700; color:#7dd3fc;">${r.codigo_boleta}</td>
                <td>${r.gestor}</td><td>${r.corretora}</td><td>${r.codigo_titulo}</td>
                <td>${normMercadoRV(r.tipo_mercado)}</td><td>${shortOrigemRV(r.origem_boleta)}</td>
                <td style="font-weight:600;">${fmtBRLRV(r.valor_operacao)}</td>
                <td><span class="rv-st-badge ${statusBadgeClassRV(r.situacao_boleta)}">${r.situacao_boleta}</span></td>
                <td style="color:#94a3b8;">${fmtDateTimeRV(r.dtRec)}</td>
              </tr>
            `).join('') || '<tr><td colspan="9" class="rv-empty">Nenhuma boleta nesta situação no período filtrado.</td></tr>'}
          </tbody>
        </table>
      </div>
    </div>
  `;

  createChartRV('sitMix', 'chartRvSitMix', {
    type: 'bar',
    data: {
      labels: sitCounts.map(x => x.name),
      datasets: [{ label: 'Boletas', data: sitCounts.map(x => x.val), backgroundColor: sitCounts.map(x => x.color), borderRadius: 8 }]
    },
    options: rvBaseChartOptions(fmtIntRV)
  });

  createChartRV('cancIntra', 'chartRvCancIntra', {
    type: 'line',
    data: {
      labels: RV_HOUR_LABELS,
      datasets: [
        { label: 'Cancelada (média/dia)', data: stCanc.mean, borderColor: '#fb7185', backgroundColor: 'rgba(251,113,133,0.16)', fill: true, tension: 0.4, borderWidth: 2.5 },
        { label: 'Em Aprovação (média/dia)', data: stEmAprov.mean, borderColor: '#fbbf24', backgroundColor: 'rgba(251,191,36,0.12)', fill: false, tension: 0.4, borderWidth: 2, borderDash: [5, 4] }
      ]
    },
    options: rvBaseChartOptions(fmtIntRV)
  });
}

// -------------------------------------------------------------------------
// TAB 7: NATUREZA & MERCADOS (VISTA / OPÇÃO + 3 ORIGENS RV)
// -------------------------------------------------------------------------
function renderTabRvNatureza(el, base) {
  const byNat  = groupTopRV(base, r => r.natureza, () => 1, 10);
  const byMkt  = groupTopRV(base, r => normMercadoRV(r.tipo_mercado), () => 1, 10);
  const byOrig = groupTopRV(base, r => shortOrigemRV(r.origem_boleta), () => 1, 10);

  const compraFin = base.filter(r => r.natureza.toLowerCase().startsWith('c')).reduce((a, b) => a + b.valor_operacao, 0);
  const vendaFin  = base.filter(r => r.natureza.toLowerCase().startsWith('v')).reduce((a, b) => a + b.valor_operacao, 0);
  const netFin    = compraFin - vendaFin;

  const compraHr = RV_HOURS.map(h => base.filter(r => r.hour === h && r.natureza.toLowerCase().startsWith('c')).length);
  const vendaHr  = RV_HOURS.map(h => base.filter(r => r.hour === h && r.natureza.toLowerCase().startsWith('v')).length);

  // Resumo cruzado Origem x Mercado
  const crossMap = new Map();
  base.forEach(r => {
    const orig = shortOrigemRV(r.origem_boleta);
    const mkt  = normMercadoRV(r.tipo_mercado);
    const k = `${orig}|||${mkt}`;
    if (!crossMap.has(k)) crossMap.set(k, { orig, mkt, vol: 0, fin: 0, canc: 0 });
    const o = crossMap.get(k);
    o.vol++; o.fin += r.valor_operacao;
    if (isCanceladaRV(r.situacao_boleta)) o.canc++;
  });
  const crossList = [...crossMap.values()].sort((a, b) => b.vol - a.vol);

  el.innerHTML = `
    <div class="rv-section-title"><span>Natureza, Mercados (Vista × Opção) &amp; Origens</span></div>
    <div class="rv-kpi-grid">
      <div class="kpi-card">
        <div class="kpi-title">Natureza Predominante</div>
        <div class="kpi-value">${byNat[0]?.name || '-'}</div>
        <div class="kpi-sub">${fmtIntRV(byNat[0]?.val || 0)} operações (${fmtPctRV((byNat[0]?.val || 0) / Math.max(1, base.length) * 100)})</div>
      </div>
      <div class="kpi-card ${netFin >= 0 ? 'kpi-card-status-green' : 'kpi-card-status-red'}">
        <div class="kpi-title">Saldo Net (Compra − Venda)</div>
        <div class="kpi-value">${fmtBRLShortRV(netFin)}</div>
        <div class="kpi-sub">C: ${fmtBRLShortRV(compraFin)} | V: ${fmtBRLShortRV(vendaFin)}</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-title">Mercado Predominante</div>
        <div class="kpi-value">${byMkt[0]?.name || '-'}</div>
        <div class="kpi-sub">${fmtPctRV((byMkt[0]?.val || 0) / Math.max(1, base.length) * 100)} do volume</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-title">Origem Principal</div>
        <div class="kpi-value" style="font-size:19px;">${byOrig[0]?.name || '-'}</div>
        <div class="kpi-sub">${fmtPctRV((byOrig[0]?.val || 0) / Math.max(1, base.length) * 100)} das boletas</div>
      </div>
    </div>

    <div class="chart-container rv-chart-box" style="margin-bottom:20px;">
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
        <div class="title" style="margin-bottom:0;">Distribuição Intraday por Natureza (Compra vs Venda)</div>
        <span class="tag">FLOW</span>
      </div>
      <div style="position:relative; height:270px; width:100%;"><canvas id="chartRvNatIntra"></canvas></div>
    </div>

    <div class="rv-grid-2">
      <div class="chart-container rv-chart-box" style="margin-bottom:0;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
          <div class="title" style="margin-bottom:0;">Mix por Tipo de Mercado</div>
          <span class="tag">MERCADOS</span>
        </div>
        <div style="position:relative; height:230px; width:100%;"><canvas id="chartRvMktMix"></canvas></div>
      </div>
      <div class="chart-container rv-chart-box" style="margin-bottom:0;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
          <div class="title" style="margin-bottom:0;">Mix por Origem da Boleta</div>
          <span class="tag">ORIGEM</span>
        </div>
        <div style="position:relative; height:230px; width:100%;"><canvas id="chartRvOrigMix"></canvas></div>
      </div>
    </div>

    <div class="table-container">
      <div class="rv-table-toolbar">
        <div class="title" style="margin-bottom:0;">Consolidado Origem × Tipo de Mercado</div>
        <span class="tag">BREAKDOWN</span>
      </div>
      <div class="tableWrap">
        <table>
          <thead><tr><th>Origem</th><th>Mercado</th><th>Volume</th><th>% Volume</th><th>Financeiro</th><th>Ticket Médio</th><th>% Cancelada</th></tr></thead>
          <tbody>
            ${crossList.map(x => `
              <tr>
                <td style="font-weight:700; color:#fff;">${x.orig}</td>
                <td>${x.mkt}</td>
                <td>${fmtIntRV(x.vol)}</td>
                <td>${fmtPctRV((x.vol / Math.max(1, base.length)) * 100)}</td>
                <td style="color:#18e4ff; font-weight:600;">${fmtBRLShortRV(x.fin)}</td>
                <td>${fmtBRLShortRV(x.fin / Math.max(1, x.vol))}</td>
                <td><span class="rv-st-badge ${x.canc / Math.max(1, x.vol) > 0.05 ? 'rv-st-err' : 'rv-st-ok'}">${fmtPctRV((x.canc / Math.max(1, x.vol)) * 100)}</span></td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      </div>
    </div>
  `;

  createChartRV('natIntra', 'chartRvNatIntra', {
    type: 'bar',
    data: {
      labels: RV_HOUR_LABELS,
      datasets: [
        { label: 'Compra', data: compraHr, backgroundColor: '#18e4ff', borderRadius: 5 },
        { label: 'Venda',  data: vendaHr,  backgroundColor: '#fb7185', borderRadius: 5 }
      ]
    },
    options: rvBaseChartOptions(fmtIntRV)
  });

  createChartRV('mktMix', 'chartRvMktMix', {
    type: 'doughnut',
    data: { labels: byMkt.map(x => x.name), datasets: [{ data: byMkt.map(x => x.val), backgroundColor: ['#0ea5e9', '#a78bfa', '#14b8a6'], borderWidth: 0 }] },
    options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'right', labels: { color: '#cbd5e1' } } } }
  });

  createChartRV('origMix', 'chartRvOrigMix', {
    type: 'doughnut',
    data: { labels: byOrig.map(x => x.name), datasets: [{ data: byOrig.map(x => x.val), backgroundColor: ['#34d399', '#38bdf8', '#fbbf24', '#a78bfa'], borderWidth: 0 }] },
    options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'right', labels: { color: '#cbd5e1' } } } }
  });
}

// -------------------------------------------------------------------------
// TAB 8: HEATMAP (VOLUME E FINANCEIRO)
// -------------------------------------------------------------------------
function renderTabRvHeatmap(el, base) {
  const metric = rvState.heatmapMetric;
  const dayNames = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];
  const dayIdx   = [1, 2, 3, 4, 5];

  const cellVal = (rows) => {
    if (!rows.length) return 0;
    if (metric === 'volume') return rows.length;
    return rows.reduce((a, b) => a + b.valor_operacao, 0) / 1e6;
  };
  const fmtCell = (v) => {
    if (v === 0) return '·';
    return metric === 'volume' ? fmtIntRV(v) : fmtDecRV(v, 1) + 'M';
  };

  const buildMatrix = (labels, filterFn) => {
    const grid = labels.map(lbl => RV_HOURS.map(h => cellVal(base.filter(r => r.hour === h && filterFn(r, lbl)))));
    const maxV = Math.max(0.01, ...grid.flat());
    return `
      <div class="rv-heatmap-wrap">
        <table class="rv-heatmap-table">
          <thead><tr><th class="rv-row-lbl"></th>${RV_HOURS.map(h => `<th>${String(h).padStart(2, '0')}h</th>`).join('')}</tr></thead>
          <tbody>
            ${labels.map((lbl, rIdx) => `
              <tr>
                <th class="rv-row-lbl" title="${lbl}">${lbl}</th>
                ${grid[rIdx].map((v, cIdx) => {
                  const ratio = v / maxV;
                  const bg = v === 0 ? 'rgba(15,31,56,0.5)' :
                    metric === 'financeiro'
                      ? `rgba(251, ${Math.round(191 - ratio * 65)}, ${Math.round(36 + ratio * 30)}, ${(0.16 + ratio * 0.74).toFixed(2)})`
                      : `rgba(14, ${Math.round(165 + ratio * 55)}, ${Math.round(233 - ratio * 35)}, ${(0.16 + ratio * 0.74).toFixed(2)})`;
                  const txtCol = ratio > 0.55 ? '#031525' : '#e2e8f0';
                  return `<td class="rv-hm-cell" style="background:${bg}; color:${txtCol};" title="${lbl} às ${RV_HOUR_LABELS[cIdx]}: ${fmtCell(v)}">${fmtCell(v)}</td>`;
                }).join('')}
              </tr>
            `).join('')}
          </tbody>
        </table>
      </div>
    `;
  };

  const top12Gestores = groupTopRV(base, r => r.gestor, () => 1, 12).map(x => x.name);

  el.innerHTML = `
    <div class="chart-container rv-chart-box" style="margin-bottom:16px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px;">
      <div class="title" style="margin-bottom:0;">Mapa de Calor Operacional (08h às 21h)</div>
      <div class="rv-toggle-group">
        <button class="rv-toggle-btn ${metric === 'volume' ? 'active' : ''}" onclick="setRvStateAndRender('heatmapMetric','volume','tab-rv-heatmap')">Volume</button>
        <button class="rv-toggle-btn ${metric === 'financeiro' ? 'active' : ''}" onclick="setRvStateAndRender('heatmapMetric','financeiro','tab-rv-heatmap')">Financeiro (R$ Mi)</button>
      </div>
    </div>

    <div class="chart-container rv-chart-box" style="margin-bottom:18px;">
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
        <div class="title" style="margin-bottom:0;">Dia da Semana × Horário</div>
        <span class="tag">WEEKLY PATTERN</span>
      </div>
      ${buildMatrix(dayNames, (r, lbl) => r.dayOfWeek === dayIdx[dayNames.indexOf(lbl)])}
    </div>

    <div class="chart-container rv-chart-box">
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
        <div class="title" style="margin-bottom:0;">Top 12 Gestores × Horário</div>
        <span class="tag">GESTOR BEHAVIOR</span>
      </div>
      ${buildMatrix(top12Gestores, (r, lbl) => r.gestor === lbl)}
    </div>
  `;
}

// -------------------------------------------------------------------------
// TAB 9: CLIENTES & TÍTULOS
// -------------------------------------------------------------------------
function renderTabRvClientes(el, base) {
  const m = rvState.clientesMetric;
  const valFn = m === 'volume' ? () => 1 : r => r.valor_operacao;
  const fmtFn = m === 'volume' ? fmtIntRV : fmtBRLShortRV;

  const uniqCli = new Set(base.map(r => r.cliente)).size;
  const uniqTit = new Set(base.map(r => r.codigo_titulo)).size;
  const topCli  = groupTopRV(base, r => r.cliente, valFn, 10);
  const topTit  = groupTopRV(base, r => r.codigo_titulo, valFn, 10);

  const top10CliVol = groupTopRV(base, r => r.cliente, () => 1, 10).reduce((a, b) => a + b.val, 0);
  const concCli = base.length ? (top10CliVol / base.length) * 100 : 0;

  const titMap = new Map();
  base.forEach(r => {
    const k = r.codigo_titulo;
    if (!titMap.has(k)) titMap.set(k, { name: k, vol: 0, fin: 0, mkts: new Set() });
    const o = titMap.get(k);
    o.vol++; o.fin += r.valor_operacao; o.mkts.add(normMercadoRV(r.tipo_mercado));
  });
  const titList = [...titMap.values()].sort((a, b) => b.fin - a.fin);

  el.innerHTML = `
    <div class="rv-section-title"><span>Clientes &amp; Títulos Negociados</span></div>
    <div class="rv-kpi-grid">
      <div class="kpi-card">
        <div class="kpi-title">Clientes Únicos</div>
        <div class="kpi-value">${fmtIntRV(uniqCli)}</div>
        <div class="kpi-sub">Ativos no período</div>
      </div>
      <div class="kpi-card kpi-card-status-green">
        <div class="kpi-title">Títulos Únicos</div>
        <div class="kpi-value">${fmtIntRV(uniqTit)}</div>
        <div class="kpi-sub">Ativos negociados</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-title">Concentração Top 10 Clientes</div>
        <div class="kpi-value">${fmtPctRV(concCli)}</div>
        <div class="kpi-sub">Do volume total de boletas</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-title">Título Mais Negociado</div>
        <div class="kpi-value" style="font-size:19px;">${titList[0]?.name || '-'}</div>
        <div class="kpi-sub">${fmtBRLShortRV(titList[0]?.fin || 0)}</div>
      </div>
    </div>

    <div class="rv-grid-2">
      <div class="chart-container rv-chart-box" style="margin-bottom:0;">
        <div style="display:flex; justify-content:space-between; align-items:center; gap:8px;">
          <div class="title" style="margin-bottom:0;">Top 10 Clientes</div>
          <div class="rv-toggle-group">
            <button class="rv-toggle-btn ${m === 'volume' ? 'active' : ''}" onclick="setRvStateAndRender('clientesMetric','volume','tab-rv-clientes')">Volume</button>
            <button class="rv-toggle-btn ${m === 'financeiro' ? 'active' : ''}" onclick="setRvStateAndRender('clientesMetric','financeiro','tab-rv-clientes')">Financeiro</button>
          </div>
        </div>
        ${renderRankingRVHTML(topCli, topCli[0]?.val || 1, fmtFn)}
      </div>
      <div class="chart-container rv-chart-box" style="margin-bottom:0;">
        <div style="display:flex; justify-content:space-between; align-items:center; gap:8px;">
          <div class="title" style="margin-bottom:0;">Top 10 Títulos (codigo_titulo)</div>
          <span class="tag">${m === 'volume' ? 'VOLUME' : 'FINANCEIRO'}</span>
        </div>
        ${renderRankingRVHTML(topTit, topTit[0]?.val || 1, fmtFn, 'amber')}
      </div>
    </div>

    <div class="table-container">
      <div class="rv-table-toolbar">
        <div class="title" style="margin-bottom:0;">Catálogo de Títulos Negociados</div>
        <input type="text" id="rvTitSearch" class="rv-search-input" placeholder="Filtrar título (ex: BPAC11, CSMG3)..." />
      </div>
      <div class="tableWrap" style="max-height:420px; overflow-y:auto;">
        <table>
          <thead><tr><th>Código Título</th><th>Mercados</th><th>Operações</th><th>Financeiro Total</th><th>Ticket Médio</th></tr></thead>
          <tbody id="rvTitTbody"></tbody>
        </table>
      </div>
    </div>
  `;

  const drawTit = (q = '') => {
    const t = q.trim().toLowerCase();
    const list = titList.filter(x => !t || x.name.toLowerCase().includes(t));
    document.getElementById('rvTitTbody').innerHTML = list.length ? list.map(x => `
      <tr>
        <td style="font-weight:700; color:#7dd3fc;">${x.name}</td>
        <td>${[...x.mkts].join(', ')}</td>
        <td>${fmtIntRV(x.vol)}</td>
        <td style="font-weight:600;">${fmtBRLRV(x.fin)}</td>
        <td>${fmtBRLShortRV(x.fin / Math.max(1, x.vol))}</td>
      </tr>
    `).join('') : '<tr><td colspan="5" class="rv-empty">Nenhum título encontrado.</td></tr>';
  };
  drawTit();
  document.getElementById('rvTitSearch').addEventListener('input', e => drawTit(e.target.value));
}

// -------------------------------------------------------------------------
// TAB 10: QUALIDADE & CORTE
// -------------------------------------------------------------------------
function renderTabRvQualidade(el, base) {
  const after18 = base.filter(r => r.after18);
  const divDates = base.filter(r => r.dateDivergence);
  const zeroOrMissing = base.filter(r => r.valor_operacao <= 0 || r.gestor === 'N/D' || r.corretora === 'N/D');
  const cancCount = base.filter(r => isCanceladaRV(r.situacao_boleta)).length;

  const pctA18  = base.length ? (after18.length / base.length) * 100 : 0;
  const pctDiv  = base.length ? (divDates.length / base.length) * 100 : 0;
  const pctInc  = base.length ? (zeroOrMissing.length / base.length) * 100 : 0;
  const pctCanc = base.length ? (cancCount / base.length) * 100 : 0;
  const qualIndex = Math.max(0, Math.min(100, 100 - pctA18 * 0.5 - pctCanc * 2.0 - pctInc * 2.0 - Math.min(20, pctDiv * 0.2)));

  const days = [...new Set(base.map(r => r.ymd))].sort();
  const dayVols = days.map(d => base.filter(r => r.ymd === d).length);
  const dayA18Pct = days.map(d => {
    const sub = base.filter(r => r.ymd === d);
    return sub.length ? (sub.filter(r => r.after18).length / sub.length) * 100 : 0;
  });

  const anomalies = base
    .filter(r => r.after18 || isCanceladaRV(r.situacao_boleta) || isEmAprovacaoRV(r.situacao_boleta) || r.valor_operacao <= 0)
    .slice(0, 80);

  el.innerHTML = `
    <div class="rv-section-title"><span>Qualidade Operacional &amp; Janela de Corte</span></div>
    <div class="rv-kpi-grid">
      <div class="kpi-card ${pctA18 > 20 ? 'kpi-card-status-yellow' : 'kpi-card-status-green'}">
        <div class="kpi-title">% Recepção Pós-18h</div>
        <div class="kpi-value">${fmtPctRV(pctA18)}</div>
        <div class="kpi-sub">${fmtIntRV(after18.length)} boletas após janela</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-title">Pregão ≠ Data Operação</div>
        <div class="kpi-value">${fmtIntRV(divDates.length)}</div>
        <div class="kpi-sub">${fmtPctRV(pctDiv)} das operações (D+N)</div>
      </div>
      <div class="kpi-card ${zeroOrMissing.length > 0 ? 'kpi-card-status-red' : 'kpi-card-status-green'}">
        <div class="kpi-title">Inconsistências Detectadas</div>
        <div class="kpi-value">${fmtIntRV(zeroOrMissing.length)}</div>
        <div class="kpi-sub">Valores zerados ou campos N/D</div>
      </div>
      <div class="kpi-card ${qualIndex >= 75 ? 'kpi-card-status-green' : qualIndex >= 55 ? 'kpi-card-status-yellow' : 'kpi-card-status-red'}">
        <div class="kpi-title">Índice de Qualidade</div>
        <div class="kpi-value">${fmtDecRV(qualIndex, 1)} / 100</div>
        <div class="kpi-sub">Score consolidado de governança</div>
      </div>
    </div>

    <div class="chart-container rv-chart-box" style="margin-bottom:20px;">
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
        <div class="title" style="margin-bottom:0;">Evolução Diária: Volume vs % Pós-18h</div>
        <span class="tag">CUTOFF MONITOR</span>
      </div>
      <div style="position:relative; height:270px; width:100%;"><canvas id="chartRvQualDaily"></canvas></div>
    </div>

    <div class="table-container">
      <div class="rv-table-toolbar">
        <div class="title" style="margin-bottom:0;">Auditoria de Anomalias e Corte (Top 80)</div>
        <span class="tag">AUDIT LOG</span>
      </div>
      <div class="tableWrap" style="max-height:420px; overflow-y:auto;">
        <table>
          <thead><tr><th>Boleta</th><th>Gestor</th><th>Corretora</th><th>Valor (R$)</th><th>Situação</th><th>Recepção</th><th>Alertas Detectados</th></tr></thead>
          <tbody>
            ${anomalies.map(r => {
              const tags = [];
              if (r.after18) tags.push('<span class="rv-st-badge rv-st-warn">Pós-18h</span>');
              if (isCanceladaRV(r.situacao_boleta)) tags.push('<span class="rv-st-badge rv-st-err">Cancelada</span>');
              if (isEmAprovacaoRV(r.situacao_boleta)) tags.push('<span class="rv-st-badge rv-st-warn">Em Aprovação</span>');
              if (r.valor_operacao <= 0) tags.push('<span class="rv-st-badge rv-st-err">Valor Zero</span>');
              return `
                <tr>
                  <td style="font-weight:700; color:#7dd3fc;">${r.codigo_boleta}</td>
                  <td>${r.gestor}</td><td>${r.corretora}</td>
                  <td>${fmtBRLRV(r.valor_operacao)}</td>
                  <td><span class="rv-st-badge ${statusBadgeClassRV(r.situacao_boleta)}">${r.situacao_boleta}</span></td>
                  <td style="color:#94a3b8;">${fmtDateTimeRV(r.dtRec)}</td>
                  <td style="display:flex; gap:5px;">${tags.join('')}</td>
                </tr>
              `;
            }).join('') || '<tr><td colspan="7" class="rv-empty">Nenhuma anomalia encontrada no período.</td></tr>'}
          </tbody>
        </table>
      </div>
    </div>
  `;

  createChartRV('qualDaily', 'chartRvQualDaily', {
    type: 'bar',
    data: {
      labels: days.map(d => d.slice(5).split('-').reverse().join('/')),
      datasets: [
        { type: 'bar',  label: 'Volume Diário', data: dayVols, backgroundColor: 'rgba(56, 189, 248, 0.45)', borderRadius: 6, yAxisID: 'y' },
        { type: 'line', label: '% Pós-18h',     data: dayA18Pct, borderColor: '#fbbf24', backgroundColor: '#fbbf24', borderWidth: 2.5, tension: 0.35, yAxisID: 'y1' }
      ]
    },
    options: {
      responsive: true, maintainAspectRatio: false,
      plugins: { legend: { labels: { color: '#cbd5e1' } } },
      scales: {
        x:  { grid: { color: 'rgba(255,255,255,.05)' }, ticks: { color: '#94a3b8' } },
        y:  { beginAtZero: true, grid: { color: 'rgba(255,255,255,.05)' }, ticks: { color: '#94a3b8', callback: v => fmtIntRV(v) } },
        y1: { beginAtZero: true, max: 100, position: 'right', grid: { drawOnChartArea: false }, ticks: { color: '#fbbf24', callback: v => v + '%' } }
      }
    }
  });
}

// -------------------------------------------------------------------------
// TAB 11: RANKING OPERACIONAL (SCORECARD EXECUTIVO ADAPTADO PARA RV)
// -------------------------------------------------------------------------
function renderTabRvRanking(el, base) {
  const ent = rvState.rankingEntity;
  const map = new Map();
  base.forEach(r => {
    const k = r[ent] || 'N/D';
    if (!map.has(k)) map.set(k, { name: k, vol: 0, fin: 0, aprov: 0, emAprov: 0, canc: 0, a18: 0 });
    const o = map.get(k);
    o.vol++; o.fin += r.valor_operacao;
    if (isCanceladaRV(r.situacao_boleta)) o.canc++;
    else if (isEmAprovacaoRV(r.situacao_boleta)) o.emAprov++;
    else if (isAprovadaRV(r.situacao_boleta)) o.aprov++;
    if (r.after18) o.a18++;
  });

  const list = [...map.values()].map(o => {
    const cancPct    = o.vol ? (o.canc / o.vol) * 100 : 0;
    const emAprovPct = o.vol ? (o.emAprov / o.vol) * 100 : 0;
    const aprovPct   = o.vol ? (o.aprov / o.vol) * 100 : 0;
    const a18Pct     = o.vol ? (o.a18 / o.vol) * 100 : 0;
    // Score RV (sem Leadtime por enquanto): 50% baixa cancelamento + 25% baixa pendência Em Aprovação + 25% pontualidade pré-18h
    const score = Math.max(0, Math.min(100,
      Math.max(0, 100 - cancPct * 4) * 0.50 +
      Math.max(0, 100 - emAprovPct * 2) * 0.25 +
      Math.max(0, 100 - a18Pct * 1.5) * 0.25
    ));
    const status = score >= 78 ? 'Excelente' : score >= 58 ? 'Atenção' : 'Crítico';
    const badge  = score >= 78 ? 'rv-st-ok' : score >= 58 ? 'rv-st-warn' : 'rv-st-err';
    const barCol = score >= 78 ? '#34d399' : score >= 58 ? '#fbbf24' : '#fb7185';
    return { ...o, ticket: o.fin / Math.max(1, o.vol), cancPct, emAprovPct, aprovPct, a18Pct, score, status, badge, barCol };
  }).sort((a, b) => b.score - a.score || b.vol - a.vol);

  el.innerHTML = `
    <div class="chart-container rv-chart-box" style="margin-bottom:16px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px;">
      <div>
        <div class="title" style="margin-bottom:2px;">Scorecard Executivo de Saúde Operacional — RV</div>
        <div style="font-size:11px; color:#94a3b8;">Score composto por baixa taxa de cancelamento (50%), baixa pendência Em Aprovação (25%) e pontualidade pré-18h (25%).</div>
      </div>
      <div class="rv-toggle-group">
        <button class="rv-toggle-btn ${ent === 'gestor' ? 'active' : ''}" onclick="setRvStateAndRender('rankingEntity','gestor','tab-rv-ranking')">Por Gestor</button>
        <button class="rv-toggle-btn ${ent === 'corretora' ? 'active' : ''}" onclick="setRvStateAndRender('rankingEntity','corretora','tab-rv-ranking')">Por Corretora</button>
        <button class="rv-toggle-btn ${ent === 'cliente' ? 'active' : ''}" onclick="setRvStateAndRender('rankingEntity','cliente','tab-rv-ranking')">Por Cliente</button>
      </div>
    </div>

    <div class="table-container">
      <div class="tableWrap" style="max-height:540px; overflow-y:auto;">
        <table>
          <thead>
            <tr>
              <th>#</th><th>Entidade</th><th>Score de Saúde</th><th>Classificação</th>
              <th>Volume</th><th>Financeiro</th><th>Ticket Médio</th>
              <th>% Aprovada</th><th>% Em Aprov.</th><th>% Pós-18h</th><th>% Cancel.</th>
            </tr>
          </thead>
          <tbody>
            ${list.map((x, idx) => `
              <tr>
                <td style="color:#94a3b8; font-weight:700;">#${idx + 1}</td>
                <td style="font-weight:700; color:#fff;">${x.name}</td>
                <td>
                  <div class="rv-score-wrap">
                    <div class="rv-score-track"><div class="rv-score-fill" style="width:${x.score.toFixed(0)}%; background:${x.barCol};"></div></div>
                    <span style="font-weight:700; width:30px; text-align:right;">${x.score.toFixed(0)}</span>
                  </div>
                </td>
                <td><span class="rv-st-badge ${x.badge}">${x.status}</span></td>
                <td>${fmtIntRV(x.vol)}</td>
                <td style="color:#18e4ff; font-weight:600;">${fmtBRLShortRV(x.fin)}</td>
                <td>${fmtBRLShortRV(x.ticket)}</td>
                <td>${fmtPctRV(x.aprovPct)}</td>
                <td>${fmtPctRV(x.emAprovPct)}</td>
                <td>${fmtPctRV(x.a18Pct)}</td>
                <td>${fmtPctRV(x.cancPct)}</td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      </div>
    </div>
  `;
}























