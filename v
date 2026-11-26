// =========================================================================
// MÓDULO RV — ESTADO, PARSING, FILTROS E VISÃO VOLUME DE OPERAÇÕES
// =========================================================================
let rawDataRV = [];
let rvSampleRowsCache = [];

// Faixa horária intraday (altere 14 para 16 caso queira ir até 23:00)
const RV_HOURS = Array.from({ length: 14 }, (_, i) => i + 8); // 08:00 às 21:00
const RV_HOUR_LABELS = RV_HOURS.map(h => String(h).padStart(2, '0') + ':00');

const fmtIntRV = (n) => new Intl.NumberFormat('pt-BR', { maximumFractionDigits: 0 }).format(n || 0);
const fmtDecRV = (n, d = 1) => new Intl.NumberFormat('pt-BR', { minimumFractionDigits: d, maximumFractionDigits: d }).format(n || 0);
const fmtBRLRV = (n) => new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL', maximumFractionDigits: 2 }).format(n || 0);
const fmtBRLShortRV = (n) => {
  const abs = Math.abs(n || 0);
  const sign = n < 0 ? '-' : '';
  if (abs >= 1e9) return sign + 'R$ ' + fmtDecRV(abs / 1e9, 2) + ' Bi';
  if (abs >= 1e6) return sign + 'R$ ' + fmtDecRV(abs / 1e6, 2) + ' Mi';
  if (abs >= 1e3) return sign + 'R$ ' + fmtDecRV(abs / 1e3, 1) + ' mil';
  return fmtBRLRV(n);
};

function parseBRNumberRV(val) {
  if (typeof val === 'number') return isFinite(val) ? val : 0;
  if (val === null || val === undefined) return 0;
  let s = String(val).trim().replace(/[R$\s]/g, '');
  if (!s) return 0;
  const hasComma = s.includes(',');
  const hasDot = s.includes('.');
  if (hasComma && hasDot) {
    s = s.lastIndexOf(',') > s.lastIndexOf('.')
      ? s.replace(/\./g, '').replace(',', '.')
      : s.replace(/,/g, '');
  } else if (hasComma) {
    s = s.split(',').length === 2 ? s.replace(',', '.') : s.replace(/,/g, '');
  } else if (hasDot && s.split('.').length > 2) {
    s = s.replace(/\./g, '');
  }
  const num = parseFloat(s);
  return isFinite(num) ? num : 0;
}

function parseSmartDateRV(val) {
  if (!val) return null;
  if (val instanceof Date && !isNaN(val)) return val;
  const s = String(val).trim();
  if (!s) return null;

  // YYYY-MM-DD[T ]HH:MM[:SS[.mmm]] (formato de data/resultado.csv)
  let m = s.match(/^(\d{4})-(\d{1,2})-(\d{1,2})(?:[ T](\d{1,2}):(\d{2})(?::(\d{2}))?)?/);
  if (m) {
    const d = new Date(+m[1], +m[2] - 1, +m[3], +(m[4] || 0), +(m[5] || 0), +(m[6] || 0));
    d._hasTime = m[4] !== undefined;
    return isNaN(d) ? null : d;
  }

  // DD/MM/YYYY[T ]HH:MM[:SS]
  m = s.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})(?:[ T](\d{1,2}):(\d{2})(?::(\d{2}))?)?/);
  if (m) {
    const d = new Date(+m[3], +m[2] - 1, +m[1], +(m[4] || 0), +(m[5] || 0), +(m[6] || 0));
    d._hasTime = m[4] !== undefined;
    return isNaN(d) ? null : d;
  }
  return null;
}

function toYMDRV(d) {
  if (!d) return '';
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}

function fmtDateTimeRV(d) {
  if (!d) return '-';
  const dd = String(d.getDate()).padStart(2, '0');
  const mm = String(d.getMonth() + 1).padStart(2, '0');
  const hh = String(d.getHours()).padStart(2, '0');
  const mi = String(d.getMinutes()).padStart(2, '0');
  return `${dd}/${mm}/${d.getFullYear()} ${hh}:${mi}`;
}

function percentileRV(arr, p) {
  if (!arr.length) return 0;
  const sorted = [...arr].sort((a, b) => a - b);
  const idx = (sorted.length - 1) * p;
  const lo = Math.floor(idx), hi = Math.ceil(idx);
  return sorted[lo] + (sorted[hi] - sorted[lo]) * (idx - lo);
}

function isPendingOrExceptionRV(sit) {
  const s = String(sit || '').toLowerCase();
  return s.includes('aprova') || s.includes('pend') || s.includes('aguard') ||
         s.includes('cancel') || s.includes('devolv') || s.includes('rejeit') || s.includes('erro');
}

function statusBadgeClassRV(sit) {
  const s = String(sit || '').toLowerCase();
  if (s.includes('liquid') || s.includes('confirm') || s.includes('conclu')) return 'rv-st-ok';
  if (s.includes('cancel') || s.includes('devolv') || s.includes('rejeit') || s.includes('erro')) return 'rv-st-err';
  if (s.includes('aprova') || s.includes('pend') || s.includes('aguard')) return 'rv-st-warn';
  return 'rv-st-info';
}

function carregarDadosRV() {
  fetch('data/resultado.csv', { cache: 'no-store' })
    .then(resp => {
      if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
      return resp.text();
    })
    .then(csvText => {
      const cleanText = String(csvText || '').replace(/^\uFEFF/, '');
      Papa.parse(cleanText, {
        header: true,
        delimiter: ';',
        skipEmptyLines: true,
        transformHeader: h => h.trim().toLowerCase(),
        complete: function(results) {
          const rows = results.data || [];
          const normalized = [];

          for (let i = 0; i < rows.length; i++) {
            const r = rows[i];
            const dtOp = parseSmartDateRV(r.data_operacao);
            const dtPreg = parseSmartDateRV(r.data_pregao) || dtOp;
            const dtRec = parseSmartDateRV(r.data_recepcao) || dtOp;
            const refDate = dtRec || dtOp || dtPreg;
            if (!refDate) continue;

            const opYmd = toYMDRV(dtOp);
            const pregYmd = toYMDRV(dtPreg);
            const ymd = toYMDRV(refDate);

            let leadtime = null;
            if (dtRec && dtOp && dtRec._hasTime && dtOp._hasTime) {
              const diffMin = (dtRec.getTime() - dtOp.getTime()) / 60000;
              if (Math.abs(diffMin) <= 1440) leadtime = Math.abs(diffMin);
            }

            const rawHour = refDate.getHours();
            const hour = Math.min(RV_HOURS[RV_HOURS.length - 1], Math.max(RV_HOURS[0], rawHour));

            normalized.push({
              codigo_boleta: String(r.codigo_boleta || `BOL-${i}`).trim(),
              dtOp,
              dtPreg,
              dtRec,
              refDate,
              dateStr: ymd,
              ymd,
              hour,
              rawHour,
              dayOfWeek: refDate.getDay(),
              natureza: String(r.natureza || 'Compra').trim(),
              tipo_mercado: String(r.tipo_mercado || 'Vista').trim(),
              gestor: String(r.gestor || 'N/D').trim(),
              corretora: String(r.corretora || 'N/D').trim(),
              cliente: String(r.cliente || 'N/D').trim(),
              codigo_titulo: String(r.codigo_titulo || 'N/D').trim(),
              valor_operacao: parseBRNumberRV(r.valor_operacao),
              situacao_boleta: String(r.situacao_boleta || 'N/D').trim(),
              origem_boleta: String(r.origem_boleta || 'Mercado').trim(),
              leadtime,
              after18: rawHour >= 18,
              dateDivergence: Boolean(opYmd && pregYmd && opYmd !== pregYmd)
            });
          }

          rawDataRV = normalized;
          console.log(`✅ Dados RV carregados: ${rawDataRV.length} boletas`);
          atualizarDashboardRV();
        },
        error: function(err) {
          console.error('❌ Erro ao parsear CSV RV:', err);
        }
      });
    })
    .catch(err => {
      console.error('❌ Erro ao carregar data/resultado.csv:', err);
    });
}

function getFilteredDataRV(periodo = 1) {
  if (!rawDataRV.length) return [];

  const elStart = document.getElementById(periodo === 1 ? 'dataInicio1' : 'dataInicio2');
  const elEnd = document.getElementById(periodo === 1 ? 'dataFim1' : 'dataFim2');
  const startStr = elStart ? elStart.value : '';
  const endStr = elEnd ? elEnd.value : '';

  const gestoresSelecionados = typeof getGestoresSelecionados === 'function'
    ? getGestoresSelecionados(periodo)
    : null;

  const elOrig = document.getElementById(periodo === 1 ? 'filtroOrigem1' : 'filtroOrigem2');
  const oFiltro = elOrig ? elOrig.value : 'Todos';

  return rawDataRV.filter(d => {
    if (startStr && d.dateStr < startStr) return false;
    if (endStr && d.dateStr > endStr) return false;
    if (gestoresSelecionados !== null && !gestoresSelecionados.includes(d.gestor)) return false;
    if (oFiltro && oFiltro !== 'Todos' && !oFiltro.startsWith('Todas') && d.origem_boleta !== oFiltro) return false;
    return true;
  });
}

function computeIntradayStatsRV(rows, valueFn = () => 1) {
  const days = [...new Set(rows.map(r => r.ymd))];
  const numDays = Math.max(1, days.length);

  const byDayHour = {};
  days.forEach(day => {
    byDayHour[day] = Object.fromEntries(RV_HOURS.map(h => [h, 0]));
  });

  rows.forEach(r => {
    if (byDayHour[r.ymd] && byDayHour[r.ymd][r.hour] !== undefined) {
      byDayHour[r.ymd][r.hour] += valueFn(r);
    }
  });

  const mean = [], p25 = [], p75 = [], spread = [];
  RV_HOURS.forEach(h => {
    const vals = days.map(day => byDayHour[day][h]);
    const avg = vals.reduce((a, b) => a + b, 0) / numDays;
    const q25 = percentileRV(vals, 0.25);
    const q75 = percentileRV(vals, 0.75);
    mean.push(Math.round(avg));
    p25.push(Math.round(q25));
    p75.push(Math.round(q75));
    spread.push(q75 - q25);
  });

  let peakIdx = 0, volIdx = 0;
  mean.forEach((v, i) => { if (v > mean[peakIdx]) peakIdx = i; });
  spread.forEach((v, i) => { if (v > spread[volIdx]) volIdx = i; });

  return {
    numDays: days.length,
    mean,
    p25,
    p75,
    peakHour: days.length ? RV_HOUR_LABELS[peakIdx] : '--:--',
    peakVal: mean[peakIdx] || 0,
    volatileHour: days.length ? RV_HOUR_LABELS[volIdx] : '--:--',
    volatileSpread: spread[volIdx] || 0
  };
}

function groupTopRV(rows, keyFn, valFn = () => 1, limit = 10) {
  const map = new Map();
  rows.forEach(r => {
    const k = keyFn(r) || 'N/D';
    map.set(k, (map.get(k) || 0) + valFn(r));
  });
  return [...map.entries()]
    .map(([name, val]) => ({ name, val }))
    .sort((a, b) => b.val - a.val)
    .slice(0, limit);
}

function renderRankingRVHTML(items, maxVal, formatVal, barClass = '') {
  if (!items.length) return '<div class="rv-empty">Sem dados para o filtro atual.</div>';
  return `<div class="rv-rank-list">${items.map((it, idx) => {
    const pct = maxVal > 0 ? Math.max(3, (it.val / maxVal) * 100) : 0;
    return `
      <div class="rv-rank-item">
        <span class="rv-rank-pos">#${idx + 1}</span>
        <span class="rv-rank-name" title="${it.name}">${it.name}</span>
        <div class="rv-rank-track"><div class="rv-rank-fill ${barClass}" style="width:${pct.toFixed(1)}%"></div></div>
        <span class="rv-rank-val">${formatVal(it.val)}</span>
      </div>
    `;
  }).join('')}</div>`;
}

function atualizarDashboardRV() {
  if (!rawDataRV.length) return;
  updateTabRvVolIntradiario();
  console.log('✅ Dashboard RV atualizado');
}

function updateTabRvVolIntradiario() {
  const base = getFilteredDataRV(1);
  const comp = getFilteredDataRV(2);

  const stB = computeIntradayStatsRV(base);
  const stC = computeIntradayStatsRV(comp);

  const totalFin = base.reduce((a, b) => a + b.valor_operacao, 0);
  const ticketMedio = base.length ? totalFin / base.length : 0;
  const mediaDiaria = stB.numDays ? Math.round(base.length / stB.numDays) : 0;

  // 1. KPIs
  document.getElementById('kpiRvVolPico').innerText = stB.peakHour;
  document.getElementById('kpiRvVolPicoSub').innerText = `+${fmtIntRV(stB.peakVal)} ops/dia na média`;

  document.getElementById('kpiRvVolVolatil').innerText = stB.volatileHour;
  document.getElementById('kpiRvVolVolatilSub').innerText = `Dispersão P25–P75: ${fmtDecRV(stB.volatileSpread, 1)}`;

  document.getElementById('kpiRvVolMedia').innerText = fmtIntRV(mediaDiaria);
  document.getElementById('kpiRvVolMediaSub').innerText = `Ticket: ${fmtBRLShortRV(ticketMedio)}`;

  document.getElementById('kpiRvVolTotal').innerText = fmtIntRV(base.length);
  document.getElementById('kpiRvVolTotalSub').innerText = `${stB.numDays} dias úteis`;

  // Semáforo dinâmico nos cards (padrão SELIC)
  const cardVolatil = document.getElementById('card-rv-vol-volatil');
  const dispPct = stB.peakVal > 0 ? (stB.volatileSpread / stB.peakVal) * 100 : 0;
  cardVolatil.className = 'kpi-card ' + (
    dispPct > 30 ? 'kpi-card-status-red' :
    dispPct > 15 ? 'kpi-card-status-yellow' : 'kpi-card-status-green'
  );

  // 2. Gráfico Intraday (Chart.js no padrão SELIC)
  const hasComp = comp.length > 0;
  const datasets = [
    {
      label: 'P75 (Base)',
      data: stB.p75,
      borderColor: 'transparent',
      backgroundColor: 'rgba(24, 228, 255, 0.12)',
      fill: '+1',
      pointRadius: 0,
      tension: 0.4
    },
    {
      label: 'P25 (Base)',
      data: stB.p25,
      borderColor: 'transparent',
      fill: false,
      pointRadius: 0,
      tension: 0.4
    },
    {
      label: 'Recepção - Período Base',
      data: stB.mean,
      borderColor: '#18e4ff',
      backgroundColor: '#18e4ff',
      borderWidth: 3,
      pointRadius: 4,
      pointHoverRadius: 6,
      tension: 0.4,
      fill: false
    },
    {
      label: 'Recepção - Período Comparação',
      data: hasComp ? stC.mean : [],
      borderColor: '#ffa63b',
      backgroundColor: '#ffa63b',
      borderWidth: 2,
      borderDash: [6, 4],
      pointRadius: 3,
      tension: 0.4,
      fill: false
    }
  ];

  if (charts.rvVolIntradiario) {
    charts.rvVolIntradiario.data.labels = RV_HOUR_LABELS;
    charts.rvVolIntradiario.data.datasets = datasets;
  } else {
    const canvas = document.getElementById('chartRvVolIntradiario');
    if (canvas) {
      charts.rvVolIntradiario = new Chart(canvas.getContext('2d'), {
        type: 'line',
        data: { labels: RV_HOUR_LABELS, datasets },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          interaction: { mode: 'index', intersect: false },
          animation: { duration: 600, easing: 'easeOutQuart' },
          plugins: {
            legend: {
              labels: { color: '#cbd5e1', usePointStyle: true, boxWidth: 8, font: { size: 11 } }
            },
            tooltip: {
              backgroundColor: 'rgba(6, 17, 33, 0.94)',
              borderColor: 'rgba(24, 228, 255, 0.35)',
              borderWidth: 1,
              callbacks: {
                label: (ctx) => `${ctx.dataset.label}: ${fmtIntRV(ctx.parsed.y)} ops/dia`
              }
            }
          },
          scales: {
            x: {
              grid: { color: 'rgba(255,255,255,.05)' },
              ticks: { color: '#94a3b8' }
            },
            y: {
              beginAtZero: true,
              grid: { color: 'rgba(255,255,255,.05)' },
              ticks: { color: '#94a3b8', callback: (v) => fmtIntRV(v) }
            }
          }
        }
      });
    }
  }
  toggleChartLinesRV();

  // 3. Rankings (Top 10 Gestores + Pós-18h)
  const topGestores = groupTopRV(base, d => d.gestor, () => 1, 10);
  document.getElementById('rvRankTopGestores').innerHTML =
    renderRankingRVHTML(topGestores, topGestores[0]?.val || 1, fmtIntRV);

  const after18Rows = base.filter(d => d.after18);
  const topAfter18 = groupTopRV(after18Rows, d => d.gestor, () => 1, 10);
  const pctA18 = base.length ? (after18Rows.length / base.length) * 100 : 0;
  document.getElementById('rvAfter18Sub').innerText =
    `${fmtIntRV(after18Rows.length)} operações após 18h (${fmtDecRV(pctA18, 1)}% do período)`;
  document.getElementById('rvRankAfter18').innerHTML =
    renderRankingRVHTML(topAfter18, topAfter18[0]?.val || 1, fmtIntRV, 'amber');

  // 4. Tabela Top 100 (prioriza Em Aprovação / Pendentes / Canceladas e maior valor)
  rvSampleRowsCache = [...base]
    .sort((a, b) =>
      (isPendingOrExceptionRV(b.situacao_boleta) ? 1 : 0) - (isPendingOrExceptionRV(a.situacao_boleta) ? 1 : 0) ||
      b.valor_operacao - a.valor_operacao
    )
    .slice(0, 100);

  const searchInput = document.getElementById('rvSampleSearch');
  filtrarTabelaAmostraRV(searchInput ? searchInput.value : '');
}

function toggleChartLinesRV() {
  if (!charts.rvVolIntradiario) return;
  const showP75  = document.getElementById('toggleRvVolP75')?.checked ?? true;
  const showBase = document.getElementById('toggleRvVolBase')?.checked ?? true;
  const showComp = document.getElementById('toggleRvVolComp')?.checked ?? true;

  const ds = charts.rvVolIntradiario.data.datasets;
  if (ds[0]) ds[0].hidden = !showP75;
  if (ds[1]) ds[1].hidden = !showP75;
  if (ds[2]) ds[2].hidden = !showBase;
  if (ds[3]) ds[3].hidden = !showComp || !(ds[3].data && ds[3].data.length > 0);
  charts.rvVolIntradiario.update();
}

function filtrarTabelaAmostraRV(query = '') {
  const tbody = document.getElementById('rvSampleTbody');
  if (!tbody) return;
  const term = String(query || '').trim().toLowerCase();

  const filtered = rvSampleRowsCache.filter(r =>
    !term || `${r.codigo_boleta} ${r.gestor} ${r.corretora} ${r.cliente} ${r.codigo_titulo} ${r.origem_boleta} ${r.situacao_boleta}`.toLowerCase().includes(term)
  );

  if (!filtered.length) {
    tbody.innerHTML = '<tr><td colspan="9" class="rv-empty">Nenhuma boleta encontrada para o filtro atual.</td></tr>';
    return;
  }

  tbody.innerHTML = filtered.map(r => `
    <tr>
      <td style="font-weight:700; color:#7dd3fc;">${r.codigo_boleta}</td>
      <td>${r.gestor}</td>
      <td>${r.corretora}</td>
      <td>${r.cliente}</td>
      <td>${r.codigo_titulo}</td>
      <td>${r.origem_boleta}</td>
      <td style="font-weight:600;">${fmtBRLRV(r.valor_operacao)}</td>
      <td><span class="rv-st-badge ${statusBadgeClassRV(r.situacao_boleta)}">${r.situacao_boleta}</span></td>
      <td style="color:#94a3b8;">${fmtDateTimeRV(r.dtRec)}</td>
    </tr>
  `).join('');
}
